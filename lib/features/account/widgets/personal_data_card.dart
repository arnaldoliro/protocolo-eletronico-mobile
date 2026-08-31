import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/brazilian_states.dart';
import '../../../core/models/account_profile.dart';
import '../../../core/models/update_profile_request.dart';
import '../../../core/services/address_service.dart';
import '../../../core/services/mock/address_mock_service.dart';
import '../../../core/services/mock/profile_mock_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/masked_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/field_action_button.dart';
import '../../../core/widgets/labeled_dropdown.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../../../core/widgets/read_only_field.dart';
import '../../../core/widgets/section_header.dart';
import 'account_card.dart';

enum _ProfileField { name, phone, cep, street, number, neighborhood, state, city }

/// Quanto tempo o CPF completo fica visível antes de voltar a mascarar.
const _cpfRevealTimeout = Duration(seconds: 20);

/// Dados pessoais e endereço, editáveis.
///
/// E-mail e CPF são exibidos por [ReadOnlyField], não por campo desabilitado.
class PersonalDataCard extends StatefulWidget {
  final AccountProfile profile;

  /// Chamado a cada save bem-sucedido, com o perfil já normalizado pelo
  /// backend. É por aqui que o nome novo chega ao cabeçalho da Home.
  final ValueChanged<AccountProfile> onSaved;

  /// Informa a casca se há edição pendente, para a guarda de saída.
  final ValueChanged<bool> onDirtyChanged;

  const PersonalDataCard({
    super.key,
    required this.profile,
    required this.onSaved,
    required this.onDirtyChanged,
  });

  @override
  State<PersonalDataCard> createState() => PersonalDataCardState();
}

class PersonalDataCardState extends State<PersonalDataCard>
    with WidgetsBindingObserver {
  final ProfileService _profileService = ProfileMockService();
  final AddressService _addressService = AddressMockService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  String? _selectedStateCode;
  String? _selectedCity;
  List<String> _cities = const [];
  bool _loadingCities = false;

  /// Descarta respostas obsoletas quando o usuário troca de UF rapidamente e
  /// a resposta antiga chega depois da nova. Compartilhado com a carga
  /// inicial: um load lento não pode aterrissar depois de uma troca de UF.
  int _citiesRequestId = 0;

  bool _isSearchingCep = false;
  bool _isSaving = false;
  bool _isRevealingCpf = false;

  /// CPF completo. Vive só aqui, morre com a tela — nunca no AccountProfile,
  /// nunca em shared_preferences, nunca em log.
  String? _fullCpf;
  Timer? _cpfHideTimer;

  final Map<_ProfileField, String?> _errors = {};
  String? _submitError;
  String? _successMessage;
  bool _dirty = false;

  bool get isDirty => _dirty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _seedFromProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cpfHideTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Com o CPF revelado na tela, o snapshot de "apps recentes" do sistema
    // guarda a imagem. FLAG_SECURE seria o correto, mas é mudança de
    // plataforma — TODO(seguranca).
    if (state != AppLifecycleState.resumed) _hideCpf();
  }

  void _seedFromProfile() {
    final profile = widget.profile;

    _nameController.text = profile.name;
    _phoneController.text = formatWithMask(InputMasks.phone, profile.phone);
    _cepController.text = formatWithMask(InputMasks.cep, profile.cep);
    _streetController.text = profile.street;
    _numberController.text = profile.number;
    _complementController.text = profile.complement ?? '';
    _neighborhoodController.text = profile.neighborhood;

    _selectedStateCode = profile.stateCode;
    _selectedCity = profile.city;
    // Semear a cidade do perfil ANTES de qualquer requisição. Se a lista
    // chegar sem ela — ou se a busca falhar — o DropdownButtonFormField
    // dispara assert e derruba a tela na abertura.
    _cities = [profile.city];

    _loadCities(profile.stateCode);
  }

  void _markDirty() {
    if (_dirty) return;
    _dirty = true;
    widget.onDirtyChanged(true);
  }

  void _clearError(_ProfileField field) {
    _markDirty();
    if (_errors[field] == null && _submitError == null && _successMessage == null) {
      return;
    }
    setState(() {
      _errors[field] = null;
      _submitError = null;
      _successMessage = null;
    });
  }

  // ------------------------------------------------------------- cidades

  /// Só busca. Separado de [_onStateChanged] porque a carga inicial e a busca
  /// por CEP precisam do fetch sem passar pela guarda nem limpar a cidade.
  Future<void> _loadCities(String code) async {
    final requestId = ++_citiesRequestId;
    setState(() => _loadingCities = true);

    try {
      final cities = await _addressService.citiesByState(code);
      if (!mounted || requestId != _citiesRequestId) return;
      setState(() {
        // A cidade selecionada precisa continuar na lista em TODOS os
        // caminhos, senão o dropdown dispara assert.
        _cities = _selectedCity != null && !cities.contains(_selectedCity)
            ? ([...cities, _selectedCity!]..sort())
            : cities;
      });
    } catch (_) {
      if (!mounted || requestId != _citiesRequestId) return;
      setState(
        () => _errors[_ProfileField.city] = 'Não foi possível carregar as cidades',
      );
    } finally {
      if (mounted && requestId == _citiesRequestId) {
        setState(() => _loadingCities = false);
      }
    }
  }

  Future<void> _onStateChanged(String? code) async {
    if (code == null || code == _selectedStateCode) return;

    setState(() {
      _selectedStateCode = code;
      // Zerar cidade e lista no MESMO setState é obrigatório: se o valor
      // antigo sobreviver à troca da lista, o dropdown dispara assert.
      _selectedCity = null;
      _cities = const [];
      _errors[_ProfileField.state] = null;
      _errors[_ProfileField.city] = null;
    });
    _markDirty();

    await _loadCities(code);
  }

  // ----------------------------------------------------------------- CEP

  bool get _canSearchCep =>
      onlyDigits(_cepController.text).length == 8 && !_isSaving;

  Future<void> _searchCep() async {
    final cep = onlyDigits(_cepController.text);
    if (cep.length != 8) return;

    setState(() {
      _isSearchingCep = true;
      _errors[_ProfileField.cep] = null;
    });

    try {
      final address = await _addressService.findByCep(cep);
      if (!mounted) return;

      // Campos preenchidos permanecem editáveis: bases de CEP têm lacunas e
      // CEP de logradouro único não traz número.
      _streetController.text = address.street;
      _neighborhoodController.text = address.neighborhood;
      _markDirty();

      final sameState = address.stateCode == _selectedStateCode;
      setState(() {
        _selectedStateCode = address.stateCode;
        _selectedCity = address.city;
        if (!_cities.contains(address.city)) {
          _cities = [..._cities, address.city]..sort();
        }
        _errors[_ProfileField.street] = null;
        _errors[_ProfileField.neighborhood] = null;
        _errors[_ProfileField.state] = null;
        _errors[_ProfileField.city] = null;
      });

      // Só recarrega quando a UF mudou de verdade — evita o piscar da cidade.
      if (!sameState) await _loadCities(address.stateCode);
    } on CepNotFoundException {
      if (mounted) {
        setState(() => _errors[_ProfileField.cep] = 'CEP não encontrado');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _submitError =
              'Não foi possível buscar o CEP. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingCep = false);
    }
  }

  // ----------------------------------------------------------------- CPF

  void _hideCpf() {
    _cpfHideTimer?.cancel();
    if (_fullCpf == null || !mounted) return;
    setState(() => _fullCpf = null);
  }

  Future<void> _revealCpf() async {
    if (_isRevealingCpf) return;
    if (_fullCpf != null) {
      _hideCpf();
      return;
    }

    setState(() => _isRevealingCpf = true);
    try {
      final cpf = await _profileService.revealCpf();
      if (!mounted) return;
      setState(() => _fullCpf = formatWithMask(InputMasks.cpf, cpf));

      _cpfHideTimer?.cancel();
      _cpfHideTimer = Timer(_cpfRevealTimeout, _hideCpf);
    } catch (_) {
      // Sem retry automático: é um endpoint que devolve dado pessoal.
      if (mounted) {
        setState(
          () => _submitError = 'Não foi possível exibir o CPF. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isRevealingCpf = false);
    }
  }

  // -------------------------------------------------------------- salvar

  /// Validação apenas de UX — o backend revalida tudo e é a autoridade.
  bool _validate() {
    final errors = <_ProfileField, String?>{
      _ProfileField.name: Validators.required(_nameController.text),
      _ProfileField.phone: Validators.digitsLength(
        _phoneController.text,
        11,
        'Celular deve ter 11 dígitos',
      ),
      _ProfileField.cep: Validators.digitsLength(
        _cepController.text,
        8,
        'CEP deve ter 8 dígitos',
      ),
      _ProfileField.street: Validators.required(_streetController.text),
      _ProfileField.number: Validators.required(_numberController.text),
      _ProfileField.neighborhood: Validators.required(
        _neighborhoodController.text,
      ),
      _ProfileField.state: _selectedStateCode == null ? 'Selecione a UF' : null,
      _ProfileField.city: _selectedCity == null ? 'Selecione a cidade' : null,
    };

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });

    return errors.values.every((error) => error == null);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_validate()) {
      announceToScreenReader(context, 'Há campos com erro no formulário de dados pessoais.');
      return;
    }

    setState(() {
      _isSaving = true;
      _submitError = null;
      _successMessage = null;
    });

    try {
      final updated = await _profileService.update(
        UpdateProfileRequest(
          name: _nameController.text.trim(),
          phone: onlyDigits(_phoneController.text),
          cep: onlyDigits(_cepController.text),
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          complement: _complementController.text.trim().isEmpty
              ? null
              : _complementController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          stateCode: _selectedStateCode!,
          city: _selectedCity!,
        ),
      );

      if (!mounted) return;

      // Unfocus antes de repopular: o backend normaliza (trim, capitalização)
      // e reescrever o texto com o campo focado faz o cursor pular.
      FocusScope.of(context).unfocus();
      _nameController.text = updated.name;
      _phoneController.text = formatWithMask(InputMasks.phone, updated.phone);
      _streetController.text = updated.street;
      _numberController.text = updated.number;
      _complementController.text = updated.complement ?? '';
      _neighborhoodController.text = updated.neighborhood;

      _dirty = false;
      widget.onDirtyChanged(false);
      widget.onSaved(updated);

      setState(() => _successMessage = 'Dados atualizados.');
      announceToScreenReader(context, 'Dados atualizados.');
    } catch (_) {
      if (mounted) {
        setState(
          () => _submitError =
              'Não foi possível salvar. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AccountCard(
      icon: Icons.person_outline,
      title: 'Dados pessoais',
      description:
          'Atualize seu nome, celular e endereço. CPF e e-mail não podem ser '
          'alterados.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledTextField(
            label: 'Nome completo',
            isRequired: true,
            prefixIcon: Icons.badge_outlined,
            controller: _nameController,
            errorText: _errors[_ProfileField.name],
            textCapitalization: TextCapitalization.words,
            enabled: !_isSaving,
            onChanged: (_) => _clearError(_ProfileField.name),
          ),
          const SizedBox(height: 14),

          ReadOnlyField(
            label: 'E-mail',
            value: widget.profile.email,
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: 14),

          ReadOnlyField(
            label: 'CPF',
            value: _fullCpf ?? widget.profile.maskedCpf,
            prefixIcon: Icons.credit_card,
            helperText: _fullCpf != null
                ? 'Volta a ficar oculto automaticamente.'
                : null,
            action: _isRevealingCpf
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _revealCpf,
                    icon: Icon(
                      _fullCpf == null ? Icons.visibility : Icons.visibility_off,
                      color: colors.textMuted,
                      size: 20,
                    ),
                    tooltip: _fullCpf == null
                        ? 'Mostrar CPF completo'
                        : 'Ocultar CPF',
                  ),
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Celular',
            isRequired: true,
            hint: '(00) 00000-0000',
            prefixIcon: Icons.smartphone_outlined,
            controller: _phoneController,
            errorText: _errors[_ProfileField.phone],
            helperText: 'Celular com DDD, 11 dígitos.',
            keyboardType: TextInputType.phone,
            inputFormatters: const [MaskedInputFormatter(InputMasks.phone)],
            enabled: !_isSaving,
            onChanged: (_) => _clearError(_ProfileField.phone),
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'Endereço', isRequired: true),
          const SizedBox(height: 12),

          LabeledTextField(
            label: 'CEP',
            isRequired: true,
            hint: '00000-000',
            prefixIcon: Icons.location_on_outlined,
            controller: _cepController,
            errorText: _errors[_ProfileField.cep],
            keyboardType: TextInputType.number,
            inputFormatters: const [MaskedInputFormatter(InputMasks.cep)],
            enabled: !_isSaving,
            onChanged: (_) {
              _clearError(_ProfileField.cep);
              // Reavalia se o botão Buscar pode ser habilitado.
              setState(() {});
            },
            trailing: FieldActionButton(
              label: 'Buscar',
              enabled: _canSearchCep,
              isLoading: _isSearchingCep,
              onPressed: _searchCep,
            ),
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Logradouro',
            isRequired: true,
            prefixIcon: Icons.home_outlined,
            controller: _streetController,
            errorText: _errors[_ProfileField.street],
            textCapitalization: TextCapitalization.words,
            enabled: !_isSaving,
            onChanged: (_) => _clearError(_ProfileField.street),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledTextField(
                  label: 'Número',
                  isRequired: true,
                  controller: _numberController,
                  errorText: _errors[_ProfileField.number],
                  enabled: !_isSaving,
                  onChanged: (_) => _clearError(_ProfileField.number),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledTextField(
                  label: 'Complemento',
                  controller: _complementController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isSaving,
                  onChanged: (_) => _markDirty(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Bairro',
            isRequired: true,
            controller: _neighborhoodController,
            errorText: _errors[_ProfileField.neighborhood],
            textCapitalization: TextCapitalization.words,
            enabled: !_isSaving,
            onChanged: (_) => _clearError(_ProfileField.neighborhood),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledDropdown<String>(
                  label: 'UF',
                  isRequired: true,
                  hint: 'UF',
                  value: _selectedStateCode,
                  errorText: _errors[_ProfileField.state],
                  items: brazilianStates
                      .map(
                        (state) => DropdownMenuItem(
                          value: state.code,
                          child: Text('${state.code} - ${state.name}'),
                        ),
                      )
                      .toList(),
                  // Com o menu fechado mostra só a sigla: o nome completo
                  // estoura a meia largura com fonte grande.
                  selectedItemBuilder: (_) => brazilianStates
                      .map(
                        (state) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(state.code),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving ? null : _onStateChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledDropdown<String>(
                  label: 'Cidade',
                  isRequired: true,
                  hint: _selectedStateCode == null
                      ? 'Selecione a UF primeiro'
                      : 'Selecione a cidade',
                  value: _selectedCity,
                  errorText: _errors[_ProfileField.city],
                  isLoading: _loadingCities,
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city,
                          child: Text(
                            city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _selectedStateCode == null || _isSaving
                      ? null
                      : (city) {
                          _markDirty();
                          setState(() {
                            _selectedCity = city;
                            _errors[_ProfileField.city] = null;
                          });
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Banner adjacente ao botão: com dois formulários no mesmo scroll,
          // um erro no topo do card ficaria fora do viewport.
          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _submitError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusError, fontSize: 13),
              ),
            ),
          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _successMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusSuccess, fontSize: 13),
              ),
            ),

          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: colors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 20),
            label: Text(_isSaving ? 'Salvando...' : 'Salvar alterações'),
          ),
        ],
      ),
    );
  }
}

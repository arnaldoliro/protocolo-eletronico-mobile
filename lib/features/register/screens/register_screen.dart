import 'package:flutter/material.dart';
import '../../../core/constants/brazilian_states.dart';
import '../../../core/models/register_request.dart';
import '../../../core/services/address_service.dart';
import '../../../core/services/company_service.dart';
import '../../../core/services/mock/address_mock_service.dart';
import '../../../core/services/mock/company_mock_service.dart';
import '../../../core/services/mock/register_mock_service.dart';
import '../../../core/services/register_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_background.dart';
import '../../../core/widgets/auth_card_header.dart';
import '../../../core/utils/masked_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/labeled_dropdown.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../home/screens/home_shell.dart';
import '../widgets/field_action_button.dart';
import '../widgets/registration_type_toggle.dart';
import '../widgets/section_header.dart';
import '../widgets/terms_checkbox.dart';

enum RegisterField {
  name,
  cpf,
  cnpj,
  companyName,
  email,
  phone,
  password,
  confirmPassword,
  cep,
  street,
  number,
  neighborhood,
  state,
  city,
  terms,
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AddressService _addressService = AddressMockService();
  final CompanyService _companyService = CompanyMockService();
  final RegisterService _registerService = RegisterMockService();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  RegistrationType _type = RegistrationType.individual;
  bool _acceptedTerms = false;

  String? _selectedStateCode;
  String? _selectedCity;
  List<String> _cities = const [];
  bool _loadingCities = false;

  /// Descarta respostas de requisições obsoletas quando o usuário troca de UF
  /// rapidamente e a resposta antiga chega depois da nova.
  int _citiesRequestId = 0;

  bool _isSearchingCep = false;
  bool _isSearchingCnpj = false;
  bool _isSubmitting = false;

  bool get _isCompany => _type == RegistrationType.company;

  final Map<RegisterField, String?> _errors = {};
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ erros

  void _clearError(RegisterField field) {
    if (_errors[field] == null) return;
    setState(() => _errors[field] = null);
  }

  // ------------------------------------------------------------------- tipo

  void _onTypeChanged(RegistrationType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      // Os erros dos campos que saem de cena ficariam pendurados e voltariam
      // ao alternar de novo — limpa tudo na troca.
      _errors.clear();
      _submitError = null;
    });
  }

  // ------------------------------------------------------------------ CNPJ

  bool get _canSearchCnpj =>
      onlyDigits(_cnpjController.text).length == 14 && !_isSubmitting;

  Future<void> _searchCnpj() async {
    final cnpj = onlyDigits(_cnpjController.text);
    if (cnpj.length != 14) return;

    setState(() {
      _isSearchingCnpj = true;
      _errors[RegisterField.cnpj] = null;
    });

    try {
      final companyName = await _companyService.findCompanyName(cnpj);
      if (!mounted) return;
      // Permanece editável: a razão social da Receita pode estar
      // desatualizada em relação ao que a empresa usa.
      _companyNameController.text = companyName;
      setState(() => _errors[RegisterField.companyName] = null);
    } on CompanyNotFoundException {
      if (mounted) {
        setState(() => _errors[RegisterField.cnpj] = 'CNPJ não encontrado');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível consultar o CNPJ. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingCnpj = false);
    }
  }

  // ------------------------------------------------------------------- UF

  Future<void> _onStateChanged(String? code) async {
    if (code == null || code == _selectedStateCode) return;

    final requestId = ++_citiesRequestId;

    setState(() {
      _selectedStateCode = code;
      // Zerar cidade e lista no MESMO setState é obrigatório: se o valor
      // antigo sobreviver à troca da lista, o DropdownButtonFormField dispara
      // assert e o app crasha.
      _selectedCity = null;
      _cities = const [];
      _loadingCities = true;
      _errors[RegisterField.state] = null;
      _errors[RegisterField.city] = null;
    });

    try {
      final cities = await _addressService.citiesByState(code);
      if (!mounted || requestId != _citiesRequestId) return;
      setState(() => _cities = cities);
    } catch (_) {
      if (!mounted || requestId != _citiesRequestId) return;
      setState(
        () => _errors[RegisterField.city] = 'Não foi possível carregar as cidades',
      );
    } finally {
      if (mounted && requestId == _citiesRequestId) {
        setState(() => _loadingCities = false);
      }
    }
  }

  // ------------------------------------------------------------------- CEP

  bool get _canSearchCep =>
      onlyDigits(_cepController.text).length == 8 && !_isSubmitting;

  Future<void> _searchCep() async {
    final cep = onlyDigits(_cepController.text);
    if (cep.length != 8) return;

    setState(() {
      _isSearchingCep = true;
      _errors[RegisterField.cep] = null;
    });

    try {
      final address = await _addressService.findByCep(cep);
      if (!mounted) return;

      // Campos preenchidos permanecem editáveis: bases de CEP têm lacunas e
      // CEP de logradouro único não traz número.
      _streetController.text = address.street;
      _neighborhoodController.text = address.neighborhood;

      await _onStateChanged(address.stateCode);
      if (!mounted) return;

      setState(() {
        // O CEP é a fonte mais confiável: se a cidade não estiver na lista do
        // backend, inserimos — sem isso o dropdown dispara assert.
        if (!_cities.contains(address.city)) {
          _cities = [..._cities, address.city]..sort();
        }
        _selectedCity = address.city;
        _errors[RegisterField.street] = null;
        _errors[RegisterField.neighborhood] = null;
      });
    } on CepNotFoundException {
      if (mounted) {
        setState(() => _errors[RegisterField.cep] = 'CEP não encontrado');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível buscar o CEP. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingCep = false);
    }
  }

  // -------------------------------------------------------------- validação

  /// Validação apenas de UX — o backend revalida tudo e é a autoridade sobre
  /// formato, unicidade e política de senha.
  bool _validate() {
    final errors = <RegisterField, String?>{
      // Em PJ estes dois campos passam a ser do responsável legal.
      RegisterField.name: Validators.required(_nameController.text),
      RegisterField.cpf: Validators.digitsLength(
        _cpfController.text,
        11,
        'CPF deve ter 11 dígitos',
      ),
      if (_isCompany) ...{
        RegisterField.cnpj: Validators.digitsLength(
          _cnpjController.text,
          14,
          'CNPJ deve ter 14 dígitos',
        ),
        RegisterField.companyName: Validators.required(
          _companyNameController.text,
        ),
      },
      RegisterField.email: Validators.email(_emailController.text),
      RegisterField.phone: Validators.digitsLength(
        _phoneController.text,
        11,
        'Celular deve ter 11 dígitos',
      ),
      RegisterField.password: Validators.minLength(
        _passwordController.text,
        8,
        'A senha deve ter no mínimo 8 caracteres',
      ),
      RegisterField.confirmPassword: Validators.passwordMatch(
        _passwordController.text,
        _confirmPasswordController.text,
      ),
      RegisterField.cep: Validators.digitsLength(
        _cepController.text,
        8,
        'CEP deve ter 8 dígitos',
      ),
      RegisterField.street: Validators.required(_streetController.text),
      RegisterField.number: Validators.required(_numberController.text),
      RegisterField.neighborhood: Validators.required(
        _neighborhoodController.text,
      ),
      RegisterField.state: _selectedStateCode == null ? 'Selecione a UF' : null,
      RegisterField.city: _selectedCity == null ? 'Selecione a cidade' : null,
      RegisterField.terms: _acceptedTerms ? null : 'É preciso aceitar os termos',
    };

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });

    return errors.values.every((error) => error == null);
  }

  // ----------------------------------------------------------------- submit

  Future<void> _submit() async {
    // Guarda contra double-tap antes do rebuild: cadastro duplicado é pior
    // que login duplicado.
    if (_isSubmitting) return;
    if (!_validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final user = await _registerService.register(
        RegisterRequest(
          type: _type,
          fullName: _nameController.text.trim(),
          cpf: onlyDigits(_cpfController.text),
          cnpj: _isCompany ? onlyDigits(_cnpjController.text) : null,
          companyName: _isCompany ? _companyNameController.text.trim() : null,
          email: _emailController.text.trim(),
          phone: onlyDigits(_phoneController.text),
          password: _passwordController.text,
          cep: onlyDigits(_cepController.text),
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          complement: _complementController.text.trim().isEmpty
              ? null
              : _complementController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          stateCode: _selectedStateCode!,
          city: _selectedCity!,
          acceptedTerms: _acceptedTerms,
        ),
      );

      if (!mounted) return;
      // pushAndRemoveUntil, não pushReplacement: com o login ainda na pilha,
      // o botão voltar levaria o usuário autenticado de volta para lá.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeShell(user: user)),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _submitError = 'Não foi possível criar a conta. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AuthBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
                boxShadow: colors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthCardHeader(
                    icon: Icons.person_add_alt_1,
                    title: 'Criar conta',
                    subtitle: 'Cadastre-se para abrir e acompanhar protocolos',
                  ),
                  const SizedBox(height: 24),

                  const SectionHeader(title: 'Tipo de cadastro', isRequired: true),
                  const SizedBox(height: 8),
                  RegistrationTypeToggle(
                    selected: _type,
                    onChanged: _onTypeChanged,
                  ),
                  const SizedBox(height: 16),

                  // Pessoa Jurídica antepõe CNPJ e razão social; os campos
                  // seguintes passam a ser do responsável legal.
                  if (_isCompany) ...[
                    LabeledTextField(
                      label: 'CNPJ',
                      isRequired: true,
                      hint: '00.000.000/0000-00',
                      prefixIcon: Icons.apartment,
                      controller: _cnpjController,
                      errorText: _errors[RegisterField.cnpj],
                      keyboardType: TextInputType.number,
                      inputFormatters: const [
                        MaskedInputFormatter(InputMasks.cnpj),
                      ],
                      suggestionsEnabled: false,
                      onChanged: (_) {
                        _clearError(RegisterField.cnpj);
                        // Reavalia se "Consultar" pode ser habilitado.
                        setState(() {});
                      },
                      trailing: FieldActionButton(
                        label: 'Consultar',
                        enabled: _canSearchCnpj,
                        isLoading: _isSearchingCnpj,
                        onPressed: _searchCnpj,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Razão social',
                      isRequired: true,
                      hint: 'Razão social da empresa',
                      prefixIcon: Icons.business_outlined,
                      controller: _companyNameController,
                      errorText: _errors[RegisterField.companyName],
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => _clearError(RegisterField.companyName),
                    ),
                    const SizedBox(height: 14),
                  ],

                  LabeledTextField(
                    label: _isCompany ? 'Nome do responsável' : 'Nome completo',
                    isRequired: true,
                    hint: _isCompany
                        ? 'Responsável legal pela empresa'
                        : 'Como aparece nos seus documentos',
                    prefixIcon: Icons.badge_outlined,
                    controller: _nameController,
                    errorText: _errors[RegisterField.name],
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    onChanged: (_) => _clearError(RegisterField.name),
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: _isCompany ? 'CPF do responsável' : 'CPF',
                    isRequired: true,
                    hint: '000.000.000-00',
                    prefixIcon: Icons.credit_card,
                    controller: _cpfController,
                    errorText: _errors[RegisterField.cpf],
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      MaskedInputFormatter(InputMasks.cpf),
                    ],
                    // CPF é dado sensível: sem sugestão nem autocorreção.
                    suggestionsEnabled: false,
                    onChanged: (_) => _clearError(RegisterField.cpf),
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: 'E-mail',
                    isRequired: true,
                    hint: 'seu@email.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    errorText: _errors[RegisterField.email],
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => _clearError(RegisterField.email),
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: 'Celular',
                    isRequired: true,
                    hint: '(00) 00000-0000',
                    helperText: 'Celular com DDD, 11 dígitos.',
                    prefixIcon: Icons.smartphone,
                    controller: _phoneController,
                    errorText: _errors[RegisterField.phone],
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      MaskedInputFormatter(InputMasks.phone),
                    ],
                    autofillHints: const [AutofillHints.telephoneNumber],
                    onChanged: (_) => _clearError(RegisterField.phone),
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: 'Senha',
                    isRequired: true,
                    hint: 'Mínimo 8 caracteres',
                    helperText: 'Combine letras maiúsculas, minúsculas e números.',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    errorText: _errors[RegisterField.password],
                    obscureText: true,
                    suggestionsEnabled: false,
                    onChanged: (_) => _clearError(RegisterField.password),
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: 'Confirme a senha',
                    isRequired: true,
                    hint: 'Repita a senha',
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    errorText: _errors[RegisterField.confirmPassword],
                    obscureText: true,
                    suggestionsEnabled: false,
                    onChanged: (_) => _clearError(RegisterField.confirmPassword),
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
                    errorText: _errors[RegisterField.cep],
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      MaskedInputFormatter(InputMasks.cep),
                    ],
                    autofillHints: const [AutofillHints.postalCode],
                    onChanged: (_) {
                      _clearError(RegisterField.cep);
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
                    errorText: _errors[RegisterField.street],
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _clearError(RegisterField.street),
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
                          errorText: _errors[RegisterField.number],
                          keyboardType: TextInputType.text,
                          onChanged: (_) => _clearError(RegisterField.number),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledTextField(
                          label: 'Complemento',
                          controller: _complementController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  LabeledTextField(
                    label: 'Bairro',
                    isRequired: true,
                    controller: _neighborhoodController,
                    errorText: _errors[RegisterField.neighborhood],
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _clearError(RegisterField.neighborhood),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledDropdown<String>(
                          label: 'UF',
                          isRequired: true,
                          hint: 'Selecione a UF',
                          value: _selectedStateCode,
                          errorText: _errors[RegisterField.state],
                          items: brazilianStates
                              .map(
                                (state) => DropdownMenuItem(
                                  value: state.code,
                                  child: Text('${state.code} - ${state.name}'),
                                ),
                              )
                              .toList(),
                          // Com o menu fechado mostra só a sigla: o nome
                          // completo estoura a meia largura com fonte grande.
                          selectedItemBuilder: (_) => brazilianStates
                              .map(
                                (state) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(state.code),
                                ),
                              )
                              .toList(),
                          onChanged: _isSubmitting ? null : _onStateChanged,
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
                          errorText: _errors[RegisterField.city],
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
                          onChanged:
                              _selectedStateCode == null || _isSubmitting
                              ? null
                              : (city) => setState(() {
                                  _selectedCity = city;
                                  _errors[RegisterField.city] = null;
                                }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TermsCheckbox(
                    value: _acceptedTerms,
                    errorText: _errors[RegisterField.terms],
                    onChanged: (value) => setState(() {
                      _acceptedTerms = value;
                      _errors[RegisterField.terms] = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  if (_submitError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _submitError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.statusError),
                      ),
                    ),

                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          colors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: colors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_alt_1, size: 20),
                    label: Text(_isSubmitting ? 'Criando...' : 'Criar conta'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tenho conta — ',
                        style: TextStyle(color: colors.textMuted, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _goToLogin,
                        child: Text(
                          'entrar',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

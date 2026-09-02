import 'package:flutter/material.dart';

import '../../../core/models/municipality.dart';
import '../../../core/services/mock/municipality_mock_service.dart';
import '../../../core/services/municipality_service.dart';
import '../../../core/tenant/municipality_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_background.dart';
import '../../../core/widgets/auth_card_header.dart';
import '../widgets/municipality_tile.dart';

/// Escolha do município antes do login.
///
/// É a primeira tela do app no primeiro acesso, e a única porta para trocar de
/// município depois. Não tem botão de voltar: no boot ela é a raiz da pilha, e
/// quando alcançada pelo "trocar" a pilha também é só ela.
class MunicipalitySelectionScreen extends StatefulWidget {
  const MunicipalitySelectionScreen({super.key});

  @override
  State<MunicipalitySelectionScreen> createState() =>
      _MunicipalitySelectionScreenState();
}

class _MunicipalitySelectionScreenState
    extends State<MunicipalitySelectionScreen> {
  final MunicipalityService _service = MunicipalityMockService();

  List<Municipality> _municipalities = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final municipalities = await _service.loadAvailable();
      if (!mounted) return;
      setState(() => _municipalities = municipalities);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _select(Municipality municipality) {
    MunicipalityScope.of(context).select(municipality);
    // pushReplacement nos dois caminhos: vindo do boot ou do "trocar", a pilha
    // termina como [login].
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final current = MunicipalityScope.of(context).selected;

    return AuthBackground(
      // O AuthBackground já expande para a tela inteira, então o Expanded
      // abaixo tem altura definida — o cabeçalho fica fixo e só a lista rola.
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: AuthCardHeader(
              icon: Icons.location_city,
              title: 'Selecione seu município',
              subtitle:
                  'Escolha a prefeitura onde você quer abrir e acompanhar '
                  'protocolos.',
            ),
          ),
          Expanded(child: _buildBody(colors, current)),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors colors, Municipality? current) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (_hasError || _municipalities.isEmpty) {
      return _buildError(colors);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: _municipalities.length,
      itemBuilder: (context, index) {
        final municipality = _municipalities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MunicipalityTile(
            key: ValueKey(municipality.id),
            municipality: municipality,
            isSelected: municipality.id == current?.id,
            onTap: () => _select(municipality),
          ),
        );
      },
    );
  }

  Widget _buildError(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar os municípios',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Verifique sua conexão e tente de novo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.inputBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

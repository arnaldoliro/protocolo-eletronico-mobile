import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/process_model.dart';
import '../../../core/models/process_query.dart';
import '../../../core/services/mock/process_list_mock_service.dart';
import '../../../core/services/process_list_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../widgets/process_card.dart';
import '../widgets/process_filter_sheet.dart';
import '../widgets/process_search_field.dart';

/// Espera antes de buscar, para não disparar uma requisição por tecla.
const _debounce = Duration(milliseconds: 300);

/// Listagem dos protocolos do usuário, com busca e filtros.
class ProcessesScreen extends StatefulWidget {
  const ProcessesScreen({super.key});

  @override
  State<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends State<ProcessesScreen> {
  final ProcessListService _service = ProcessListMockService();
  final _searchController = TextEditingController();

  ProcessQuery _query = ProcessQuery();
  List<ProcessModel> _items = const [];
  int _total = 0;

  bool _isLoading = true;
  bool _hasError = false;

  /// Primeira carga: distingue o esqueleto inicial do refiltro, que mantém a
  /// lista anterior na tela.
  bool _firstLoad = true;

  Timer? _debounceTimer;

  /// Descarta respostas obsoletas: `Future` não cancela em Dart, então uma
  /// busca antiga pode aterrissar depois da nova e sobrescrever o resultado.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scheduleLoad(immediate: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// [immediate] pula o debounce. Usado por tudo que não é digitação — ficar
  /// 300ms parado depois de aplicar um filtro parece travamento.
  void _scheduleLoad({bool immediate = false, bool announce = false}) {
    _debounceTimer?.cancel();
    if (immediate) {
      _load(announce: announce);
      return;
    }
    _debounceTimer = Timer(_debounce, _load);
  }

  Future<void> _load({bool announce = false}) async {
    final requestId = ++_requestId;
    final query = _query;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _service.load(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items = result.items;
        _total = result.total;
      });
      if (announce) {
        announceToScreenReader(context, _countLabel(result.total));
      }
    } catch (_) {
      // A guarda vale também aqui: sem ela, uma requisição antiga que falha
      // pintaria o erro por cima de dados novos e válidos.
      if (!mounted || requestId != _requestId) return;
      setState(() => _hasError = true);
      if (announce) {
        announceToScreenReader(context, 'Falha ao carregar os protocolos.');
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _isLoading = false;
          _firstLoad = false;
        });
      }
    }
  }

  String _countLabel(int total) {
    if (total == 0) return 'Nenhum protocolo encontrado';
    return total == 1 ? '1 protocolo' : '$total protocolos';
  }

  void _onSearchChanged(String value) {
    // Sem setState: reconstruir a lista a cada tecla é desperdício. O botão de
    // limpar observa o controller por conta própria.
    _query = _query.copyWith(text: value);
    _scheduleLoad();
  }

  void _clearSearch() {
    _searchController.clear();
    // clear() não dispara onChanged — a busca precisa ser refeita à mão.
    _query = _query.copyWith(text: '');
    _scheduleLoad(immediate: true);
  }

  void _clearEverything() {
    _searchController.clear();
    _query = _query.cleared();
    _scheduleLoad(immediate: true, announce: true);
  }

  Future<void> _openFilters() async {
    final updated = await showProcessFilterSheet(context, current: _query);
    // Nulo = a folha foi fechada sem aplicar.
    if (updated == null || !mounted) return;
    if (updated == _query) return;
    _query = updated;
    _scheduleLoad(immediate: true, announce: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Meus protocolos'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(colors)),
          if (_showList)
            SliverList.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  index == _items.length - 1 ? 24 : 12,
                ),
                child: ProcessCard(
                  key: ValueKey(_items[index].id),
                  process: _items[index],
                ),
              ),
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildPlaceholder(colors),
            ),
        ],
      ),
    );
  }

  /// Durante um refiltro a lista anterior continua na tela: trocá-la por um
  /// spinner perderia a posição de rolagem e o foco do leitor de tela.
  bool get _showList => _items.isNotEmpty && !(_hasError && _items.isEmpty);

  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProcessSearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _scheduleLoad(immediate: true),
            onClear: _clearSearch,
          ),
          const SizedBox(height: 12),
          _buildFilterRow(colors),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppColors colors) {
    final count = _query.activeFilterCount;

    return Row(
      children: [
        Expanded(
          child: _isLoading && !_firstLoad
              ? Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Buscando...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  _firstLoad ? '' : _countLabel(_total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: count == 0
              ? 'Filtros'
              : 'Filtros, $count ${count == 1 ? 'ativo' : 'ativos'}',
          child: ExcludeSemantics(
            child: OutlinedButton.icon(
              onPressed: _openFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: count > 0 ? colors.primary : colors.inputText,
                side: BorderSide(
                  color: count > 0 ? colors.primary : colors.inputBorder,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.tune, size: 18),
              label: Text(count == 0 ? 'Filtros' : 'Filtros ($count)'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(AppColors colors) {
    if (_firstLoad && _isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }
    if (_hasError) {
      return _Placeholder(
        icon: Icons.cloud_off_outlined,
        title: 'Não foi possível carregar seus protocolos',
        actionLabel: 'Tentar novamente',
        onAction: () => _scheduleLoad(immediate: true, announce: true),
      );
    }
    // Filtro ativo e nada casou é diferente de não ter protocolo nenhum: a
    // saída de um é limpar o filtro, a do outro é abrir um protocolo.
    if (_query.hasAnyFilter) {
      return _Placeholder(
        icon: Icons.search_off_outlined,
        title: 'Nenhum protocolo encontrado',
        message: 'Tente outro termo ou remova os filtros aplicados.',
        actionLabel: 'Limpar filtros',
        onAction: _clearEverything,
      );
    }
    return const _Placeholder(
      icon: Icons.inbox_outlined,
      title: 'Você ainda não tem protocolos',
      message: 'Quando abrir um protocolo, ele aparece aqui.',
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Placeholder({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, fontSize: 13),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAction,
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
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'consumed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppProvider>().loadInitialCharacters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    try {
      final results = await context.read<AppProvider>().api.searchCharacters(query);
      if (!mounted) return;
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum personagem encontrado.')),
        );
      } else {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetailScreen(characterId: results.first.id),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _open(Character character) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DetailScreen(characterId: character.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Explorar', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('CATÁLOGO DO MULTIVERSO', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFF9BE564))),
        ]),
        actions: [
          IconButton(tooltip: 'Favoritos', icon: const Icon(Icons.star), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
          IconButton(tooltip: 'Personagens conhecidos', icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsumedScreen()))),
          PopupMenuButton<String>(
            tooltip: 'Menu da conta',
            onSelected: (value) async {
              if (value == 'logout') await context.read<AppProvider>().logout();
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Sair da conta'))],
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, app, _) {
          if (app.isLoading && app.characters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (app.characters.isEmpty && app.errorMessage != null) {
            return _ErrorView(message: app.errorMessage!, onRetry: app.loadInitialCharacters);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar personagem...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  )),
                  const SizedBox(width: 8),
                  SizedBox(height: 50, child: ElevatedButton(
                    onPressed: _searching ? null : _search,
                    child: _searching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Buscar'),
                  )),
                ]),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final provider = context.read<AppProvider>();
                    provider.characters.clear();
                    await provider.loadInitialCharacters();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.73,
                      crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: app.characters.length,
                    itemBuilder: (context, index) => _CharacterCard(
                      character: app.characters[index], onTap: () => _open(app.characters[index]),
                      favorite: app.isFavorite(app.characters[index].id),
                    ),
                  ),
                ),
              ),
              if (app.errorMessage != null)
                Padding(padding: const EdgeInsets.all(8), child: Text(app.errorMessage!,
                  style: const TextStyle(color: Colors.orangeAccent))),
              if (app.hasMore)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: SizedBox(width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: app.isLoadingMore ? null : app.loadMoreCharacters,
                      child: app.isLoadingMore ? const CircularProgressIndicator()
                        : const Text('CARREGAR MAIS PERSONAGENS'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final bool favorite;
  const _CharacterCard({required this.character, required this.onTap, required this.favorite});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir detalhes de ${character.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                Image.network(character.image, fit: BoxFit.cover,
                  semanticLabel: 'Imagem do personagem ${character.name}',
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF303847),
                    child: Center(child: Icon(Icons.person, size: 58, color: Colors.white54)),
                  )),
                if (favorite) const Positioned(top: 8, right: 8,
                  child: CircleAvatar(radius: 15, backgroundColor: Colors.black87,
                    child: Icon(Icons.star, size: 17, color: Color(0xFFFFD45C))),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(character.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text('${character.species} • ${character.status}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, size: 54, color: Colors.white54),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    )),
  );
}

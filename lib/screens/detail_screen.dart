import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;
  const DetailScreen({super.key, required this.characterId});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Character> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AppProvider>().api.fetchCharacterDetails(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do personagem')),
      body: FutureBuilder<Character>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Não foi possível carregar os detalhes.'),
                TextButton(onPressed: () => setState(() {
                  _future = context.read<AppProvider>().api.fetchCharacterDetails(widget.characterId);
                }), child: const Text('Tentar novamente')),
              ]),
            ));
          }
          final character = snapshot.data!;
          return Consumer<AppProvider>(builder: (context, app, _) {
            final favorite = app.isFavorite(character.id);
            final consumed = app.isConsumed(character.id);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(aspectRatio: 1.05,
                    child: Image.network(character.image, fit: BoxFit.cover,
                      semanticLabel: 'Imagem de ${character.name}',
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF303847), child: Icon(Icons.person, size: 100))),
                  ),
                ),
                const SizedBox(height: 18),
                Text(character.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _Tag(text: character.status),
                  _Tag(text: character.species),
                  _Tag(text: character.gender),
                ]),
                const SizedBox(height: 20),
                _InfoRow(label: 'Origem', value: character.origin, icon: Icons.public),
                _InfoRow(label: 'Última localização', value: character.location, icon: Icons.location_on_outlined),
                _InfoRow(label: 'Tipo', value: character.type.isEmpty ? 'Não informado' : character.type, icon: Icons.category_outlined),
                const SizedBox(height: 22),
                SizedBox(height: 50, child: OutlinedButton.icon(
                  onPressed: () => app.toggleFavorite(character),
                  icon: Icon(favorite ? Icons.star : Icons.star_border),
                  label: Text(favorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'),
                )),
                const SizedBox(height: 10),
                SizedBox(height: 50, child: ElevatedButton.icon(
                  onPressed: () => app.toggleConsumed(character),
                  icon: Icon(consumed ? Icons.check_circle : Icons.bookmark_add_outlined),
                  label: Text(consumed ? 'Remover dos conhecidos' : 'Marcar como conhecido'),
                )),
              ]),
            );
          });
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(text),
    backgroundColor: const Color(0xFF34452F),
    side: BorderSide.none,
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF9BE564)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ])),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/character.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus favoritos')),
      body: Consumer<AppProvider>(builder: (context, app, _) {
        if (app.favorites.isEmpty) return const _EmptyState(
          icon: Icons.star_border, text: 'Você ainda não favoritou nenhum personagem.');
        return _CharacterList(characters: app.favorites);
      }),
    );
  }
}

class _CharacterList extends StatelessWidget {
  final List<Character> characters;
  const _CharacterList({required this.characters});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(14),
    itemCount: characters.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final character = characters[index];
      return Card(child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(character.image),
          onBackgroundImageError: (_, __) {}),
        title: Text(character.name),
        subtitle: Text('${character.species} • ${character.status}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetailScreen(characterId: character.id))),
      ));
    },
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 58, color: Colors.white38),
      const SizedBox(height: 12),
      Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
    ]),
  ));
}

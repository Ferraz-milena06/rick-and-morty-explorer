import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'detail_screen.dart';

class ConsumedScreen extends StatelessWidget {
  const ConsumedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens conhecidos')),
      body: Consumer<AppProvider>(builder: (context, app, _) {
        if (app.consumed.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_border, size: 58, color: Colors.white38),
              SizedBox(height: 12),
              Text('Sua lista ainda está vazia. Marque personagens como conhecidos nos detalhes.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            ]),
          ));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: app.consumed.length,
          itemBuilder: (context, index) {
            final character = app.consumed[index];
            return Card(child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(character.image),
                onBackgroundImageError: (_, __) {}),
              title: Text(character.name),
              subtitle: Text(character.species),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => DetailScreen(characterId: character.id))),
            ));
          },
        );
      }),
    );
  }
}

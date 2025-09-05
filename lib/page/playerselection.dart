//playerselection.dart
// stateful widget to select 3 players from list of players
import 'package:flutter/material.dart';

class PlayerSelection extends StatefulWidget {
  const PlayerSelection({super.key});

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  final List<String> players = [
    'Player 1',
    'Player 2',
    'Player 3',
    'Player 4',
    'Player 5',
    'Player 6',
    'Player 7',
    'Player 8',
    'Player 9',
    'Player 10',
  ];
  final Set<String> selectedPlayers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Players')),
      // body with Row of selected players at top
      // and ListView of players below it.
      body: Column(
        children: [
          Container(
            height: 100,
            color: Colors.grey[200],
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: selectedPlayers
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Chip(
                        label: Text(player),
                        onDeleted: () {
                          setState(() {
                            selectedPlayers.remove(player);
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 players per row
                childAspectRatio: 3, // Adjust for ListTile-like look
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isSelected = selectedPlayers.contains(player);
                return Card(
                  margin: const EdgeInsets.all(4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(player[0]),
                      // If you have images, use: backgroundImage: AssetImage('assets/avatars/$player.png'),
                    ),
                    title: Text(player, style: const TextStyle(fontSize: 14)),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedPlayers.remove(player);
                        } else {
                          if (selectedPlayers.length < 3) {
                            selectedPlayers.add(player);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You can only select up to 3 players.',
                                ),
                              ),
                            );
                          }
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

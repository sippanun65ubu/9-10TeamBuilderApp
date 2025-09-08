import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:advanced_app/controller/team_controller.dart';
import 'package:advanced_app/model/pokemon_model.dart';

class SavedTeamsPage extends StatelessWidget {
  final TeamController controller = Get.find<TeamController>();

  SavedTeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Teams')),
      body: Obx(() {
        if (controller.savedTeams.isEmpty) {
          return const Center(child: Text('No saved teams.'));
        }
        return ListView.builder(
          itemCount: controller.savedTeams.length,
          itemBuilder: (context, index) {
            final team = controller.savedTeams[index];
            return ListTile(
              title: Text(team['name']),
              subtitle: Row(
                children: (team['pokemon'] as List<Pokemon>)
                    .map((p) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Image.network(p.imageUrl, width: 40, height: 40),
                        ))
                    .toList(),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTeamPage(teamIndex: index),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class EditTeamPage extends StatefulWidget {
  final int teamIndex;
  const EditTeamPage({super.key, required this.teamIndex});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late TextEditingController nameController;
  late List<Pokemon> teamPokemon;
  final TeamController controller = Get.find<TeamController>();

  @override
  void initState() {
    super.initState();
    final team = controller.savedTeams[widget.teamIndex];
    nameController = TextEditingController(text: team['name']);
    teamPokemon = List<Pokemon>.from(team['pokemon']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Team Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: teamPokemon
                  .map((p) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Image.network(p.imageUrl, width: 40, height: 40),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.updateSavedTeam(
                  widget.teamIndex,
                  nameController.text,
                  teamPokemon,
                );
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:advanced_app/controller/team_controller.dart';
import 'package:advanced_app/model/pokemon_model.dart';

class TeamSelectionScreen extends StatelessWidget {
  TeamSelectionScreen({super.key});

  final TeamController controller = Get.put(TeamController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Set the initial text for the team name editor
    textController.text = controller.teamName.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Wrap the title in Obx to make it reactive
        title: Obx(
          () => Text(controller.teamName.value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.resetTeam(),
            tooltip: 'Reset Team',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTeamEditor(),
            const SizedBox(height: 10),
            _buildSelectedTeamDisplay(),
            const Divider(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildPokemonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamEditor() {
    return TextField(
      controller: textController,
      decoration: const InputDecoration(
        labelText: 'Team Name',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.edit),
      ),
      onChanged: (value) => controller.updateTeamName(value),
    );
  }

  Widget _buildSelectedTeamDisplay() {
    return Obx(
      () => Container(
        height: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            if (index < controller.selectedTeam.length) {
              final pokemon = controller.selectedTeam[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(pokemon.imageUrl, height: 60, width: 60),
                  Text(pokemon.name, style: const TextStyle(fontSize: 12)),
                ],
              );
            }
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.question_mark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search Pokémon',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildPokemonGrid() {
    return Expanded(
      // Obx listens to changes in controller variables and rebuilds the widget
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.filteredPokemon.length,
          itemBuilder: (context, index) {
            final pokemon = controller.filteredPokemon[index];
            return _buildPokemonCard(pokemon);
          },
        );
      }),
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
  return Obx(
    () {
      final isSelected = controller.selectedTeam.contains(pokemon);
      return GestureDetector(
        onTap: () => controller.selectPokemon(pokemon),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // ความเร็วของ animation
          curve: Curves.easeInOut, // รูปแบบการเคลื่อนไหว
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
              width: 2,
            ),
          ),
          // ทำให้การ์ดขยายใหญ่ขึ้นเล็กน้อยเมื่อถูกเลือก
          transform: isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(pokemon.imageUrl,
                        height: 70, width: 70, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    Text(
                      pokemon.name.capitalizeFirst!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // ทำให้ไอคอน Check ค่อยๆ ปรากฏและหายไป
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.check_circle, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
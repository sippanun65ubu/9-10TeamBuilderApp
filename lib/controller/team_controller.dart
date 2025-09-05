import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:9-10TeamBuilderApp/model/pokemon_model.dart';

class TeamController extends GetxController {
  // Reactive variables that automatically update the UI when they change.
  var allPokemon = <Pokemon>[].obs;
  var selectedTeam = <Pokemon>[].obs;
  var teamName = 'My Pokémon Team'.obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  final _storage = GetStorage(); // Instance of GetStorage

  // Computed property to filter Pokémon based on the search query.
  List<Pokemon> get filteredPokemon {
    if (searchQuery.isEmpty) {
      return allPokemon;
    } else {
      return allPokemon
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved data and fetch new data when the controller is initialized.
    loadTeamFromStorage();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    try {
      isLoading(true);
      // Fetch the first 151 Pokémon (Gen 1)
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        allPokemon.value =
            results.map((json) => Pokemon.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load Pokémon');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  void selectPokemon(Pokemon pokemon) {
    if (selectedTeam.contains(pokemon)) {
      selectedTeam.remove(pokemon);
    } else {
      if (selectedTeam.length < 3) {
        selectedTeam.add(pokemon);
      } else {
        Get.snackbar(
          'Team Full',
          'You can only select up to 3 Pokémon.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    saveTeamToStorage(); // Save after every change
  }

  void updateTeamName(String newName) {
    teamName.value = newName;
    saveTeamToStorage(); // Save after name change
  }

  void resetTeam() {
    selectedTeam.clear();
    saveTeamToStorage(); // Save the empty team
  }

  void saveTeamToStorage() {
    // Convert list of Pokemon objects to a list of JSON maps before saving
    _storage.write('teamName', teamName.value);
    _storage.write(
        'selectedTeam', selectedTeam.map((p) => p.toJson()).toList());
  }

  void loadTeamFromStorage() {
    // Read the saved team name or use a default
    teamName.value = _storage.read('teamName') ?? 'My Pokémon Team';

    // Read the list of JSON maps and convert it back to a list of Pokemon objects
    final savedTeam = _storage.read<List>('selectedTeam');
    if (savedTeam != null) {
      selectedTeam.value =
          savedTeam.map((json) => Pokemon.fromJson(json)).toList();
    }
  }
}
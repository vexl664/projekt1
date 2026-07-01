import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/places_database.dart';
import '../models/place_note.dart';
import 'add_place_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PlaceNote>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() {
    _placesFuture = PlacesDatabase.instance.getPlaces();
  }

  Future<void> _openAddPlaceScreen() async {
    final wasSaved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddPlaceScreen(),
      ),
    );

    if (wasSaved == true) {
      setState(_loadPlaces);
    }
  }

  Future<void> _deletePlace(PlaceNote place) async {
    final id = place.id;
    if (id == null) {
      return;
    }

    await PlacesDatabase.instance.deletePlace(id);
    setState(_loadPlaces);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Miejsce usunięte'),
      ),
    );
  }

  Future<void> _openMaps(PlaceNote place) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie udało się otworzyć Google Maps'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  Widget _buildPlaceImage(PlaceNote place) {
    final imagePath = place.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.place, size: 40);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.file(
        File(imagePath),
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 64,
            height: 64,
            child: Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  Widget _buildPlaceTile(PlaceNote place) {
    return ListTile(
      leading: _buildPlaceImage(place),
      title: Text(place.text),
      subtitle: Text(
        '${_formatDate(place.createdAt)}\n'
        'GPS: ${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
      ),
      isThreeLine: true,
      onTap: () => _openMaps(place),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Usuń',
        onPressed: () => _deletePlace(place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Miejsca'),
      ),
      body: FutureBuilder<List<PlaceNote>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Nie udało się wczytać miejsc'),
            );
          }

          final places = snapshot.data ?? [];
          if (places.isEmpty) {
            return const Center(
              child: Text('Brak zapisanych miejsc'),
            );
          }

          return ListView.separated(
            itemCount: places.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildPlaceTile(places[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPlaceScreen,
        tooltip: 'Dodaj miejsce',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../database/places_database.dart';
import '../models/place_note.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _imagePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photo == null) {
        return;
      }

      setState(() {
        _imagePath = photo.path;
      });
    } catch (error) {
      _showMessage('Nie udało się zrobić zdjęcia');
    }
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('GPS service disabled');
      _showMessage('Włącz lokalizację GPS');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    debugPrint('Location permission after check: $permission');

    if (permission == LocationPermission.denied) {
      _showMessage('Brak zgody na lokalizację');
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage('Lokalizacja jest trwale zablokowana w ustawieniach');
      return null;
    }

    try {
      debugPrint('Start fetching GPS position');
      debugPrint('Getting current GPS position');
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        'Used current GPS position: '
        'lat=${currentPosition.latitude}, '
        'lng=${currentPosition.longitude}, '
        'timestamp=${currentPosition.timestamp}',
      );
      _showMessage(
        'Pobrano GPS: ${currentPosition.latitude.toStringAsFixed(5)}, '
        '${currentPosition.longitude.toStringAsFixed(5)}',
      );
      return currentPosition;
    } on TimeoutException catch (error) {
      debugPrint('Current GPS position timeout: $error');
    } catch (error) {
      debugPrint('Current GPS position error: $error');
    }

    try {
      debugPrint('Using last known GPS position fallback');
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        debugPrint(
          'Used last known GPS position: '
          'lat=${lastKnownPosition.latitude}, '
          'lng=${lastKnownPosition.longitude}, '
          'timestamp=${lastKnownPosition.timestamp}',
        );
        _showMessage(
          'Pobrano GPS: ${lastKnownPosition.latitude.toStringAsFixed(5)}, '
          '${lastKnownPosition.longitude.toStringAsFixed(5)}',
        );
        return lastKnownPosition;
      }

      debugPrint('Last known GPS position fallback is empty');
    } catch (error) {
      debugPrint('Last known GPS position fallback error: $error');
    }

    _showMessage('Nie udało się pobrać lokalizacji. Spróbuj ponownie.');
    return null;
  }

  Future<void> _savePlace() async {
    if (_isSaving) {
      return;
    }

    debugPrint('Start saving place');

    final note = _noteController.text.trim();
    if (note.isEmpty) {
      _showMessage('Wpisz notatkę');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      debugPrint('Before GPS fetch');
      final position = await _getCurrentPosition();
      if (position == null) {
        return;
      }

      debugPrint('After GPS fetch');
      final place = PlaceNote(
        text: note,
        latitude: position.latitude,
        longitude: position.longitude,
        imagePath: _imagePath,
        createdAt: DateTime.now(),
      );

      debugPrint('Before SQLite insert');
      await PlacesDatabase.instance.insertPlace(place);
      debugPrint('After SQLite insert');

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Save place error: $error');
      _showMessage('Nie udało się zapisać miejsca');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildPhotoPreview() {
    final imagePath = _imagePath;
    if (imagePath == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Brak zdjęcia'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj miejsce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notatka',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildPhotoPreview(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Zrób zdjęcie'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _savePlace,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Zapisywanie...' : 'Zapisz miejsce'),
            ),
          ],
        ),
      ),
    );
  }
}

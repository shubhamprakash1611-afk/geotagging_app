import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_location.dart';
import '../providers/app_state_provider.dart';
import '../widgets/mini_map_widget.dart';
import '../utils/constants.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Saved Locations', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentGreen),
            onPressed: () => _showAddLocationModal(context),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, state, _) {
          final locations = state.savedLocations;

          if (locations.isEmpty) {
            return const Center(
              child: Text(
                'No saved locations yet.\nTap + to add your current location.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final loc = locations[index];
              final bool isActive = loc.isInRange(state.location.latitude, state.location.longitude);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? AppColors.accentGreen : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MiniMapWidget(
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  loc.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Active', style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.address,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.radar, size: 14, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text('${loc.rangeMeters}m Geofence', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                              const Spacer(),
                              InkWell(
                                onTap: () => state.removeSavedLocation(loc.id),
                                child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddLocationModal(BuildContext context) {
    final state = context.read<AppStateProvider>();
    if (!state.locationAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location is not available yet.')));
      return;
    }

    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Current Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.location.fullAddress,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'e.g., Office, Site A, Home',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                
                final newLoc = SavedLocation(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  latitude: state.location.latitude,
                  longitude: state.location.longitude,
                  address: state.location.fullAddress,
                  city: state.location.city,
                  state: state.location.state,
                  country: state.location.country,
                  createdAt: DateTime.now(),
                );
                
                state.addSavedLocation(newLoc);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}


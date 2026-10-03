import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/saved_location.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/mini_map_widget.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Saved Locations',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.surfaceGradient),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton.filledTonal(
              tooltip: 'Save current location',
              icon: const Icon(Icons.add_location_alt_rounded, size: 20),
              color: AppColors.accentGreen,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
              ),
              onPressed: () => _showAddLocationModal(context),
            ),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, state, _) {
          final locations = state.savedLocations;
          if (locations.isEmpty) {
            return _EmptyLocations(
              onAdd: () => _showAddLocationModal(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loc = locations[index];
              final isActive = loc.isInRange(
                state.location.latitude,
                state.location.longitude,
              );
              return _LocationCard(
                location: loc,
                isActive: isActive,
                onDelete: () => state.removeSavedLocation(loc.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddLocationModal(BuildContext context) async {
    final state = context.read<AppStateProvider>();
    if (!state.locationAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still finding your location. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_location_alt_rounded,
            color: Color(0xFF042117),
          ),
        ),
        title: const Text(
          'Save this location',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                state.location.fullAddress,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Location name',
                hintText: 'Office, Home, Site A…',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.65),
                ),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.62),
                prefixIcon: const Icon(
                  Icons.edit_location_alt_outlined,
                  color: AppColors.accentCyan,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentGreen),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              state.addSavedLocation(
                SavedLocation(
                  id: const Uuid().v4(),
                  title: title,
                  latitude: state.location.latitude,
                  longitude: state.location.longitude,
                  address: state.location.fullAddress,
                  city: state.location.city,
                  state: state.location.state,
                  country: state.location.country,
                  createdAt: DateTime.now(),
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: const Color(0xFF042117),
            ),
            icon: const Icon(Icons.bookmark_add_rounded, size: 18),
            label: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    titleController.dispose();
  }
}

class _EmptyLocations extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyLocations({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33268FFF), Color(0x2239E6A5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 42,
                color: AppColors.accentCyan,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Keep important places close',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your current position for faster field check-ins and geofence status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: const Color(0xFF042117),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text(
                'Save current location',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final SavedLocation location;
  final bool isActive;
  final VoidCallback onDelete;

  const _LocationCard({
    required this.location,
    required this.isActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceRaised, AppColors.surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? AppColors.accentGreen.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.08),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: MiniMapWidget(
                latitude: location.latitude,
                longitude: location.longitude,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  location.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      size: 14,
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${location.rangeMeters} m geofence',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete ${location.title}',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: Color(0xFFFF7770),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

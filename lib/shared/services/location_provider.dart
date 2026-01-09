import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  Future<Position?> build() async {
    return await _getCurrentLocation();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // SPEED OPTIMIZATION: Try to get last known position FIRST for instant load
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        // Use cached location immediately, then update in background
        _updateLocationInBackground();
        return lastPosition;
      }
    } catch (_) {
      // Continue to get fresh location if no cached location
    }

    // Get fresh position with shorter timeout for faster response
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // Changed from high to medium for speed
          distanceFilter: 100, // Only update if moved 100m for efficiency
        ),
      ).timeout(
        const Duration(seconds: 5), // Reduced from 10 to 5 seconds
        onTimeout: () async {
          // Fallback to last known position
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return lastPosition;
          }
          throw Exception('Location timeout and no last known position');
        },
      );
      return position;
    } catch (e) {
      // Try to get last known position as final fallback
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  // Background location update (doesn't block initial load)
  void _updateLocationInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        ).timeout(const Duration(seconds: 10));

        // Only update if we got a more accurate position
        final currentState = state.value;
        if (currentState != null && position != null) {
          final distance = Geolocator.distanceBetween(
            currentState.latitude,
            currentState.longitude,
            position.latitude,
            position.longitude,
          );

          // Only update if moved more than 500m or accuracy improved
          if (distance > 500 || position.accuracy < currentState.accuracy) {
            state = AsyncValue.data(position);
          }
        }
      } catch (_) {
        // Silently fail background update
      }
    });
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCurrentLocation());
  }
}

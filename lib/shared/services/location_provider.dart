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

    // Get current position with timeout and fallback
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 10),
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

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCurrentLocation());
  }
}

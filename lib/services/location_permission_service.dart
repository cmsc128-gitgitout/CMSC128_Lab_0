import 'package:geolocator/geolocator.dart';

enum LocationAccessOutcome {
  granted,
  servicesDisabled,
  denied,
  deniedForever,
  unableToDetermine,
}

class LocationPermissionService {
  LocationPermissionService({
    Future<bool> Function()? isLocationServiceEnabled,
    Future<LocationPermission> Function()? checkPermission,
    Future<LocationPermission> Function()? requestPermission,
  }) : _isLocationServiceEnabled =
           isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission;

  final Future<bool> Function() _isLocationServiceEnabled;
  final Future<LocationPermission> Function() _checkPermission;
  final Future<LocationPermission> Function() _requestPermission;

  Future<LocationAccessOutcome> requestAccess() async {
    final serviceEnabled = await _isLocationServiceEnabled();
    var permission = await _checkPermission();

    if (!serviceEnabled) {
      return LocationAccessOutcome.servicesDisabled;
    }

    if (permission == LocationPermission.denied) {
      permission = await _requestPermission();
    }

    return switch (permission) {
      LocationPermission.whileInUse ||
      LocationPermission.always => LocationAccessOutcome.granted,
      LocationPermission.denied => LocationAccessOutcome.denied,
      LocationPermission.deniedForever => LocationAccessOutcome.deniedForever,
      LocationPermission.unableToDetermine =>
        LocationAccessOutcome.unableToDetermine,
    };
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tara_larga/services/location_permission_service.dart';

void main() {
  test(
    'checks permission but does not request it when services are off',
    () async {
      var checkedPermission = false;
      var requestedPermission = false;
      final service = LocationPermissionService(
        isLocationServiceEnabled: () async => false,
        checkPermission: () async {
          checkedPermission = true;
          return LocationPermission.denied;
        },
        requestPermission: () async {
          requestedPermission = true;
          return LocationPermission.whileInUse;
        },
      );

      final result = await service.requestAccess();

      expect(result, LocationAccessOutcome.servicesDisabled);
      expect(checkedPermission, isTrue);
      expect(requestedPermission, isFalse);
    },
  );

  test('does not request permission again when already granted', () async {
    var requestedPermission = false;
    final service = LocationPermissionService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async {
        requestedPermission = true;
        return LocationPermission.denied;
      },
    );

    final result = await service.requestAccess();

    expect(result, LocationAccessOutcome.granted);
    expect(requestedPermission, isFalse);
  });

  test(
    'requests permission after a denial and returns the new state',
    () async {
      var requestedPermission = false;
      final service = LocationPermissionService(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.denied,
        requestPermission: () async {
          requestedPermission = true;
          return LocationPermission.deniedForever;
        },
      );

      final result = await service.requestAccess();

      expect(requestedPermission, isTrue);
      expect(result, LocationAccessOutcome.deniedForever);
    },
  );

  test('does not re-request permanently denied permission', () async {
    var requestedPermission = false;
    final service = LocationPermissionService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.deniedForever,
      requestPermission: () async {
        requestedPermission = true;
        return LocationPermission.whileInUse;
      },
    );

    final result = await service.requestAccess();

    expect(result, LocationAccessOutcome.deniedForever);
    expect(requestedPermission, isFalse);
  });
}

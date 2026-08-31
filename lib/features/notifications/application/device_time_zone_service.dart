import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract interface class DeviceTimeZoneService {
  Future<String> currentIdentifier();
  tz.Location locationFor(String identifier);
}

final class FlutterDeviceTimeZoneService implements DeviceTimeZoneService {
  FlutterDeviceTimeZoneService() {
    tz_data.initializeTimeZones();
  }

  @override
  Future<String> currentIdentifier() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      locationFor(info.identifier);
      return info.identifier;
    } on Object {
      return 'UTC';
    }
  }

  @override
  tz.Location locationFor(String identifier) {
    try {
      return tz.getLocation(identifier);
    } on Object {
      return tz.UTC;
    }
  }
}

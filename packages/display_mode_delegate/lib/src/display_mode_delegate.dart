import 'dart:async';

import 'package:flutter/services.dart';

import 'model/display_mode.dart';

class DisplayModeDelegate {
  const DisplayModeDelegate._();

  static const _channel = MethodChannel('rhythm_native/display_mode');

  /// [supported] returns all the modes that can be set as the preferred mode.
  /// This always returns [DisplayMode.auto] as one of the modes.
  static Future<List<DisplayMode>> get supported async {
    final rawModes =
        (await _channel.invokeMethod<List<dynamic>>('getSupportedModes'))!;

    final modes = rawModes.map((dynamic i) {
      final item = (i as Map<dynamic, dynamic>).cast<String, dynamic>();
      return DisplayMode.fromJson(item);
    }).toList();

    modes.insert(0, DisplayMode.auto);
    return modes;
  }

  /// [active] fetches the currently active mode. This is not always the
  /// preferred mode set by [setPreferredMode]. It can be altered by the
  /// system based on the display settings.
  static Future<DisplayMode> get active async {
    final mode =
        (await _channel.invokeMethod<Map<dynamic, dynamic>>('getActiveMode'))!;

    return DisplayMode.fromJson(mode.cast<String, dynamic>());
  }

  /// [preferred] returns the currently preferred mode. If not manually set
  /// with [setPreferredMode] then it will be [DisplayMode.auto].
  static Future<DisplayMode> get preferred async {
    final mode = (await _channel
        .invokeMethod<Map<dynamic, dynamic>>('getPreferredMode'))!;

    return DisplayMode.fromJson(mode.cast<String, dynamic>());
  }

  /// [setPreferredMode] changes the preferred mode. It is upto the system
  /// to use this. Sometimes system can choose not switch to this based on
  /// internal heuristics. Check [active] to see if it actually switches.
  static Future<void> setPreferredMode(DisplayMode mode) async {
    return await _channel.invokeMethod<void>(
      'setPreferredMode',
      <String, dynamic>{'mode': mode.id},
    );
  }

  /// [setHighRefreshRate] changes preferred mode to highest refresh rate
  /// available maintaining current resolution
  static Future<void> setHighRefreshRate() async {
    final modes = await supported;
    final activeMode = await active;
    final preferredMode = await preferred;

    DisplayMode newMode = activeMode;

    for (final mode in modes) {
      if (mode.height == newMode.height &&
          mode.width == newMode.width &&
          mode.refreshRate > newMode.refreshRate) {
        newMode = mode;
      }
    }

    if (newMode != preferredMode) {
      await setPreferredMode(newMode);
    }
  }

  /// [setLowRefreshRate] changes preferred mode to lowest refresh rate
  /// available maintaining current resolution
  static Future<void> setLowRefreshRate() async {
    final modes = await supported;
    final activeMode = await active;
    final preferredMode = await preferred;

    DisplayMode newMode = activeMode;

    for (final mode in modes) {
      if (mode.height == newMode.height &&
          mode.width == newMode.width &&
          mode.refreshRate < newMode.refreshRate) {
        newMode = mode;
      }
    }

    if (newMode != preferredMode) {
      await setPreferredMode(newMode);
    }
  }
}

// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:flutter_sound_web/flutter_sound_web.dart';
import 'package:geolocator_web/geolocator_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:record_web/record_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  FlutterSoundPlugin.registerWith(registrar);
  GeolocatorPlugin.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  RecordPluginWeb.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}

import 'package:hisab/core/preferences/preference_config.dart';

StringPreference<String> get sharedPrefCurrentLocalization => const StringPreference('localization', 'en');
BoolPreference get sharedPrefTheme => const BoolPreference('theme', false);

DoublePreference get sharedPrefLocationLatitude => const DoublePreference('loc_lat', null);
IntPreference<int> get sharedPrefCalcIndex => const IntPreference('calc', 0);

List<BoolPreference> get sharedPrefAdhanVisibility => const [
  BoolPreference('vis_fajr', true),
  BoolPreference('vis_sunrise', true),
  BoolPreference('vis_dhuhr', true),
  BoolPreference('vis_asr', true),
  BoolPreference('vis_magrib', true),
  BoolPreference('vis_isha', true),
  BoolPreference('vis_midnight', true),
  BoolPreference('vis_last_third', true),
];

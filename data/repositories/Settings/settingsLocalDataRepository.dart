import 'package:hive/hive.dart';
import 'package:news/utils/hiveBoxKeys.dart';

class SettingsLocalDataRepository {
  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBoxKey).put(currentLanguageCodeKey, value);
  }

  String getCurrentLanguageCode() {
    return Hive.box(settingsBoxKey).get(currentLanguageCodeKey) ?? "";
  }

  Future<void> setCurrentLangId(String value) async {
    Hive.box(settingsBoxKey).put(currentLanguageIDKey, value);
  }

  String getCurrentLanguageId() {
    return Hive.box(settingsBoxKey).get(currentLanguageIDKey) ?? '';
  }

  Future<void> setCurrentLanguageRTL(String value) async {
    Hive.box(settingsBoxKey).put(currentLanguageRTLKey, value);
  }

  String getCurrentLanguageRTL() {
    return Hive.box(settingsBoxKey).get(currentLanguageRTLKey) ?? "";
  }

  Future<void> setIntroSlider(bool value) async {
    Hive.box(settingsBoxKey).put(introSliderKey, value);
  }

  bool getIntroSlider() {
    return Hive.box(settingsBoxKey).get(introSliderKey) ?? true;
  }

  Future<void> setFcmToken(String value) async {
    Hive.box(settingsBoxKey).put(tokenKey, value);
  }

  String getFcmToken() {
    return Hive.box(settingsBoxKey).get(tokenKey) ?? "";
  }

  Future<void> setCurrentTheme(String value) async {
    Hive.box(settingsBoxKey).put(currentThemeKey, value);
  }

  String getCurrentTheme() {
    return Hive.box(settingsBoxKey).get(currentThemeKey) ?? "";
  }

  Future<void> setNotification(bool value) async {
    Hive.box(settingsBoxKey).put(notificationKey, value);
  }

  bool getNotification() {
    return Hive.box(settingsBoxKey).get(notificationKey) ?? true;
  }

  Future<void> setLocationCityKeys(double? latitude, double? longitude) async {
    Hive.box(locationCityBoxKey).put(latitudeKey, latitude);
    Hive.box(locationCityBoxKey).put(longitudeKey, longitude);
  }

  Set<String> getLocationCityValues() {
    Set<String> locationValues = {Hive.box(locationCityBoxKey).get(latitudeKey).toString(), Hive.box(locationCityBoxKey).get(longitudeKey).toString()};
    return locationValues;
  }
}

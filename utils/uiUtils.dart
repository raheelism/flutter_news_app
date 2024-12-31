import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/fbInterstitialAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/googleInterstitialAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/unityInterstitialAds.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/labelKeys.dart';
import 'package:news/ui/styles/appTheme.dart';
import 'package:news/utils/hiveBoxKeys.dart';

class UiUtils {
  static GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static Future<void> setDynamicStringValue(String key, String value) async {
    Hive.box(settingsBoxKey).put(key, value);
  }

  static Future<void> setDynamicListValue(String key, String value) async {
    List<String>? valueList = getDynamicListValue(key);
    if (!valueList.contains(value)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(value);

      Hive.box(settingsBoxKey).put(key, valueList);
    }
  }

  static List<String> getDynamicListValue(String key) {
    return Hive.box(settingsBoxKey).get(key);
  }

  static String getSvgImagePath(String imageName) {
    return "assets/images/svgImage/$imageName.svg";
  }

  static String getPlaceholderPngPath() {
    return "assets/images/placeholder.png";
  }

  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

// get app theme
  static String getThemeLabelFromAppTheme(AppTheme appTheme) {
    if (appTheme == AppTheme.Dark) {
      return darkThemeKey;
    }
    return lightThemeKey;
  }

  static AppTheme getAppThemeFromLabel(String label) {
    return (label == darkThemeKey) ? AppTheme.Dark : AppTheme.Light;
  }

  static String getTranslatedLabel(BuildContext context, String labelKey) {
    return context.read<LanguageJsonCubit>().getTranslatedLabels(labelKey);
  }

  static String? convertToAgo(BuildContext context, DateTime input, int from) {
    Duration diff = DateTime.now().difference(input);
    initializeDateFormatting(); //locale according to location
    final langCode = Hive.box(settingsBoxKey).get(currentLanguageCodeKey);
    bool isNegative = diff.isNegative;
    if (diff.inDays <= 30) {
      if (diff.inDays >= 1 || (isNegative && diff.inDays < 1)) {
        if (from == 0) {
          var newFormat = DateFormat("MMM dd, yyyy", langCode);
          final newsDate1 = newFormat.format(input);
          return newsDate1;
        } else if (from == 1) {
          return "${diff.inDays} ${getTranslatedLabel(context, 'days')} ${getTranslatedLabel(context, 'ago')}";
        } else if (from == 2) {
          var newFormat = DateFormat("dd MMMM yyyy HH:mm:ss", langCode);
          final newsDate1 = newFormat.format(input);
          return newsDate1;
        } else if (from == 3) {
          var newFormat = DateFormat("MMMM dd, yyyy", langCode);
          final newNewsDate = newFormat.format(input);
          return newNewsDate;
        }
      } else if (diff.inHours >= 1 || (isNegative && diff.inMinutes < 1)) {
        if (input.minute == 00) {
          return "${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${getTranslatedLabel(context, 'ago')}";
        } else {
          if (from == 2) {
            return "${getTranslatedLabel(context, 'about')} ${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${input.minute} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
          } else {
            return "${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${input.minute} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
          }
        }
      } else if (diff.inMinutes >= 1 || (isNegative && diff.inMinutes < 1)) {
        return "${diff.inMinutes} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
      } else if (diff.inSeconds >= 1) {
        return "${diff.inSeconds} ${getTranslatedLabel(context, 'seconds')} ${getTranslatedLabel(context, 'ago')}";
      } else {
        return getTranslatedLabel(context, 'justNow');
      }
    } else if (diff.inDays <= 365) {
      int months = calculateMonthsDifference(input, DateTime.now());
      return "$months ${getTranslatedLabel(context, 'months')} ${getTranslatedLabel(context, 'ago')}";
    } else {
      double years = calculateYearsDifference(input, DateTime.now());
      return "$years ${getTranslatedLabel(context, 'months')} ${getTranslatedLabel(context, 'ago')}";
    }
    return null;
  }

  static int calculateMonthsDifference(DateTime startDate, DateTime endDate) {
    int yearsDifference = endDate.year - startDate.year;
    int monthsDifference = endDate.month - startDate.month;

    return yearsDifference * 12 + monthsDifference;
  }

  static double calculateYearsDifference(DateTime startDate, DateTime endDate) {
    int monthsDifference = calculateMonthsDifference(startDate, endDate);
    return monthsDifference / 12;
  }

  static setUIOverlayStyle({required AppTheme appTheme}) {
    appTheme == AppTheme.Light
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: backgroundColor.withOpacity(0.8), statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark))
        : SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor: darkSecondaryColor.withOpacity(0.8), statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light));
  }

  static userLogOut({required BuildContext contxt}) {
    for (int i = 0; i < AuthProviders.values.length; i++) {
      if (AuthProviders.values[i].name == contxt.read<AuthCubit>().getType()) {
        contxt.read<BookmarkCubit>().resetState();
        contxt.read<LikeAndDisLikeCubit>().resetState();
        contxt.read<AuthCubit>().signOut(AuthProviders.values[i]).then((value) {
          Navigator.of(contxt).pushNamedAndRemoveUntil(Routes.login, (route) => false);
        });
      }
    }
  }

//widget for User Profile Picture in Comments
  static Widget setFixedSizeboxForProfilePicture({required Widget childWidget}) {
    return SizedBox(height: 35, width: 35, child: childWidget);
  }

  //Add & Edit News Screen
  //roundedRectangle dashed border widget
  static Widget dottedRRectBorder({required Widget childWidget}) {
    return DottedBorder(dashPattern: const [6, 3], borderType: BorderType.RRect, radius: const Radius.circular(10), child: ClipRRect(child: Center(child: childWidget)));
  }

  static Widget dropdownArrow({required BuildContext context}) {
    return Align(alignment: Alignment.centerRight, child: Icon(Icons.keyboard_arrow_down_outlined, color: getColorScheme(context).primaryContainer));
  }

  static Widget setRowWithContainer({required BuildContext context, required Widget firstChild, required bool isContentTypeUpload}) {
    return Container(
      width: double.maxFinite,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(color: getColorScheme(context).surface, borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          firstChild,
          (isContentTypeUpload)
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: Align(alignment: Alignment.centerRight, child: Icon(Icons.file_upload_outlined, color: getColorScheme(context).primaryContainer)))
              : dropdownArrow(context: context)
        ],
      ),
    );
  }

  static Widget setBottomsheetContainer({required String listItem, required String compareTo, required BuildContext context, required String entryId}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0), color: (compareTo != "" && compareTo == entryId) ? Theme.of(context).primaryColor : getColorScheme(context).primaryContainer.withOpacity(0.1)),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.center,
        child: CustomTextLabel(
            text: listItem,
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: (compareTo == entryId) ? getColorScheme(context).secondary : getColorScheme(context).primaryContainer)));
  }

  static Widget setTopPaddingParent({required Widget childWidget}) {
    return Padding(padding: const EdgeInsets.only(top: 10.0), child: childWidget);
  }

//Home Screen - featured sections
  static Widget setPlayButton({required BuildContext context, double heightVal = 40}) {
    return Container(
        alignment: Alignment.center,
        height: heightVal,
        width: heightVal,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
        child: const Icon(Icons.play_arrow_sharp, size: 25, color: secondaryColor));
  }

  //Native Ads
  static BannerAd createBannerAd({required BuildContext context}) {
    return BannerAd(
        adUnitId: context.read<AppConfigurationCubit>().bannerId()!,
        request: const AdRequest(),
        size: AdSize.mediumRectangle,
        listener: BannerAdListener(
            onAdLoaded: (_) => debugPrint("native ad is Loaded !!!"),
            onAdFailedToLoad: (ad, err) {
              debugPrint("error in loading Native ad $err");
              ad.dispose();
            },
            onAdOpened: (Ad ad) => debugPrint('Native ad opened.'),
            // Called when an ad opens an overlay that covers the screen.
            onAdClosed: (Ad ad) => debugPrint('Native ad closed.'),
            // Called when an ad removes an overlay that covers the screen.
            onAdImpression: (Ad ad) => debugPrint('Native ad impression.')));
  }

  static Widget bannerAdsShow({required BuildContext context}) {
    return AdWidget(key: UniqueKey(), ad: createBannerAd(context: context)..load());
  }

  static Widget fbNativeAdsShow({required BuildContext context}) {
    return (context.read<AppConfigurationCubit>().nativeId() != "")
        ? FacebookNativeAd(
            placementId: context.read<AppConfigurationCubit>().nativeId()!,
            adType: Platform.isAndroid ? NativeAdType.NATIVE_AD : NativeAdType.NATIVE_AD_VERTICAL,
            width: double.infinity,
            height: 320,
            keepAlive: true,
            keepExpandedWhileLoading: false,
            expandAnimationDuraion: 300,
            listener: (result, value) => debugPrint("Native Ad: $result --> $value"))
        : const SizedBox.shrink();
  }

  //Interstitial Ads
  static showInterstitialAds({required BuildContext context}) {
    if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1") {
      if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
        showGoogleInterstitialAd(context);
      } else if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
        showFBInterstitialAd();
      } else {
        showUnityInterstitialAds(context.read<AppConfigurationCubit>().interstitialId()!);
      }
    }
  }

  //calculate time in Minutes to Read News Article
  static int calculateReadingTime(String text) {
    const wordsPerMinute = 200;
    final wordCount = text.trim().split(' ').length;
    final readTime = (wordCount / wordsPerMinute).ceil();
    return readTime;
  }
}

Widget nativeAdsShow({required BuildContext context, required int index}) {
  if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1" &&
      context.read<AppConfigurationCubit>().checkAdsType() != null &&
      (context.read<AppConfigurationCubit>().getIOSAdsType() != "unity" || context.read<AppConfigurationCubit>().getAdsType() != "unity") &&
      index != 0 &&
      index % nativeAdsIndex == 0) {
    print("native ads show");
    return Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
            padding: const EdgeInsets.all(7.0),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10.0)),
            child: context.read<AppConfigurationCubit>().checkAdsType() == "google" && (context.read<AppConfigurationCubit>().bannerId() != "")
                ? UiUtils.bannerAdsShow(context: context)
                : UiUtils.fbNativeAdsShow(context: context)));
  } else {
    return const SizedBox.shrink();
  }
}

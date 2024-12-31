import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/uiUtils.dart';

Future<void> createDynamicLink({required BuildContext context, required String id, required String title, required bool isVideoId, required bool isBreakingNews, required String image}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: deepLinkUrlPrefix,
    link: Uri.parse('https://$deeplinkURL/?id=$id&isVideoId=$isVideoId&isBreakingNews=$isBreakingNews&langId=${context.read<AppLocalizationCubit>().state.id}'),
    androidParameters: const AndroidParameters(packageName: packageName, minimumVersion: 1),
    iosParameters: const IOSParameters(bundleId: iosPackage, minimumVersion: '1', appStoreId: appStoreId),
    socialMetaTagParameters: SocialMetaTagParameters(title: title, imageUrl: Uri.parse(image), description: appName),
  );

  final ShortDynamicLink shortenedLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  var str = "$title\n\n$appName\n\n${UiUtils.getTranslatedLabel(context, 'shareMsg')}\n\n$androidLbl\n"
      "$androidLink$packageName";
  if (iosLink.isNotEmpty) str += "\n\n$iosLbl\n$iosLink";

  Share.share("${shortenedLink.shortUrl.toString()}\n\n$str", subject: appName, sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2));
}

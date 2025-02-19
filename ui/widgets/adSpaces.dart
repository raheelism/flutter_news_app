//sponsored Ads

import 'package:flutter/material.dart';
import 'package:news/data/models/adSpaceModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:url_launcher/url_launcher.dart';

class AdSpaces extends StatelessWidget {
  AdSpaceModel adsModel;
  AdSpaces({super.key, required this.adsModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: InkWell(
          splashColor: Colors.transparent,
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(adsModel.adUrl!))) {
              //To open link in other apps or outside of Current App
              //Add -> , mode: LaunchMode.externalApplication
              await launchUrl(Uri.parse(adsModel.adUrl!));
            }
          },
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsetsDirectional.only(end: 5),
              child: CustomTextLabel(
                text: 'sponsoredLbl',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CustomNetworkImage(networkImageUrl: adsModel.adImage!, isVideo: false, width: MediaQuery.of(context).size.width, fit: BoxFit.values.first),
            ),
          ])),
    );
  }
}

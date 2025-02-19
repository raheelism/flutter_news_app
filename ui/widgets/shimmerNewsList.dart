import 'package:flutter/material.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

shimmerNewsList(BuildContext context, {bool isNews = true}) {
  //videos,Subcategory,Bookmarks & TagsPage
  return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(top: 0.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (_, i) => Padding(
              padding: EdgeInsetsDirectional.only(top: i == 0 ? 0 : 15.0),
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height / 35.0, start: 10.0, end: 10.0),
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4.5,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.withOpacity(0.6)),
                        )),
                    (!isNews)
                        ? const SizedBox.shrink()
                        : Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 10.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    height: 16.0,
                                    child: ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: 2,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding: const EdgeInsetsDirectional.only(start: 5.5),
                                              child: Container(
                                                height: 20.0,
                                                width: 65,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0),
                                                decoration:
                                                    const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)), color: secondaryColor),
                                              ));
                                        })),
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.15,
                                  height: 10.0,
                                  margin: const EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.withOpacity(0.6)),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2.0,
                                  height: 10.0,
                                  margin: const EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.withOpacity(0.6)),
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: MediaQuery.of(context).size.width / 1.35),
                                    iconButtons(context: context),
                                    SizedBox(width: MediaQuery.of(context).size.width / 99.0),
                                    iconButtons(context: context),
                                    SizedBox(width: MediaQuery.of(context).size.width / 99.0),
                                    iconButtons(context: context)
                                  ],
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              )),
          itemCount: 6,
        ),
      ));
}

Widget iconButtons({required BuildContext context}) {
  return Container(
    width: MediaQuery.of(context).size.width / 20.0,
    height: 20.0,
    padding: const EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: Colors.grey.withOpacity(0.6)),
  );
}

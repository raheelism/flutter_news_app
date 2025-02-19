import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/ConnectivityCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/NewsByIdCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/themeCubit.dart';
import 'package:news/ui/screens/CategoryScreen.dart';
import 'package:news/ui/screens/HomePage/HomePage.dart';
import 'package:news/ui/screens/Profile/ProfileScreen.dart';
import 'package:news/ui/screens/RSSFeedScreen.dart';
import 'package:news/ui/screens/VideoScreen.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';

GlobalKey<HomeScreenState>? homeScreenKey;
bool? isNotificationReceivedInbg;
String? notificationNewsId;
String? saleNotification;

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  DashBoardState createState() => DashBoardState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const DashBoard());
  }
}

class DashBoardState extends State<DashBoard> {
  List<Widget> fragments = [];
  DateTime? currentBackPressTime;
  int _selectedIndex = 0;
  List<IconData> iconList = [];
  List<String> itemName = [];
  bool shouldPopScope = false;

  @override
  void initState() {
    homeScreenKey = GlobalKey<HomeScreenState>();
    iconList = [
      Icons.home_rounded,
      Icons.video_collection_rounded,
      //Add only if Category Mode is enabled From Admin panel.
      if (context.read<AppConfigurationCubit>().getCategoryMode() == "1") Icons.grid_view_rounded,
      // Icons.notifications_rounded,
      Icons.rss_feed_rounded,
      Icons.settings_rounded
    ];
    itemName = ['homeLbl', 'videosLbl', 'categoryLbl', 'rssFeed', 'profile'];
    fragments = [
      HomeScreen(key: homeScreenKey),
      const VideoScreen(),
      //Add only if Category Mode is enabled From Admin panel.
      if (context.read<AppConfigurationCubit>().getCategoryMode() == "1") const CategoryScreen(),
      // const NotificationScreen(),
      RSSFeedScreen(),
      const ProfileScreen(),
    ];
    initDynamicLinks();
    checkForPengingNotifications();
    checkMaintenanceMode();
    super.initState();
  }

  void checkMaintenanceMode() {
    if (context.read<AppConfigurationCubit>().getMaintenanceMode() == "1") {
      //app is in maintenance mode - no function should be performed
      Navigator.of(context).pushReplacementNamed(Routes.maintenance);
    }
  }

  void checkForPengingNotifications() async {
    if (isNotificationReceivedInbg != null && notificationNewsId != null && notificationNewsId != "0" && isNotificationReceivedInbg!) {
      context.read<NewsByIdCubit>().getNewsById(newsId: notificationNewsId!, langId: context.read<AppLocalizationCubit>().state.id).then((value) {
        if (value.isNotEmpty) {
          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
        }
      });
    }
  }

  //when dynamic link shared, open in app using this function
  void initDynamicLinks() async {
    // when app is open or in background then this method will be called
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final Uri deepLink = dynamicLink.link;
      if (deepLink.queryParameters.isNotEmpty) {
        String id = deepLink.queryParameters['id']!;
        String isVideoID = deepLink.queryParameters['isVideoId']!;
        String newsLangId = deepLink.queryParameters['langId']!;
        String isBreakingNews = deepLink.queryParameters['isBreakingNews']!;
        //to use it in Firebase payload in same file
        if (isBreakingNews == "true") {
          context.read<BreakingNewsCubit>().getBreakingNews(langId: newsLangId).then((value) {
            if (value.isNotEmpty) {
              for (int i = 0; i < value.length; i++) {
                if (value[i].id == id) {
                  UiUtils.rootNavigatorKey.currentState!.pushNamed(Routes.newsDetails, arguments: {"breakModel": value[i], "isFromBreak": true, "fromShowMore": false});
                }
              }
            }
          });
        } else {
          context.read<NewsByIdCubit>().getNewsById(newsId: id, langId: newsLangId).then((value) {
            if (value.isNotEmpty) {
              if (isVideoID == 'true') {
                UiUtils.rootNavigatorKey.currentState!.pushNamed(Routes.newsVideo, arguments: {"model": value[0], "from": 1});
              } else {
                UiUtils.rootNavigatorKey.currentState!.pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
              }
            }
          });
        }
      }
    }, onError: (e) async {
      debugPrint(e.toString());
    });

    // when your App Is Killed Or Open From Play store then this method will be called
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      final Uri deepLink = data.link;
      if (Platform.isAndroid) {
        if (deepLink.queryParameters.isNotEmpty) {
          String id = deepLink.queryParameters['id']!;
          String isVideoID = deepLink.queryParameters['isVideoId']!;
          String newsLangId = deepLink.queryParameters['langId']!;
          String isBreakingNews = deepLink.queryParameters['isBreakingNews']!;
          if (isBreakingNews == "true") {
            context.read<BreakingNewsCubit>().getBreakingNews(langId: newsLangId).then((value) {
              if (value.isNotEmpty) {
                for (int i = 0; i < value.length; i++) {
                  if (value[i].id == id) {
                    Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": value[i], "isFromBreak": true, "fromShowMore": false});
                  }
                }
              }
            });
          } else {
            context.read<NewsByIdCubit>().getNewsById(newsId: id, langId: newsLangId).then((value) {
              if (value.isNotEmpty) {
                if (isVideoID == 'true') {
                  Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"model": value[0], "from": 1});
                } else {
                  Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
                }
              }
            });
          }
        }
      }
    }
  }

  onWillPop(bool isTrue) {
    DateTime now = DateTime.now();
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        shouldPopScope = false;
      });
    } else if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      showSnackBar(UiUtils.getTranslatedLabel(context, 'exitWR'), context);
      setState(() => shouldPopScope = false);
    }
    setState(() => shouldPopScope = true);
  }

  Widget buildNavBarItem(IconData icon, String itemName, int index) {
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width / iconList.length,
        decoration: index == _selectedIndex ? BoxDecoration(border: Border(top: BorderSide(width: 3, color: Theme.of(context).primaryColor))) : null,
        child: Column(
          children: [
            SizedBox(height: 3),
            Icon(icon, color: index == _selectedIndex ? Theme.of(context).primaryColor : UiUtils.getColorScheme(context).outline),
            SizedBox(height: 2.5),
            CustomTextLabel(text: itemName, softWrap: true, textStyle: TextStyle(fontSize: 12))
          ],
        ),
      ),
    );
  }

  bottomBar() {
    List<Widget> navBarItemList = [];
    for (var i = 0; i < iconList.length; i++) {
      navBarItemList.add(buildNavBarItem(iconList[i], itemName[i], i));
    }

    return Container(
        padding: (Platform.isIOS) ? EdgeInsets.only(bottom: 25) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: UiUtils.getColorScheme(context).secondary,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          boxShadow: [BoxShadow(blurRadius: 6, offset: const Offset(5.0, 5.0), color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.4), spreadRadius: 0)],
        ),
        child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)), child: Row(children: navBarItemList)));
  }

  @override
  Widget build(BuildContext context) {
    UiUtils.setUIOverlayStyle(appTheme: context.read<ThemeCubit>().state.appTheme); //set UiOverlayStyle according to selected theme
    return PopScope(
      canPop: shouldPopScope,
      onPopInvoked: onWillPop,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Future.delayed(Duration.zero, () {
              context.read<BookmarkCubit>().getBookmark(langId: context.read<AppLocalizationCubit>().state.id);
              context.read<LikeAndDisLikeCubit>().getLike(langId: context.read<AppLocalizationCubit>().state.id);
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            bottomNavigationBar: bottomBar(),
            body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, connectivityStatus) {
                if (connectivityStatus is ConnectivityDisconnected) {
                  return ErrorContainerWidget(errorMsg: UiUtils.getTranslatedLabel(context, 'internetmsg'), onRetry: () {});
                } else {
                  return IndexedStack(index: _selectedIndex, children: fragments);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

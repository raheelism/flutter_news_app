import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/videosCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/ui/widgets/videoItem.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/uiUtils.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  VideoScreenState createState() => VideoScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const VideoScreen());
  }
}

class VideoScreenState extends State<VideoScreen> {
  late final PageController _videoScrollController = PageController()..addListener(hasMoreVideoScrollListener);

  int currentIndex = 0;
  int totalItems = 0;

  void getVideos() {
    Future.delayed(Duration.zero, () {
      context.read<VideoCubit>().getVideo(
          langId: context.read<AppLocalizationCubit>().state.id,
          latitude: SettingsLocalDataRepository().getLocationCityValues().first,
          longitude: SettingsLocalDataRepository().getLocationCityValues().last);
    });
  }

  @override
  void initState() {
    getVideos();
    super.initState();
  }

  @override
  void dispose() {
    _videoScrollController.dispose();
    super.dispose();
  }

  void hasMoreVideoScrollListener() {
    final newIndex = _videoScrollController.page?.round() ?? 0;
    if (currentIndex != newIndex) {
      setState(() {
        currentIndex = newIndex;
      });

      if (currentIndex == totalItems - 1) {
        if (context.read<VideoCubit>().hasMoreVideo()) {
          context.read<VideoCubit>().getMoreVideo(
              langId: context.read<AppLocalizationCubit>().state.id,
              latitude: SettingsLocalDataRepository().getLocationCityValues().first,
              longitude: SettingsLocalDataRepository().getLocationCityValues().last);
        } else {
          debugPrint("No more videos");
        }
      }
    }
  }

  Widget _buildVideos() {
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, state) {
        if (state is VideoFetchSuccess) {
          totalItems = state.video.length;
          return RefreshIndicator(
              onRefresh: () async {
                getVideos();
              },
              child: PageView.builder(
                  controller: _videoScrollController,
                  scrollDirection: Axis.vertical,
                  physics: PageScrollPhysics(),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    return _buildVideoContainer(
                        video: state.video[index], hasMore: state.hasMore, hasMoreVideoFetchError: state.hasMoreFetchError, index: index, totalCurrentVideo: state.video.length);
                  }));
        }
        if (state is VideoFetchFailure) {
          return ErrorContainerWidget(
              errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getVideos);
        }
        return SizedBox.shrink();
      },
    );
  }

  _buildVideoContainer({required NewsModel video, required int index, required int totalCurrentVideo, required bool hasMoreVideoFetchError, required bool hasMore}) {
    if (index == totalCurrentVideo - 1 && index != 0) {
      if (hasMore) {
        if (hasMoreVideoFetchError) {
          return Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: IconButton(
                    onPressed: () {
                      context.read<VideoCubit>().getMoreVideo(
                          langId: context.read<AppLocalizationCubit>().state.id,
                          latitude: SettingsLocalDataRepository().getLocationCityValues().first,
                          longitude: SettingsLocalDataRepository().getLocationCityValues().last);
                    },
                    icon: Icon(Icons.error, color: Theme.of(context).primaryColor))),
          );
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }

    return VideoItem(model: video);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: setCustomAppBar(height: 44, isBackBtn: false, label: 'videosLbl', context: context, isConvertText: true), body: _buildVideos());
  }
}

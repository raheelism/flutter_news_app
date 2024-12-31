import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/createDynamicLink.dart';
import 'package:news/ui/widgets/loginRequired.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/videoPlayContainer.dart';

class VideoItem extends StatefulWidget {
  final NewsModel model;

  const VideoItem({super.key, required this.model});

  @override
  VideoItemState createState() => VideoItemState();
}

class VideoItemState extends State<VideoItem> {
  String formattedDescription = "";
  bool playVideo = false;

  @override
  void initState() {
    super.initState();
  }

  void dispose() async {
    playVideo = false;

    super.dispose();
  }

  void checkAndSetDescription({required String descr}) {
    bool skip = false;
    formattedDescription = "";
    if (descr.isNotEmpty)
      for (int i = 0; i < (descr.length); i++) {
        if (descr[i] == "<") {
          skip = true;
        } else if (descr[i] == ">") {
          skip = false;
        } else {
          if (!skip) {
            formattedDescription += descr[i];
          }
        }
      }
  }

  Widget videoData(NewsModel video) {
    checkAndSetDescription(descr: video.desc!);
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          ClipRRect(
            child: GestureDetector(
              onTap: () {
                playVideo = !playVideo;
                setState(() {});
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, darkSecondaryColor]).createShader(bounds);
                    },
                    blendMode: BlendMode.darken,
                    child: (playVideo)
                        ? SizedBox(
                            width: double.maxFinite,
                            height: (Platform.isIOS) ? MediaQuery.of(context).size.height / 1.29 : MediaQuery.of(context).size.height / 1.22,
                            child: VideoPlayContainer(contentType: video.contentType!, contentValue: video.contentValue!))
                        : CustomNetworkImage(
                            networkImageUrl: (video.contentType == 'video_youtube' && video.contentValue!.isNotEmpty)
                                ? 'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(video.contentValue!)!}/0.jpg'
                                : video.image!,
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                            height: (Platform.isIOS) ? MediaQuery.of(context).size.height / 1.29 : MediaQuery.of(context).size.height / 1.22,
                            isVideo: true),
                  ),
                  CircleAvatar(radius: 30, backgroundColor: Colors.black45, child: Icon((playVideo) ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white)),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      bottom: 25.0,
                      start: 0,
                      height: MediaQuery.of(context).size.height / 8.4,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: CustomTextLabel(
                                    text: video.title!,
                                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomTextLabel(
                                  text: formattedDescription.trim(), textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: secondaryColor), maxLines: 3, overflow: TextOverflow.ellipsis),
                            )
                          ],
                        ),
                      )),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 10.0,
                    end: 10.0,
                    height: MediaQuery.of(context).size.height / 6,
                    width: MediaQuery.of(context).size.width / 8,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Column(
                        children: [
                          likeButton(),
                          const SizedBox(height: 15),
                          BlocProvider(
                            create: (context) => UpdateBookmarkStatusCubit(BookmarkRepository()),
                            child: BlocBuilder<BookmarkCubit, BookmarkState>(
                                bloc: context.read<BookmarkCubit>(),
                                builder: (context, bookmarkState) {
                                  bool isBookmark = context.read<BookmarkCubit>().isNewsBookmark(video.id!);
                                  return BlocConsumer<UpdateBookmarkStatusCubit, UpdateBookmarkStatusState>(
                                      bloc: context.read<UpdateBookmarkStatusCubit>(),
                                      listener: ((context, state) {
                                        if (state is UpdateBookmarkStatusSuccess) {
                                          (state.wasBookmarkNewsProcess) ? context.read<BookmarkCubit>().addBookmarkNews(state.news) : context.read<BookmarkCubit>().removeBookmarkNews(state.news);
                                          setState(() {});
                                        }
                                      }),
                                      builder: (context, state) {
                                        return InkWell(
                                            onTap: () {
                                              if (context.read<AuthCubit>().getUserId() != "0") {
                                                if (state is UpdateBookmarkStatusInProgress) return;
                                                context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(news: video, status: (isBookmark) ? "0" : "1");
                                              } else {
                                                loginRequired(context);
                                              }
                                            },
                                            child: state is UpdateBookmarkStatusInProgress
                                                ? SizedBox(height: 15, width: 15, child: showCircularProgress(true, Theme.of(context).primaryColor))
                                                : Icon(isBookmark ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined, color: secondaryColor));
                                      });
                                }),
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                              onTap: () async {
                                (await InternetConnectivity.isNetworkAvailable())
                                    ? createDynamicLink(context: context, id: video.id!, title: video.title!, isVideoId: true, isBreakingNews: false, image: video.image!)
                                    : showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                              },
                              splashColor: Colors.transparent,
                              child: const Icon(Icons.share_rounded, color: secondaryColor))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.model.contentValue!.isNotEmpty) ? videoData(widget.model) : const SizedBox.shrink();
  }

  Widget likeButton() {
    bool isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model.newsId!);

    return BlocProvider(
        create: (context) => UpdateLikeAndDisLikeStatusCubit(LikeAndDisLikeRepository()),
        child: BlocConsumer<LikeAndDisLikeCubit, LikeAndDisLikeState>(
            bloc: context.read<LikeAndDisLikeCubit>(),
            listener: ((context, state) {
              if (state is LikeAndDisLikeFetchSuccess) {
                isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model.newsId!);
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateLikeAndDisLikeStatusCubit, UpdateLikeAndDisLikeStatusState>(
                  bloc: context.read<UpdateLikeAndDisLikeStatusCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateLikeAndDisLikeStatusSuccess) {
                      context.read<LikeAndDisLikeCubit>().getLike(langId: context.read<AppLocalizationCubit>().state.id);
                    }
                  }),
                  builder: (context, state) {
                    return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (context.read<AuthCubit>().getUserId() != "0") {
                            if (state is UpdateLikeAndDisLikeStatusInProgress) {
                              return;
                            }
                            context.read<UpdateLikeAndDisLikeStatusCubit>().setLikeAndDisLikeNews(news: widget.model, status: (isLike) ? "0" : "1");
                          } else {
                            loginRequired(context);
                          }
                        },
                        child: (state is UpdateLikeAndDisLikeStatusInProgress)
                            ? SizedBox(height: 15, width: 15, child: showCircularProgress(true, Theme.of(context).primaryColor))
                            : ((isLike) ? const Icon(Icons.thumb_up_alt, size: 25, color: secondaryColor) : const Icon(Icons.thumb_up_off_alt, size: 25, color: secondaryColor)));
                  });
            }));
  }
}

import 'package:codeway_stories/utils/media_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class StoryModel {
  String url;
  VideoPlayerController? videoController;
  bool isInitialized = false;
  StoryModel({
    required this.url,
  });
  MediaType get mediaType => url.mediaType;
  // duration is 5 secs if not specified
  Duration get duration {
    switch (url.mediaType) {
      case MediaType.mp4:
      return videoController!.value.duration;
      default:
      return Duration(seconds: 5);
    }
  }
  // initialization is necessarry only for videos
  Future<void> initVideo() async {
    if(url.mediaType == MediaType.mp4){
      if (!isInitialized){
        videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await videoController?.initialize().then((value) async => await videoController?.play());
        isInitialized = true;
      }
    }
  }

  Future<void> resetAndPlayVideo () async {
    await videoController?.seekTo(Duration.zero).then((value) async => await videoController?.play());
  }
}
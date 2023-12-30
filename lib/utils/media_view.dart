// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:codeway_stories/models/story_model.dart';
import 'package:codeway_stories/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatelessWidget {
  double? width;
  double? height;
  StoryModel storyModel;

  MediaView({
    required this.storyModel,
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
      switch (storyModel.mediaType) {
        case MediaType.img:
          return CachedNetworkImage(
            width: width,
            height: height,
            imageUrl: storyModel.url,
            placeholder: (context, url) => placeHolder(),
            errorWidget: (context, url, error) => Center(
                child: Text(
                  error.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              )
          );
        case MediaType.mp4:
          return Container(
            width: width,
            height: height,
            child: FutureBuilder(
              future: storyModel.initVideo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                return placeHolder();
                return VideoPlayer(storyModel.videoController!);
              })
          );
        default:
          return Container();
      }
  }

  Container placeHolder() {
    return Container(
            child: LinearProgressIndicator(
              color: Colors.grey.shade200,
              backgroundColor: Colors.grey.shade100,
            ),
          );
  }
}

extension MediaTypeExtension on String {
  MediaType get mediaType {
    // network media which ends with mp4
    if ((this.startsWith("http") || this.startsWith("https")) && this.endsWith("mp4")) {
      return MediaType.mp4;
    }
    // network media which doesn't end with mp4, most likely an image
    if ((this.startsWith("http") || this.startsWith("https")) && !this.endsWith("mp4")) {
      return MediaType.img;
    }
    return MediaType.unknown;
  }
}

enum MediaType { img, mp4, unknown }

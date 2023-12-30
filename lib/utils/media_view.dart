// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatelessWidget {
  String? url;
  double? width;
  double? height;
  VideoPlayerController? videoController;

  MediaView({
    this.url,
    this.videoController,
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      switch (url!.mediaType) {
        case MediaType.img:
          return CachedNetworkImage(
            width: width,
            height: height,
            imageUrl: url!,
            placeholder: (context, url) => Container(
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
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
            child: VideoPlayer(videoController!)
          );
        default:
          return Container();
      }
    }
    return Container();
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

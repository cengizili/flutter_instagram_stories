import 'dart:math';

import 'package:codeway_stories/utils/media_view.dart';
import 'package:codeway_stories/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.read<GroupProvider>();
    return Scaffold(
      body: GestureDetector(
        onLongPress: () async {
          // pause the timer and videoController
          storyProvider.isPaused = true;
          await storyProvider.poppedStory.videoController?.pause();
        },
        onLongPressCancel: () async {
          // pause the timer and videoController
          storyProvider.isPaused = false;
          await storyProvider.poppedStory.videoController?.play();
        },
        // screen is divided into 3 sections, middle tap means nothing
        onTapUp: (details) async {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double screenWidth = box.size.width;
            final double tapPositionX = details.localPosition.dx;
            if (tapPositionX < screenWidth / 3) {
              await storyProvider.tapLeft();
            } else if (tapPositionX > screenWidth / 3) {
              await storyProvider.tapRight();
            }
          },
        onHorizontalDragEnd: (details) async {
            if (details.velocity.pixelsPerSecond.dx > 0) {
              await storyProvider.swipeRight();
            } else if (details.velocity.pixelsPerSecond.dx < 0) {
              await storyProvider.swipeLeft();
            }
          },
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MediaView(
                  height: MediaQuery.of(context).size.height*0.8,
                  width: MediaQuery.of(context).size.width*0.8,
                  url: context.watch<GroupProvider>().poppedStory.url,
                  videoController: context.watch<GroupProvider>().poppedStory.videoController,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: durationIndicator(context),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: textIndicator(context),
                ),
              ],
            ),
          ),
        ),
        ),
      );
  }

  Widget durationIndicator(BuildContext context) {
    final storyProvider = context.watch<GroupProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        storyProvider.poppedGroup.$2.storyList.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            width: MediaQuery.of(context).size.width*0.8 / (storyProvider.poppedGroup.$2.storyList.length+1),
            child: LinearProgressIndicator(
              value: index == storyProvider.poppedGroup.$2.currentStoryIndex ?
              context.watch<GroupProvider>().progress : 
              index < storyProvider.poppedGroup.$2.currentStoryIndex ? 
              1 : 0,
              ),
          ),
        )),
    );
  }
  
  Row textIndicator(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Group "+
          (context.watch<GroupProvider>().poppedGroup.$1+1).toString()+
          "/"+
          context.watch<GroupProvider>().groupList.length.toString()),
          SizedBox(width: 10,),
          Text("Story "+
            (context.watch<GroupProvider>().poppedGroup.$2.currentStoryIndex+1).toString()+
            "/"+
            context.watch<GroupProvider>().poppedGroup.$2.storyList.length.toString()),
        ],
      );
  }
}
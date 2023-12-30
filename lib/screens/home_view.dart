import 'dart:math';

import 'package:codeway_stories/models/group_model.dart';
import 'package:codeway_stories/models/story_model.dart';
import 'package:codeway_stories/utils/media_view.dart';
import 'package:codeway_stories/providers/group_provider.dart';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.read<GroupProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          // consume only when current story changes
          child: Selector<GroupProvider, StoryModel>(
            selector: (p0, p1) => p1.poppedStory,
            builder: (context, value, child) => CubePageView(
                controller: storyProvider.swipeController,
                children: storyProvider.groupList.map<Widget>((e) {
                final indicatorWidth = MediaQuery.of(context).size.width*0.8 / (e.storyList.length+1.2);
                  return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onLongPress: ()  async {
                        // pause the timer and videoController
                        storyProvider.isPaused = true;
                        await storyProvider.poppedStory.videoController?.pause();
                      },
                      onLongPressEnd: (_)  async {
                        // resume the timer and videoController
                        storyProvider.isPaused = false;
                        await storyProvider.poppedStory.videoController?.play();
                      },
                      onTapUp: (details) async {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final double screenWidth = box.size.width;
                          final double tapPositionX = details.localPosition.dx;
                          if (tapPositionX < screenWidth / 2) {
                            await storyProvider.onTapLeft();
                          } else {
                            await storyProvider.onTapRight();
                          }
                        },
                      child: MediaView(
                        width: MediaQuery.of(context).size.width*0.8,
                        height: MediaQuery.of(context).size.height*0.8,
                        storyModel: e.poppedStory,
                        ),
                      ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: durationIndicator(context, e, indicatorWidth),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: textIndicator(context),
                    ),
                    ],
                  );
                }
                ).toList(),
                // update current group if there is a page transition
                onPageChanged: (value)  async {
                  if (value < storyProvider.poppedGroupIndex)
                    await storyProvider.onSwipeRight();
                  if (value > storyProvider.poppedGroupIndex)
                    await storyProvider.onSwipeLeft();
                },
              ),
          ),
        ),
      ),
      );
  }

  Widget durationIndicator(BuildContext context, GroupModel group, double indicatorWidth) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            group.storyList.length,
            (index) => Padding(
              padding:  EdgeInsets.symmetric(horizontal: indicatorWidth/(2*(group.storyList.length))),
              child: Container(
                width: indicatorWidth,
                // isolate changes in progress
                child: Selector<GroupProvider, double>(
                  selector: (p0, p1) => p1.progress,
                  builder:(context, progress, child) => LinearProgressIndicator(
                    value: index == group.currentStoryIndex ?
                    progress : 
                    index < group.currentStoryIndex ? 
                    1 : 0,
                    ),
                ),
              ),
            )),
        );
  }
  
  Widget textIndicator(BuildContext context) {
    final storyProvider = context.read<GroupProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Group "+
        (storyProvider.poppedGroup.$1+1).toString()+
        "/"+
        storyProvider.groupList.length.toString()),
        SizedBox(width: 10,),
        Text("Story "+
          (storyProvider.poppedGroup.$2.currentStoryIndex+1).toString()+
          "/"+
          storyProvider.poppedGroup.$2.storyList.length.toString()),
      ],
    );
  }
}
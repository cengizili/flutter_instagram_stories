import 'dart:async';

import 'package:codeway_stories/utils/media_view.dart';
import 'package:codeway_stories/models/group_model.dart';
import 'package:codeway_stories/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GroupProvider extends ChangeNotifier {
  List<GroupModel> groupList;
  PageController swipeController = PageController();
  Timer? timer;
  bool isPaused = false;
  double progress = 0.0;
  final double updateInterval = 0.1;

  // pop first group in the list
  GroupProvider({this.groupList=const []}){
    groupList.first.isPopped = true;
    resetTimer();
    notifyListeners();
  }

  (int, GroupModel) get poppedGroup => groupList.indexed.firstWhere((element) => element.$2.isPopped==true);
  int get poppedGroupIndex => poppedGroup.$1;
  StoryModel get poppedStory => poppedGroup.$2.poppedStory;

  // as soon as a group is popped, all the other groups should be marked as isPopped=false
  set poppedGroup((int, GroupModel) newGroup) {
    groupList.indexed.forEach((element) {
      if (element.$1==newGroup.$1)
      element.$2.isPopped = true;
      else
      element.$2.isPopped = false;
    });
    notifyListeners();
  }

  // runs after each transition, progress == 1 should trigger tapRight event
  void resetTimer({Duration dur = const Duration(seconds: 5)}) {
    timer?.cancel();
    progress = 0;
    final duration = Duration(milliseconds: dur.inMilliseconds.toInt() ?? 0);
    timer = Timer.periodic(Duration(milliseconds: (updateInterval * 1000).toInt()), (timer) async {
      if(!isPaused)
      progress = (progress + updateInterval / (dur.inSeconds ?? 1))
          .clamp(0.0, 1.0); 
      if (progress >= 1.0) {
        progress = 0;
        timer.cancel();
        await onTapRight();
      }
      notifyListeners();
    });
  }

  // swiping right means passing to the next group
  // current story should be stopped and next one should be played if both are videos
  Future<void> onSwipeRight() async {
    await poppedStory.videoController?.pause();
    if (poppedGroup.$1 > 0){
      poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1-1);
      await poppedStory.resetAndPlayVideo();
    }
    resetTimer();
    notifyListeners();
  }

  // swiping left means going back to the previous group.
  // current story should be stopped and next one should be played if both are videos
  Future<void> onSwipeLeft() async {
    await poppedStory.videoController?.pause();
    if (poppedGroup.$1 < groupList.length-1){
      poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1+1);
      await poppedStory.resetAndPlayVideo();
    }
    resetTimer();
    notifyListeners();
  }

  // decrement currentStoryIndex, if this is the first story of the group, pass to the previous group if it exists
  // current story should be stopped and next one should be played if both are videos
  Future<void> onTapLeft() async {
    await poppedStory.videoController?.pause();
    if (!poppedGroup.$2.tapLeft() && poppedGroup.$1 > 0){
      swipeController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.linear);
      poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1-1);
    }
    await poppedStory.resetAndPlayVideo();
    resetTimer();
    notifyListeners();
  }

  // increment currentStoryIndex, if this is the last story of the group, pass to the next group if it exists
  // current story should be stopped and next one should be played if both are videos
  Future<void> onTapRight() async {
    await poppedStory.videoController?.pause();
    if (!poppedGroup.$2.tapRight() && poppedGroup.$1 < groupList.length-1){
      swipeController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.linear);
      poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1+1);
    }
    await poppedStory.resetAndPlayVideo();
    resetTimer();
    notifyListeners();
  }
}
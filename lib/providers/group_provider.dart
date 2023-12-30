import 'dart:async';

import 'package:codeway_stories/utils/media_view.dart';
import 'package:codeway_stories/models/group_model.dart';
import 'package:codeway_stories/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GroupProvider extends ChangeNotifier {
  List<GroupModel> groupList;
  late Timer timer;
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
  Future<void> resetTimer() async {
    await poppedStory.init();
    progress = 0;
    final duration = Duration(milliseconds: poppedStory.duration.inMilliseconds.toInt() ?? 0);
    timer = Timer.periodic(Duration(milliseconds: (updateInterval * 1000).toInt()), (timer) {
      if(!isPaused)
      progress = (progress + updateInterval / (poppedStory.duration.inSeconds ?? 1))
          .clamp(0.0, 1.0); 
      if (progress >= 1.0) {
        progress = 0;
        timer.cancel();
        tapRight();
      }
      notifyListeners();
    });
  }

  // swiping right means passing to the next group
  Future<void> swipeRight() async {
    if (poppedGroup.$1 > 0)
    poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1-1);
    timer.cancel();
    await resetTimer();
    notifyListeners();
  }

  // swiping left means going back to the previous group
  Future<void> swipeLeft() async {
    if (poppedGroup.$1 < groupList.length-1)
    poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1+1);
    timer.cancel();
    await resetTimer();
    notifyListeners();
  }

  // decrement currentStoryIndex, if this is the first story of the group, pass to the previous group if it exists
  Future<void> tapLeft() async {
    if (!poppedGroup.$2.tapLeft() && poppedGroup.$1 > 0)
    poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1-1);
    timer.cancel();
    await resetTimer();
    notifyListeners();
  }

  // increment currentStoryIndex, if this is the last story of the group, pass to the next group if it exists
  Future<void> tapRight() async {
    if (!poppedGroup.$2.tapRight() && poppedGroup.$1 < groupList.length-1)
    poppedGroup = groupList.indexed.firstWhere((element) => element.$1 == poppedGroup.$1+1);
    timer.cancel();
    await resetTimer();
    notifyListeners();
  }
}
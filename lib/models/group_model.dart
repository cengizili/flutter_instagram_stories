import 'dart:async';

import 'package:codeway_stories/models/story_model.dart';
import 'package:flutter/material.dart';


class GroupModel {
  
  List<StoryModel> storyList;
  int currentStoryIndex;
  bool isPopped;
  GroupModel({this.storyList=const [], this.isPopped = false, this.currentStoryIndex=0});

  StoryModel get poppedStory => storyList[currentStoryIndex]; 

  // tapping right means incrementing currentStoryIndex
  bool tapRight() {
    if (currentStoryIndex < storyList.length - 1) {
      currentStoryIndex += 1;
      return true;
    }
    return false;
  }

  // tapping left means decrementing currentStoryIndex
  bool tapLeft() {
    if (currentStoryIndex > 0) {
      currentStoryIndex -= 1;
      return true;
    }
    return false;
  }

}
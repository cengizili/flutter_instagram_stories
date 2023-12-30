import 'dart:math';

import 'package:codeway_stories/utils/media_view.dart';
import 'package:codeway_stories/models/group_model.dart';
import 'package:codeway_stories/models/story_model.dart';

// random number of groups with random number of stories with random images and videos
final randomGroupList = List<GroupModel>.generate(Random().nextInt(8)+3, (index) => GroupModel(
  storyList: List<StoryModel>.generate(Random().nextInt(8)+3, (index) => StoryModel(
    url: Random().nextBool() == true ? "https://picsum.photos/1080/1920?random=${Random().nextInt(1000)}" : 
    "https://flutter.github.io/assets-for-api-docs/assets/videos/${Random().nextBool() ? "bee" : "butterfly"}.mp4"
    ))
));
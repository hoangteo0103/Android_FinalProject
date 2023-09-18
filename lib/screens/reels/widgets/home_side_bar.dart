import 'dart:math';

import 'package:antap/data/data.dart';
import 'package:flutter/material.dart';

import 'package:antap/models/video_post.dart';

import '../../posts/components/post_comment_widget.dart';

class HomeSideBar extends StatefulWidget {
  const HomeSideBar({super.key, required this.video});

  final VideoPost video;

  @override
  State<HomeSideBar> createState() => _HomeSideBarState();
}

class _HomeSideBarState extends State<HomeSideBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late bool isFavourite = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(fontSize: 13, color: Colors.white);

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _profileImageButton(currentUser!.profileImageUrl),
          _favoriteItem(Icons.favorite, widget.video.favorite, style),
          _commentItem(
              Icons.comment, widget.video.getListComment().length, style),
          // _sideBarItem(Icons.share, 'Share', style),
          AnimatedBuilder(
            animation: _animationController,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  child: Icon(
                    Icons.circle,
                    color: Color.fromARGB(255, 45, 43, 43),
                    size: 55,
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundImage:
                      NetworkImage(currentUser!.profileImageUrl),
                ),
              ],
            ),
            builder: (context, child) {
              return Transform.rotate(
                angle: 2 * pi * _animationController.value,
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }

  _commentItem(IconData iconData, int label, TextStyle style) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            iconData,
            color: Colors.white.withOpacity(0.9),
            size: 40,
          ),
          onPressed: () {
            setState(() {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PostCommentWidget(post: widget.video);
                },
              );
            });
          },
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '$label',
          style: style,
        ),
      ],
    );
  }

  _favoriteItem(IconData iconData, int label, TextStyle style) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            iconData,
            color: isFavourite
                ? Color.fromARGB(255, 255, 4, 0)
                : Colors.white.withOpacity(0.9),
            size: 40,
          ),
          onPressed: () {
            setState(() {
              isFavourite = !isFavourite;
              if (isFavourite)
                widget.video.favorite++;
              else
                widget.video.favorite--;
            });
          },
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '$label',
          style: style,
        ),
      ],
    );
  }

  _profileImageButton(String imageUrl) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(imageUrl),
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                color: Colors.white,
                Icons.add,
                size: 20,
              )),
        ),
      ],
    );
  }
}

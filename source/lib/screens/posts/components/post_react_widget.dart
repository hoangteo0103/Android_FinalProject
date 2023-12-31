import 'package:antap/models/image_post.dart';
import 'package:antap/screens/posts/components/post_comment_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/post.dart';

class PostReactWidget extends StatefulWidget {
  final Post post;
  int isReact = 0;
  PostReactWidget({required this.post, super.key});

  @override
  State<PostReactWidget> createState() => _PostReactWidgetState();
}

class _PostReactWidgetState extends State<PostReactWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                  (widget.isReact == 0)
                      ? Icons.favorite_border
                      : Icons.favorite,
                  color: Colors.black,
                  size: 30),
              onPressed: () {
                setState(() {
                  widget.isReact = 1 - widget.isReact;
                  if (widget.isReact == 1)
                    widget.post.updateFavorite(1);
                  else
                    widget.post.updateFavorite(-1);
                });
              },
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Colors.black, size: 30),
              onPressed: () {
                setState(() {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PostCommentWidget(post: widget.post);
                    },
                  );
                });
              },
            )
          ],
        ),
        Text("Có ${widget.post.getFavorite()} lượt thích",
            style: const TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600))
      ],
    );
  }
}

import 'package:antap/models/image_post.dart';
import 'package:antap/screens/posts/components/post_image_widget.dart';
import 'package:antap/screens/posts/components/post_info_widget.dart';
import 'package:antap/screens/posts/components/post_react_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../models/post.dart';

String getSubContent(String text, int lim) {
  if (text.length <= lim) {
    return text;
  } else {
    return "${text.substring(0, lim)}...";
  }
}

Future<List<ImagePost>> getImagePosts() async {
  List<ImagePost> imagePosts = [];
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('imagePosts').get();

  querySnapshot.docs.forEach((doc) {
    ImagePost imagePost = ImagePost.fromFirestore(doc, null);
    imagePosts.add(imagePost);
  });

  return imagePosts;
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  static String id = "post_screen";

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<ImagePost>>(
          future: getImagePosts(), // Gọi hàm để lấy dữ liệu
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Hiển thị khi đang tải dữ liệu
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<ImagePost> imagePosts = snapshot.data ?? [];
              return ListView(children: [
                Column(
                  children: List.generate(imagePosts.length, (index) {
                    return Container(
                      color: Colors.black87,
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PostInfoWidget(post: imagePosts[index]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    imagePosts[index].review.title,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    imagePosts[index].review.content,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  )
                                ]),
                          ),
                          PostImageWidget(post: imagePosts[index]),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: PostReactWidget(post: imagePosts[index]))
                        ],
                      ),
                    );
                  }),
                )
              ]);
            }
          }
        )
      )
    );
  }
}

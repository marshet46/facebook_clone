import 'package:facebook/provider/commentProvider.dart';
import 'package:facebook/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:facebook/models/models.dart';


class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}
class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Call the method to fetch comments when the page loads
    Provider.of<CommentProvider>(context, listen: false).fetchComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CommentProvider>(
              builder: (context, commentProvider, _) {
                if (commentProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (commentProvider.comments.isEmpty) {
                  return Center(
                    child: Text('No comments yet.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: commentProvider.comments.length,
                    itemBuilder: (context, index) {
                      return
                      Row(
      children: [
        ProfileAvatar(
            imageUrl: "https://cvs.abyssiniasoftware.com" + commentProvider.comments[index].user.profileImage),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commentProvider.comments[index].user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${commentProvider.comments[index].createdAt.substring(0, 10)} • ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                 
                ],
              ),
              SizedBox(height: 2,),
                Row(
                children: [
                  Text(
                    '${commentProvider.comments[index].text} • ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                 
                ],
              ),
            ],
          ),
        ),
       
      ],
    );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    String commentText = _commentController.text;
                    if (commentText.isNotEmpty) {
                      await _postComment(commentText);
                      _commentController.clear();
                    }
                  },
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://cvs.abyssiniasoftware.com/api/comments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'PostId': widget.postId,
          'commentText': text,
          'UserId':1
        }),
      );

      if (response.statusCode == 201) {
        // Comment posted successfully
        // Refresh comments list
        Provider.of<CommentProvider>(context, listen: false).fetchComments(widget.postId);
      } else {
        print('Failed to post comment: ${response.statusCode}');
      }
    } catch (error) {
      print('Error posting comment: $error');
    }
  }
}

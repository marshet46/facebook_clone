import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/provider/postProvider.dart';
import 'package:facebook/screens/commentScreen.dart';
import 'package:flutter/material.dart';
import 'package:facebook/config/palette.dart';
import 'package:facebook/models/models.dart';
import 'package:facebook/widgets/widgets.dart';
import 'package:http/http.dart' as http;

class PostContainer extends StatelessWidget {
  final Post1 post;

  const PostContainer({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: isDesktop ? 5.0 : 0.0,
      ),
      elevation: isDesktop ? 1.0 : 0.0,
      shape: isDesktop
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PostHeader(post: post),
                  const SizedBox(height: 4.0),
                  Text(post.caption),
                  post.imageUrl.isNotEmpty
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 6.0),
                ],
              ),
            ),
            post.imageUrl.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CachedNetworkImage(
                        imageUrl: "https://cvs.abyssiniasoftware.com" +
                            post.imageUrl!),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _PostStats(post: post),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Post1 post;

  const _PostHeader({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
            imageUrl: "https://cvs.abyssiniasoftware.com" + post.userImageUrl),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${post.timeAgo} • ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  Icon(
                    Icons.public,
                    color: Colors.grey[600],
                    size: 12.0,
                  )
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => print('More'),
        ),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final Post1 post;

  const _PostStats({
    Key? key,
    required this.post,
  }) : super(key: key);

  Future<void> sendLike(String postId) async {
    print(postId);
    final userId = "1"; // Replace with actual user ID
    final url = 'https://cvs.abyssiniasoftware.com/api/like/$userId/$postId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 201) {
        print('Like sent successfully');
      } else {
        print('Failed to send like: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending like: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Palette.facebookBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 10.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                '${post.likes ?? 0}', // Use null-aware operator and provide a default value
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            Text(
              '${post.comments ?? 0} Comments', // Use null-aware operator and provide a default value
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '${post.shares} Shares', // Use null-aware operator and provide a default value
              style: TextStyle(
                color: Colors.grey[600],
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          children: [
            _PostButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.grey[600],
                size: 20.0,
              ),
              label: 'Like',
              onTap: () async {
                await sendLike(post.id.toString() );
              },
            ),
            _PostButton(
              icon: Icon(
                Icons.comment,
                color: Colors.grey[600],
                size: 20.0,
              ),
              label: 'Comment',
               onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(postId: post.id),
                  ),
                );
              },
            ),
            
          ],
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback onTap;

  const _PostButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 4.0),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

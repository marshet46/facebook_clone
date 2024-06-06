import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:facebook/models/models.dart';

class Post1 {
  final int id; // Change type to int and make it non-nullable
  final String userName;
  final String userImageUrl;
  final String caption;
  final String timeAgo;
  final String imageUrl;
  final int likes;
  final int comments;
  final int shares;

  Post1({
    required this.id, // Update constructor to require non-nullable id
    required this.userName,
    required this.userImageUrl,
    required this.caption,
    required this.timeAgo,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  factory Post1.fromJson(Map<String, dynamic> json) {
    return Post1(
      id: json['id'], // No need for null check or default value here
      userName: json['user']['name'] ?? "",
      userImageUrl: json['user']['imageUrl'],
      caption: json['caption'] ?? "",
      timeAgo: json['timeAgo'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      likes: json['likes'] ?? 0, // Provide default value if necessary
      comments: json['comments'] ?? 0, // Provide default value if necessary
      shares: json['shares'] ?? 0, // Provide default value if necessary
    );
  }
}

class PostProvider extends ChangeNotifier {
  List<Post1> _posts = [];
  List<Post1> get posts => _posts;

  Future<void> fetchPosts() async {
    final url = 'https://cvs.abyssiniasoftware.com/api/all-posts';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _posts = responseData.map((post) => Post1.fromJson(post)).toList();
        print(_posts);
        print("success");
      } else {
        print("error");
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      throw error;
    }
    notifyListeners();
  }
}

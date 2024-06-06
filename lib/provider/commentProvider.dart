import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

class Comment {
  final int id;
  final int postId;
  final String text;
  final String createdAt;
  final User user; // Include User object

  Comment({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['PostId'],
      text: json['commentText'],
      createdAt: json['createdAt'],
      user: User.fromJson(json['User']), // Parse user data
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String age;
  final String profileImage;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
Future<void> fetchComments(int postId) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse('https://cvs.abyssiniasoftware.com/api/comments/$postId'),
    );

    print('Fetch comments response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic>? responseData = jsonDecode(response.body);
      if (responseData != null) {
        _comments = responseData.map((data) => Comment.fromJson(data)).toList();
        print("called");
      } else {
        print('Response data is null.');
      }
    } else {
      print('Failed to fetch comments: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching comments: $error');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}

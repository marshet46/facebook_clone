import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';

class CreatePostProvider extends ChangeNotifier {
  Future<void> createPost(String text, File image) async {
    try {
      // Display loading indicator
      notifyListeners();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://cvs.abyssiniasoftware.com/api/posts'),
      );
      request.fields['text'] = text;
      request.fields['userId'] = '1'; // Use the correct userId as needed

      var stream = http.ByteStream(image.openRead().cast());
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: basename(image.path));

      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 201) {
        // Post created successfully
        print('Post created successfully');
      } else {
        // Handle failure
        print('Failed to create post: ${response.statusCode}');
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      print('Error creating post: $error');
      throw Exception('Error creating post: $error');
    } finally {
      // Hide loading indicator
      notifyListeners();
    }
  }
}

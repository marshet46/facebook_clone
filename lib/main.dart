import 'package:facebook/provider/CreatePostProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your providers
import 'package:facebook/provider/commentProvider.dart';
import 'package:facebook/provider/postProvider.dart';

// Import your screens
import 'package:facebook/screens/nav_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CommentProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => CreatePostProvider()),
      ],
      child: MaterialApp(
        title: 'Facebook',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: NavScreen(),
      ),
    );
  }
}

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post1> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final url = 'https://cvs.abyssiniasoftware.com/api/all-posts';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _posts = responseData.map((post) => Post1.fromJson(post)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _posts.isEmpty
              ? Center(
                  child: Text('No posts available'),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (ctx, index) {
                    final Post1 post = _posts[index];
                    return ListTile(
                      title: Text(post.userName),
                      subtitle: Text(post.caption),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(post.userImageUrl),
                      ),
                      trailing: Text(post.timeAgo),
                    );
                  },
                ),
    );
  }
}


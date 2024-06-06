import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/provider/postProvider.dart';
import 'package:flutter/material.dart';
import 'package:facebook/config/palette.dart';
import 'package:facebook/data/data.dart';
import 'package:facebook/models/models.dart';
import 'package:facebook/widgets/widgets.dart';
import 'package:http/http.dart' as http;

class Stories extends StatelessWidget {
  final User currentUser;
  final List<Story> stories;
  const Stories({
    Key? key,
    required this.currentUser,
    required this.stories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: 1 + stories.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _StoryCard(
                key: UniqueKey(), // Ensure unique key
                isAddStory: true,
                currentUser: currentUser,
              ),
            );
          }
          final Story story = stories[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _StoryCard(
              key: UniqueKey(), // Ensure unique key
              story: story,
            ),
          );
        },
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final bool isAddStory;
  final User? currentUser;
  final Story? story;

  const _StoryCard({
    Key? key,
    this.isAddStory = false,
    this.currentUser,
    this.story,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: CachedNetworkImage(
            imageUrl: isAddStory ? currentUser!.imageUrl : story!.imageUrl,
            height: double.infinity,
            width: 110.0,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: double.infinity,
          width: 110.0,
          decoration: BoxDecoration(
            gradient: Palette.storyGradient,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
        ),
        Positioned(
          top: 8.0,
          left: 8.0,
          child: isAddStory
              ? Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add),
                    iconSize: 30.0,
                    color: Palette.facebookBlue,
                    onPressed: () => print('Add to Story'),
                  ),
                )
              : ProfileAvatar(
                  imageUrl: story!.user.imageUrl,
                  hasBorder: !story!.isViewed,
                ),
        ),
        Positioned(
          bottom: 8.0,
          left: 8.0,
          right: 8.0,
          child: Text(
            isAddStory ? 'Add to Story' : story!.user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrackingScrollController _trackingScrollController =
      TrackingScrollController();

  @override
  void dispose() {
    _trackingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Responsive(
          mobile:
              _HomeScreenMobile(scrollController: _trackingScrollController),
          desktop:
              _HomeScreenMobile(scrollController: _trackingScrollController),
        ),
      ),
    );
  }
}

class _HomeScreenMobile extends StatefulWidget {
  final TrackingScrollController scrollController;

  const _HomeScreenMobile({
    required this.scrollController,
  });

  @override
  _HomeScreenMobileState createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<_HomeScreenMobile> {
  
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
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Ethiobook',
            style: const TextStyle(
              color: Color.fromARGB(255, 28, 183, 17),
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
            ),
          ),
          centerTitle: false,
          floating: true,
          actions: [
            CircleButton(
              icon: Icons.search,
              iconSize: 30.0,
              onPressed: () => print('Search'),
            ),
            CircleButton(
              icon: Icons.message,
              iconSize: 30.0,
              onPressed: () => print('Messenger'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: CreatePostContainer(currentUser: currentUser),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
          sliver: SliverToBoxAdapter(
            child: Rooms(onlineUsers: onlineUsers),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          sliver: SliverToBoxAdapter(
            child: Stories(
              currentUser: currentUser,
              stories: stories,
            ),
          ),
        ),
        _isLoading
          ? SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _posts.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Text('No posts available'),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Post1 post = _posts[index];
                      return PostContainer(post: post);
                    },
                    childCount: _posts.length,
                  ),
                ),
      ],
    );
  }
}

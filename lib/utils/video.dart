import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HowToUsePage extends StatefulWidget {
  @override
  _HowToUsePageState createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage> {
  late Future<Map<String, String>> _videoLinks;

  Future<Map<String, String>> _fetchVideoLinks() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('video').doc('videos').get();
      final data = doc.data() as Map<String, dynamic>?;
      return {
        'video1': data?['video1'] ?? '',
        'video2': data?['video2'] ?? '',
        'video3': data?['video3'] ?? '',
      };
    } catch (e) {
      print('Error fetching video links: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _videoLinks = _fetchVideoLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to allow gradient
        toolbarHeight: 70,
        elevation: 0, // Remove shadow if not needed
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 185, 41), // Yellow at the top
                Colors.white, // White at the bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                const SizedBox(width: 45),
                ClipRRect(
                  child: Image.asset("asset/onshopnewcurvedlogo.png", width: 50),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'On Shop',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _videoLinks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error loading videos'));
          }

          final videoLinks = snapshot.data!;
          return ListView(
            children: [
              if (videoLinks['video1']?.isNotEmpty == true)
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: YoutubePlayer.convertUrlToId(videoLinks['video1']!)!,
                    flags: YoutubePlayerFlags(
                      autoPlay: false, // Video starts paused
                      mute: false,
                      controlsVisibleAtStart: true, // Show controls from the start
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
              if (videoLinks['video2']?.isNotEmpty == true)
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: YoutubePlayer.convertUrlToId(videoLinks['video2']!)!,
                    flags: YoutubePlayerFlags(
                      autoPlay: false, // Video starts paused
                      mute: false,
                      controlsVisibleAtStart: true, // Show controls from the start
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
              if (videoLinks['video3']?.isNotEmpty == true)
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: YoutubePlayer.convertUrlToId(videoLinks['video3']!)!,
                    flags: YoutubePlayerFlags(
                      autoPlay: false, // Video starts paused
                      mute: false,
                      controlsVisibleAtStart: true, // Show controls from the start
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
            ],
          );
        },
      ),
    );
  }
}
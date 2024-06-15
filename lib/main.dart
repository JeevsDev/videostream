// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  void _navigateToVideoPlayerScreen(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  void _handleDownloadAndShowFile(String url) {
    if (url.isNotEmpty) {
      _navigateToVideoPlayerScreen(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Video Downloader', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 200, color: Colors.white),
              Card(
                color: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        cursorColor: Colors.yellowAccent[400],
                        style: TextStyle(color: Colors.yellowAccent[400]),
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'Enter video URL',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_urlController.text.isNotEmpty) {
                            _handleDownloadAndShowFile(_urlController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellowAccent[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Download and Play', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('OR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.yellowAccent[400])),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleDownloadAndShowFile(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(250, 50),
                ),
                child: Text('Download and Play Sample'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = true;
  String? _downloadError;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      }).catchError((error) {
        print('Video initialization error: $error');
        setState(() {
          _downloadError = 'Video initialization failed. Please check the URL.';
        });
      });

    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _localFilePath = '${directory.path}/video.mp4';
      print('Downloading video to: $_localFilePath');

      final dio = Dio();
      await dio.download(
        widget.videoUrl,
        _localFilePath!,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
              print('Download progress: $_downloadProgress');
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        print('Download completed.');
      });

      _controller = VideoPlayerController.file(File(_localFilePath!))
        ..initialize().then((_) {
          setState(() {});
          if (_isPlaying) {
            _controller.play();
          }
        }).catchError((error) {
          print('Video initialization error: $error');
          setState(() {
            _downloadError = 'Video initialization failed. Please check the URL.';
          });
        });
    } catch (e) {
      print('Download error: $e');
      setState(() {
        _downloadError = 'Download failed. Please check the URL and your internet connection.';
        _isDownloading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        automaticallyImplyLeading: false,
        title: Text('Video Found!', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.grey[800],
              elevation: 4.0,
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Requested Video File:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent[400],
                      ),
                    ),
                    SizedBox(height: 10),
                    _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : _downloadError != null
                            ? Text(_downloadError!, style: TextStyle(color: Colors.red))
                            : CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.grey[800],
              elevation: 4.0,
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _isDownloading
                        ? LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        : Text('Download Complete', style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      'Download Progress: ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.yellowAccent[400],
              onPressed: () {
                if (_controller.value.isInitialized) {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      _isPlaying = false;
                    } else {
                      _controller.play();
                      _isPlaying = true;
                    }
                  });
                }
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 50),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

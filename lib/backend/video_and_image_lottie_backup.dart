// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:lottie/lottie.dart';
//
// class VideoOrImageBackground extends StatefulWidget {
//   final String path;
//   final Widget? child;
//   final bool playVideo;
//
//   const VideoOrImageBackground({
//     super.key,
//     required this.path,
//     this.playVideo = true,
//     this.child,
//   });
//
//   @override
//   State<VideoOrImageBackground> createState() => _VideoOrImageBackgroundState();
// }
//
// class _VideoOrImageBackgroundState extends State<VideoOrImageBackground> {
//   VideoPlayerController? _videoController;
//
//   final Set<String> videoExtensions = {'mp4', 'mkv', 'mov', 'webm', 'avi'};
//   final Set<String> imageExtensions = {'png', 'jpg', 'jpeg', 'webp', 'gif'};
//   final Set<String> lottieExtensions = {'json', 'lottie'};
//
//   @override
//   void initState() {
//     super.initState();
//     _initController();
//   }
//
//   @override
//   void didUpdateWidget(VideoOrImageBackground oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.path != widget.path) {
//       _videoController?.dispose();
//       _videoController = null;
//       _initController();
//     }
//   }
//
//   void _initController() {
//     final extension = widget.path.split('.').last.split('?').first.toLowerCase();
//     if (videoExtensions.contains(extension) && widget.playVideo && !widget.path.startsWith('http')) {
//       _videoController = VideoPlayerController.asset(widget.path)
//         ..initialize().then((_) {
//           if (mounted) {
//             setState(() {});
//             _videoController!.setLooping(true);
//             _videoController!.play();
//           }
//         });
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isNetwork = widget.path.startsWith('http');
//     final extension = widget.path.split('.').last.split('?').first.toLowerCase();
//
//     Widget background;
//
//     if (_videoController != null && _videoController!.value.isInitialized) {
//       background = FittedBox(
//         fit: BoxFit.cover,
//         child: SizedBox(
//           width: _videoController!.value.size.width,
//           height: _videoController!.value.size.height,
//           child: VideoPlayer(_videoController!),
//         ),
//       );
//     } else if (isNetwork) {
//       if (lottieExtensions.contains(extension)) {
//         background = Lottie.network(
//           widget.path,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
//         );
//       } else {
//         background = Image.network(
//           widget.path,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
//         );
//       }
//     } else if (lottieExtensions.contains(extension)) {
//       background = Lottie.asset(
//         widget.path,
//         fit: BoxFit.cover,
//       );
//     } else if (imageExtensions.contains(extension)) {
//       background = Image.asset(
//         widget.path,
//         fit: BoxFit.cover,
//       );
//     } else {
//       background = _buildErrorWidget();
//     }
//
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         background,
//         if (widget.child != null) widget.child!,
//       ],
//     );
//   }
//
//   Widget _buildErrorWidget() {
//     return Container(
//       color: Colors.grey[900],
//       alignment: Alignment.center,
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, color: Colors.white54, size: 40),
//           SizedBox(height: 8),
//           Text("Failed to load asset", style: TextStyle(color: Colors.white54)),
//         ],
//       ),
//     );
//   }
// }

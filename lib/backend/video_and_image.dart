import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoOrImageBackground extends StatefulWidget {
  final String path;
  final Widget? child;
  final bool isActive; // Adicione esta linha

  const VideoOrImageBackground({
    super.key,
    required this.path,
    this.child,
    this.isActive = true, // Padrão como true para não quebrar outros lugares
  });

  @override
  State<VideoOrImageBackground> createState() => _VideoOrImageBackgroundState();
}

class _VideoOrImageBackgroundState extends State<VideoOrImageBackground> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(VideoOrImageBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o caminho mudou OU se a tela acabou de ficar ativa (isActive mudou de false para true)
    if (oldWidget.path != widget.path || (widget.isActive && !oldWidget.isActive)) {
      _disposeController();
      _initController();
    }
  }

  void _disposeController() {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
  }

  void _initController() {
    final extension = widget.path.split('.').last.toLowerCase();
    if (extension == 'mp4') {
      _videoController = VideoPlayerController.asset(widget.path)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _videoController!.setLooping(true);
            _videoController!.setVolume(0); // Silencioso para backgrounds
            _videoController!.play();
          }
        }).catchError((error) {
          debugPrint("Erro ao inicializar vídeo: $error");
        });
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extension = widget.path.split('.').last.toLowerCase();
    Widget background;

    if (_isInitialized && _videoController != null) {
      background = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    } else {
      // Fallback para PNG enquanto o vídeo carrega ou se o path for imagem
      final displayPath = extension == 'mp4' 
          ? widget.path.replaceAll('.mp4', '.png') 
          : widget.path;

      background = Image.asset(
        displayPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

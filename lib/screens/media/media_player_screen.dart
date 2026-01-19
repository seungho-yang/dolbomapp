import 'package:flutter/material.dart';
import '../../models/media_model.dart';

class MediaPlayerScreen extends StatefulWidget {
  final MediaModel media;
  final Color categoryColor;
  final String categoryName;

  const MediaPlayerScreen({
    super.key,
    required this.media,
    required this.categoryColor,
    this.categoryName = '미디어',
  });

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: widget.categoryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 제목
              Text(
                widget.media.title ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // 플레이어 컨트롤 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 재생 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlaying = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('재생 중...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isPlaying ? Colors.green : Colors.grey,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: _isPlaying ? Colors.green : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),

                  // 중지 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlaying = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('중지'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: !_isPlaying ? Colors.red : Colors.grey,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.stop,
                        size: 50,
                        color: !_isPlaying ? Colors.red : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // 미디어 정보
              if (widget.media.path != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        '경로',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.media.path!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // 준비 중 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '미디어 플레이어 기능은 준비 중입니다.\n실제 재생 기능은 추후 구현될 예정입니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:deca_mobile/schedule/data/models/session_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// youtube_player_iframe (webview_flutter) chi ho tro Android/iOS/macOS/Web
/// — KHONG co ban Windows/Linux desktop. Nhung platform, du chay tren may
/// dev Windows, phai bo qua nhung player va chi con nut mo ngoai, khong thi
/// se trang/loi im lang (day la nguyen nhan pho bien nhat khi "video khong
/// chay" tren may dev chay Windows desktop thay vi Chrome/Android).
bool _videoEmbedSupportedOnThisPlatform() {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

/// 1 video bai giang: nhung player YouTube, co nut "Mo tren YouTube" du phong
/// (SPEC_VideoBaiGiang_Zoom.md §1 quyet dinh #6).
class YoutubePlayerTile extends StatefulWidget {
  const YoutubePlayerTile({required this.video, super.key});

  final SessionVideoItem video;

  @override
  State<YoutubePlayerTile> createState() => _YoutubePlayerTileState();
}

class _YoutubePlayerTileState extends State<YoutubePlayerTile> {
  YoutubePlayerController? _controller;
  bool _embedFailed = false;

  @override
  void initState() {
    super.initState();
    if (!_videoEmbedSupportedOnThisPlatform()) {
      _embedFailed = true;
      return;
    }
    final videoId = YoutubePlayerController.convertUrlToId(
      widget.video.youtubeUrl,
    );
    if (videoId == null || videoId.isEmpty) {
      _embedFailed = true;
      return;
    }
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.video.youtubeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.video.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          if (_embedFailed || _controller == null) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Mở trên YouTube'),
              onPressed: _openExternally,
            ),
            if (!_videoEmbedSupportedOnThisPlatform()) ...[
              const SizedBox(height: 4),
              Text(
                'Nền tảng này chưa hỗ trợ xem trực tiếp trong app — mở bằng trình duyệt/app YouTube.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ]
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: _controller!),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:deca_mobile/schedule/data/models/session_content.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 1 link Zoom cua buoi: nut "Tham gia" noi bat trong khung gio buoi hoc.
/// Xem SPEC_VideoBaiGiang_Zoom.md §5.1.
class ZoomLinkTile extends StatelessWidget {
  const ZoomLinkTile({
    required this.link,
    this.isWithinSessionWindow = false,
    super.key,
  });

  final ZoomLinkItem link;

  /// true = dang trong khung gio buoi hoc (vd tu truoc gio bat dau 15').
  final bool isWithinSessionWindow;

  Future<void> _join(BuildContext context) async {
    final uri = Uri.tryParse(link.zoomUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (link.meetingId != null && link.meetingId!.isNotEmpty)
                  Text(
                    'ID: ${link.meetingId}'
                    '${link.passcode != null && link.passcode!.isNotEmpty ? ' · Passcode: ${link.passcode}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isWithinSessionWindow
              ? FilledButton.icon(
                  icon: const Icon(Icons.videocam),
                  label: const Text('Tham gia'),
                  onPressed: () => _join(context),
                )
              : OutlinedButton.icon(
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Tham gia'),
                  onPressed: () => _join(context),
                ),
        ],
      ),
    );
  }
}

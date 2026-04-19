import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../models/confession.dart';

class ConfessionShareSheet extends StatefulWidget {
  final Confession confession;
  const ConfessionShareSheet({super.key, required this.confession});

  static void show(BuildContext context, Confession confession) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConfessionShareSheet(confession: confession),
    );
  }

  @override
  State<ConfessionShareSheet> createState() => _ConfessionShareSheetState();
}

class _ConfessionShareSheetState extends State<ConfessionShareSheet> {
  bool _copied = false;

  String get _link => 'https://confessnepal.app/c/${widget.confession.id}';
  String get _shareText =>
      '"${widget.confession.content}"\n\n— ${widget.confession.anonymousName} on ConfessNepal\n$_link';
  String get _encoded => Uri.encodeComponent(_shareText);
  String get _encodedLink => Uri.encodeComponent(_link);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<SharePlatformData> items = [
      SharePlatformData(
        _copied ? 'Copied!' : 'Copy Link',
        AppColors.primary,
        _copied ? Icons.check_rounded : Icons.link_rounded,
        () async {
          await Clipboard.setData(ClipboardData(text: _link));
          if (mounted) setState(() => _copied = true);
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) setState(() => _copied = false);
        },
      ),
      SharePlatformData('WhatsApp', const Color(0xFF25D366), Icons.chat_bubble_rounded,
          () => shareTo('https://wa.me/?text=$_encoded')),
      SharePlatformData('Facebook', const Color(0xFF1877F2), Icons.facebook_rounded,
          () => shareTo('https://www.facebook.com/sharer/sharer.php?u=$_encodedLink')),
      SharePlatformData('Instagram', const Color(0xFFE1306C), Icons.camera_alt_rounded,
          () { Navigator.pop(context); Share.share(_shareText); }),
      SharePlatformData('Telegram', const Color(0xFF229ED9), Icons.send_rounded,
          () => shareTo('https://t.me/share/url?url=$_encodedLink&text=$_encoded')),
      SharePlatformData('Twitter/X', const Color(0xFF1DA1F2), Icons.alternate_email_rounded,
          () => shareTo('https://twitter.com/intent/tweet?text=$_encoded')),
      SharePlatformData('More', AppColors.textSecondary, Icons.more_horiz_rounded,
          () { Navigator.pop(context); Share.share(_shareText, subject: 'Confession on ConfessNepal'); }),
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.backgroundSecondary.withValues(alpha: 0.9) 
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          border: Border(
            top: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SHARE CONFESSION',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Share options row
            SizedBox(
              height: 94,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 22),
                itemBuilder: (context, i) => PlatformIcon(key: ValueKey(i), p: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareTo(String url) {
    Navigator.pop(context);
    Share.shareUri(Uri.parse(url));
  }
}

class SharePlatformData {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const SharePlatformData(this.label, this.color, this.icon, this.onTap);
}

class PlatformIcon extends StatelessWidget {
  final SharePlatformData p;
  const PlatformIcon({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: p.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62, 
            height: 62,
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: p.color.withValues(alpha: 0.25), 
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: p.color.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                p.icon, 
                color: p.color, 
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            p.label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

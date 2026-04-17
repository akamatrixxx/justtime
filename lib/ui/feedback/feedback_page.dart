import 'package:flutter/cupertino.dart';
import '../../data/model/feedback.dart';

class FeedbackPage extends StatefulWidget {
  final Future<void> Function(FeedbackType) onFeedbackSubmitted;
  final VoidCallback? onOpenMenu;

  const FeedbackPage({
    super.key,
    required this.onFeedbackSubmitted,
    this.onOpenMenu,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _submitting = false;

  Future<void> _submit(FeedbackType type) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onFeedbackSubmitted(type);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      navigationBar: CupertinoNavigationBar(
        border: null,
        backgroundColor: CupertinoColors.systemGroupedBackground
            .resolveFrom(context)
            .withAlpha(220),
        leading: widget.onOpenMenu == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onOpenMenu,
                child: const Icon(
                  CupertinoIcons.line_horizontal_3,
                  size: 26,
                ),
              ),
        middle: const Text(
          '今日のフィードバック',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF50C9C3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          CupertinoIcons.chat_bubble_2_fill,
                          color: CupertinoColors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '通知のタイミングは\nいかがでしたか？',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label.resolveFrom(context),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '次回の通知時刻の調整に使います',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _FeedbackChoice(
                emoji: '⏰',
                label: 'まだ早いよ',
                sub: '次はもう少し遅く',
                onPressed: _submitting
                    ? null
                    : () => _submit(FeedbackType.tooEarly),
              ),
              const SizedBox(height: 10),
              _FeedbackChoice(
                emoji: '🙏',
                label: 'ありがとう',
                sub: 'ちょうど良いタイミング',
                primary: true,
                onPressed: _submitting
                    ? null
                    : () => _submit(FeedbackType.goodTiming),
              ),
              const SizedBox(height: 10),
              _FeedbackChoice(
                emoji: '😮‍💨',
                label: 'なんでいまさら',
                sub: '次はもう少し早く',
                onPressed: _submitting
                    ? null
                    : () => _submit(FeedbackType.tooLate),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackChoice extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback? onPressed;
  final bool primary;

  const _FeedbackChoice({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = primary
        ? CupertinoColors.activeBlue
        : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final fg = primary
        ? CupertinoColors.white
        : CupertinoColors.label.resolveFrom(context);
    final subColor = primary
        ? CupertinoColors.white.withAlpha(220)
        : CupertinoColors.secondaryLabel.resolveFrom(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: subColor),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}

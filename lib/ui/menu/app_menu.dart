import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay, Colors;

typedef NotifyTimeLoader = Future<TimeOfDay?> Function();

/// 左からスライドインするメニュードロワー。
Future<void> showAppMenu(
  BuildContext context, {
  required NotifyTimeLoader loadTodayNotifyTime,
  required Future<void> Function() onOpenSettings,
  required Future<void> Function() onExportLog,
  required Future<void> Function() onTestNotification,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'menu',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim, secAnim) {
      return _AppMenuPanel(
        loadTodayNotifyTime: loadTodayNotifyTime,
        onOpenSettings: onOpenSettings,
        onExportLog: onExportLog,
        onTestNotification: onTestNotification,
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

class _AppMenuPanel extends StatefulWidget {
  final NotifyTimeLoader loadTodayNotifyTime;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onExportLog;
  final Future<void> Function() onTestNotification;

  const _AppMenuPanel({
    required this.loadTodayNotifyTime,
    required this.onOpenSettings,
    required this.onExportLog,
    required this.onTestNotification,
  });

  @override
  State<_AppMenuPanel> createState() => _AppMenuPanelState();
}

class _AppMenuPanelState extends State<_AppMenuPanel> {
  TimeOfDay? _notifyTime;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final t = await widget.loadTodayNotifyTime();
    if (!mounted) return;
    setState(() {
      _notifyTime = t;
      _loading = false;
    });
  }

  String _fmt(TimeOfDay? t) {
    if (t == null) return '未設定';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: size.width * 0.82,
        height: double.infinity,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'メニュー',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 22,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: _NotifyTimeCard(loading: _loading, text: _fmt(_notifyTime)),
              ),
              const SizedBox(height: 12),
              _MenuTile(
                icon: CupertinoIcons.clock,
                label: '時間設定を変更',
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onOpenSettings();
                },
              ),
              _MenuTile(
                icon: CupertinoIcons.arrow_down_doc,
                label: '通知ログをCSVで書き出す',
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onExportLog();
                },
              ),
              _MenuTile(
                icon: CupertinoIcons.bell_circle,
                label: '1分後にテスト通知を送る',
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onTestNotification();
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'justtime',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifyTimeCard extends StatelessWidget {
  final bool loading;
  final String text;

  const _NotifyTimeCard({required this.loading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50C9C3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.bell_fill,
            color: CupertinoColors.white,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日の通知予定',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                loading
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : Text(
                        text,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.activeBlue,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }
}

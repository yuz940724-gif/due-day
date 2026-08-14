import 'package:flutter/material.dart';

import '../../backup/local_backup.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../notifications/notification_models.dart';
import '../../state/bill_scope.dart';
import '../insights/insights_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _backupBusy = false;
  void _showTodo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final store = BillScope.of(context);
    final succeeded = await store.setNotificationsEnabled(enabled);
    if (!mounted) return;
    _showTodo(
      context,
      succeeded
          ? (enabled ? '已开启应用内提醒' : '已关闭应用内提醒，已有提醒已取消')
          : '提醒设置没有同步完成，请点击重试',
    );
  }

  Future<void> _requestPermission() async {
    await BillScope.of(context).requestNotificationPermission();
    if (!mounted) return;
    final status = BillScope.of(context).notificationPermissionStatus;
    _showTodo(context, switch (status) {
      NotificationPermissionStatus.authorized => '通知权限已允许，将按账单安排提醒',
      NotificationPermissionStatus.provisional => '已允许临时通知，将按账单安排提醒',
      NotificationPermissionStatus.denied => '通知权限已拒绝，请到 iOS 设置中允许通知',
      NotificationPermissionStatus.notDetermined => '还没有完成通知权限选择，请稍后重试',
    });
  }

  Future<void> _sendTestNotification() async {
    final succeeded = await BillScope.of(context).showTestNotification();
    if (!mounted) return;
    _showTodo(context, succeeded ? '测试提醒已发送' : '测试提醒发送失败，请检查通知权限');
  }

  Future<void> _exportBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      await BillScope.backupOf(context).exportBackup();
      if (mounted) _showTodo(context, '本地备份已准备好，可在系统分享面板中保存或发送');
    } catch (_) {
      if (mounted) _showTodo(context, '导出备份失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      final selected = await BillScope.backupOf(context).pickAndInspect();
      if (!mounted || selected == null) return;
      final s = selected.summary;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('确认恢复本地备份？'),
          content: Text(
            '导出时间：${_formatExportedAt(s.exportedAt)}\n'
            '计划 ${s.planCount} 项 · 账期 ${s.periodCount} 条 · 提醒规则 ${s.reminderRuleCount} 条\n\n'
            '恢复会完整替换当前本机账单和历史，无法撤销。备份为明文，可能包含金额和历史。',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('确认恢复')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final result = await BillScope.backupOf(context).restore(selected.file.bytes);
      if (mounted) {
        _showTodo(
          context,
          result.notificationReconcileFailed
              ? '账单已恢复，但提醒同步失败，请稍后重试'
              : '恢复成功：已替换 ${s.periodCount} 条账期，并重新同步提醒',
        );
      }
    } on LocalBackupException catch (error) {
      if (mounted) _showTodo(context, error.message);
    } catch (_) {
      if (mounted) _showTodo(context, '恢复失败，原有本机账单已保留；提醒已尝试重新同步');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  String _formatExportedAt(DateTime value) {
    final d = value.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _permissionText(NotificationPermissionStatus status) =>
      switch (status) {
        NotificationPermissionStatus.notDetermined => '系统权限尚未决定',
        NotificationPermissionStatus.authorized => '系统通知已允许',
        NotificationPermissionStatus.provisional => '系统通知已临时允许',
        NotificationPermissionStatus.denied => '系统通知已拒绝，请到 iOS 设置调整',
      };

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Text('我的', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本地体验模式',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${store.plans.length} 项账单 · 数据保存在本机',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.lock_open_rounded, color: AppColors.white),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SettingsSection(
            title: '提醒',
            children: [
              SwitchListTile.adaptive(
                value: store.notificationsEnabled,
                onChanged: _toggleNotifications,
                secondary: const _SettingIcon(
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.accent,
                ),
                title: const Text('账单提醒'),
                subtitle: Text(
                  _permissionText(store.notificationPermissionStatus),
                ),
              ),
              if (store.notificationsEnabled &&
                  store.notificationPermissionStatus ==
                      NotificationPermissionStatus.notDetermined)
                ListTile(
                  onTap: _requestPermission,
                  leading: const _SettingIcon(
                    icon: Icons.lock_open_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('允许通知'),
                  subtitle: const Text('仅在你确认后向系统申请通知权限'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                )
              else if (store.notificationsEnabled &&
                  store.notificationPermissionStatus ==
                      NotificationPermissionStatus.denied)
                ListTile(
                  onTap: () =>
                      _showTodo(context, '请打开 iOS 设置 > 通知 > 还款助手并允许通知'),
                  leading: const _SettingIcon(
                    icon: Icons.settings_outlined,
                    color: AppColors.warning,
                  ),
                  title: const Text('通知权限已拒绝'),
                  subtitle: const Text('请到 iOS 设置中允许通知；这里不会自动再次弹窗'),
                ),
              if (store.notificationsEnabled &&
                  (store.notificationPermissionStatus ==
                          NotificationPermissionStatus.authorized ||
                      store.notificationPermissionStatus ==
                          NotificationPermissionStatus.provisional))
                ListTile(
                  onTap: _sendTestNotification,
                  leading: const _SettingIcon(
                    icon: Icons.send_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('发送测试提醒'),
                  subtitle: const Text('确认当前设备可以接收本地通知'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              _SettingsDivider(),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsSection(
            title: '数据',
            children: [
              ListTile(
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                ),
                leading: const _SettingIcon(
                  icon: Icons.insights_outlined,
                  color: Color(0xFF765E91),
                ),
                title: const Text('统计与趋势'),
                subtitle: Text('${formatMonth(store.today)}账单概览'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                ),
              ),
              _SettingsDivider(),
              ListTile(
                onTap: () =>
                    _showTodo(context, 'TODO：接入 RuoYi app-api 后启用云端同步'),
                leading: const _SettingIcon(
                  icon: Icons.cloud_outlined,
                  color: Color(0xFF5369A6),
                ),
                title: const Text('云端同步'),
                subtitle: const Text('当前使用本地 SQLite，云端同步待接入'),
                trailing: const Text(
                  '待接入',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
              ),
              _SettingsDivider(),
              ListTile(
                onTap: _backupBusy ? null : _exportBackup,
                leading: const _SettingIcon(
                  icon: Icons.ios_share_outlined,
                  color: Color(0xFF4E7B74),
                ),
                title: const Text('导出本地备份'),
                subtitle: const Text('明文 JSON，包含账单金额和历史'),
                trailing: _backupBusy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
              ),
              _SettingsDivider(),
              ListTile(
                onTap: _backupBusy ? null : _restoreBackup,
                leading: const _SettingIcon(icon: Icons.restore_outlined, color: Color(0xFF4E7B74)),
                title: const Text('恢复本地备份'),
                subtitle: const Text('选择 JSON，确认后完整替换本机账单'),
                trailing: _backupBusy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsSection(
            title: '关于',
            children: [
              ListTile(
                onTap: () => _showTodo(context, '个人账单还款助手 · Flutter iOS 原型'),
                leading: const _SettingIcon(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.inkMuted,
                ),
                title: const Text('关于还款助手'),
                subtitle: const Text('版本 0.1.0 · 前端交互原型'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '当前未启用登录和真实 API。账单与提醒设置保存在本机，不会自动上传数据。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1),
    );
  }
}

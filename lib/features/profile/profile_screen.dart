import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../state/bill_scope.dart';
import '../insights/insights_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _defaultReminderHour = 9;

  void _showTodo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDefaultTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _defaultReminderHour, minute: 0),
      helpText: '默认提醒时间',
      confirmText: '确定',
      cancelText: '取消',
    );
    if (selected != null && mounted) {
      setState(() => _defaultReminderHour = selected.hour);
    }
  }

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
                        '${store.plans.length} 项账单 · 登录功能暂未接入',
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
                onChanged: (value) {
                  store.setNotificationsEnabled(value);
                  _showTodo(context, value ? '已开启界面状态，iOS 通知权限接口待接入' : '已关闭提醒');
                },
                secondary: const _SettingIcon(
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.accent,
                ),
                title: const Text('账单提醒'),
                subtitle: const Text('本地通知接口待接入'),
              ),
              _SettingsDivider(),
              ListTile(
                onTap: _pickDefaultTime,
                leading: const _SettingIcon(
                  icon: Icons.schedule_outlined,
                  color: AppColors.warning,
                ),
                title: const Text('默认提醒时间'),
                subtitle: const Text('新账单会优先使用这个时间'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_defaultReminderHour.toString().padLeft(2, '0')}:00',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.inkMuted),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
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
                subtitle: Text('${formatMonth(DateTime.now())}账单概览'),
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
                subtitle: const Text('当前数据只在本次运行中有效'),
                trailing: const Text(
                  '待接入',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
              ),
              _SettingsDivider(),
              ListTile(
                onTap: () => _showTodo(context, 'TODO：实现 CSV / JSON 数据导出'),
                leading: const _SettingIcon(
                  icon: Icons.ios_share_outlined,
                  color: Color(0xFF4E7B74),
                ),
                title: const Text('导出账单'),
                subtitle: const Text('保存个人账单备份'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                ),
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
            '当前未启用登录、真实 API 和通知插件。所有对应入口均保留 TODO，不会上传任何数据。',
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

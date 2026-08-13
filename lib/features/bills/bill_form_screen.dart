import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/bill_plan.dart';
import '../../shared/widgets/bill_visuals.dart';
import '../../state/bill_scope.dart';

class BillFormScreen extends StatefulWidget {
  const BillFormScreen({this.plan, super.key});

  final BillPlan? plan;

  @override
  State<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends State<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _institutionController;
  late final TextEditingController _suffixController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late BillCategory _category;
  late BillingCycle _cycle;
  late DateTime _dueDate;
  late Set<int> _reminderDays;
  late int _reminderHour;
  late bool _amountUnknown;
  late bool _autoDebit;
  bool _saving = false;

  bool get _editing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _titleController = TextEditingController(text: plan?.title ?? '');
    _institutionController = TextEditingController(
      text: plan?.institution ?? '',
    );
    _suffixController = TextEditingController(text: plan?.accountSuffix ?? '');
    _amountController = TextEditingController(
      text: plan?.amountInCents == null
          ? ''
          : formatCurrency(
              plan!.amountInCents,
              withSymbol: false,
            ).replaceAll(',', ''),
    );
    _noteController = TextEditingController(text: plan?.note ?? '');
    _category = plan?.category ?? BillCategory.creditCard;
    _cycle = plan?.cycle ?? BillingCycle.monthly;
    _dueDate = plan?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _reminderDays = {...?plan?.reminderDays};
    if (_reminderDays.isEmpty) _reminderDays = {3, 1};
    _reminderHour = plan?.reminderHour ?? 9;
    _amountUnknown = plan?.amountPending ?? false;
    _autoDebit = plan?.isAutoDebit ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _institutionController.dispose();
    _suffixController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    final parts = normalized.split('.');
    if (parts.length > 2 || parts.first.isEmpty) return null;
    final yuan = int.tryParse(parts.first);
    if (yuan == null) return null;
    var cents = 0;
    if (parts.length == 2) {
      if (parts[1].length > 2 || int.tryParse(parts[1]) == null) return null;
      cents = int.parse(parts[1].padRight(2, '0'));
    }
    return yuan * 100 + cents;
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 20),
      helpText: '选择下一次到期日',
      confirmText: '确定',
      cancelText: '取消',
    );
    if (selected != null && mounted) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: 0),
      helpText: '选择提醒时间',
      confirmText: '确定',
      cancelText: '取消',
    );
    if (selected != null && mounted) {
      setState(() => _reminderHour = selected.hour);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderDays.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请至少选择一个提醒时间')));
      return;
    }

    final amount = _amountUnknown ? null : _parseAmount(_amountController.text);
    if (!_amountUnknown && amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入正确的金额，最多保留两位小数')));
      return;
    }

    setState(() => _saving = true);
    final draft = BillDraft(
      title: _titleController.text.trim(),
      category: _category,
      institution: _institutionController.text.trim(),
      accountSuffix: _suffixController.text.trim(),
      amountInCents: amount,
      cycle: _cycle,
      dueDate: _dueDate,
      reminderDays: _reminderDays.toList()..sort((a, b) => b.compareTo(a)),
      reminderHour: _reminderHour,
      isAutoDebit: _autoDebit,
      note: _noteController.text.trim(),
      currentInstallment: widget.plan?.currentInstallment,
      totalInstallments: widget.plan?.totalInstallments,
    );
    final store = BillScope.of(context);
    final result = _editing
        ? await store.update(widget.plan!.id, draft)
        : await store.create(draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result != null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? '编辑账单' : '新增账单'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
          tooltip: '关闭',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
          children: [
            Text('账单类型', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final category in BillCategory.values)
                  ChoiceChip(
                    avatar: Icon(
                      iconForCategory(category),
                      size: 18,
                      color: _category == category
                          ? AppColors.white
                          : colorForCategory(category),
                    ),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                    showCheckmark: false,
                    selectedColor: AppColors.ink,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.divider),
                    labelStyle: TextStyle(
                      color: _category == category
                          ? AppColors.white
                          : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text('基本信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '账单名称',
                hintText: '例如：招商银行信用卡',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '请输入账单名称' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _institutionController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '机构（选填）',
                      hintText: '银行或服务商',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _suffixController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: '尾号',
                      hintText: '1234',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              enabled: !_amountUnknown,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '每期金额',
                prefixText: '¥ ',
                hintText: '0.00',
              ),
            ),
            CheckboxListTile(
              value: _amountUnknown,
              onChanged: (value) =>
                  setState(() => _amountUnknown = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('金额每期确认'),
              subtitle: const Text('适合信用卡等金额不固定的账单'),
            ),
            const SizedBox(height: 18),
            Text('周期与日期', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<BillingCycle>(
              initialValue: _cycle,
              decoration: const InputDecoration(labelText: '重复周期'),
              items: [
                for (final cycle in BillingCycle.values)
                  DropdownMenuItem(value: cycle, child: Text(cycle.label)),
              ],
              onChanged: (cycle) {
                if (cycle != null) setState(() => _cycle = cycle);
              },
            ),
            const SizedBox(height: 12),
            _PickerTile(
              icon: Icons.event_outlined,
              label: '下一次到期日',
              value: '${formatDate(_dueDate)} · ${formatWeekday(_dueDate)}',
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _autoDebit,
              onChanged: (value) => setState(() => _autoDebit = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('自动扣款'),
              subtitle: const Text('仍会提醒你检查余额和扣款结果'),
            ),
            const SizedBox(height: 18),
            Text('提醒设置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '选择到期前提醒的天数',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              children: [
                for (final days in const [7, 3, 1, 0])
                  FilterChip(
                    label: Text(days == 0 ? '当天' : '提前 $days 天'),
                    selected: _reminderDays.contains(days),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _reminderDays.add(days);
                        } else {
                          _reminderDays.remove(days);
                        }
                      });
                    },
                    selectedColor: AppColors.accentSoft,
                    checkmarkColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.divider),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _PickerTile(
              icon: Icons.schedule_outlined,
              label: '提醒时间',
              value: '${_reminderHour.toString().padLeft(2, '0')}:00',
              onTap: _pickReminderTime,
            ),
            const SizedBox(height: 26),
            Text('备注', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '记录扣款账户或其他需要留意的事项',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Text(_editing ? '保存修改' : '保存账单'),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 3),
                    Text(value, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

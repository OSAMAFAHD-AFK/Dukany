import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../../core/utils/functions/password_generator.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../data/models/shop_model.dart';
import '../../manager/create_shop_cubit/create_shop_cubit.dart';

/// Returns the created shop, or null if cancelled.
Future<ShopModel?> showCreateShopDialog(BuildContext context) {
  return showDialog<ShopModel>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider(create: (_) => getIt<CreateShopCubit>(), child: const CreateShopDialogBody()),
  );
}

class CreateShopDialogBody extends StatefulWidget {
  const CreateShopDialogBody({super.key});

  @override
  State<CreateShopDialogBody> createState() => _CreateShopDialogBodyState();
}

class _CreateShopDialogBodyState extends State<CreateShopDialogBody> {
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController(text: generateShopPassword());
  final _notesController = TextEditingController();
  int _months = 1;

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() => context.read<CreateShopCubit>().createShop(
    shopName: _shopNameController.text,
    ownerName: _ownerNameController.text,
    phone: _phoneController.text,
    password: _passwordController.text,
    months: _months,
    notes: _notesController.text,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateShopCubit, CreateShopState>(
      listener: (context, state) {
        if (state.status == CreateShopStatus.failure) showAppSnackBar(context, state.errorMessage!, isError: true);
      },
      builder: (context, state) {
        if (state.status == CreateShopStatus.success) return _CredentialsView(state: state);
        return AlertDialog(
          title: const Text('بقالة جديدة'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: _shopNameController, label: 'اسم البقالة', hint: 'بقالة النور'),
                  const SizedBox(height: 14),
                  CustomTextField(controller: _ownerNameController, label: 'اسم صاحب البقالة'),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'رقم الجوال (اسم الدخول)',
                    hint: '777123456',
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    textDirection: TextDirection.ltr,
                    suffix: IconButton(
                      tooltip: 'توليد كلمة جديدة',
                      onPressed: () => _passwordController.text = generateShopPassword(),
                      icon: const Icon(Icons.casino_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('مدة الاشتراك', style: AppTextStyles.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final months in const [1, 3, 6, 12])
                        ChoiceChip(
                          label: Text(months == 1 ? 'شهر' : '$months أشهر'),
                          selected: _months == months,
                          labelStyle: TextStyle(color: _months == months ? Colors.white : AppColors.ink),
                          onSelected: (_) => setState(() => _months = months),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _notesController,
                    label: 'ملاحظات (اختياري)',
                    hint: 'العنوان، طريقة الدفع…',
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            TextButton(
              onPressed: state.status == CreateShopStatus.saving ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            CustomButton(
              label: 'إنشاء الحساب',
              icon: Icons.check_rounded,
              expand: false,
              height: 48,
              isLoading: state.status == CreateShopStatus.saving,
              onPressed: _submit,
            ),
          ],
        );
      },
    );
  }
}

/// Shown once after creation so the admin can hand the login to the owner.
class _CredentialsView extends StatelessWidget {
  const _CredentialsView({required this.state});

  final CreateShopState state;

  @override
  Widget build(BuildContext context) {
    final text =
        'مرحباً ${state.createdShop!.ownerName}\n'
        'تم تفعيل تطبيق دُكاني لبقالة ${state.createdShop!.name}\n'
        'رقم الدخول: ${formatPhoneForDisplay(state.loginPhone!).replaceAll(' ', '')}\n'
        'كلمة المرور: ${state.loginPassword}';
    return AlertDialog(
      title: const Text('تم إنشاء البقالة ✓'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أرسل بيانات الدخول لصاحب البقالة:', style: AppTextStyles.caption),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: SelectableText(text, style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) showAppSnackBar(context, 'تم النسخ');
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text('نسخ'),
        ),
        FilledButton(onPressed: () => Navigator.of(context).pop(state.createdShop), child: const Text('تم')),
      ],
    );
  }
}

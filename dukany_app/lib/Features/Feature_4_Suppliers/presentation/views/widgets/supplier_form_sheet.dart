import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/repos/suppliers_repo.dart';
import '../../manager/supplier_form_cubit/supplier_form_cubit.dart';

/// Opens the add / edit supplier sheet. Returns the saved supplier.
Future<SupplierModel?> showSupplierFormSheet(BuildContext context, {SupplierModel? editingSupplier}) {
  return showModalBottomSheet<SupplierModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) => SupplierFormCubit(getIt<SuppliersRepo>(), editingSupplier: editingSupplier),
      child: SupplierFormSheetBody(editingSupplier: editingSupplier),
    ),
  );
}

class SupplierFormSheetBody extends StatefulWidget {
  const SupplierFormSheetBody({super.key, this.editingSupplier});

  final SupplierModel? editingSupplier;

  @override
  State<SupplierFormSheetBody> createState() => _SupplierFormSheetBodyState();
}

class _SupplierFormSheetBodyState extends State<SupplierFormSheetBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final supplier = widget.editingSupplier;
    _nameController = TextEditingController(text: supplier?.name);
    _phoneController = TextEditingController(
      text: supplier?.hasPhone == true ? formatPhoneForDisplay(supplier!.phone!).replaceAll(' ', '') : null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SupplierFormCubit>().save(name: _nameController.text, phone: _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingSupplier != null;
    return BlocConsumer<SupplierFormCubit, SupplierFormState>(
      listener: (context, state) {
        if (state.status == SupplierFormStatus.success) {
          Navigator.of(context).pop(state.savedSupplier);
        } else if (state.status == SupplierFormStatus.failure) {
          showAppSnackBar(context, state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditing ? 'تعديل بيانات المورد' : 'مورد جديد', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              const Text('شركة الجملة أو الموزع الذي تأخذ منه البضاعة', style: AppTextStyles.caption),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                label: 'اسم المورد / الشركة',
                hint: 'مثال: شركة النقيب',
                prefixIcon: Icons.storefront_outlined,
                autofocus: !isEditing,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'رقم المندوب (اختياري)',
                hint: '777123456',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: isEditing ? 'حفظ التعديل' : 'إضافة المورد',
                icon: Icons.check_rounded,
                isLoading: state.status == SupplierFormStatus.saving,
                onPressed: _save,
              ),
            ],
          ),
        );
      },
    );
  }
}

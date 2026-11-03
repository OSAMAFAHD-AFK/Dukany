import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repos/customers_repo.dart';
import '../../manager/customer_form_cubit/customer_form_cubit.dart';

/// Opens the add / edit customer sheet. Returns the saved customer.
Future<CustomerModel?> showCustomerFormSheet(BuildContext context, {CustomerModel? editingCustomer}) {
  return showModalBottomSheet<CustomerModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) => CustomerFormCubit(getIt<CustomersRepo>(), editingCustomer: editingCustomer),
      child: CustomerFormSheetBody(editingCustomer: editingCustomer),
    ),
  );
}

class CustomerFormSheetBody extends StatefulWidget {
  const CustomerFormSheetBody({super.key, this.editingCustomer});

  final CustomerModel? editingCustomer;

  @override
  State<CustomerFormSheetBody> createState() => _CustomerFormSheetBodyState();
}

class _CustomerFormSheetBodyState extends State<CustomerFormSheetBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final customer = widget.editingCustomer;
    _nameController = TextEditingController(text: customer?.name);
    _phoneController = TextEditingController(
      text: customer?.hasPhone == true ? formatPhoneForDisplay(customer!.phone!).replaceAll(' ', '') : null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<CustomerFormCubit>().save(name: _nameController.text, phone: _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingCustomer != null;
    return BlocConsumer<CustomerFormCubit, CustomerFormState>(
      listener: (context, state) {
        if (state.status == CustomerFormStatus.success) {
          Navigator.of(context).pop(state.savedCustomer);
        } else if (state.status == CustomerFormStatus.failure) {
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
              Text(isEditing ? 'تعديل بيانات الزبون' : 'زبون جديد', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              const Text('رقم الجوال يُستخدم لإرسال الحساب عبر واتساب', style: AppTextStyles.caption),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                label: 'اسم الزبون',
                hint: 'مثال: أحمد علي',
                prefixIcon: Icons.person_outline_rounded,
                autofocus: !isEditing,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'رقم الجوال (واتساب)',
                hint: '777123456',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: isEditing ? 'حفظ التعديل' : 'إضافة الزبون',
                icon: Icons.check_rounded,
                isLoading: state.status == CustomerFormStatus.saving,
                onPressed: _save,
              ),
            ],
          ),
        );
      },
    );
  }
}

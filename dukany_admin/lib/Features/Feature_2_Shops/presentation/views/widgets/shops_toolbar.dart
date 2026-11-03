import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../data/models/shop_filter.dart';
import '../../manager/shops_cubit/shops_cubit.dart';
import 'create_shop_dialog.dart';

class ShopsToolbar extends StatelessWidget {
  const ShopsToolbar({super.key, required this.state});

  final ShopsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShopsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: cubit.search,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم البقالة أو صاحبها أو الرقم',
                  fillColor: AppColors.surface,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: 'تحديث',
              onPressed: cubit.loadShops,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 10),
            CustomButton(
              label: 'بقالة جديدة',
              icon: Icons.add_rounded,
              expand: false,
              height: 50,
              onPressed: () async {
                final created = await showCreateShopDialog(context);
                if (created != null) cubit.addCreatedShop(created);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in ShopFilter.values)
              ChoiceChip(
                label: Text('${filter.label} (${state.countOf(filter)})'),
                selected: state.filter == filter,
                labelStyle: TextStyle(color: state.filter == filter ? Colors.white : AppColors.ink),
                onSelected: (_) => cubit.changeFilter(filter),
              ),
          ],
        ),
      ],
    );
  }
}

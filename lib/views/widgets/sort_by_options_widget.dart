// lib/views/widgets/sort_by_options_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_controller.dart';
import '../utils/helper.dart' as helper;

class SortByOptionsWidget extends StatelessWidget {
  const SortByOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<HomeController>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
            child: Text(
              'Urutkan Berdasarkan',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // ============== Membuat daftar pilihan dari sortByOptions di controller ==============
          ...controller.sortByOptionsDisplay.entries.map((entry) {
            final value = entry.key;
            final displayText = entry.value;

            return Consumer<HomeController>(
                builder: (context, currentControllerState, _) {
              return RadioListTile<String>(
                title: Text(displayText, style: theme.textTheme.titleMedium),
                value: value,
                groupValue: currentControllerState.currentSortBy,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.setSortOrder(newValue);
                    Navigator.pop(context);
                  }
                },
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              );
            });
          }).toList(),
          helper.vsMedium,
        ],
      ),
    );
  }
}

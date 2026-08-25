import 'package:flutter/material.dart';

import '../../shared/widgets/number_format_settings_sheet.dart';
import '../../shared/widgets/theme_settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeSettingsSection(),
              SizedBox(height: 28),
              NumberFormatSettingsSheet(),
            ],
          ),
        ),
      ),
    );
  }
}

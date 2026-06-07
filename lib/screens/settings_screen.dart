import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.themeMode == ThemeMode.dark;
    final isAr = settings.language == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(isAr ? 'المظهر واللغة' : 'Appearance & Language', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(isAr ? 'الوضع الداكن' : 'Dark Mode'),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  value: isDark,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (value) => settings.toggleTheme(value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(isAr ? 'لغة التطبيق' : 'App Language'),
                  subtitle: Text(isAr ? 'العربية' : 'English'),
                  leading: const Icon(Icons.language),
                  onTap: () {
                    // التبديل بين اللغتين
                    settings.toggleLanguage(isAr ? 'en' : 'ar');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          Text(isAr ? 'السوق المحلي' : 'Local Market', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.public),
              title: Text(isAr ? 'الدولة الحالية' : 'Current Country'),
              subtitle: Text(settings.selectedCountry),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settings.selectedCountry,
                  items: settings.countryData.keys.map((String country) {
                    return DropdownMenuItem<String>(value: country, child: Text(country));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) settings.setCountry(newValue);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import 'stage_detail_screen.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  Map<String, List<Map<String, dynamic>>> _expensesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllExpenses());
  }

  Future<void> _loadAllExpenses() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, List<Map<String, dynamic>>> loaded = {};
    for (var stageObj in settings.currentStagesData) {
      String stageName = stageObj['name'];
      String? data = prefs.getString('exp_$stageName');
      if (data != null) {
        loaded[stageName] = List<Map<String, dynamic>>.from(jsonDecode(data));
      } else {
        loaded[stageName] = [];
      }
    }
    
    setState(() {
      _expensesMap = loaded;
      _isLoading = false;
    });
  }

  // يتم استدعاؤها تلقائياً من الصفحة الأخرى
  Future<void> _saveExpenses(String stageName, List<Map<String, dynamic>> exp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exp_$stageName', jsonEncode(exp));
    setState(() => _expensesMap[stageName] = exp);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isAr = settings.language == 'ar';
    final currency = settings.currentCountryData['currency'];
    final stagesData = settings.currentStagesData;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    double totalSpent = 0;
    int completedStagesCount = 0;

    for (var stageObj in stagesData) {
      var expensesList = _expensesMap[stageObj['name']] ?? [];
      double stageTotal = 0;
      for (var item in expensesList) {
        stageTotal += item['amount'];
        totalSpent += item['amount'];
      }
      if (stageTotal > 0) completedStagesCount++; // المرحلة منجزة إذا تم إنفاق مبلغ فيها
    }

    double remaining = settings.estimatedBudget - totalSpent;
    double progressPercent = stagesData.isEmpty ? 0 : (completedStagesCount / stagesData.length);

    return Column(
      children: [
        // 1. لوحة الميزانية (Dashboard)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBudgetInfo(isAr ? 'المنفق حتى الآن' : 'Spent So Far', totalSpent, currency, Colors.white),
                  _buildBudgetInfo(isAr ? 'المتبقي التقديري' : 'Est. Remaining', remaining, currency, remaining < 0 ? Colors.redAccent : Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAr ? 'إنجاز المشروع' : 'Project Progress', style: const TextStyle(color: Colors.white70)),
                  Text('${(progressPercent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Theme.of(context).colorScheme.secondary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        
        // 2. قائمة المراحل المخصصة للدولة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: stagesData.length,
            itemBuilder: (context, i) {
              String stageName = stagesData[i]['name'];
              List<String> defaultItems = List<String>.from(stagesData[i]['items']);
              List<Map<String, dynamic>> stageExpenses = _expensesMap[stageName] ?? [];
              
              double stageTotal = stageExpenses.fold(0, (sum, item) => sum + item['amount']);
              bool isStarted = stageTotal > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isStarted ? 2 : 0,
                color: isStarted ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isStarted ? Theme.of(context).colorScheme.secondary : Colors.grey.shade300,
                    child: Icon(isStarted ? Icons.check : Icons.construction, color: Colors.white, size: 20),
                  ),
                  title: Text(stageName, style: TextStyle(fontWeight: FontWeight.bold, decoration: isStarted ? TextDecoration.lineThrough : null)),
                  subtitle: Text('${isAr ? "التكلفة:" : "Cost:"} ${stageTotal.toStringAsFixed(0)} $currency', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.edit_document, size: 20),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => StageDetailScreen(
                          stageName: stageName,
                          defaultItems: defaultItems, // إرسال البنود المخصصة للدولة
                          savedExpenses: stageExpenses, 
                          onAutoSave: (newExpenses) => _saveExpenses(stageName, newExpenses)
                        ),
                      )
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(String title, double amount, String currency, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 5),
        Text('${amount.toStringAsFixed(0)} $currency', style: TextStyle(color: amountColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
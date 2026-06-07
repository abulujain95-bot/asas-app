import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class StageDetailScreen extends StatefulWidget {
  final String stageName;
  final List<String> defaultItems; // البنود الافتراضية المجلوبة من الإعدادات
  final List<Map<String, dynamic>> savedExpenses;
  final Function(List<Map<String, dynamic>>) onAutoSave;

  const StageDetailScreen({
    super.key, 
    required this.stageName, 
    required this.defaultItems,
    required this.savedExpenses, 
    required this.onAutoSave
  });

  @override
  State<StageDetailScreen> createState() => _StageDetailScreenState();
}

class _StageDetailScreenState extends State<StageDetailScreen> {
  late List<Map<String, dynamic>> _currentExpenses;
  
  @override
  void initState() {
    super.initState();
    // إذا لم يقم العميل بإضافة شيء سابقاً، نقوم بتحميل البنود الافتراضية للدولة بصفر
    if (widget.savedExpenses.isEmpty) {
      _currentExpenses = widget.defaultItems.map((item) => {'label': item, 'amount': 0.0}).toList();
    } else {
      _currentExpenses = List.from(widget.savedExpenses);
    }
    // حفظ مبدئي في حال تم توليد بنود جديدة
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAutoSave());
  }

  // دالة الحفظ التلقائي
  void _triggerAutoSave() {
    widget.onAutoSave(_currentExpenses);
    setState(() {}); // تحديث إجمالي التكلفة في أعلى الشاشة
  }

  // نافذة الإضافة المخصصة
  void _addCustomExpense() {
    final isAr = Provider.of<SettingsProvider>(context, listen: false).language == 'ar';
    showDialog(
      context: context,
      builder: (ctx) {
        String label = '';
        double amount = 0;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isAr ? 'إضافة مصروف جديد' : 'Add New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(
                decoration: InputDecoration(labelText: isAr ? 'نوع المصروف (مثال: وقود)' : 'Expense Type'), 
                onChanged: (v) => label = v
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(labelText: isAr ? 'المبلغ' : 'Amount'), 
                keyboardType: TextInputType.number, 
                onChanged: (v) => amount = double.tryParse(v) ?? 0
              ),
            ]
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
            ElevatedButton(
              onPressed: () {
                if (label.isNotEmpty) {
                  _currentExpenses.add({'label': label, 'amount': amount});
                  _triggerAutoSave(); // حفظ تلقائي فور الإضافة
                  Navigator.pop(ctx);
                }
              }, 
              child: Text(isAr ? 'إضافة' : 'Add')
            )
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    _currentExpenses.removeAt(index);
    _triggerAutoSave(); // حفظ تلقائي فور الحذف
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currency = settings.currentCountryData['currency'];
    final isAr = settings.language == 'ar';

    double totalStageCost = _currentExpenses.fold(0, (sum, item) => sum + item['amount']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stageName),
        // زر الإضافة في الأعلى
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _addCustomExpense,
            tooltip: isAr ? 'إضافة مصروف' : 'Add Expense',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // لوحة التكلفة العلوية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                Text(isAr ? 'إجمالي تكلفة المرحلة' : 'Stage Total Cost', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text(
                  '${totalStageCost.toStringAsFixed(0)} $currency',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _currentExpenses.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        // اسم البند
                        Expanded(
                          flex: 3,
                          child: Text(
                            _currentExpenses[i]['label'], 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        // حقل إدخال التكلفة (يتحدث ويحفظ تلقائياً)
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _currentExpenses[i]['amount'] == 0 ? '' : _currentExpenses[i]['amount'].toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0.0',
                              suffixText: currency,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (value) {
                              _currentExpenses[i]['amount'] = double.tryParse(value) ?? 0.0;
                              _triggerAutoSave(); // تحديث فوري للميزانية
                            },
                          ),
                        ),
                        // زر الحذف في الجهة اليسرى
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => _deleteExpense(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
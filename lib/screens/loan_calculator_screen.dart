import 'package:flutter/material.dart';
import 'dart:math'; // ضروري للعمليات الحسابية المعقدة للقروض
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_helper.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();

  // نظام العملات
  String _selectedCurrency = 'ر.ع';
  final Map<String, String> _currencies = {
    'ر.ع': '﷼', // ريال عماني
    'ر.س': '﷼', // ريال سعودي
    'د.إ': 'د.إ', // درهم إماراتي
    'د.ك': 'د.ك', // دينار كويتي
    'USD': '\$', // دولار
  };

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() { _interstitialAd = ad; _isAdLoaded = true; });
        },
        onAdFailedToLoad: (err) => setState(() => _isAdLoaded = false),
      ),
    );
  }

  void _calculateLoan() {
    if (_amountController.text.isEmpty || _interestController.text.isEmpty || _monthsController.text.isEmpty) {
      return;
    }

    double p = double.parse(_amountController.text); // مبلغ القرض
    double annualRate = double.parse(_interestController.text); // الفائدة السنوية
    int n = int.parse(_monthsController.text); // عدد الأشهر

    // معادلة القسط الشهري: [P x r x (1+r)^n] / [(1+r)^n - 1]
    double r = annualRate / 12 / 100; // الفائدة الشهرية
    double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    
    double totalPayment = emi * n;
    double totalInterest = totalPayment - p;
    double interestPercentage = (totalInterest / totalPayment) * 100;

    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _showResult(emi, totalInterest, totalPayment, interestPercentage);
          _loadInterstitialAd();
        },
      );
    } else {
      _showResult(emi, totalInterest, totalPayment, interestPercentage);
    }
  }

  void _showResult(double emi, double interest, double total, double percent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('تفاصيل القرض الذكية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 20),
            _resultRow('القسط الشهري:', emi.toStringAsFixed(3), _selectedCurrency, isBold: true),
            _resultRow('فوائد البنك الكلية:', interest.toStringAsFixed(3), _selectedCurrency),
            _resultRow('المبلغ الإجمالي المسترد:', total.toStringAsFixed(3), _selectedCurrency),
            const Divider(),
            _resultRow('نسبة "استقطاع" الفائدة:', '${percent.toStringAsFixed(1)}%', '', color: Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, String cur, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('$value $cur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حاسبة التمويل البنكي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // اختيار العملة
            const Text('اختر العملة:'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _currencies.keys.map((cur) => GestureDetector(
                onTap: () => setState(() => _selectedCurrency = cur),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCurrency == cur ? Theme.of(context).primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_currencies[cur]} $cur', style: TextStyle(color: _selectedCurrency == cur ? Colors.white : Colors.black)),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 25),
            _buildInput('مبلغ القرض المطلوب', _amountController, Icons.money, 'مثال: 40000'),
            _buildInput('نسبة الفائدة السنوية (%)', _interestController, Icons.percent, 'مثال: 4.5'),
            _buildInput('مدة السداد (بالأشهر)', _monthsController, Icons.calendar_month, 'مثال: 240 شهر (20 سنة)'),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _calculateLoan,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                child: const Text('تحليل القرض وإظهار النتائج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
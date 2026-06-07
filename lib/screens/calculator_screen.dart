import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_helper.dart';
import '../providers/settings_provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _customPriceController = TextEditingController();
  String _selectedFinishType = 'متوسط'; 

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
        onAdLoaded: (ad) { setState(() { _interstitialAd = ad; _isAdLoaded = true; }); },
        onAdFailedToLoad: (err) => setState(() => _isAdLoaded = false),
      ),
    );
  }

  void _calculateAndShowAd() {
    final isAr = Provider.of<SettingsProvider>(context, listen: false).language == 'ar';
    
    if (_areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'الرجاء إدخال المساحة' : 'Please enter area')));
      return;
    }
    
    if (_selectedFinishType == 'سعر مخصص' && _customPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'الرجاء إدخال سعر المتر المخصص' : 'Please enter custom price')));
      return;
    }

    FocusScope.of(context).unfocus();

    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _showResultDialog();
          _loadInterstitialAd(); 
        },
      );
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final prices = settings.currentCountryData['prices'] as Map<String, dynamic>;
    final currency = settings.currentCountryData['currency'] as String;
    final isAr = settings.language == 'ar';

    double area = double.parse(_areaController.text);
    double pricePerSqm = 0.0;

    if (_selectedFinishType == 'سعر مخصص' || _selectedFinishType == 'Custom Price') {
      pricePerSqm = double.parse(_customPriceController.text.isEmpty ? "0" : _customPriceController.text);
    } else {
      pricePerSqm = (prices[_selectedFinishType] as num).toDouble();
    }

    double totalCost = area * pricePerSqm;
    
    // ربط النتيجة بمخ التطبيق (حفظ الميزانية)
    settings.setBudget(totalCost); 
    
    double emergencyFund = totalCost * 0.10; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text(isAr ? 'التكلفة التقديرية' : 'Estimated Cost'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${totalCost.toStringAsFixed(0)} $currency', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
            const Divider(height: 30),
            Text(isAr ? 'صندوق الطوارئ (10%):' : 'Emergency Fund (10%):', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${emergencyFund.toStringAsFixed(0)} $currency'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isAr = settings.language == 'ar';
    final currency = settings.currentCountryData['currency'] as String;
    final prices = settings.currentCountryData['prices'] as Map<String, dynamic>;
    
    List<String> options = prices.keys.toList();
    options.add(isAr ? 'سعر مخصص' : 'Custom Price');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), 
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? 'احسب التكلفة' : 'Calculate Cost', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'المساحة الإجمالية (م²)' : 'Total Area (sqm)',
                prefixIcon: const Icon(Icons.aspect_ratio),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            Text(isAr ? 'مستوى التشطيب:' : 'Finish Level:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFinishType,
                  isExpanded: true,
                  items: options.map((String type) {
                    bool isCustom = (type == 'سعر مخصص' || type == 'Custom Price');
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(isCustom ? type : '$type (~ ${prices[type]} $currency)'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) => setState(() => _selectedFinishType = newValue!),
                ),
              ),
            ),
            
            if (_selectedFinishType == 'سعر مخصص' || _selectedFinishType == 'Custom Price') ...[
              const SizedBox(height: 20),
              TextField(
                controller: _customPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'أدخل سعر المتر ($currency)' : 'Enter Price ($currency)',
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _calculateAndShowAd,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                child: Text(isAr ? 'احسب' : 'Calculate', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
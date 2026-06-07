import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _selectedCountry = 'عُمان';
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'ar';
  double _estimatedBudget = 0.0; 

  // قاعدة البيانات الشاملة لجميع الدول
  final Map<String, Map<String, dynamic>> countryData = {
    'عُمان': {
      'currency': 'ر.ع',
      'prices': {'تجاري (عادي)': 110.0, 'متوسط': 135.0, 'راقي (ديلوكس)': 165.0},
      'stages_ar': [
        {'name': 'الخرائط وإباحة البناء', 'items': ['رسوم إباحة البلدية', 'أتعاب المكتب الاستشاري', 'فحص التربة', 'تأمين العمال']},
        {'name': 'الحفر والردم', 'items': ['إيجار الحفارة', 'نقل المخلفات', 'رمل الكبس', 'إيجار الدكاكة']},
        {'name': 'القواعد والأساسات', 'items': ['حديد التسليح', 'خرسانة القواعد', 'أخشاب النجار', 'عازل القواعد (القار)']},
        {'name': 'الأعمدة والأسقف', 'items': ['حديد الأسقف', 'خرسانة السقف', 'الطابوق', 'أجور العمالة']},
        {'name': 'التشطيبات والخدمات', 'items': ['أنابيب السباكة', 'أسلاك الكهرباء', 'البلستر (المساح)', 'السيراميك والأصباغ']}
      ],
      'stages_en': [
        {'name': 'Maps & Permits', 'items': ['Municipality Fees', 'Consultant Fees', 'Soil Test', 'Workers Insurance']},
        {'name': 'Excavation & Backfill', 'items': ['Excavator Rent', 'Waste Removal', 'Backfill Sand', 'Compactor Rent']},
        {'name': 'Foundations', 'items': ['Steel Rebar', 'Ready-mix Concrete', 'Carpentry', 'Foundation Insulation']},
        {'name': 'Superstructure', 'items': ['Slab Steel', 'Slab Concrete', 'Blocks', 'Labor Cost']},
        {'name': 'Finishes & MEP', 'items': ['Plumbing Pipes', 'Electrical Wires', 'Plastering', 'Tiles & Paint']}
      ]
    },
    'السعودية': {
      'currency': 'ر.س',
      'prices': {'تجاري (عادي)': 1200.0, 'متوسط': 1500.0, 'راقي (ديلوكس)': 2000.0},
      'stages_ar': [
        {'name': 'المخططات والرخص', 'items': ['رخصة بلدي', 'المكتب الهندسي', 'المكتب المساحي', 'التأمين ضد العيوب']},
        {'name': 'الحفر والإحلال', 'items': ['حفر الأرض', 'ترحيل المخلفات', 'تربة الإحلال', 'اختبار الدمك']},
        {'name': 'القواعد والميد', 'items': ['حديد التسليح', 'الخرسانة الجاهزة', 'البلك البركاني', 'العزل المائي']},
        {'name': 'العظم (الأعمدة والأسقف)', 'items': ['الحديد', 'الخرسانة', 'أجور المقاول', 'ونش الرفع']},
        {'name': 'التشطيبات النهائية', 'items': ['تأسيس السباكة', 'تأسيس الكهرباء', 'اللياسة', 'الدهانات والبلاط']}
      ],
      'stages_en': [
        {'name': 'Plans & Permits', 'items': ['Balady Permit', 'Engineering Office', 'Surveyor', 'Insurance Policy']},
        {'name': 'Excavation', 'items': ['Digging', 'Debris Removal', 'Replacement Soil', 'Compaction Test']},
        {'name': 'Foundations & Tie Beams', 'items': ['Steel', 'Ready-mix Concrete', 'Volcanic Blocks', 'Waterproofing']},
        {'name': 'Superstructure (Bones)', 'items': ['Steel', 'Concrete', 'Contractor Fees', 'Crane Rent']},
        {'name': 'Finishes', 'items': ['Plumbing Rough-in', 'Electrical Rough-in', 'Plastering', 'Paint & Tiles']}
      ]
    },
    'الإمارات': {
      'currency': 'د.إ',
      'prices': {'تجاري (عادي)': 1300.0, 'متوسط': 1600.0, 'راقي (ديلوكس)': 2200.0},
      'stages_ar': [
        {'name': 'المخططات والتصاريح', 'items': ['رسوم البلدية', 'الدفاع المدني', 'الاستشاري', 'فحص التربة']},
        {'name': 'تجهيز الموقع', 'items': ['الحفر', 'السياج المؤقت', 'نقل المخلفات', 'تسوية الأرض']},
        {'name': 'الأساسات', 'items': ['الحديد', 'الخرسانة', 'العزل التأسيسي', 'مكافحة الرمة (النمل الأبيض)']},
        {'name': 'الهيكل الخرساني', 'items': ['الأعمدة', 'الأسقف', 'الطابوق العازل', 'العمالة']},
        {'name': 'التشطيبات والكهروميكانيك', 'items': ['أعمال التكييف', 'الكهرباء والسباكة', 'الأصباغ', 'الأرضيات']}
      ],
      'stages_en': [
        {'name': 'Plans & Permits', 'items': ['Municipality Fees', 'Civil Defense', 'Consultant', 'Soil Test']},
        {'name': 'Site Prep', 'items': ['Excavation', 'Temporary Fence', 'Debris Removal', 'Land Leveling']},
        {'name': 'Foundations', 'items': ['Steel', 'Concrete', 'Insulation', 'Termite Control']},
        {'name': 'Concrete Structure', 'items': ['Columns', 'Slabs', 'Insulated Blocks', 'Labor']},
        {'name': 'Finishes & MEP', 'items': ['HVAC', 'MEP Works', 'Paint', 'Flooring']}
      ]
    },
    'الكويت': {
      'currency': 'د.ك',
      'prices': {'تجاري (عادي)': 100.0, 'متوسط': 130.0, 'راقي (ديلوكس)': 180.0},
      'stages_ar': [
        {'name': 'المخططات والتراخيص', 'items': ['رسوم البلدية', 'المكتب الهندسي', 'رخصة الإطفاء', 'الكهرباء والماء']},
        {'name': 'الحفر وتجهيز القسيمة', 'items': ['الحفر', 'الدفان', 'تدعيم الجوار', 'نقل الأنقاض']},
        {'name': 'الهيكل الأسود (الأساسات)', 'items': ['الحديد', 'الخرسانة', 'العازل المائي', 'النجارة والحدادة']},
        {'name': 'الهيكل الأسود (الأسقف)', 'items': ['حديد الأسقف', 'الخرسانة', 'الطابوق الأبيض العازل', 'أجور المقاول']},
        {'name': 'التشطيبات', 'items': ['المساح الخارجي والداخلي', 'التمديدات الصحية', 'الكهرباء', 'السيراميك والأصباغ']}
      ],
      'stages_en': [
        {'name': 'Plans & Licenses', 'items': ['Municipality', 'Engineering Office', 'Fire Dept', 'MEP Approvals']},
        {'name': 'Excavation & Plot Prep', 'items': ['Excavation', 'Backfilling', 'Shoring', 'Debris Removal']},
        {'name': 'Black Structure (Foundations)', 'items': ['Steel', 'Concrete', 'Waterproofing', 'Carpentry/Smithing']},
        {'name': 'Black Structure (Slabs)', 'items': ['Slab Steel', 'Concrete', 'White Insulated Blocks', 'Contractor']},
        {'name': 'Finishes', 'items': ['Plastering', 'Sanitary', 'Electrical', 'Tiles & Paint']}
      ]
    },
  };

  String get selectedCountry => _selectedCountry;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  double get estimatedBudget => _estimatedBudget;

  Map<String, dynamic> get currentCountryData => countryData[_selectedCountry] ?? countryData['عُمان']!;

  List<Map<String, dynamic>> get currentStagesData {
    final data = currentCountryData;
    if (data['stages_ar'] == null) return countryData['عُمان']!['stages_ar']; 
    return _language == 'ar' ? List<Map<String, dynamic>>.from(data['stages_ar']) : List<Map<String, dynamic>>.from(data['stages_en']);
  }

  SettingsProvider() { _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // سطر الحماية: التأكد من أن الدولة المحفوظة موجودة فعلاً في الكود
    String savedCountry = prefs.getString('country') ?? 'عُمان';
    if (!countryData.containsKey(savedCountry)) {
      savedCountry = 'عُمان'; 
    }
    
    _selectedCountry = savedCountry;
    _language = prefs.getString('language') ?? 'ar';
    _estimatedBudget = prefs.getDouble('budget') ?? 0.0;
    _themeMode = (prefs.getBool('isDark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setBudget(double budget) {
    _estimatedBudget = budget;
    SharedPreferences.getInstance().then((p) => p.setDouble('budget', budget));
    notifyListeners();
  }

  Future<void> setCountry(String country) async {
    _selectedCountry = country;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('country', country);
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('isDark', isDark);
  }

  Future<void> toggleLanguage(String langCode) async {
    _language = langCode;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('language', langCode);
  }
}
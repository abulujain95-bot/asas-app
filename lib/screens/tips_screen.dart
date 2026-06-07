import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/pdf_contract_service.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isAr = settings.language == 'ar';
    final country = settings.selectedCountry;

    final Map<String, List<Map<String, dynamic>>> guidesData = {
      'عُمان': [
        {'title': 'المرحلة الأولى: التخطيط وإباحة البناء', 'icon': Icons.architecture, 'details': ['التعاقد مع مكتب استشاري مرخص.', 'الموافقات من الدفاع المدني والكهرباء.', 'استخراج الإباحة عبر منصة بلديات.']},
        {'title': 'المرحلة الثانية: التجهيز والشروع', 'icon': Icons.assignment, 'details': ['توقيع العقد مع المقاول.', 'دفع تأمين المخلفات.', 'استخراج تصريح الشروع وتثبيت العلائم.']},
        {'title': 'المرحلة الثالثة: التنفيذ (الهيكل والتشطيب)', 'icon': Icons.construction, 'details': ['رش المبيدات قبل القواعد.', 'صب الخرسانة والأعمدة والأسقف.', 'التشطيبات والبلستر وتمديدات PPR.']},
        {'title': 'المرحلة الرابعة: إتمام البناء', 'icon': Icons.home, 'details': ['تنظيف الموقع بالكامل.', 'إصدار شهادة إتمام البناء.', 'توصيل العدادات الدائمة واسترداد التأمين.']}
      ],
      'السعودية': [
        {'title': 'المرحلة الأولى: المخططات ورخصة بلدي', 'icon': Icons.architecture, 'details': ['الالتزام بالكود السعودي SBC.', 'استخراج التأمين ضد العيوب الخفية.', 'إصدار رخصة البناء عبر بلدي.']},
        {'title': 'المرحلة الثانية: تجهيز الموقع', 'icon': Icons.assignment, 'details': ['التعاقد مع مقاول ومكتب مشرف.', 'تسوير الموقع ووضع لوحة المشروع.']},
        {'title': 'المرحلة الثالثة: العظم والتشطيب', 'icon': Icons.construction, 'details': ['حفر وإحلال وصب الميد.', 'تطبيق العزل الحراري الإلزامي.', 'أعمال اللياسة والتشطيب.']},
        {'title': 'المرحلة الرابعة: شهادة الإشغال', 'icon': Icons.home, 'details': ['رفع التقرير النهائي.', 'اجتياز الفحص وإصدار شهادة الإشغال.', 'إطلاق التيار الكهربائي.']}
      ],
    };

    final List<Map<String, String>> structuralTips = [
      {'title': 'فحص التربة', 'desc': 'يعتبر الأساس لتحديد نوع القواعد (منفصلة، لبشة، إلخ). لا تبدأ بدونه لتفادي الهبوط المستقبلي.'},
      {'title': 'معالجة الخرسانة (رش الماء)', 'desc': 'يجب رش العناصر الخرسانية (القواعد، الأعمدة، الأسقف) بالماء مرتين يومياً لمدة لا تقل عن 7 أيام لضمان صلابتها.'},
      {'title': 'العزل المائي والحراري', 'desc': 'استخدم لفائف البيتومين للقواعد، والعزل الحراري للأسطح والجدران لتقليل استهلاك الكهرباء بنسبة 40%.'},
      {'title': 'فحص التمديدات', 'desc': 'قم بضغط أنابيب السباكة (PPR) بجهاز الضغط قبل تغطيتها بالبلستر أو السيراميك للتأكد من عدم وجود تسريب.'},
    ];

    List<Map<String, dynamic>> displayGuide = guidesData[country] ?? guidesData['عُمان']!;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'دليل الإنشاء والعقود' : 'Construction Guide')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                ),
                title: Text(isAr ? 'عقد مقاولة قانوني' : 'Legal Contract', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(isAr ? 'نموذج جاهز لدولة $country' : 'Template for $country', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // التعديل هنا: تمرير context ليعرض الأخطاء للمستخدم
                    PdfContractService.generateAndPrintContract(context, country, settings.language);
                  },
                  child: Text(isAr ? 'إنشاء' : 'Generate'),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(isAr ? 'نصائح هيكلية هامة للمشروع' : 'Important Structural Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: structuralTips.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(structuralTips[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(child: Text(structuralTips[index]['desc']!, style: const TextStyle(fontSize: 13, height: 1.4))),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 10),
              child: Text(isAr ? 'مراحل الإجراءات والتراخيص' : 'Procedures & Permits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              itemCount: displayGuide.length,
              itemBuilder: (context, index) {
                final stage = displayGuide[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ExpansionTile(
                    leading: Icon(stage['icon'], color: Theme.of(context).colorScheme.secondary),
                    title: Text(stage['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (stage['details'] as List<String>).map((detail) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.arrow_left, size: 20, color: Theme.of(context).primaryColor),
                                  Expanded(child: Text(detail, style: const TextStyle(fontSize: 13, height: 1.5))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfContractService {
  static Future<void> generateAndPrintContract(BuildContext context, String country, String language) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري إنشاء العقد، يرجى الانتظار...'), duration: Duration(seconds: 1)),
      );

      final pdf = pw.Document();

      // قراءة الخطوط محلياً
      final ByteData regularFontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
      final arabicFont = pw.Font.ttf(regularFontData);

      final ByteData boldFontData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
      final boldFont = pw.Font.ttf(boldFontData);

      // تحميل الشعار
      pw.MemoryImage? appLogo;
      try {
        final ByteData imageBytes = await rootBundle.load('assets/icon/app_icon.png');
        appLogo = pw.MemoryImage(imageBytes.buffer.asUint8List());
      } catch (e) {
        debugPrint('Logo not found: $e');
      }

      String contractTitle = '';
      String contractBody = '';
      String printDate = DateTime.now().toString().substring(0, 10);

      if (language == 'ar') {
        if (country == 'عُمان') {
          contractTitle = 'عقد مقاولة بناء - سلطنة عُمان';
          contractBody = '''
إنه في يوم [.......................] الموافق [..../..../........] تم الاتفاق بين كل من:

الطرف الأول (المالك): ..............................................................
رقم البطاقة الشخصية: [.......................] هاتف: [.......................]

الطرف الثاني (المقاول): ..............................................................
رقم السجل التجاري: [.......................] هاتف: [.......................]

تمهيد:
بناءً على القوانين والأنظمة المعمول بها في سلطنة عُمان، واشتراطات شؤون البلديات وإباحة البناء رقم [................].

البند الأول: موضوع العقد
يلتزم الطرف الثاني بتنفيذ أعمال (تسليم مفتاح / هيكل) للمشروع الكائن في ولاية [................] مربع [................] قطعة [................].

البند الثاني: التزامات المقاول
1. الالتزام التام بالخرائط المعتمدة من المكتب الاستشاري.
2. توفير عمالة ماهرة وعلى كفالة المقاول، والالتزام باشتراطات الأمن والسلامة.
3. معالجة أي عيوب إنشائية تظهر خلال فترة الضمان المحددة بـ (........) سنة.

البند الثالث: القيمة والدفعات
تم الاتفاق على أن تكون القيمة الإجمالية للمشروع: [.......................] ريال عماني.
وتُدفع حسب الدفعات التالية المعتمدة من الاستشاري:
- الدفعة المقدمة: [.......................] ر.ع عند استلام الموقع.
- دفعة صب القواعد: [.......................] ر.ع.
- دفعة صب سقف الدور الأرضي: [.......................] ر.ع.
- (تضاف باقي الدفعات: ..............................................................)

البند الرابع: مدة التنفيذ والشرط الجزائي
يلتزم الطرف الثاني بتسليم المشروع خلال (........) شهراً تبدأ من تاريخ استلام تصريح الشروع.
في حال التأخير، يُخصم مبلغ [................] ر.ع عن كل يوم تأخير.
''';
        } else if (country == 'السعودية') {
          contractTitle = 'عقد مقاولة إنشاءات - المملكة العربية السعودية';
          contractBody = '''
إنه في يوم [.......................] الموافق [..../..../........] تم الاتفاق بين كل من:

الطرف الأول (المالك): ..............................................................
رقم الهوية الوطنية: [.......................] هاتف: [.......................]

الطرف الثاني (المقاول): ..............................................................
رقم السجل التجاري: [.......................] رخصة بلدي: [.......................]

تمهيد:
بناءً على اشتراطات كود البناء السعودي (SBC) ومتطلبات منصة "بلدي" ورخصة البناء رقم [................].

البند الأول: موضوع العقد
تنفيذ أعمال بناء مشروع سكنى/تجاري على الأرض رقم [................] في حي [................].

البند الثاني: التزامات المقاول
1. الالتزام الكامل بكود البناء السعودي وتوجيهات المكتب الهندسي المشرف.
2. استخراج وثيقة التأمين الإلزامي ضد العيوب الخفية.
3. إزالة كافة المخلفات من الموقع وعدم التعدي على ممتلكات الجيران أو الارتدادات.

البند الثالث: القيمة المالية
إجمالي قيمة العقد: [.......................] ريال سعودي.
جدول الدفعات (يُصرف بعد اجتياز فحص المراحل من المكتب المشرف):
- دفعة توقيع العقد: [.......................] ر.س.
- دفعة صب الميد والقواعد: [.......................] ر.س.
- دفعة صب الأسقف (العظم): [.......................] ر.س.
- (أخرى: ..............................................................)

البند الرابع: مدة المشروع والغرامات
مدة التنفيذ: (........) شهراً من تاريخ تسليم الموقع.
غرامة التأخير: [................] ر.س عن كل أسبوع تأخير.
''';
        } else if (country == 'الإمارات') {
          contractTitle = 'عقد بناء وتشييد - الإمارات العربية المتحدة';
          contractBody = '''
تم تحرير هذا العقد في يوم [.......................] الموافق [..../..../........] بين:

الطرف الأول (المالك): ..............................................................
رقم الهوية الإماراتية: [.......................]

الطرف الثاني (المقاول): ..............................................................
رقم الرخصة التجارية: [.......................]

تمهيد:
وفقاً لاشتراطات البلدية والدفاع المدني بدولة الإمارات وتصريح البناء رقم [................].

البند الأول: الالتزامات الفنية
1. تنفيذ الأعمال وفق المخططات الهندسية المعتمدة وتوجيهات الاستشاري الرئيسي.
2. تطبيق أعلى معايير السلامة المهنية (HSE) وتوفير سياج مؤقت للموقع.
3. يضمن المقاول الهيكل الإنشائي لمدة 10 سنوات، وأعمال العزل لسنة واحدة.

البند الثاني: الدفعات المالية
القيمة الإجمالية: [.......................] درهم إماراتي.
تُدفع بنظام الدفعات المرتبطة بالإنجاز (Milestones):
- دفعة تجهيز الموقع: [.......................] د.إ.
- دفعة الأساسات: [.......................] د.إ.
- دفعة الهيكل الخرساني: [.......................] د.إ.
- (أخرى: ..............................................................)

البند الثالث: الإنجاز والتأخير
مدة المشروع: (........) شهراً. يلتزم المقاول بدفع غرامة [................] د.إ عن كل يوم تأخير.
''';
        } else {
          contractTitle = 'عقد مقاولة بناء (نموذج عام) - دولة الكويت';
          contractBody = '''
إنه في يوم [.......................] الموافق [..../..../........] تم الاتفاق بين:

الطرف الأول (المالك): ..............................................................
الرقم المدني: [.......................]

الطرف الثاني (المقاول): ..............................................................
رقم الترخيص: [.......................]

البند الأول: مجال العمل
تنفيذ القسيمة رقم [................] قطاع [................] حسب مخططات المكتب الهندسي.

البند الثاني: الشروط
1. الالتزام باشتراطات بلدية الكويت وقوة الإطفاء العام ووزارة الكهرباء والماء.
2. توفير مواد عالية الجودة واعتمادها من المالك قبل التركيب.

البند الثالث: القيمة المالية والمدة
إجمالي العقد: [.......................] دينار كويتي.
مدة التنفيذ: (........) يوماً. يتم دفع المبالغ كالتالي:
- [.......................] د.ك (مقدم).
- [.......................] د.ك (عند الهيكل الأسود).
- [.......................] د.ك (عند التشطيبات).
''';
        }
      } else {
        contractTitle = 'Construction Contract Agreement - $country';
        contractBody = '''
Date: [..../..../........]

Party 1 (Owner): ........................................ ID: [................]
Party 2 (Contractor): ........................................ Reg No: [................]

1. Scope of Work: Contractor agrees to build the project located at [................] as per approved consultant drawings.

2. Project Value: Total cost is [................] payable in milestones.

3. Duration & Penalty: Project length is [................] months. Delay penalty is [................] per day.

4. Warranty: 10-year structural warranty is mandatory.
        ''';
      }

      // تقسيم النص إلى أسطر لتفادي خطأ (TooManyPagesException)
      final List<String> contractLines = contractBody.split('\n');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          textDirection: language == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: boldFont,
          ),
          header: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('تطبيق أَسَاس (ASAS)', style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.blue900)),
                        pw.Text('النظام الهندسي الذكي لإدارة المشاريع', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ]
                    ),
                    if (appLogo != null) pw.Image(appLogo, width: 40, height: 40),
                  ]
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
              ]
            );
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(color: PdfColors.grey),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('تاريخ الطباعة: $printDate', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    pw.Text('تم إنشاء العقد بواسطة تطبيق أساس', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  ]
                )
              ]
            );
          },
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(contractTitle, style: pw.TextStyle(font: boldFont, fontSize: 20)),
              ),
              pw.SizedBox(height: 30),
              
              // عرض الأسطر بشكل مفصل لتقبل امتداد الصفحات المتعددة
              ...contractLines.map((line) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                    line,
                    style: pw.TextStyle(font: arabicFont, fontSize: 13, lineSpacing: 2),
                  ),
                );
              }),

              pw.SizedBox(height: 50),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(language == 'ar' ? 'توقيع المالك (الطرف الأول)' : 'Owner Signature', style: pw.TextStyle(font: boldFont)),
                      pw.SizedBox(height: 40),
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 10),
                      pw.Text(language == 'ar' ? 'التاريخ: ..../..../........' : 'Date: ..../..../........', style: pw.TextStyle(font: arabicFont)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(language == 'ar' ? 'توقيع المقاول (الطرف الثاني)' : 'Contractor Signature', style: pw.TextStyle(font: boldFont)),
                      pw.SizedBox(height: 40),
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 10),
                      pw.Text(language == 'ar' ? 'التاريخ: ..../..../........' : 'Date: ..../..../........', style: pw.TextStyle(font: arabicFont)),
                    ]
                  )
                ]
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Contract_$country',
      );
      
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الإنشاء: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
# إصلاح خطأ NoSuchMethodError: 'toDouble'

## المشكلة:
كان التطبيق يتعطل مع الخطأ التالي:
```
NoSuchMethodError: 'toDouble'
Dynamic call failed
Tried to invoke 'null' like a method
Receiver: '0.00'
Arguments: []
```

## السبب:
عند تحويل البيانات من JSON القادمة من قاعدة البيانات، كانت القيم الرقمية (مثل `fee_paid`, `consultation_fee`, `rating`) تأتي بأنواع مختلفة:
- أحياناً `null`
- أحياناً `String` (مثل `"0.00"`)
- أحياناً `int`
- أحياناً `double`

وكان الكود يحاول استدعاء `.toDouble()` مباشرة على هذه القيم، مما يسبب خطأ عندما تكون القيمة `null` أو `String`.

## الحل:

### 1. إضافة دالة مساعدة `_parseDouble`:
```dart
// Helper function to safely parse double values
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}
```

### 2. استبدال جميع استدعاءات `.toDouble()`:

#### في `Appointment.fromJson`:
```dart
// قبل:
feePaid: (json['fee_paid'] ?? 0.0).toDouble(),

// بعد:
feePaid: _parseDouble(json['fee_paid']),
```

#### في `Doctor.fromJson`:
```dart
// قبل:
consultationFee: (json['consultation_fee'] ?? 0.0).toDouble(),
rating: (json['rating'] ?? 0.0).toDouble(),

// بعد:
consultationFee: _parseDouble(json['consultation_fee']),
rating: _parseDouble(json['rating']),
```

## الملفات المعدلة:
- ✅ `lib/services/data_service.dart`
  - إضافة دالة `_parseDouble` المساعدة
  - إصلاح 3 مواضع تستخدم `.toDouble()`

## النتيجة:
✅ التطبيق الآن يعمل بدون أخطاء
✅ يمكن عرض المواعيد بنجاح
✅ يمكن حجز الاستشارات بنجاح
✅ جميع القيم الرقمية يتم معالجتها بشكل آمن

## الاختبار:
1. ✅ صفحة المواعيد تعمل بدون أخطاء
2. ✅ صفحة الاستشارة تعمل بدون أخطاء
3. ✅ الصفحة الرئيسية تعمل بدون أخطاء
4. ✅ Hot Reload نجح بدون مشاكل

---

## الحالة النهائية:
🟢 السيرفر: يعمل على `http://localhost:8000`
🟢 التطبيق: يعمل على Chrome
🟢 قاعدة البيانات: متصلة
✅ جميع الأخطاء تم إصلاحها

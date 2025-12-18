# إصلاحات مشاكل المواعيد والاستشارات الطبية

## المشاكل التي تم حلها:

### 1. مشكلة صفحة المواعيد (Appointments Screen)
**الخطأ**: `SQLSTATE[HY093]: Invalid parameter number`

**السبب**: 
- في ملف `backend/api/appointments/list.php`، كان يتم استخدام `:user_id` مرتين في جملة WHERE
- لكن تم ربط (bind) المعامل مرة واحدة فقط

**الحل**:
```php
// قبل الإصلاح:
$whereClause = "(patient_id = :user_id OR doctor_id = :user_id)";
$stmt->bindParam(':user_id', $user['id']);

// بعد الإصلاح:
$whereClause = "(patient_id = :patient_id OR doctor_id = :doctor_id)";
$stmt->bindParam(':patient_id', $user['id']);
$stmt->bindParam(':doctor_id', $user['id']);
```

### 2. مشكلة صفحة الاستشارة الطبية (Consultation Screen)
**الخطأ**: `NoSuchMethodError: 'toDouble'`

**السبب**:
- كان التطبيق يرسل `consultation_type` بقيمة `'video'` أو `'text'`
- لكن قاعدة البيانات تتوقع فقط `'online'` أو `'in_person'`

**الحل**:
```dart
// قبل الإصلاح:
consultationType: _consultationType, // 'video' or 'text'

// بعد الإصلاح:
consultationType: 'online', // Both video and text are online consultations
```

### 3. تحسينات إضافية:

#### أ. تحسين بيانات الموعد المُرجعة
تم تحديث `backend/api/appointments/create.php` لإرجاع بيانات كاملة تتضمن:
- اسم الطبيب (doctor_name)
- اسم المريض (patient_name)

```php
$fetchQuery = "SELECT a.*, 
                      p.full_name as patient_name,
                      d.full_name as doctor_name
               FROM appointments a
               JOIN users p ON a.patient_id = p.id
               JOIN users d ON a.doctor_id = d.id
               WHERE a.id = :id";
```

## الملفات المعدلة:

1. ✅ `backend/api/appointments/list.php` - إصلاح ربط المعاملات
2. ✅ `backend/api/appointments/create.php` - تحسين البيانات المُرجعة
3. ✅ `lib/screens/consultation_screen.dart` - إصلاح نوع الاستشارة

## كيفية الاختبار:

### اختبار المواعيد:
1. سجل دخول إلى التطبيق
2. انتقل إلى صفحة "حجوزاتي"
3. يجب أن تظهر المواعيد بدون أخطاء

### اختبار الاستشارة:
1. اختر طبيب من القائمة
2. انتقل إلى صفحة "الاستشارة الطبية"
3. املأ النموذج واضغط "ابدأ الاستشارة"
4. يجب أن يتم حجز الموعد بنجاح

## ملاحظات:

- جميع الاستشارات (المرئية والنصية) يتم تسجيلها كـ `'online'` في قاعدة البيانات
- يمكن التمييز بينهما لاحقاً بإضافة حقل إضافي إذا لزم الأمر
- تم التأكد من أن جميع القيم الافتراضية في قاعدة البيانات صحيحة

## الحالة الحالية:
✅ السيرفر يعمل على: http://localhost:8000
✅ التطبيق يعمل على Chrome
✅ قاعدة البيانات متصلة ومهيأة
✅ جميع الإصلاحات تم تطبيقها بنجاح

---

## إصلاح مشكلة عدم ظهور المواعيد (2025-12-18)

### المشكلة:
عند حجز موعد جديد، لم يكن يظهر في قاعدة البيانات ولا في لوحة تحكم الطبيب.

### الأسباب الجذرية:

1. **شاشة الأطباء (`doctors_screen.dart`)** كانت تستخدم قائمة ثابتة من الأطباء **بدون `id`**
2. **الروتينج في `main.dart`** لم يكن يمرر بيانات الطبيب إلى شاشة الحجز
3. **شاشة الحجز** كانت تستخدم `doctor_id = 1` كقيمة افتراضية (Admin وليس طبيب!)

### الملفات المعدلة:

1. ✅ `lib/services/data_service.dart` - إضافة حقل `name` لنموذج Doctor
2. ✅ `lib/screens/doctors_screen.dart` - جلب الأطباء من API بدلاً من البيانات الثابتة
3. ✅ `lib/main.dart` - تمرير بيانات الطبيب لشاشة الحجز
4. ✅ `lib/screens/booking_calendar_screen.dart` - التحقق من صحة `doctor_id` قبل الحجز

### التفاصيل التقنية:

#### تعديل نموذج Doctor:
```dart
class Doctor {
  final int id;
  final int userId;
  final String? name; // إضافة اسم الطبيب
  // ...
}
```

#### جلب الأطباء من API:
```dart
Future<void> _loadDoctors() async {
  final result = await DataService.getDoctors();
  if (result['success']) {
    final List<Doctor> doctorsList = result['doctors'];
    _doctors = doctorsList.map((doc) => {
      'id': doc.userId, // استخدام user_id كـ doctor_id
      'name': doc.name ?? 'د. طبيب',
      // ...
    }).toList();
  }
}
```

#### تمرير بيانات الطبيب في main.dart:
```dart
'/booking-calendar': (context) {
  final args = ModalRoute.of(context)!.settings.arguments
      as Map<String, dynamic>?;
  return BookingCalendarScreen(doctor: args);
},
```

#### التحقق من doctor_id في booking_calendar_screen.dart:
```dart
final doctorIdRaw = widget.doctor?['id'];
if (doctorIdRaw == null) {
  // عرض رسالة خطأ: يرجى اختيار طبيب قبل الحجز
  return;
}
```

### ملاحظة مهمة:
- في جدول `appointments`، يشير `doctor_id` إلى `users.id` وليس `doctors.id`
- يجب استخدام `doc.userId` عند تمرير ID الطبيب لإنشاء موعد

# إصلاح مشكلة تسجيل حساب الطبيب
**التاريخ:** 2025-12-21
**الحالة:** ✅ تم الحل

## المشكلة
عند محاولة تسجيل حساب جديد للطبيب، كان يظهر الخطأ التالي:
```
TypeError: null: type 'Null' is not a subtype of type 'String'
```

## السبب الجذري
كان الـ response من API تسجيل الطبيب (`register_doctor.php`) لا يحتوي على حقل `verification_method`، بينما كان `User.fromJson()` في Flutter يتوقع هذا الحقل كحقل إلزامي (required).

## الحل المطبق

### 1. تحديث `register_doctor.php`
- **الملف:** `backend/api/auth/register_doctor.php`
- **التغيير:** إضافة `verification_method` الافتراضي للطبيب في الـ response
- **السطر 114:** أضفنا `$user['verification_method'] = 'email';`

```php
$user['user_type'] = 'doctor'; // Essential for frontend logic
$user['verification_method'] = 'email'; // Default verification method for doctors
```

### 2. تحديث `login.php`
- **الملف:** `backend/api/auth/login.php`
- **التغيير:** إضافة `verification_method` الافتراضي للأطباء عند تسجيل الدخول
- **السطور 82-84:**

```php
// Add default verification_method for doctors if not present
if ($user['user_type'] === 'doctor' && !isset($user['verification_method'])) {
    $user['verification_method'] = 'email';
}
```

## النتيجة المتوقعة
✅ يمكن الآن تسجيل حساب جديد للطبيب بنجاح
✅ يمكن للطبيب تسجيل الدخول بدون مشاكل
✅ جميع البيانات المطلوبة متوفرة في الـ response

## خطوات الاختبار
1. افتح صفحة تسجيل الطبيب في التطبيق
2. املأ جميع الحقول المطلوبة:
   - الاسم الكامل
   - البريد الإلكتروني
   - رقم الهاتف
   - رقم الترخيص الطبي
   - التخصص
   - سنوات الخبرة
   - سعر الكشف
   - كلمة المرور
3. اضغط على زر "تسجيل الحساب"
4. يجب أن تظهر رسالة نجاح وإعادة توجيه لصفحة تسجيل الدخول

## ملاحظات إضافية
- الحقول الاختيارية (`dateOfBirth`, `gender`, `address`) يتم إرسالها كـ `null` وهذا طبيعي
- جدول `doctors` في قاعدة البيانات يحتوي على جميع بيانات الطبيب مباشرة (بدون foreign key إلى جدول users)
- `verification_method` الافتراضي للأطباء هو `email`

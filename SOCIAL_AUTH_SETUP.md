# إعداد تسجيل الدخول عبر Google و Facebook

## 📋 الخطوات المطلوبة

### 1️⃣ إعداد Google Sign-In

#### أ. إنشاء مشروع في Google Cloud Console
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو اختر مشروع موجود
3. قم بتفعيل **Google+ API**

#### ب. إنشاء OAuth 2.0 Client IDs

**للويب (Web):**
1. اذهب إلى **APIs & Services** > **Credentials**
2. انقر على **Create Credentials** > **OAuth client ID**
3. اختر **Web application**
4. أضف Authorized JavaScript origins:
   ```
   http://localhost:8000
   http://localhost
   ```
5. أضف Authorized redirect URIs:
   ```
   http://localhost:8000
   ```
6. احفظ **Client ID**

**لنظام Android:**
1. أنشئ **OAuth client ID** جديد
2. اختر **Android**
3. احصل على SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. أدخل package name: `com.example.tabibek`
5. احفظ **Client ID**

**لنظام iOS:**
1. أنشئ **OAuth client ID** جديد
2. اختر **iOS**
3. أدخل Bundle ID: `com.example.tabibek`
4. احفظ **Client ID** و **iOS URL scheme**

#### ج. تحديث ملفات التطبيق

**Android** - عدل `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.example.tabibek"
    // ... باقي الإعدادات
}
```

**iOS** - عدل `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- ضع هنا iOS URL scheme من Google -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

---

### 2️⃣ إعداد Facebook Login

#### أ. إنشاء تطبيق في Facebook Developers
1. اذهب إلى [Facebook Developers](https://developers.facebook.com/)
2. انقر على **My Apps** > **Create App**
3. اختر **Consumer** كنوع التطبيق
4. أدخل اسم التطبيق واختر الفئة

#### ب. إضافة Facebook Login
1. من لوحة التحكم، اذهب إلى **Add Product**
2. اختر **Facebook Login** وانقر **Set Up**
3. اختر **Web** كمنصة
4. أدخل Site URL: `http://localhost:8000`

#### ج. الحصول على App ID و App Secret
1. من **Settings** > **Basic**
2. احفظ **App ID** و **App Secret**

#### د. تحديث ملفات التطبيق

**Android** - عدل `android/app/src/main/res/values/strings.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Tabibek</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

**Android** - عدل `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <!-- ... -->
    
    <meta-data 
        android:name="com.facebook.sdk.ApplicationId" 
        android:value="@string/facebook_app_id"/>
    
    <meta-data 
        android:name="com.facebook.sdk.ClientToken" 
        android:value="@string/facebook_client_token"/>
    
    <activity 
        android:name="com.facebook.FacebookActivity"
        android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
        android:label="@string/app_name" />
    
    <activity
        android:name="com.facebook.CustomTabActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="@string/fb_login_protocol_scheme" />
        </intent-filter>
    </activity>
</application>
```

**iOS** - عدل `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Tabibek</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
</array>
```

---

### 3️⃣ اختبار التطبيق

#### للويب (Chrome):
```bash
flutter run -d chrome
```

#### للأندرويد:
```bash
flutter run -d android
```

#### للـ iOS:
```bash
flutter run -d ios
```

---

## ⚠️ ملاحظات هامة

1. **للتطوير المحلي**: تأكد من إضافة `localhost` في إعدادات OAuth
2. **للإنتاج**: ستحتاج لإضافة domain الفعلي للموقع
3. **الأمان**: لا تشارك Client Secret أو App Secret في الكود المصدري
4. **الاختبار**: استخدم حسابات اختبار في Facebook أثناء التطوير

---

## 🔧 استكشاف الأخطاء

### خطأ: "Developer Error"
- تأكد من صحة SHA-1 fingerprint (Android)
- تأكد من صحة Bundle ID (iOS)

### خطأ: "Invalid OAuth client"
- تأكد من إضافة redirect URIs الصحيحة
- تأكد من تفعيل Google+ API

### خطأ Facebook: "App Not Set Up"
- تأكد من إضافة Facebook Login product
- تأكد من صحة App ID في ملفات التطبيق

---

## 📚 موارد إضافية

- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in)
- [Facebook Login Documentation](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Authentication](https://firebase.google.com/docs/auth) (بديل موحد)

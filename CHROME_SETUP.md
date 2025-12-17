# Chrome Setup Instructions

## 🔧 **Step 1: Update API Configuration for Web**

You need to find your computer's IP address and update the API service.

### Find Your IP Address:
1. Open Command Prompt (cmd)
2. Type: `ipconfig`
3. Look for "IPv4 Address" under your network adapter
4. Usually looks like: `192.168.1.x` or `10.0.0.x`

### Update API Service:
1. Open `lib/services/api_service.dart`
2. Find line 4: `static const String baseUrl = 'http://localhost/tabibek/backend/api';`
3. Replace `localhost` with your IP address:
   ```dart
   static const String baseUrl = 'http://192.168.1.100/tabibek/backend/api';
   // Replace 192.168.1.100 with your actual IP
   ```

## 🗄️ **Step 2: Set Up Database**

### If you get "table already exists" error:
1. Open phpMyAdmin
2. Select `tabibak` database
3. Go to SQL tab
4. Run `backend/database/cleanup_database.sql`
5. Then run `backend/database/schema_minimal.sql`

## 🌐 **Step 3: Run in Chrome**

```bash
flutter run -d chrome
```

## 📱 **Step 4: Test Registration**

1. Open the app in Chrome
2. Go to Registration screen
3. Fill in all fields including password
4. Password must be at least 6 characters
5. Confirm password must match
6. Submit registration

## 🔍 **Step 5: Verify in Database**

1. Check phpMyAdmin → `tabibak` → `users` table
2. Your new user should appear there
3. Password is hashed (secure)

## 🧪 **Test with Sample Accounts**

- Admin: admin@tabibak.com / password
- Doctor: doctor@tabibak.com / password  
- Patient: patient@tabibak.com / password

## ⚠️ **Troubleshooting**

### If connection fails:
1. Check Wampserver is running
2. Verify IP address is correct
3. Ensure backend files are in `C:\wamp64\www\tabibek\`
4. Check MySQL service is running

### If registration fails:
1. Check all required fields are filled
2. Password must be 6+ characters
3. Email must be valid format
4. Phone must be numbers only
5. Must agree to terms

The registration form includes password fields - just make sure to fill them in!
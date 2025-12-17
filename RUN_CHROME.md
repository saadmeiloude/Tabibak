# Running Flutter App in Chrome

## ✅ **Step 1: Update IP Address (IMPORTANT)**

I've updated the API service, but you may need to change the IP address:

### Find Your IP Address:
1. Open Command Prompt (cmd)
2. Type: `ipconfig`
3. Look for "IPv4 Address" under your network adapter
4. Usually looks like: `192.168.1.x` or `10.0.x.x`

### Update API Service:
If your IP is different from `192.168.1.100`:
1. Open `lib/services/api_service.dart`
2. Change line 7:
   ```dart
   static const String baseUrl = 'http://192.168.1.100/tabibek/backend/api';
   ```
   Replace `192.168.1.100` with your actual IP

## 🗄️ **Step 2: Setup Database**

### If you get "table already exists" error:
1. Open phpMyAdmin
2. Select `tabibak` database
3. Go to SQL tab
4. Run: `backend/database/cleanup_database.sql`
5. Then run: `backend/database/schema_minimal.sql`

## 🌐 **Step 3: Run in Chrome**

```bash
flutter run -d chrome
```

## 🧪 **Step 4: Test Authentication**

### Test Registration:
1. Open the app in Chrome
2. Go to Registration screen
3. Fill in all fields including password
4. Password must be 6+ characters
5. Submit registration

### Test Login:
Use these credentials:
- admin@tabibak.com / password
- doctor@tabibak.com / password
- patient@tabibak.com / password

## ⚠️ **Troubleshooting**

### If connection fails:
1. Check Wampserver is running
2. Verify IP address is correct
3. Ensure backend files are in `C:\wamp64\www\tabibek\`
4. Check MySQL service is running

### If registration/login fails:
1. Check all required fields are filled
2. Password must be 6+ characters
3. Email must be valid format
4. Must agree to terms

## 📱 **Expected Behavior**

1. **Registration**: Creates new user in MySQL database
2. **Login**: Authenticates against MySQL database
3. **Navigation**: Goes to main screen after successful login
4. **Database**: Check phpMyAdmin to see new users

The authentication system is now connected to MySQL database!
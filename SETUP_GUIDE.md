# Tabibek Medical App - MySQL Database Integration Guide

## Overview
This guide will help you integrate your Flutter app with a MySQL database using Wampserver64 for user authentication and dynamic data storage.

## Prerequisites
- Wampserver64 installed and running
- MySQL database access
- Flutter development environment

## Part 1: Database Setup

### Step 1: Create Database and Tables
1. Open Wampserver64 and ensure MySQL is running
2. Open phpMyAdmin (usually accessible at http://localhost/phpmyadmin)
3. Create a new database named `tabibak`
4. Import the SQL schema:
   - Go to the `backend/database/` folder
   - Open `schema.sql` and copy its contents
   - In phpMyAdmin, select the `tabibak` database
   - Go to the SQL tab and paste the schema
   - Click "Go" to execute

### Step 2: Verify Database Structure
After importing, you should see these tables:
- `users` - User accounts and profiles
- `doctors` - Doctor-specific information
- `appointments` - Appointment bookings
- `medical_records` - Patient medical history
- `reviews` - Doctor reviews and ratings
- `notifications` - User notifications
- `messages` - Chat messages
- `user_sessions` - Authentication tokens
- `password_resets` - Password reset tokens

## Part 2: Backend API Setup

### Step 1: Deploy PHP Files
1. Copy the entire `backend/` folder to your Wamp64 directory:
   ```
   C:\wamp64\www\tabibek\
   ```
   
2. Ensure your directory structure looks like:
   ```
   C:\wamp64\www\tabibek\
   ├── backend/
   │   ├── api/
   │   │   ├── auth/
   │   │   │   ├── login.php
   │   │   │   ├── register.php
   │   │   │   └── logout.php
   │   ├── config/
   │   │   └── database.php
   │   └── database/
   │       └── schema.sql
   ```

### Step 2: Configure Database Connection
The database configuration in `backend/config/database.php` is already set up with:
- Host: localhost
- Database: tabibak
- Username: root
- Password: (empty)

### Step 3: Test API Endpoints
You can test the API endpoints using:
- **Login**: `http://localhost/tabibek/backend/api/auth/login.php`
- **Register**: `http://localhost/tabibek/backend/api/auth/register.php`
- **Logout**: `http://localhost/tabibek/backend/api/auth/logout.php`

## Part 3: Flutter App Configuration

### Step 1: Install Dependencies
Run the following command in your Flutter project directory:
```bash
flutter pub get
```

### Step 2: Update API Base URL
In `lib/services/api_service.dart`, update the base URL if needed:
```dart
static const String baseUrl = 'http://localhost/tabibek/backend/api';
```

**Important**: For Android devices, you may need to use your computer's IP address instead of `localhost`:
```dart
static const String baseUrl = 'http://192.168.1.100/tabibek/backend/api'; // Replace with your IP
```

### Step 3: Configure Network Permissions
For Android, add internet permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

For iOS, ensure `Info.plist` includes:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Part 4: Testing the Authentication Flow

### Step 1: Register a New User
1. Run the Flutter app
2. Navigate to the registration screen
3. Fill in the registration form:
   - Full Name: Any name
   - Email: Any valid email
   - Phone: Any valid phone number (numbers only)
   - Password: At least 6 characters
   - Verification Method: SMS or Email
4. Submit the form

### Step 2: Login with New User
1. After registration, navigate to login
2. Use the same email and password you just registered
3. The app should authenticate and navigate to the main screen

### Step 3: Test Database Connection
Check the `users` table in phpMyAdmin to see if your registration was stored:
1. Open phpMyAdmin
2. Select the `tabibak` database
3. Click on the `users` table
4. You should see your new user entry

## Part 5: Sample Data and Test Accounts

The database schema includes some sample accounts:

### Admin Account
- Email: admin@tabibak.com
- Password: password

### Doctor Account
- Email: doctor@tabibak.com
- Password: password

### Patient Account
- Email: patient@tabibak.com
- Password: password

## Part 6: Troubleshooting

### Common Issues and Solutions

1. **Connection Refused Error**
   - Ensure Wampserver is running
   - Check if MySQL service is started
   - Verify the base URL in `api_service.dart`

2. **Database Connection Failed**
   - Check database credentials in `database.php`
   - Ensure the `tabibak` database exists
   - Verify MySQL is running on port 3306

3. **Flutter Network Error**
   - Add internet permissions to Android manifest
   - Use computer IP address instead of localhost for Android devices
   - Check firewall settings

4. **CORS Errors**
   - The PHP backend includes CORS headers
   - If issues persist, check browser developer tools

### Debug Steps
1. Check Wampserver logs for PHP errors
2. Use browser developer tools to monitor API requests
3. Check Flutter console for network errors
4. Verify database connection using phpMyAdmin

## Part 7: Next Steps

Once authentication is working, you can extend the system:

1. **Additional API Endpoints**: Create endpoints for appointments, medical records, etc.
2. **Profile Management**: Implement user profile updates
3. **Doctor Services**: Add doctor-specific functionality
4. **Real-time Features**: Implement chat and notifications
5. **Security Enhancements**: Add rate limiting, input validation, etc.

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify all files are in the correct locations
3. and Ensure Wampserver MySQL are properly configured
4. Test API endpoints directly in a browser or Postman

## File Structure Reference

```
projet_integrateure/
├── backend/                          # PHP Backend (copy to www/tabibek/)
│   ├── api/
│   │   ├── auth/
│   │   │   ├── login.php            # User login endpoint
│   │   │   ├── register.php         # User registration endpoint
│   │   │   └── logout.php           # User logout endpoint
│   │   └── user/
│   │       └── profile.php          # Profile management (to be created)
│   ├── config/
│   │   └── database.php             # Database configuration
│   └── database/
│       └── schema.sql               # Database schema
├── lib/
│   ├── services/
│   │   ├── api_service.dart         # HTTP client service
│   │   ├── auth_service.dart        # Authentication service
│   │   └── data_service.dart        # Data management service
│   └── screens/
│              # Updated ├── login_screen.dart login screen
│       └── register_screen.dart     # Updated registration screen
└── pubspec.yaml                     # Updated dependencies
```

## Security Notes

1. **Password Security**: Passwords are hashed using PHP's `password_hash()` function
2. **Session Management**: Uses JWT-like tokens stored in database
3. **Input Validation**: All inputs are validated and sanitized
4. **CORS Configuration**: Configured for cross-origin requests
5. **SQL Injection Prevention**: Uses prepared statements

For production deployment, consider:
- Using HTTPS
- Implementing rate limiting
- Adding more robust input validation
- Setting up proper session management
- Implementing refresh tokens
- Adding email/SMS verification
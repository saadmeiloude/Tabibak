# API Examples - Flutter Integration

Ce document fournit des exemples concrets d'utilisation des services Flutter avec le backend Spring Boot.

## 📋 Table des Matières
- [Authentication](#authentication)
- [Appointments](#appointments)
- [Doctors](#doctors)
- [Patients](#patients)
- [Medical Records](#medical-records)
- [Wallet & Transactions](#wallet--transactions)
- [Chat & Messages](#chat--messages)
- [Reviews](#reviews)
- [Articles](#articles)

---

## Authentication

### Login
```dart
import 'package:tabibek/services/auth_service.dart';

Future<void> loginExample() async {
  final result = await AuthService.login(
    'patient@example.com',
    'password123',
  );

  if (result['success'] == true) {
    final user = result['user'];
    print('Logged in as: ${user['firstName']} ${user['lastName']}');
    print('Role: ${user['role']}');
  } else {
    print('Login failed: ${result['message']}');
  }
}
```

### Register Patient
```dart
Future<void> registerPatientExample() async {
  final result = await AuthService.register(
    fullName: 'John Doe',
    email: 'john.doe@example.com',
    password: 'securePassword123',
    phone: '+1234567890',
    verificationMethod: 'email',
    dateOfBirth: '1990-01-15',
    gender: 'MALE',
    address: '123 Main St, New York',
    emergencyContact: '+0987654321',
  );

  if (result['success'] == true) {
    print('Registration successful!');
  } else {
    print('Registration failed: ${result['message']}');
  }
}
```

### Register Doctor
```dart
Future<void> registerDoctorExample() async {
  final result = await AuthService.registerDoctor(
    fullName: 'Dr. Jane Smith',
    email: 'dr.smith@hospital.com',
    password: 'doctorPass123',
    phone: '+1234567890',
    licenseNumber: 'MD123456',
    specialization: 'Cardiology',
    consultationFee: 200.0,
    experienceYears: 15,
  );

  if (result['success'] == true) {
    print('Doctor registration successful!');
  } else {
    print('Registration failed: ${result['message']}');
  }
}
```

---

## Appointments

### Create Appointment
```dart
import 'package:tabibek/services/data_service.dart';

Future<void> createAppointmentExample() async {
  final result = await DataService.createAppointment(
    doctorId: 2,
    appointmentDate: DateTime(2026, 1, 15),
    appointmentTime: DateTime(2026, 1, 15, 10, 0),
    patientId: 5, // Optional, auto-detected from token
    symptoms: 'Chest pain and shortness of breath',
    consultationType: 'online',
    durationMinutes: 30,
  );

  if (result['success'] == true) {
    final appointment = result['appointment'];
    print('Appointment created: ${appointment.id}');
    print('Date: ${appointment.appointmentDate}');
    print('Status: ${appointment.status}');
  } else {
    print('Failed: ${result['message']}');
  }
}
```

### Get User Appointments
```dart
Future<void> getUserAppointmentsExample() async {
  final result = await DataService.getUserAppointments();

  if (result['success'] == true) {
    final appointments = result['appointments'] as List<Appointment>;
    print('Found ${appointments.length} appointments');
    
    for (var apt in appointments) {
      print('${apt.doctorName} - ${apt.appointmentDate} - ${apt.status}');
    }
  }
}
```

### Cancel Appointment
```dart
Future<void> cancelAppointmentExample() async {
  final result = await DataService.cancelAppointment(1);

  if (result['success'] == true) {
    print('Appointment cancelled successfully');
  } else {
    print('Failed: ${result['message']}');
  }
}
```

---

## Doctors

### Get All Doctors
```dart
Future<void> getDoctorsExample() async {
  final result = await DataService.getDoctors();

  if (result['success'] == true) {
    final doctors = result['doctors'] as List<Doctor>;
    
    for (var doctor in doctors) {
      print('${doctor.name} - ${doctor.specialty}');
      print('Rating: ${doctor.rating} (${doctor.reviewCount} reviews)');
      print('Fee: \$${doctor.consultationFee}');
      print('---');
    }
  }
}
```

### Get Doctors by Specialty
```dart
Future<void> getDoctorsBySpecialtyExample() async {
  final result = await DataService.getDoctors(
    specialization: 'Cardiology',
  );

  if (result['success'] == true) {
    final doctors = result['doctors'] as List<Doctor>;
    print('Found ${doctors.length} cardiologists');
  }
}
```

### Get Doctor Details
```dart
Future<void> getDoctorDetailsExample() async {
  final result = await DataService.getDoctorDetails(2);

  if (result['success'] == true) {
    final doctor = result['doctor'] as Doctor;
    print('Name: ${doctor.name}');
    print('Specialty: ${doctor.specialty}');
    print('Experience: ${doctor.experienceYears} years');
    print('Bio: ${doctor.bio}');
    print('Clinic: ${doctor.clinicAddress}');
  }
}
```

---

## Patients

### Get Patient Details
```dart
Future<void> getPatientDetailsExample() async {
  final result = await DataService.getPatientDetails(5);

  if (result['success'] == true) {
    final patient = result['data'];
    print('Patient: ${patient['name']}');
    print('Blood Type: ${patient['bloodType']}');
    print('Allergies: ${patient['allergies']}');
  }
}
```

### Save Patient (Create or Update)
```dart
Future<void> savePatientExample() async {
  final patientData = {
    'userId': 5,
    'phone': '+1234567890',
    'birthDate': '1990-01-15',
    'gender': 'MALE',
    'bloodType': 'A_POSITIVE',
    'address': '123 Main St',
    'city': 'New York',
    'country': 'USA',
    'emergencyContactName': 'Jane Doe',
    'emergencyContactPhone': '+0987654321',
    'allergies': ['Penicillin', 'Peanuts'],
    'currentMedications': ['Metformin'],
    'insuranceProvider': 'Blue Cross',
    'insuranceNumber': 'BC123456',
  };

  final result = await DataService.savePatient(patientData);

  if (result['success'] == true) {
    print('Patient saved successfully');
  }
}
```

---

## Medical Records

### Get Patient Records
```dart
Future<void> getPatientRecordsExample() async {
  final result = await DataService.getPatientRecords(patientId: 5);

  if (result['success'] == true) {
    final records = result['records'] as List<MedicalRecord>;
    
    for (var record in records) {
      print('${record.title} - ${record.recordType}');
      print('Date: ${record.recordDate}');
      print('Diagnosis: ${record.diagnosis}');
      print('Treatment: ${record.treatment}');
      print('---');
    }
  }
}
```

### Create Medical Record
```dart
Future<void> createMedicalRecordExample() async {
  final result = await DataService.createMedicalRecord(
    doctorId: 2,
    recordType: 'CONSULTATION',
    title: 'Regular Checkup',
    patientId: 5,
    description: 'Patient presented with mild symptoms',
    diagnosis: 'Common cold',
    treatment: 'Rest and fluids',
    medications: 'Paracetamol 500mg',
    appointmentId: 1,
  );

  if (result['success'] == true) {
    final record = result['record'] as MedicalRecord;
    print('Medical record created: ${record.id}');
  }
}
```

---

## Wallet & Transactions

### Get Wallet Balance
```dart
import 'package:tabibek/services/wallet_service.dart';

Future<void> getBalanceExample() async {
  final result = await WalletService.getBalance(userId: 5);

  if (result['success'] == true) {
    final balance = result['balance'];
    print('Current balance: \$$balance');
  }
}
```

### Deposit Money
```dart
Future<void> depositExample() async {
  final result = await WalletService.deposit(
    userId: 5,
    amount: 100.0,
    paymentMethod: 'CREDIT_CARD',
  );

  if (result['success'] == true) {
    final transaction = result['transaction'];
    print('Deposit successful: \$${transaction['amount']}');
  }
}
```

### Get Transactions
```dart
Future<void> getTransactionsExample() async {
  final result = await WalletService.getTransactions(userId: 5);

  if (result['success'] == true) {
    final transactions = result['transactions'] as List;
    
    for (var tx in transactions) {
      print('${tx['type']}: \$${tx['amount']} - ${tx['status']}');
    }
  }
}
```

---

## Chat & Messages

### Create Chat Room
```dart
Future<void> createChatRoomExample() async {
  // Assuming you have a chat service
  final response = await ApiClient().post(
    '/chat/rooms',
    queryParameters: {
      'senderId': 5,
      'receiverId': 2,
    },
  );

  final chatRoom = ChatRoom.fromJson(response.data);
  print('Chat room created: ${chatRoom.id}');
}
```

### Send Message
```dart
Future<void> sendMessageExample() async {
  final message = Message(
    id: 0, // Will be set by backend
    chatRoomId: 1,
    senderId: 5,
    receiverId: 2,
    message: 'Hello Doctor, I need help',
    type: MessageType.text,
    timestamp: DateTime.now(),
    isRead: false,
    status: MessageStatus.sent,
    createdAt: DateTime.now(),
  );

  final response = await ApiClient().post(
    '/messages',
    data: message.toJson(),
  );

  print('Message sent: ${response.data['id']}');
}
```

### Get Chat Messages
```dart
Future<void> getChatMessagesExample() async {
  final response = await ApiClient().get('/messages/chatroom/1');

  final messages = (response.data as List)
      .map((json) => Message.fromJson(json))
      .toList();

  print('Found ${messages.length} messages');
}
```

---

## Reviews

### Rate Doctor
```dart
Future<void> rateDoctorExample() async {
  final result = await DataService.rateDoctor(
    doctorId: 2,
    rating: 5,
    reviewText: 'Excellent doctor, very professional and caring',
    appointmentId: 1,
  );

  if (result['success'] == true) {
    print('Review submitted successfully');
  }
}
```

### Get Doctor Reviews
```dart
Future<void> getDoctorReviewsExample() async {
  final response = await ApiClient().get('/reviews/doctor/2');

  final reviews = (response.data as List)
      .map((json) => Review.fromJson(json))
      .toList();

  for (var review in reviews) {
    print('Rating: ${review.rating}/5');
    print('Review: ${review.reviewText}');
    print('---');
  }
}
```

---

## Articles

### Get All Articles
```dart
Future<void> getArticlesExample() async {
  final result = await DataService.getResearch();

  if (result['success'] == true) {
    final articles = result['research'] as List;
    
    for (var article in articles) {
      print('${article.title}');
      print('Category: ${article.category}');
      print('Excerpt: ${article.excerpt}');
      print('---');
    }
  }
}
```

### Get Articles by Category
```dart
Future<void> getArticlesByCategoryExample() async {
  final result = await DataService.getResearch(category: 'Cardiology');

  if (result['success'] == true) {
    final articles = result['research'] as List;
    print('Found ${articles.length} cardiology articles');
  }
}
```

### Create Article
```dart
Future<void> createArticleExample() async {
  final result = await DataService.createResearch(
    title: 'Heart Health Tips',
    summary: 'Essential tips for maintaining heart health',
    content: 'Lorem ipsum dolor sit amet...',
    category: 'Cardiology',
    tags: 'heart,health,tips',
    isPublished: true,
  );

  if (result['success'] == true) {
    print('Article created successfully');
  }
}
```

---

## Error Handling

### Handling API Exceptions
```dart
import 'package:tabibek/core/exceptions/api_exception.dart';
import 'package:tabibek/core/utils/error_handler.dart';

Future<void> errorHandlingExample() async {
  try {
    final result = await DataService.getDoctors();
    
    if (result['success'] == true) {
      // Handle success
    }
  } on UnauthorizedException catch (e) {
    print('Please login again: ${e.message}');
    // Navigate to login screen
  } on NotFoundException catch (e) {
    print('Resource not found: ${e.message}');
  } on NetworkException catch (e) {
    print('No internet connection: ${e.message}');
    // Show offline UI
  } on ApiException catch (e) {
    print('API Error: ${e.message}');
    // Show error dialog
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

### Using ErrorHandler
```dart
Future<void> errorHandlerExample() async {
  try {
    final result = await DataService.getDoctors();
  } catch (e) {
    final userMessage = ErrorHandler.getUserMessage(e);
    print('Error: $userMessage');

    if (ErrorHandler.isNetworkError(e)) {
      print('Please check your internet connection');
    }

    if (ErrorHandler.requiresReauth(e)) {
      print('Session expired, please login again');
      // Navigate to login
    }
  }
}
```

---

## Best Practices

### 1. Always Handle Errors
```dart
// ❌ Bad
final result = await DataService.getDoctors();
final doctors = result['doctors'];

// ✅ Good
try {
  final result = await DataService.getDoctors();
  
  if (result['success'] == true) {
    final doctors = result['doctors'] as List<Doctor>;
    // Use doctors
  } else {
    // Handle error
    print('Error: ${result['message']}');
  }
} catch (e) {
  // Handle exception
  print('Exception: $e');
}
```

### 2. Use Null-Safety
```dart
// ✅ Good
final doctor = result['doctor'] as Doctor?;
if (doctor != null) {
  print(doctor.name);
}

// Or
final doctorName = doctor?.name ?? 'Unknown';
```

### 3. Use Async/Await Properly
```dart
// ✅ Good
Future<void> loadData() async {
  setState(() => isLoading = true);
  
  try {
    final result = await DataService.getDoctors();
    setState(() {
      doctors = result['doctors'];
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}
```

### 4. Check Success Flag
```dart
// ✅ Good
final result = await DataService.createAppointment(...);

if (result['success'] == true) {
  // Success path
} else {
  // Error path
  showError(result['message']);
}
```

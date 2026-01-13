# DTO Mapping: Spring Boot ↔ Flutter

Ce document détaille le mapping exact entre les DTOs Spring Boot et les modèles Flutter.

## 📋 Table des Matières
- [User](#user)
- [Patient](#patient)
- [Doctor](#doctor)
- [Appointment](#appointment)
- [Department](#department)
- [Consultation](#consultation)
- [ChatRoom & Message](#chatroom--message)
- [Review](#review)
- [Invoice](#invoice)
- [Notification](#notification)
- [Wallet & Transaction](#wallet--transaction)
- [Article](#article)
- [MedicalRecord](#medicalrecord)

---

## User

### Spring Boot Entity
```java
class User {
    Long id;
    String firstName;
    String lastName;
    String email;
    String avatarUrl;
    String phone;
    UserRole role; // PATIENT, DOCTOR, ADMIN
    String address;
    String emergencyContact;
    Gender gender; // MALE, FEMALE, OTHER
    LocalDate dateOfBirth;
    String verificationMethod;
    Boolean isVerified;
    Boolean isActive;
    LocalDateTime createdAt;
    LocalDateTime updatedAt;
}
```

### Flutter Model
```dart
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final UserRole role;
  final String? address;
  final String? emergencyContact;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String verificationMethod;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### JSON Example
```json
{
  "id": 1,
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "avatarUrl": "https://example.com/avatar.jpg",
  "phone": "+1234567890",
  "role": "PATIENT",
  "address": "123 Main St",
  "emergencyContact": "+0987654321",
  "gender": "MALE",
  "dateOfBirth": "1990-01-15",
  "verificationMethod": "email",
  "isVerified": true,
  "isActive": true,
  "createdAt": "2026-01-01T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

---

## Patient

### Spring Boot Entity
```java
class Patient {
    Long id;
    Long userId;
    String phone;
    LocalDate birthDate;
    Integer age;
    Gender gender;
    BloodType bloodType; // A_POSITIVE, O_NEGATIVE, etc.
    String profileImage;
    String address;
    String city;
    String country;
    String emergencyContactName;
    String emergencyContactPhone;
    List<String> medicalHistory;
    List<String> allergies;
    List<String> currentMedications;
    String insuranceProvider;
    String insuranceNumber;
    PatientStatus status; // ACTIVE, INACTIVE, DISCHARGED
    LocalDateTime lastVisit;
    LocalDateTime nextAppointment;
    Integer totalVisits;
    Integer totalAppointments;
    String assignedDoctor;
    String notes;
}
```

### Flutter Model
```dart
class Patient {
  final int id;
  final int userId;
  final String? phone;
  final DateTime? birthDate;
  final int? age;
  final Gender? gender;
  final BloodType? bloodType;
  final String? profileImage;
  final String? address;
  final String? city;
  final String? country;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final List<String> medicalHistory;
  final List<String> allergies;
  final List<String> currentMedications;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final PatientStatus status;
  final DateTime? lastVisit;
  final DateTime? nextAppointment;
  final int totalVisits;
  final int totalAppointments;
  final String? assignedDoctor;
  final String? notes;
}
```

### JSON Example
```json
{
  "id": 1,
  "userId": 5,
  "phone": "+1234567890",
  "birthDate": "1990-05-15",
  "age": 36,
  "gender": "MALE",
  "bloodType": "A_POSITIVE",
  "profileImage": "https://example.com/patient.jpg",
  "address": "123 Main St",
  "city": "New York",
  "country": "USA",
  "emergencyContactName": "Jane Doe",
  "emergencyContactPhone": "+0987654321",
  "medicalHistory": ["Diabetes", "Hypertension"],
  "allergies": ["Penicillin", "Peanuts"],
  "currentMedications": ["Metformin", "Lisinopril"],
  "insuranceProvider": "Blue Cross",
  "insuranceNumber": "BC123456",
  "status": "ACTIVE",
  "lastVisit": "2026-01-01T14:00:00",
  "nextAppointment": "2026-01-15T10:00:00",
  "totalVisits": 12,
  "totalAppointments": 15,
  "assignedDoctor": "Dr. Smith",
  "notes": "Patient requires regular checkups"
}
```

---

## Doctor

### Spring Boot Entity
```java
class Doctor {
    Long id;
    Long userId;
    String email;
    String name;
    String specialty;
    String location;
    Double rating;
    Integer reviewCount;
    String profileImage;
    String qualifications;
    Integer experienceYears;
    String bio;
    String clinicAddress;
    Double consultationFee;
    Boolean isAvailable;
    Boolean isVerified;
    String licenseNumber;
    String licenseAuthority;
    String medicalSchool;
    Integer graduationYear;
    String phone;
    String education;
    String certifications;
    String availabilitySchedule;
    Long departmentId;
}
```

### JSON Example
```json
{
  "id": 1,
  "userId": 2,
  "email": "dr.smith@hospital.com",
  "name": "Dr. John Smith",
  "specialty": "Cardiology",
  "location": "New York",
  "rating": 4.8,
  "reviewCount": 150,
  "profileImage": "https://example.com/doctor.jpg",
  "qualifications": "MD, FACC",
  "experienceYears": 15,
  "bio": "Experienced cardiologist",
  "clinicAddress": "456 Hospital Ave",
  "consultationFee": 200.00,
  "isAvailable": true,
  "isVerified": true,
  "licenseNumber": "MD123456",
  "licenseAuthority": "State Medical Board",
  "medicalSchool": "Harvard Medical School",
  "graduationYear": 2008,
  "phone": "+1234567890",
  "education": "MD from Harvard",
  "certifications": "Board Certified in Cardiology",
  "availabilitySchedule": "Mon-Fri 9AM-5PM",
  "departmentId": 1
}
```

---

## Appointment

### Spring Boot DTO
```java
class AppointmentResponseDTO {
    Long id;
    Long patientId;
    Long doctorId;
    String patientName;
    String patientPhoto;
    String doctorName;
    String department;
    String specialty;
    LocalDateTime appointmentDate;
    String time; // "HH:MM"
    AppointmentStatus status; // PENDING, CONFIRMED, COMPLETED, CANCELLED
    String notes;
}
```

### JSON Example
```json
{
  "id": 1,
  "patientId": 5,
  "doctorId": 2,
  "patientName": "John Doe",
  "patientPhoto": "https://example.com/patient.jpg",
  "doctorName": "Dr. Smith",
  "department": "Cardiology",
  "specialty": "Heart Specialist",
  "appointmentDate": "2026-01-15T10:00:00",
  "time": "10:00",
  "status": "CONFIRMED",
  "notes": "Regular checkup"
}
```

---

## Department

### JSON Example
```json
{
  "id": 1,
  "name": "Cardiology",
  "icon": "heart",
  "status": "ACTIVE",
  "bedsTotal": 50,
  "bedsOccupied": 30,
  "description": "Heart and cardiovascular care",
  "headDoctorId": 2,
  "patientsCount": 120,
  "doctorsCount": 8
}
```

---

## Consultation

### JSON Example
```json
{
  "id": 1,
  "patientId": 5,
  "doctorId": 2,
  "doctorName": "Dr. Smith",
  "specialty": "Cardiology",
  "consultationDate": "2026-01-15T14:00:00",
  "status": "SCHEDULED",
  "notes": "Follow-up consultation"
}
```

---

## ChatRoom & Message

### ChatRoom JSON
```json
{
  "id": 1,
  "senderId": 5,
  "receiverId": 2,
  "isActive": true,
  "createdAt": "2026-01-01T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

### Message JSON
```json
{
  "id": 1,
  "chatRoomId": 1,
  "senderId": 5,
  "receiverId": 2,
  "message": "Hello Doctor",
  "appointmentId": null,
  "type": "TEXT",
  "attachmentUrl": null,
  "timestamp": "2026-01-07T10:30:00",
  "isRead": false,
  "status": "SENT",
  "audioDuration": null
}
```

---

## Review

### JSON Example
```json
{
  "id": 1,
  "doctorId": 2,
  "patientId": 5,
  "rating": 5,
  "reviewText": "Excellent doctor, very professional",
  "isAnonymous": false,
  "appointmentId": 1,
  "createdAt": "2026-01-07T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

---

## Invoice

### JSON Example
```json
{
  "id": 1,
  "patientId": 5,
  "doctorId": 2,
  "patientName": "John Doe",
  "doctorName": "Dr. Smith",
  "service": "Consultation",
  "date": "2026-01-07",
  "amount": 200.00,
  "paymentMethod": "CREDIT_CARD",
  "status": "PAID"
}
```

---

## Notification

### JSON Example
```json
{
  "id": 1,
  "userId": 5,
  "type": "APPOINTMENT",
  "title": "Appointment Reminder",
  "message": "Your appointment with Dr. Smith is tomorrow at 10:00 AM",
  "timestamp": "2026-01-07T10:00:00",
  "isRead": false,
  "relatedId": 1,
  "priority": "HIGH"
}
```

---

## Wallet & Transaction

### Wallet JSON
```json
{
  "id": 1,
  "userId": 5,
  "balance": 500.00,
  "currency": "USD",
  "createdAt": "2026-01-01T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

### Transaction JSON
```json
{
  "id": 1,
  "walletId": 1,
  "amount": 200.00,
  "type": "PAYMENT",
  "status": "COMPLETED",
  "description": "Consultation payment",
  "referenceId": "INV-001",
  "createdAt": "2026-01-07T10:00:00"
}
```

---

## Article

### JSON Example
```json
{
  "id": 1,
  "title": "Heart Health Tips",
  "content": "Lorem ipsum dolor sit amet...",
  "category": "Cardiology",
  "tags": "heart,health,tips",
  "authorId": 2,
  "published": true,
  "coverImage": "https://example.com/article.jpg",
  "createdAt": "2026-01-01T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

---

## MedicalRecord

### JSON Example
```json
{
  "id": 1,
  "patientId": 5,
  "doctorId": 2,
  "appointmentId": 1,
  "recordType": "CONSULTATION",
  "title": "Regular Checkup",
  "description": "Patient presented with mild symptoms",
  "diagnosis": "Common cold",
  "treatment": "Rest and fluids",
  "medications": "Paracetamol 500mg",
  "attachments": "https://example.com/record.pdf",
  "recordDate": "2026-01-07",
  "createdAt": "2026-01-07T10:00:00",
  "updatedAt": "2026-01-07T10:00:00"
}
```

---

## 🔑 Règles de Mapping

### Conventions de Nommage
- **Spring Boot**: `camelCase` (ex: `firstName`, `lastName`)
- **Flutter**: `camelCase` (ex: `firstName`, `lastName`)
- **JSON**: `camelCase` (ex: `"firstName": "John"`)

### Types de Données

| Spring Boot | Flutter | Notes |
|-------------|---------|-------|
| `Long` | `int` | IDs et nombres entiers |
| `Integer` | `int` | Nombres entiers |
| `Double` | `double` | Nombres décimaux |
| `BigDecimal` | `double` | Montants financiers |
| `String` | `String` | Texte |
| `Boolean` | `bool` | Booléens |
| `LocalDate` | `DateTime` | Dates (format: `YYYY-MM-DD`) |
| `LocalDateTime` | `DateTime` | Dates avec heure (ISO 8601) |
| `List<String>` | `List<String>` | Listes de chaînes |
| `Enum` | `enum` | Énumérations |

### Enums

Tous les enums utilisent des valeurs en **MAJUSCULES** dans le JSON :
- `UserRole`: `PATIENT`, `DOCTOR`, `ADMIN`
- `Gender`: `MALE`, `FEMALE`, `OTHER`
- `AppointmentStatus`: `PENDING`, `CONFIRMED`, `COMPLETED`, `CANCELLED`
- etc.

### Dates

- **LocalDate** → `"YYYY-MM-DD"` (ex: `"2026-01-07"`)
- **LocalDateTime** → ISO 8601 (ex: `"2026-01-07T10:00:00"`)

### Valeurs Nullables

- Spring Boot: `@Nullable` ou types optionnels
- Flutter: `Type?` (ex: `String?`, `int?`)

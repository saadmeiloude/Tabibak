# Best Practices - Flutter Development

Guide des bonnes pratiques pour le développement Flutter avec null-safety, async/await, et gestion d'erreurs.

## 📋 Table des Matières
- [Null Safety](#null-safety)
- [Async/Await](#asyncawait)
- [Error Handling](#error-handling)
- [State Management](#state-management)
- [API Integration](#api-integration)
- [Code Organization](#code-organization)

---

## Null Safety

### Utiliser les Types Nullables Correctement

```dart
// ✅ Bon
class User {
  final int id;
  final String name;
  final String? email; // Nullable
  final String? phone; // Nullable
  
  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });
}

// ❌ Mauvais
class User {
  final int? id; // ID ne devrait jamais être null
  final String? name; // Name requis, ne devrait pas être null
}
```

### Gérer les Valeurs Nullables

```dart
// ✅ Bon - Utiliser l'opérateur ??
final displayName = user.name ?? 'Unknown User';

// ✅ Bon - Utiliser l'opérateur ?.
final emailLength = user.email?.length ?? 0;

// ✅ Bon - Vérifier null avant utilisation
if (user.email != null) {
  sendEmail(user.email!); // ! est sûr ici
}

// ❌ Mauvais - Force unwrap sans vérification
sendEmail(user.email!); // Peut crasher si null
```

### Valeurs par Défaut

```dart
// ✅ Bon
class Patient {
  final PatientStatus status;
  final int totalVisits;
  
  Patient({
    this.status = PatientStatus.active,
    this.totalVisits = 0,
  });
}

// ✅ Bon - Dans fromJson
factory Patient.fromJson(Map<String, dynamic> json) {
  return Patient(
    status: json['status'] != null
        ? PatientStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
            orElse: () => PatientStatus.active)
        : PatientStatus.active,
    totalVisits: json['totalVisits'] ?? 0,
  );
}
```

---

## Async/Await

### Utiliser async/await Correctement

```dart
// ✅ Bon
Future<List<Doctor>> loadDoctors() async {
  try {
    final result = await DataService.getDoctors();
    
    if (result['success'] == true) {
      return result['doctors'] as List<Doctor>;
    }
    return [];
  } catch (e) {
    print('Error loading doctors: $e');
    return [];
  }
}

// ❌ Mauvais - Pas de gestion d'erreur
Future<List<Doctor>> loadDoctors() async {
  final result = await DataService.getDoctors();
  return result['doctors']; // Peut crasher
}
```

### Éviter les Appels Séquentiels Inutiles

```dart
// ❌ Mauvais - Séquentiel (lent)
Future<void> loadData() async {
  final doctors = await DataService.getDoctors();
  final patients = await DataService.getPatients();
  final appointments = await DataService.getUserAppointments();
}

// ✅ Bon - Parallèle (rapide)
Future<void> loadData() async {
  final results = await Future.wait([
    DataService.getDoctors(),
    DataService.getPatients(),
    DataService.getUserAppointments(),
  ]);
  
  final doctors = results[0]['doctors'];
  final patients = results[1]['patients'];
  final appointments = results[2]['appointments'];
}
```

### Utiliser FutureBuilder dans les Widgets

```dart
// ✅ Bon
class DoctorsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DataService.getDoctors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data?['success'] != true) {
          return Center(child: Text('No doctors found'));
        }
        
        final doctors = snapshot.data!['doctors'] as List<Doctor>;
        
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return DoctorCard(doctor: doctors[index]);
          },
        );
      },
    );
  }
}
```

---

## Error Handling

### Gérer les Exceptions API

```dart
// ✅ Bon - Gestion complète des erreurs
Future<void> createAppointment() async {
  try {
    setState(() => isLoading = true);
    
    final result = await DataService.createAppointment(
      doctorId: doctorId,
      appointmentDate: selectedDate,
      appointmentTime: selectedTime,
    );
    
    if (result['success'] == true) {
      showSuccessMessage('Appointment created successfully');
      Navigator.pop(context);
    } else {
      showErrorMessage(result['message'] ?? 'Failed to create appointment');
    }
  } on UnauthorizedException catch (e) {
    showErrorMessage('Please login again');
    Navigator.pushReplacementNamed(context, '/login');
  } on NetworkException catch (e) {
    showErrorMessage('No internet connection');
  } on ApiException catch (e) {
    showErrorMessage(e.message);
  } catch (e) {
    showErrorMessage('An unexpected error occurred');
    print('Error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}
```

### Créer des Messages d'Erreur Utilisateur

```dart
// ✅ Bon
void showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}

// ✅ Bon - Avec ErrorHandler
void handleError(dynamic error) {
  final userMessage = ErrorHandler.getUserMessage(error);
  showErrorMessage(userMessage);
  
  if (ErrorHandler.requiresReauth(error)) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

---

## State Management

### Utiliser setState Correctement

```dart
// ✅ Bon
class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> appointments = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await DataService.getUserAppointments();
      
      if (result['success'] == true) {
        setState(() {
          appointments = result['appointments'] as List<Appointment>;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointment: appointments[index]);
      },
    );
  }
}
```

---

## API Integration

### Vérifier le Flag Success

```dart
// ✅ Bon
final result = await DataService.getDoctors();

if (result['success'] == true) {
  final doctors = result['doctors'] as List<Doctor>;
  // Utiliser doctors
} else {
  print('Error: ${result['message']}');
}

// ❌ Mauvais - Pas de vérification
final doctors = result['doctors']; // Peut être null si erreur
```

### Typage Correct des Résultats

```dart
// ✅ Bon
final result = await DataService.getDoctors();

if (result['success'] == true) {
  final doctors = result['doctors'] as List<Doctor>;
  
  for (var doctor in doctors) {
    print(doctor.name); // Type-safe
  }
}

// ❌ Mauvais - Pas de typage
final doctors = result['doctors'];
for (var doctor in doctors) {
  print(doctor['name']); // Pas type-safe
}
```

### Utiliser les Modèles

```dart
// ✅ Bon - Utiliser les modèles
final appointment = Appointment.fromJson(json);
print(appointment.doctorName);
print(appointment.appointmentDate);

// ❌ Mauvais - Accès direct au JSON
print(json['doctorName']);
print(json['appointmentDate']);
```

---

## Code Organization

### Structure des Fichiers

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   └── token_storage.dart
│   ├── config/
│   │   └── api_config.dart
│   ├── exceptions/
│   │   └── api_exception.dart
│   ├── utils/
│   │   └── error_handler.dart
│   └── models/
│       └── enums.dart
├── models/
│   ├── user.dart
│   ├── doctor.dart
│   ├── patient.dart
│   ├── appointment.dart
│   └── ...
├── services/
│   ├── auth_service.dart
│   ├── data_service.dart
│   ├── patient_service.dart
│   └── ...
├── screens/
│   ├── home/
│   ├── doctors/
│   ├── appointments/
│   └── ...
└── widgets/
    ├── common/
    └── ...
```

### Nommer les Fichiers et Classes

```dart
// ✅ Bon
// Fichier: appointment_card.dart
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  
  const AppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);
}

// Fichier: appointment_service.dart
class AppointmentService {
  static Future<Map<String, dynamic>> create(...) async { }
  static Future<Map<String, dynamic>> getAll() async { }
}
```

### Constantes et Configuration

```dart
// ✅ Bon - Centraliser les constantes
class AppConstants {
  static const String appName = 'Tabibak';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String doctors = '/doctors';
  static const String appointments = '/appointments';
}
```

---

## Performance

### Éviter les Rebuilds Inutiles

```dart
// ✅ Bon - Utiliser const
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('Hello'); // const évite les rebuilds
  }
}

// ✅ Bon - Extraire les widgets statiques
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  
  const DoctorCard({Key? key, required this.doctor}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildHeader(), // Widget séparé
          _buildBody(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() => const Text('Doctor Info');
}
```

### Utiliser ListView.builder

```dart
// ✅ Bon - Lazy loading
ListView.builder(
  itemCount: doctors.length,
  itemBuilder: (context, index) {
    return DoctorCard(doctor: doctors[index]);
  },
)

// ❌ Mauvais - Charge tout en mémoire
ListView(
  children: doctors.map((d) => DoctorCard(doctor: d)).toList(),
)
```

---

## Testing

### Tester les Modèles

```dart
void main() {
  test('User fromJson should parse correctly', () {
    final json = {
      'id': 1,
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john@example.com',
      'role': 'PATIENT',
      'isVerified': true,
      'isActive': true,
      'createdAt': '2026-01-01T10:00:00',
      'updatedAt': '2026-01-01T10:00:00',
    };

    final user = User.fromJson(json);

    expect(user.id, 1);
    expect(user.firstName, 'John');
    expect(user.lastName, 'Doe');
    expect(user.email, 'john@example.com');
    expect(user.role, UserRole.patient);
    expect(user.isVerified, true);
  });
}
```

---

## Résumé des Bonnes Pratiques

### ✅ À FAIRE
- Toujours gérer les erreurs avec try-catch
- Vérifier le flag `success` dans les résultats API
- Utiliser les types nullables correctement (`String?`)
- Utiliser `const` pour les widgets statiques
- Extraire les widgets complexes en composants
- Utiliser `ListView.builder` pour les longues listes
- Centraliser les constantes et configuration
- Typer correctement les résultats (`as List<Doctor>`)
- Utiliser les modèles au lieu d'accéder au JSON brut

### ❌ À ÉVITER
- Force unwrap (`!`) sans vérification null
- Ignorer les erreurs
- Appels API séquentiels quand parallèle possible
- Widgets non-const qui pourraient l'être
- Accès direct au JSON sans modèles
- `ListView` avec `.toList()` pour grandes listes
- Hardcoder les valeurs dans le code

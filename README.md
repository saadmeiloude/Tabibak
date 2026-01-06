# Tabibek 🏥

**Tabibek** est une application mobile complète développée en Flutter, conçue pour faciliter la connexion entre patients et professionnels de santé. Elle offre une plateforme intuitive pour la gestion des rendez-vous médicaux, le suivi des dossiers patients et la télé-médecine.

---

## 📋 Table des Matières
- [Description](#-description)
- [Fonctionnalités Principales](#-fonctionnalités-principales)
- [Technologies Utilisées](#-technologies-utilisées)
- [Architecture du Projet](#-architecture-du-projet)
- [Structure des Dossiers](#-structure-des-dossiers)
- [Installation et Configuration](#-installation-et-configuration)
- [Bonnes Pratiques](#-bonnes-pratiques)
- [Auteur](#-auteur)

---

## 📝 Description
L'objectif de **Tabibek** est de moderniser l'accès aux soins en digitalisant le parcours patient. L'application permet aux utilisateurs de trouver des médecins par spécialité, de réserver des créneaux, et de gérer leurs documents médicaux en toute sécurité. Pour les médecins, elle offre un tableau de bord de gestion de leur activité.

---

## ✨ Fonctionnalités Principales

### Pour les Patients
*   **Authentification Sécurisée** : Connexion classique, récupération de mot de passe.
*   **Recherche de Médecins** : Filtrage par spécialité et disponibilité.
*   **Gestion des Rendez-vous** : Prise de RDV, annulation, report.
*   **Dossier Médical** : Upload et consultation de documents médicaux (ordonnances, analyses).
*   **Portefeuille (Wallet)** : Gestion des paiements et solde virtuel.
*   **Notifications** : Rappels de rendez-vous et alertes système.

### Pour les Médecins
*   **Tableau de Bord** : Vue d'ensemble des statistiques et rendez-vous du jour.
*   **Gestion de Planning** : Définition des disponibilités.
*   **Dossiers Patients** : Accès à l'historique médical des patients.

---

## 🛠 Technologies Utilisées
Ce projet s'appuie sur un ensemble robuste de technologies Flutter :

*   **Framework** : Flutter SDK (>=3.10.3)
*   **Langage** : Dart
*   **State Management** : [Provider](https://pub.dev/packages/provider) v6.x
*   **Réseau** : [http](https://pub.dev/packages/http) pour les appels API REST.
*   **Internationalisation** : `flutter_localizations` & `intl`.
*   **Gestion des Assets** : `image_picker`, `file_picker`.
*   **UI/UX** : `google_fonts`, `cupertino_icons`.
*   **Stockage Local** : `shared_preferences`.

---

## 🏗 Architecture du Projet
Le projet suit une architecture en **couches (Layered Architecture)**, séparant clairement la présentation de la logique métier data :

1.  **Presentation Layer (`screens/`, `widgets/`)** : Composants UI réactifs.
2.  **Service Layer (`services/`)** : Gestion de la logique métier et communication avec l'API (ex: `AuthService`, `DataService`).
3.  **Core Layer (`core/`)** : Constantes, Thèmes, Utils partagés.

Le pattern **Provider** est utilisé pour l'injection de dépendances et la gestion d'état, permettant une réactivité fluide de l'interface.

---

## 📂 Structure des Dossiers

```
lib/
├── core/                  # Cœur de l'application
│   ├── constants/         # Couleurs, styles, routes API
│   └── localization/      # Configuration des langues
├── l10n/                  # Fichiers de traduction (.arb)
├── screens/               # Écrans de l'application (Pages)
│   ├── doctor/            # Écrans spécifiques aux médecins
│   └── ...                # Écrans généraux (Login, Home, Profile)
├── services/              # Logique métier et appels API
│   ├── api_service.dart   # Client HTTP générique
│   ├── auth_service.dart  # Gestion authentification
│   └── data_service.dart  # Gestion des données (RDV, Médecins...)
├── widgets/               # Widgets réutilisables (Boutons, Champs texte...)
└── main.dart              # Point d'entrée
```

---

## 🚀 Installation et Configuration

### Prérequis
*   Flutter SDK installé et configuré.
*   Un émulateur Android/iOS ou un appareil physique.

### Étapes d'installation
1.  **Cloner le dépôt**
    ```bash
    git clone https://github.com/votre-username/tabibek.git
    cd tabibek
    ```

2.  **Installer les dépendances**
    ```bash
    flutter pub get
    ```

3.  **Lancer l'application**
    ```bash
    flutter run
    ```

---

## 📱 Captures d'Écran

| Accueil | Recherche | Profil Médecin | Profil Utilisateur |
|:---:|:---:|:---:|:---:|
| ![Accueil](assets/screenshots/home_placeholder.png) | ![Recherche](assets/screenshots/search_placeholder.png) | ![Docteur](assets/screenshots/doctor_placeholder.png) | ![Profil](assets/screenshots/profile_placeholder.png) |

---

## ✅ Bonnes Pratiques Appliquées
*   **Linting Strict** : Utilisation de `flutter_lints` pour garantir la qualité du code.
*   **Internationalisation (i18n)** : Application prête pour le multilingue (Arabe/Français/Anglais).
*   **Typage Fort** : Utilisation intensive du système de types de Dart.
*   **Gestion d'Erreurs** : Services API robustes avec gestion des exceptions.

---

## 🔮 Améliorations Futures
*   Migration vers **Clean Architecture** pour une meilleure scalabilité.
*   Mise en place de **Tests Unitaires et d'Intégration**.
*   Ajout d'un mode **Sombre (Dark Mode)** complet.
*   intégration de **WebSockets** pour le chat en temps réel.

---

## ✍️ Auteur
**Équipe Tabibek**
*Conçu avec ❤️ en Flutter*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/l10n/app_${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get fullName => translate('full_name');
  String get phone => translate('phone');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get logout => translate('logout');

  String get home => translate('home');
  String get appointments => translate('appointments');
  String get doctors => translate('doctors');
  String get profile => translate('profile');
  String get settings => translate('settings');

  String get search => translate('search');
  String get searchDoctors => translate('search_doctors');
  String get searchSpecialties => translate('search_specialties');
  String get filter => translate('filter');
  String get all => translate('all');

  String get bookAppointment => translate('book_appointment');
  String get consultation => translate('consultation');
  String get instantConsultation => translate('instant_consultation');
  String get medicalConsultation => translate('medical_consultation');
  String get videoConsultation => translate('video_consultation');
  String get textConsultation => translate('text_consultation');

  String get upcoming => translate('upcoming');
  String get past => translate('past');
  String get noUpcomingAppointments => translate('no_upcoming_appointments');
  String get noPastAppointments => translate('no_past_appointments');

  String get doctorProfile => translate('doctor_profile');
  String get specialty => translate('specialty');
  String get experience => translate('experience');
  String get rating => translate('rating');
  String get reviews => translate('reviews');
  String get available => translate('available');
  String get notAvailable => translate('not_available');

  String get price => translate('price');
  String get consultationPrice => translate('consultation_price');
  String get amount => translate('amount');
  String get payment => translate('payment');
  String get paymentMethod => translate('payment_method');

  String get date => translate('date');
  String get time => translate('time');
  String get duration => translate('duration');
  String get status => translate('status');

  String get symptoms => translate('symptoms');
  String get message => translate('message');
  String get attachments => translate('attachments');
  String get uploadFiles => translate('upload_files');

  String get confirm => translate('confirm');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get share => translate('share');
  String get close => translate('close');

  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get pleaseWait => translate('please_wait');

  String get language => translate('language');
  String get arabic => translate('arabic');
  String get french => translate('french');
  String get changeLanguage => translate('change_language');

  String get nouakchott => translate('nouakchott');
  String get nouadhibou => translate('nouadhibou');
  String get zouerat => translate('zouerat');
  String get atar => translate('atar');
  String get tidjikja => translate('tidjikja');

  String get currency => translate('currency');
  String get mauritanianOuguiya => translate('mauritanian_ouguiya');

  String get startConsultation => translate('start_consultation');
  String get startVideoConsultation => translate('start_video_consultation');
  String get startTextConsultation => translate('start_text_consultation');

  String get bookingConfirmed => translate('booking_confirmed');
  String get bookingCancelled => translate('booking_cancelled');
  String get appointmentBooked => translate('appointment_booked');

  String get morning => translate('morning');
  String get afternoon => translate('afternoon');
  String get evening => translate('evening');

  String get today => translate('today');
  String get tomorrow => translate('tomorrow');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get sunday => translate('sunday');

  String get notificationSettings => translate('notification_settings');
  String get privacySettings => translate('privacy_settings');
  String get about => translate('about');
  String get help => translate('help');
  String get contactUs => translate('contact_us');

  String get myOrders => translate('my_orders');
  String get active => translate('active');
  String get completed => translate('completed');
  String get cancelled => translate('cancelled');

  String get rateService => translate('rate_service');
  String get leaveReview => translate('leave_review');
  String get yourFeedback => translate('your_feedback');

  String get rememberMe => translate('remember_me');
  String get loginBiometric => translate('login_biometric');
  String get registerNow => translate('register_now');
  String get myAccount => translate('my_account');
  String get emailNotifications => translate('email_notifications');
  String get smsNotifications => translate('sms_notifications');
  String get myCards => translate('my_cards');
  String get logoutConfirmationTitle => translate('logout_confirmation_title');
  String get logoutConfirmation => translate('logout_confirmation');
  String get todaysTip => translate('todays_tip');
  String get viewAll => translate('view_all');
  String get quickActions => translate('quick_actions');
  String get recentNotifications => translate('recent_notifications');
  String get clearAllNotifications => translate('clear_all_notifications');
  String get noNotifications => translate('no_notifications');
  String get confirmAppointment => translate('confirm_appointment');
  String get reminder => translate('reminder');
  String get specialOffer => translate('special_offer');
  String get reschedule => translate('reschedule');
  String get cancelAppointmentTitle => translate('cancel_appointment_title');
  String get cancelAppointmentConfirm =>
      translate('cancel_appointment_confirm');
  String get cancellationFeeNotice => translate('cancellation_fee_notice');
  String get yesCancel => translate('yes_cancel');
  String get noKeep => translate('no_keep');
  String get rateDoctor => translate('rate_doctor');
  String get newBooking => translate('new_booking');
  String get rescheduleDialogTitle => translate('reschedule_dialog_title');
  String get rescheduleDialogContent => translate('reschedule_dialog_content');
  String get rescheduleRedirectNotice =>
      translate('reschedule_redirect_notice');
  String get howWasYourExperience => translate('how_was_your_experience');
  String get sendRating => translate('send_rating');
  String get newBookingDialogTitle => translate('new_booking_dialog_title');
  String get newBookingDialogContent => translate('new_booking_dialog_content');
  String get appNameLocal => translate('app_name');

  // New keys
  String get searchPlaceholder => translate('search_placeholder');
  String get doctorsAvailable => translate('doctors_available');
  String get listView => translate('list_view');
  String get mapView => translate('map_view');
  String get noResults => translate('no_results');
  String get tryChangingFilters => translate('try_changing_filters');
  String get viewMap => translate('view_map');
  String get mapComingSoon => translate('map_coming_soon');
  String get doctorAvailableStatus => translate('doctor_available_status');
  String get doctorUnavailableStatus => translate('doctor_unavailable_status');
  String get viewProfile => translate('view_profile');
  String get notificationsEmptyTitle => translate('notifications_empty_title');
  String get notificationsEmptyDesc => translate('notifications_empty_desc');
  String get markAllRead => translate('mark_all_read');
  String get notificationDeleted => translate('notification_deleted');
  String get markAsRead => translate('mark_as_read');
  String get editProfileTitle => translate('edit_profile_title');
  String get saveChangesSuccess => translate('save_changes_success');
  String get pickProfileImage => translate('pick_profile_image');
  String get takePhoto => translate('take_photo');
  String get pickFromGallery => translate('pick_from_gallery');
  String get uploadMedicalReports => translate('upload_medical_reports');
  String get uploadNewFile => translate('upload_new_file');
  String get fileUploaded => translate('file_uploaded');
  String get cardiologist => translate('cardiologist');
  String get generalPractitioner => translate('general_practitioner');
  String get dermatologist => translate('dermatologist');
  String get pediatrician => translate('pediatrician');
  String get orthopedist => translate('orthopedist');
  String get entSpecialist => translate('ent_specialist');
  String get securityAlert => translate('security_alert');
  String get newLoginAlert => translate('new_login_alert');
  String get ratingRequest => translate('rating_request');
  String get ratingDesc => translate('rating_desc');
  String get medicalRecords => translate('medical_records');
  String get medicalRecordsHistory => translate('medical_records_history');
  String get uploadMedicalReportsAction =>
      translate('upload_medical_reports_action');

  // Doctor Names
  String get drAhmedElmi => translate('dr_ahmed_elmi');
  String get drSaraAhmed => translate('dr_sara_ahmed');
  String get drKhaledOmar => translate('dr_khaled_omar');
  String get drFatimaZahra => translate('dr_fatima_zahra');
  String get drMohamedOtaibi => translate('dr_mohamed_otaibi');
  String get drNoraSaad => translate('dr_nora_saad');

  // Notifications
  String get notifConfirmSara => translate('notif_confirm_sara');
  String get notifReminderAhmed => translate('notif_reminder_ahmed');
  String get notifOffer20 => translate('notif_offer_20');
  String get notifRateAhmed => translate('notif_rate_ahmed');
  String get notifSecurityLogin => translate('notif_security_login');

  // Time & Units
  String get time1HourAgo => translate('time_1_hour_ago');
  String get time3HoursAgo => translate('time_3_hours_ago');
  String get timeYesterday => translate('time_yesterday');
  String get time2DaysAgo => translate('time_2_days_ago');
  String get time3DaysAgo => translate('time_3_days_ago');
  String get currencyMru => translate('currency_mru');
  String get kmUnit => translate('km_unit');
  String get dailyTipContent => translate('daily_tip_content');

  // Login Selection
  String get selectAccountType => translate('select_account_type');
  String get loginAsPatient => translate('login_as_patient');
  String get patientDesc => translate('patient_desc');
  String get loginAsDoctor => translate('login_as_doctor');
  String get doctorDesc => translate('doctor_desc');
  String get backToWelcome => translate('back_to_welcome');

  // Welcome Screen
  String get welcomeSubtitle => translate('welcome_subtitle');
  String get startNow => translate('start_now');
  String get exploreApp => translate('explore_app');
  String get continueGoogle => translate('continue_google');
  String get continueFacebook => translate('continue_facebook');
  String get watchVideo => translate('watch_video');

  // Doctor Registration
  String get joinAsDoctor => translate('join_as_doctor');
  String get doctorRegisterSuccess => translate('doctor_register_success');
  String get licenseNumberLabel => translate('license_number_label');
  String get specializationLabel => translate('specialization_label');
  String get experienceYearsHint => translate('experience_years_hint');
  String get consultationFeeHint => translate('consultation_fee_hint');
  String get welcomeBackDoctor => translate('welcome_back_doctor');
  String get emailOrPhoneLabel => translate('email_or_phone_label');
  String get emailOrPhoneHint => translate('email_or_phone_hint');
  String get enterPasswordHint => translate('enter_password_hint');
  String get notDoctorAccountError => translate('not_doctor_account_error');
  String get todayAppointments => translate('today_appointments');
  String get newPatients => translate('new_patients');
  String get totalPatients => translate('total_patients');
  String get recentlyAddedPatients => translate('recently_added_patients');
  String get newAppointmentAction => translate('new_appointment_action');
  String get newPatientAction => translate('new_patient_action');
  String get reportsAction => translate('reports_action');
  String get patientsTitle => translate('patients_title');
  String get noPatientsData => translate('no_patients_data');
  String get viewFileAction => translate('view_file_action');
  String get lastVisitLabel => translate('last_visit_label');
  String get reportsDialogTitle => translate('reports_dialog_title');
  String get totalIncomeToday => translate('total_income_today');
  String get appointmentStatusTitle => translate('appointment_status_title');

  String get noAppointmentsToday => translate('no_appointments_today');

  // Doctor Profile New Keys
  String get calendar => translate('calendar');
  String get myProfile => translate('my_profile');
  String get personalInfo => translate('personal_info');
  String get address => translate('address');
  String get professionalInfo => translate('professional_info');
  String get educationQualifications => translate('education_qualifications');
  String get certificates => translate('certificates');
  String get saveChanges => translate('save_changes');

  // Patient List Keys
  String get patientFiles => translate('patient_files');
  String get searchPatientHint => translate('search_patient_hint');
  String get noPatientsFound => translate('no_patients_found');
  String get addNewPatientTitle => translate('add_new_patient_title');
  String get patientNameLabel => translate('patient_name_label');
  String get patientIdLabel => translate('patient_id_label');
  String get ageLabel => translate('age_label');
  String get genderLabel => translate('gender_label');
  String get bloodTypeLabel => translate('blood_type_label');
  String get allergiesLabel => translate('allergies_label');
  String get add => translate('add');
  String get patientAddedSuccess => translate('patient_added_success');
  String get patientAddedError => translate('patient_added_error');
  String get patientIdDisplay => translate('patient_id_display');

  // Appointment Management Keys
  String get appointmentManagement => translate('appointment_management');
  String get list => translate('list');
  String get noAppointments => translate('no_appointments');
  String get calendarViewUnderDev => translate('calendar_view_under_dev');
  String get confirmAttendance => translate('confirm_attendance');
  String get appointmentConfirmed => translate('appointment_confirmed');
  String get appointmentCancelled => translate('appointment_cancelled');
  String get createAppointmentTitle => translate('create_appointment_title');
  String get selectPatientLabel => translate('select_patient_label');
  String get symptomsLabel => translate('symptoms_label');
  String get create => translate('create');
  String get appointmentBookedSuccess =>
      translate('appointment_booked_success');
  String get bookingFailed => translate('booking_failed');
  String get noCustomersWarning => translate('no_customers_warning');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

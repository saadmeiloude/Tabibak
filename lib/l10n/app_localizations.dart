import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[];

  /// No description provided for @app_name.
  ///
  /// In ar, this message translates to:
  /// **'طبيبك'**
  String get app_name;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirm_password;

  /// No description provided for @full_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get full_name;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @forgot_password.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgot_password;

  /// No description provided for @dont_have_account.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dont_have_account;

  /// No description provided for @already_have_account.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get already_have_account;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @appointments.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get appointments;

  /// No description provided for @doctors.
  ///
  /// In ar, this message translates to:
  /// **'الأطباء'**
  String get doctors;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @search_doctors.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن الأطباء'**
  String get search_doctors;

  /// No description provided for @search_specialties.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الأطباء أو التخصصات'**
  String get search_specialties;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @book_appointment.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد'**
  String get book_appointment;

  /// No description provided for @consultation.
  ///
  /// In ar, this message translates to:
  /// **'استشارة'**
  String get consultation;

  /// No description provided for @instant_consultation.
  ///
  /// In ar, this message translates to:
  /// **'استشارة فورية'**
  String get instant_consultation;

  /// No description provided for @medical_consultation.
  ///
  /// In ar, this message translates to:
  /// **'الاستشارة الطبية'**
  String get medical_consultation;

  /// No description provided for @video_consultation.
  ///
  /// In ar, this message translates to:
  /// **'استشارة مرئية'**
  String get video_consultation;

  /// No description provided for @text_consultation.
  ///
  /// In ar, this message translates to:
  /// **'استشارة نصية'**
  String get text_consultation;

  /// No description provided for @upcoming.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get past;

  /// No description provided for @no_upcoming_appointments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد قادمة'**
  String get no_upcoming_appointments;

  /// No description provided for @no_past_appointments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد سابقة'**
  String get no_past_appointments;

  /// No description provided for @doctor_profile.
  ///
  /// In ar, this message translates to:
  /// **'ملف الطبيب'**
  String get doctor_profile;

  /// No description provided for @specialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص'**
  String get specialty;

  /// No description provided for @experience.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة'**
  String get experience;

  /// No description provided for @rating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'تقييم'**
  String get reviews;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @not_available.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get not_available;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @consultation_price.
  ///
  /// In ar, this message translates to:
  /// **'سعر الاستشارة'**
  String get consultation_price;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payment;

  /// No description provided for @payment_method.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get payment_method;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get duration;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @symptoms.
  ///
  /// In ar, this message translates to:
  /// **'الأعراض'**
  String get symptoms;

  /// No description provided for @message.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة'**
  String get message;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// No description provided for @upload_files.
  ///
  /// In ar, this message translates to:
  /// **'رفع ملفات أو صور'**
  String get upload_files;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get success;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @please_wait.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار'**
  String get please_wait;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get french;

  /// No description provided for @change_language.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get change_language;

  /// No description provided for @nouakchott.
  ///
  /// In ar, this message translates to:
  /// **'نواكشوط'**
  String get nouakchott;

  /// No description provided for @nouadhibou.
  ///
  /// In ar, this message translates to:
  /// **'نواذيبو'**
  String get nouadhibou;

  /// No description provided for @zouerat.
  ///
  /// In ar, this message translates to:
  /// **'زويرات'**
  String get zouerat;

  /// No description provided for @atar.
  ///
  /// In ar, this message translates to:
  /// **'أطار'**
  String get atar;

  /// No description provided for @tidjikja.
  ///
  /// In ar, this message translates to:
  /// **'تجگجة'**
  String get tidjikja;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'أوقية'**
  String get currency;

  /// No description provided for @mauritanian_ouguiya.
  ///
  /// In ar, this message translates to:
  /// **'الأوقية الموريتانية'**
  String get mauritanian_ouguiya;

  /// No description provided for @start_consultation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاستشارة'**
  String get start_consultation;

  /// No description provided for @start_video_consultation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاستشارة المرئية'**
  String get start_video_consultation;

  /// No description provided for @start_text_consultation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاستشارة النصية'**
  String get start_text_consultation;

  /// No description provided for @booking_confirmed.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الحجز'**
  String get booking_confirmed;

  /// No description provided for @booking_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحجز'**
  String get booking_cancelled;

  /// No description provided for @appointment_booked.
  ///
  /// In ar, this message translates to:
  /// **'تم حجز الموعد بنجاح'**
  String get appointment_booked;

  /// No description provided for @morning.
  ///
  /// In ar, this message translates to:
  /// **'الصباح'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In ar, this message translates to:
  /// **'بعد الظهر'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In ar, this message translates to:
  /// **'المساء'**
  String get evening;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get tomorrow;

  /// No description provided for @monday.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sunday;

  /// No description provided for @notification_settings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notification_settings;

  /// No description provided for @privacy_settings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصوصية'**
  String get privacy_settings;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get help;

  /// No description provided for @contact_us.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contact_us;

  /// No description provided for @my_orders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get my_orders;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get cancelled;

  /// No description provided for @rate_service.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الخدمة'**
  String get rate_service;

  /// No description provided for @leave_review.
  ///
  /// In ar, this message translates to:
  /// **'اترك تقييم'**
  String get leave_review;

  /// No description provided for @your_feedback.
  ///
  /// In ar, this message translates to:
  /// **'رأيك يهمنا'**
  String get your_feedback;

  /// No description provided for @remember_me.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get remember_me;

  /// No description provided for @login_biometric.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول باستخدام الوجه/البصمة'**
  String get login_biometric;

  /// No description provided for @register_now.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الآن'**
  String get register_now;

  /// No description provided for @explore_app.
  ///
  /// In ar, this message translates to:
  /// **'استكشاف التطبيق'**
  String get explore_app;

  /// No description provided for @my_account.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get my_account;

  /// No description provided for @email_notifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات البريد الإلكتروني'**
  String get email_notifications;

  /// No description provided for @sms_notifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الرسائل النصية'**
  String get sms_notifications;

  /// No description provided for @my_cards.
  ///
  /// In ar, this message translates to:
  /// **'بطاقاتي'**
  String get my_cards;

  /// No description provided for @logout_confirmation_title.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout_confirmation_title;

  /// No description provided for @logout_confirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logout_confirmation;

  /// No description provided for @todays_tip.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة اليوم'**
  String get todays_tip;

  /// No description provided for @view_all.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get view_all;

  /// No description provided for @quick_actions.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات السريعة'**
  String get quick_actions;

  /// No description provided for @recent_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات الحديثة'**
  String get recent_notifications;

  /// No description provided for @clear_all_notifications.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع الإشعارات'**
  String get clear_all_notifications;

  /// No description provided for @no_notifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get no_notifications;

  /// No description provided for @confirm_appointment.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموعد'**
  String get confirm_appointment;

  /// No description provided for @reminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير'**
  String get reminder;

  /// No description provided for @special_offer.
  ///
  /// In ar, this message translates to:
  /// **'عرض خاص'**
  String get special_offer;

  /// No description provided for @reschedule.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جدولة'**
  String get reschedule;

  /// No description provided for @cancel_appointment_title.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الموعد'**
  String get cancel_appointment_title;

  /// No description provided for @cancel_appointment_confirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إلغاء موعدك مع'**
  String get cancel_appointment_confirm;

  /// No description provided for @cancellation_fee_notice.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: قد يتم تطبيق رسوم إلغاء حسب سياسة العيادة'**
  String get cancellation_fee_notice;

  /// No description provided for @yes_cancel.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إلغاء'**
  String get yes_cancel;

  /// No description provided for @no_keep.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no_keep;

  /// No description provided for @rate_doctor.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الطبيب'**
  String get rate_doctor;

  /// No description provided for @new_booking.
  ///
  /// In ar, this message translates to:
  /// **'حجز جديد'**
  String get new_booking;

  /// No description provided for @reschedule_dialog_title.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جدولة الموعد'**
  String get reschedule_dialog_title;

  /// No description provided for @reschedule_dialog_content.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إعادة جدولة موعدك مع'**
  String get reschedule_dialog_content;

  /// No description provided for @reschedule_redirect_notice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم توجيهك إلى صفحة حجز المواعيد لتحديد موعد جديد'**
  String get reschedule_redirect_notice;

  /// No description provided for @how_was_your_experience.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك مع'**
  String get how_was_your_experience;

  /// No description provided for @send_rating.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get send_rating;

  /// No description provided for @new_booking_dialog_title.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد جديد'**
  String get new_booking_dialog_title;

  /// No description provided for @new_booking_dialog_content.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حجز موعد جديد مع'**
  String get new_booking_dialog_content;

  /// No description provided for @search_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الأطباء أو التخصصات'**
  String get search_placeholder;

  /// No description provided for @doctors_available.
  ///
  /// In ar, this message translates to:
  /// **'طبيب متاح'**
  String get doctors_available;

  /// No description provided for @list_view.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get list_view;

  /// No description provided for @map_view.
  ///
  /// In ar, this message translates to:
  /// **'خريطة'**
  String get map_view;

  /// No description provided for @no_results.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get no_results;

  /// No description provided for @try_changing_filters.
  ///
  /// In ar, this message translates to:
  /// **'جرب تغيير كلمات البحث أو المرشحات'**
  String get try_changing_filters;

  /// No description provided for @view_map.
  ///
  /// In ar, this message translates to:
  /// **'عرض الخريطة'**
  String get view_map;

  /// No description provided for @map_coming_soon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم عرض موقع الأطباء قريباً'**
  String get map_coming_soon;

  /// No description provided for @doctor_available_status.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get doctor_available_status;

  /// No description provided for @doctor_unavailable_status.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get doctor_unavailable_status;

  /// No description provided for @view_profile.
  ///
  /// In ar, this message translates to:
  /// **'عرض الملف الشخصي'**
  String get view_profile;

  /// No description provided for @notifications_empty_title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notifications_empty_title;

  /// No description provided for @notifications_empty_desc.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا جميع إشعاراتك المهمة'**
  String get notifications_empty_desc;

  /// No description provided for @mark_all_read.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد الكل كمقروء'**
  String get mark_all_read;

  /// No description provided for @notification_deleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الإشعار'**
  String get notification_deleted;

  /// No description provided for @mark_as_read.
  ///
  /// In ar, this message translates to:
  /// **'مقروء'**
  String get mark_as_read;

  /// No description provided for @edit_profile_title.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get edit_profile_title;

  /// No description provided for @save_changes_success.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات'**
  String get save_changes_success;

  /// No description provided for @pick_profile_image.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورة الملف الشخصي'**
  String get pick_profile_image;

  /// No description provided for @take_photo.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get take_photo;

  /// No description provided for @pick_from_gallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get pick_from_gallery;

  /// No description provided for @upload_medical_reports.
  ///
  /// In ar, this message translates to:
  /// **'رفع التقارير الطبية'**
  String get upload_medical_reports;

  /// No description provided for @upload_new_file.
  ///
  /// In ar, this message translates to:
  /// **'رفع ملف جديد'**
  String get upload_new_file;

  /// No description provided for @file_uploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الملف'**
  String get file_uploaded;

  /// No description provided for @cardiologist.
  ///
  /// In ar, this message translates to:
  /// **'طبيب قلب'**
  String get cardiologist;

  /// No description provided for @general_practitioner.
  ///
  /// In ar, this message translates to:
  /// **'طبيبة عامة'**
  String get general_practitioner;

  /// No description provided for @dermatologist.
  ///
  /// In ar, this message translates to:
  /// **'جلدية'**
  String get dermatologist;

  /// No description provided for @pediatrician.
  ///
  /// In ar, this message translates to:
  /// **'أطفال'**
  String get pediatrician;

  /// No description provided for @orthopedist.
  ///
  /// In ar, this message translates to:
  /// **'عظام'**
  String get orthopedist;

  /// No description provided for @ent_specialist.
  ///
  /// In ar, this message translates to:
  /// **'أنف وأذن وحنجرة'**
  String get ent_specialist;

  /// No description provided for @security_alert.
  ///
  /// In ar, this message translates to:
  /// **'إشعار الأمان'**
  String get security_alert;

  /// No description provided for @new_login_alert.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل دخول جديد من جهاز مختلف'**
  String get new_login_alert;

  /// No description provided for @rating_request.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الموعد'**
  String get rating_request;

  /// No description provided for @rating_desc.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك؟ قم بتقييم الخدمة'**
  String get rating_desc;

  /// No description provided for @medical_records.
  ///
  /// In ar, this message translates to:
  /// **'سجلاتي الصحية'**
  String get medical_records;

  /// No description provided for @medical_records_history.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السجلات الطبية'**
  String get medical_records_history;

  /// No description provided for @upload_medical_reports_action.
  ///
  /// In ar, this message translates to:
  /// **'رفع تقارير طبية'**
  String get upload_medical_reports_action;

  /// No description provided for @dr_ahmed_elmi.
  ///
  /// In ar, this message translates to:
  /// **'د. أحمد علمي'**
  String get dr_ahmed_elmi;

  /// No description provided for @dr_sara_ahmed.
  ///
  /// In ar, this message translates to:
  /// **'د. سارة أحمد'**
  String get dr_sara_ahmed;

  /// No description provided for @dr_khaled_omar.
  ///
  /// In ar, this message translates to:
  /// **'د. خالد عمر'**
  String get dr_khaled_omar;

  /// No description provided for @dr_fatima_zahra.
  ///
  /// In ar, this message translates to:
  /// **'د. فاطمة الزهراء'**
  String get dr_fatima_zahra;

  /// No description provided for @dr_mohamed_otaibi.
  ///
  /// In ar, this message translates to:
  /// **'د. محمد العتيبي'**
  String get dr_mohamed_otaibi;

  /// No description provided for @dr_nora_saad.
  ///
  /// In ar, this message translates to:
  /// **'د. نورا السعد'**
  String get dr_nora_saad;

  /// No description provided for @notif_confirm_sara.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد موعدك مع د. سارة غداً في الساعة 2:00 م'**
  String get notif_confirm_sara;

  /// No description provided for @notif_reminder_ahmed.
  ///
  /// In ar, this message translates to:
  /// **'موعدك اليوم في الساعة 10:30 ص مع د. أحمد'**
  String get notif_reminder_ahmed;

  /// No description provided for @notif_offer_20.
  ///
  /// In ar, this message translates to:
  /// **'خصم 20% على الاستشارات الطبية هذا الأسبوع'**
  String get notif_offer_20;

  /// No description provided for @notif_rate_ahmed.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك مع د. أحمد؟ قم بتقييم الخدمة'**
  String get notif_rate_ahmed;

  /// No description provided for @notif_security_login.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل دخول جديد من جهاز مختلف'**
  String get notif_security_login;

  /// No description provided for @time_1_hour_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعة'**
  String get time_1_hour_ago;

  /// No description provided for @time_3_hours_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ 3 ساعات'**
  String get time_3_hours_ago;

  /// No description provided for @time_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get time_yesterday;

  /// No description provided for @time_2_days_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ يومين'**
  String get time_2_days_ago;

  /// No description provided for @time_3_days_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ 3 أيام'**
  String get time_3_days_ago;

  /// No description provided for @currency_mru.
  ///
  /// In ar, this message translates to:
  /// **'أوقية'**
  String get currency_mru;

  /// No description provided for @km_unit.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get km_unit;

  /// No description provided for @daily_tip_content.
  ///
  /// In ar, this message translates to:
  /// **'تناول 8 أكواب من الماء يومياً للحفاظ على الترطيب.'**
  String get daily_tip_content;

  /// No description provided for @select_account_type.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحساب للدخول'**
  String get select_account_type;

  /// No description provided for @login_as_patient.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول كمريض'**
  String get login_as_patient;

  /// No description provided for @patient_desc.
  ///
  /// In ar, this message translates to:
  /// **'احجز مواعيدك وتابع صحتك'**
  String get patient_desc;

  /// No description provided for @login_as_doctor.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول كطبيب'**
  String get login_as_doctor;

  /// No description provided for @doctor_desc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المواعيد ومتابعة المرضى'**
  String get doctor_desc;

  /// No description provided for @back_to_welcome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للشاشة الرئيسية'**
  String get back_to_welcome;

  /// No description provided for @welcome_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'صحتك، مبسطة. احجز أطباء موثوقين، مواعيد، وأدر سجلاتك الصحية في مكان واحد.'**
  String get welcome_subtitle;

  /// No description provided for @start_now.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get start_now;

  /// No description provided for @continue_google.
  ///
  /// In ar, this message translates to:
  /// **'الاستمرار باستخدام Google'**
  String get continue_google;

  /// No description provided for @continue_facebook.
  ///
  /// In ar, this message translates to:
  /// **'الاستمرار باستخدام Facebook'**
  String get continue_facebook;

  /// No description provided for @watch_video.
  ///
  /// In ar, this message translates to:
  /// **'شاهد فيديو سريع عن كيفية الحجز'**
  String get watch_video;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

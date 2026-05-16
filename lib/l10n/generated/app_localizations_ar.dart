import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سكينة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navLeaders => 'المتصدرون';

  @override
  String get navHabits => 'العادات';

  @override
  String get navProgress => 'التقدم';

  @override
  String get navMore => 'المزيد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonDone => 'تم';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonOr => 'أو';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonBack => 'رجوع';

  @override
  String get splashTagline => 'اعثر على السكينة في كل لحظة';

  @override
  String get loginWelcome => 'أهلاً بك من جديد';

  @override
  String get loginSubtitle => 'سجّل الدخول للاحتفاظ بتقدّمك عبر أجهزتك';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'كلمة المرور';

  @override
  String get loginForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginSignInButton => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get loginSignUpLink => 'إنشاء حساب';

  @override
  String get loginContinueAsGuest => 'المتابعة كزائر';

  @override
  String get loginErrorEnterPassword => 'أدخل كلمة المرور';

  @override
  String get loginErrorEnterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get loginErrorInvalidEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get loginErrorGeneric => 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get signupTitle => 'إنشاء حساب';

  @override
  String get signupSubtitle => 'احفظ عاداتك وسلاسلك وتقدّمك على السحابة';

  @override
  String get signupNameLabel => 'الاسم';

  @override
  String get signupNameHint => 'اسمك';

  @override
  String get signupNameError => 'أدخل اسمك';

  @override
  String get signupPasswordHint => '٦ أحرف على الأقل';

  @override
  String get signupConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get signupConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get signupConfirmEmptyError => 'أكّد كلمة المرور';

  @override
  String get signupConfirmMismatchError => 'كلمتا المرور غير متطابقتين';

  @override
  String get signupPasswordEmptyError => 'أدخل كلمة المرور';

  @override
  String get signupPasswordShortError => '٦ أحرف على الأقل';

  @override
  String get signupButton => 'إنشاء الحساب';

  @override
  String get signupSuccess => 'تم إنشاء الحساب. تحقّق من بريدك للتحقق من العنوان.';

  @override
  String get signupErrorGeneric => 'تعذّر إنشاء الحساب. حاول مرة أخرى.';

  @override
  String get forgotTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotBodyBefore => 'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get forgotBodyAfter => 'إذا كان هناك حساب بهذا البريد، فقد أرسلنا لك رابط إعادة التعيين. تحقّق من صندوق الوارد.';

  @override
  String get forgotSendButton => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotBackButton => 'العودة إلى تسجيل الدخول';

  @override
  String get forgotErrorGeneric => 'تعذّر إرسال بريد إعادة التعيين.';

  @override
  String get socialContinueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get socialContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get socialAppleFailed => 'تعذّر تسجيل الدخول بحساب Apple.';

  @override
  String get socialGoogleFailed => 'تعذّر تسجيل الدخول بحساب Google.';

  @override
  String get authErrInvalidEmail => 'صيغة البريد الإلكتروني غير صحيحة.';

  @override
  String get authErrUserDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get authErrCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrEmailInUse => 'يوجد حساب مسجَّل بهذا البريد بالفعل.';

  @override
  String get authErrWeakPassword => 'كلمة المرور ضعيفة. استخدم ٦ أحرف على الأقل.';

  @override
  String get authErrNotAllowed => 'طريقة تسجيل الدخول هذه غير مفعّلة.';

  @override
  String get authErrTooManyRequests => 'محاولات كثيرة. حاول مرة أخرى لاحقاً.';

  @override
  String get authErrNetwork => 'خطأ في الشبكة. تحقّق من الاتصال وحاول مجدداً.';

  @override
  String get authErrDifferentProvider => 'يوجد حساب بهذا البريد ولكن بطريقة تسجيل مختلفة.';

  @override
  String get authErrRecentLogin => 'يرجى تسجيل الدخول مرة أخرى للمتابعة.';

  @override
  String get authErrGeneric => 'فشل التحقّق. حاول مرة أخرى.';

  @override
  String get authErrNotSignedIn => 'غير مسجَّل الدخول.';

  @override
  String get authErrAppleOnlyIOS => 'تسجيل الدخول بـ Apple متاح فقط على iOS.';

  @override
  String get authErrSignOutFailed => 'تعذّر تسجيل الخروج.';

  @override
  String get guestBannerTitle => 'احفظ تقدّمك';

  @override
  String get guestBannerSubtitle => 'سجّل الدخول لمزامنة بياناتك عبر الأجهزة';

  @override
  String get guestBannerCta => 'تسجيل الدخول';

  @override
  String get accountCardSaveTitle => 'احفظ تقدّمك';

  @override
  String get accountCardSaveBody => 'سجّل الدخول لحفظ عاداتك وسلاسلك عبر أجهزتك.';

  @override
  String get accountCardSignInCta => 'تسجيل الدخول أو إنشاء حساب';

  @override
  String get accountSignedInLabel => 'مسجَّل الدخول';

  @override
  String accountSignedInWith(String provider) {
    return 'مسجَّل الدخول عبر $provider';
  }

  @override
  String accountSignedInVerified(String provider) {
    return 'مسجَّل الدخول عبر $provider • موثّق';
  }

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountProviderApple => 'Apple';

  @override
  String get accountProviderEmail => 'البريد الإلكتروني';

  @override
  String get accountProviderEmailLong => 'البريد الإلكتروني وكلمة المرور';

  @override
  String get accountSignOut => 'تسجيل الخروج';

  @override
  String get accountDeleteAccount => 'حذف الحساب';

  @override
  String get accountConfirmSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get accountConfirmSignOutBody => 'ستبقى بياناتك على هذا الجهاز. سجّل الدخول لاحقاً لاستئناف النسخ الاحتياطي على السحابة.';

  @override
  String get accountConfirmDeleteTitle => 'حذف الحساب؟';

  @override
  String get accountConfirmDeleteBody => 'سيتم حذف حسابك وكل بياناتك السحابية نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get accountDeleteConfirmButton => 'حذف';

  @override
  String get accountDeleted => 'تم حذف الحساب.';

  @override
  String get accountDeleteFailed => 'تعذّر حذف الحساب.';

  @override
  String get accountReauthFailed => 'تعذّرت إعادة التحقّق.';

  @override
  String get accountPasswordPromptTitle => 'أكّد كلمة المرور';

  @override
  String get accountPasswordPromptBody => 'لأسباب أمنية، أدخل كلمة المرور لتأكيد حذف الحساب.';

  @override
  String get accountVerifyEmail => 'تحقّق من بريدك الإلكتروني';

  @override
  String get accountVerifyRefresh => 'تحديث';

  @override
  String get accountVerifyResend => 'إعادة الإرسال';

  @override
  String get accountVerifySent => 'تم إرسال رسالة التحقّق.';

  @override
  String get accountVerifySuccess => 'تم التحقّق من البريد — شكراً لك!';

  @override
  String get accountVerifyStillNot => 'لم يتم التحقّق بعد. اضغط على الرابط في البريد ثم اضغط على تحديث.';

  @override
  String get accountVerifyRefreshFailed => 'تعذّر التحديث.';

  @override
  String get accountScreenTitle => 'الحساب';

  @override
  String get accountDetailsHeader => 'تفاصيل الحساب';

  @override
  String get accountFieldEmail => 'البريد الإلكتروني';

  @override
  String get accountFieldName => 'الاسم';

  @override
  String get accountFieldSignInMethod => 'طريقة تسجيل الدخول';

  @override
  String get accountFieldEmailVerified => 'حالة التحقّق من البريد';

  @override
  String get accountFieldEmailVerifiedYes => 'تم التحقّق';

  @override
  String get accountFieldEmailVerifiedNo => 'لم يتم بعد';

  @override
  String get accountFieldJoined => 'تاريخ الانضمام';

  @override
  String get accountFieldLastSignIn => 'آخر تسجيل دخول';

  @override
  String get accountFieldUserId => 'مُعرّف المستخدم';

  @override
  String get dashTitle => 'الرئيسية';

  @override
  String get dashGreetingMorning => 'صباح الخير';

  @override
  String get dashGreetingAfternoon => 'مساء الخير';

  @override
  String get dashGreetingEvening => 'مساء الخير';

  @override
  String get dashNextPrayer => 'الصلاة القادمة';

  @override
  String get dashDuaTitle => 'دعاء اليوم';

  @override
  String get dashDuaTapToRead => 'اضغط لقراءة دعاء اليوم';

  @override
  String get dashStatCompletion => 'الإنجاز';

  @override
  String get dashStatToday => 'اليوم';

  @override
  String get dashStatStreak => 'السلسلة';

  @override
  String dashStreakDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يوماً',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: '٠ أيام',
    );
    return '$_temp0';
  }

  @override
  String get dashQuickActions => 'إجراءات سريعة';

  @override
  String get dashAddHabit => 'إضافة عادة';

  @override
  String get dashViewStats => 'عرض الإحصاءات';

  @override
  String get dashTodayProgress => 'تقدّم اليوم';

  @override
  String dashCompletedOfTotal(int done, int total) {
    return '$done من $total مكتمل';
  }

  @override
  String get dashLocLoading => 'جارٍ التحميل…';

  @override
  String get dashLocDetecting => 'جارٍ تحديد الموقع…';

  @override
  String get dashLocDisabled => 'خدمات الموقع معطّلة';

  @override
  String get dashLocDenied => 'تم رفض إذن الموقع';

  @override
  String get dashLocDeniedForever => 'تم رفض إذن الموقع نهائياً';

  @override
  String get dashLocUnknown => 'موقع غير معروف';

  @override
  String get dashLocDetected => 'تم تحديد الموقع';

  @override
  String get dashLocUnable => 'تعذّر تحديد الموقع';

  @override
  String get habitsTitle => 'عاداتي';

  @override
  String get habitsSearchHint => 'اكتب اسم العادة للبحث';

  @override
  String get habitsFilterAll => 'الكل';

  @override
  String get habitsFilterFard => 'فرض';

  @override
  String get habitsFilterSunnah => 'سنّة';

  @override
  String get habitsCategoryFard => 'فرض';

  @override
  String get habitsCategorySunnah => 'سنّة';

  @override
  String get habitsEmptyTitle => 'لا توجد عادات بعد';

  @override
  String get habitsEmptySubtitle => 'ابدأ في بناء روتينك الروحي بإضافة عادات من مجموعتنا المختارة';

  @override
  String get habitsEmptyAction => 'أضف أول عادة';

  @override
  String habitsDayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متواصل',
      many: '$count يوماً متواصلاً',
      few: '$count أيام متواصلة',
      two: 'يومان متواصلان',
      one: 'يوم واحد متواصل',
      zero: '٠ أيام متواصلة',
    );
    return '$_temp0';
  }

  @override
  String habitsBackdateHelp(String title) {
    return 'تسجيل \"$title\" في…';
  }

  @override
  String get habitsBackdateMarkComplete => 'وضع علامة إنجاز في هذا اليوم';

  @override
  String get habitsBackdateRemove => 'إزالة الإنجاز في هذا اليوم';

  @override
  String get addHabitTitle => 'إضافة عادات';

  @override
  String addHabitSelectedCount(int count) {
    return '$count مُختارة';
  }

  @override
  String get addHabitEmpty => 'لا توجد عادات';

  @override
  String get addHabitAdded => 'مُضافة';

  @override
  String addHabitButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إضافة $count عادة',
      many: 'إضافة $count عادة',
      few: 'إضافة $count عادات',
      two: 'إضافة عادتين',
      one: 'إضافة عادة واحدة',
      zero: 'إضافة',
    );
    return '$_temp0';
  }

  @override
  String get addHabitSelectAtLeastOne => 'يرجى اختيار عادة واحدة على الأقل';

  @override
  String addHabitSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count عادة بنجاح!',
      many: 'تمت إضافة $count عادة بنجاح!',
      few: 'تمت إضافة $count عادات بنجاح!',
      two: 'تمت إضافة عادتين بنجاح!',
      one: 'تمت إضافة عادة بنجاح!',
      zero: 'لم تُضف عادات',
    );
    return '$_temp0';
  }

  @override
  String get addHabitErrorAdd => 'خطأ في إضافة العادات';

  @override
  String get addHabitErrorLoad => 'خطأ في تحميل العادات';

  @override
  String get prayerTitle => 'مواقيت الصلاة';

  @override
  String get prayerSchedule => 'جدول اليوم';

  @override
  String get prayerQibla => 'اتجاه القبلة';

  @override
  String get prayerQiblaPoint => 'وجّه هاتفك نحو أيقونة الكعبة';

  @override
  String get prayerQiblaLabel => 'القبلة';

  @override
  String get prayerTowardMakkah => 'نحو مكة المكرّمة';

  @override
  String get prayerCalibrateButton => 'إعادة معايرة البوصلة';

  @override
  String get prayerCalibrateTitle => 'معايرة البوصلة';

  @override
  String get prayerCalibrateBody => 'حرّك هاتفك على شكل رقم ٨';

  @override
  String get prayerNextPrayer => 'الصلاة القادمة';

  @override
  String prayerInHoursMinutes(int hours, int minutes) {
    return 'بعد $hours ساعة و$minutes دقيقة';
  }

  @override
  String prayerInMinutes(int minutes) {
    return 'بعد $minutes دقيقة';
  }

  @override
  String get prayerNext => 'التالية';

  @override
  String prayerIqamah(String time) {
    return 'الإقامة: $time';
  }

  @override
  String get prayerErrorLoad => 'تعذّر تحميل مواقيت الصلاة';

  @override
  String get prayerErrorCheckSettings => 'تحقّق من إعدادات الموقع';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerLoading => 'جارٍ التحميل';

  @override
  String get compassNorth => 'الشمال';

  @override
  String get compassNortheast => 'الشمال الشرقي';

  @override
  String get compassEast => 'الشرق';

  @override
  String get compassSoutheast => 'الجنوب الشرقي';

  @override
  String get compassSouth => 'الجنوب';

  @override
  String get compassSouthwest => 'الجنوب الغربي';

  @override
  String get compassWest => 'الغرب';

  @override
  String get compassNorthwest => 'الشمال الغربي';

  @override
  String get progressTitle => 'التقدم';

  @override
  String get progressThisWeek => 'هذا الأسبوع';

  @override
  String get progressActiveStreaks => 'السلاسل النشطة';

  @override
  String get progressNoStreaks => 'لا توجد سلاسل نشطة بعد. ابدأ ببناء عاداتك!';

  @override
  String get progressStatistics => 'الإحصاءات';

  @override
  String get progressTotalHabits => 'إجمالي العادات';

  @override
  String get progressTotalDays => 'إجمالي الأيام';

  @override
  String get progressCurrentStreak => 'السلسلة الحالية';

  @override
  String get progressBestStreak => 'أفضل سلسلة';

  @override
  String progressDays(int count) {
    return '$count يوم';
  }

  @override
  String get progressMonthlyActivity => 'النشاط الشهري';

  @override
  String get progressCalGregorian => 'ميلادي';

  @override
  String get progressCalHijri => 'هجري';

  @override
  String get progressKeepStreak => 'حافظ على سلسلتك! كل يوم له قيمة 🌟';

  @override
  String get moreTitle => 'المزيد';

  @override
  String get moreAccount => 'الحساب';

  @override
  String get moreQuran => 'القرآن الكريم';

  @override
  String get moreAthkar => 'الأذكار';

  @override
  String get moreDuaa => 'الأدعية';

  @override
  String get moreUmrahGuide => 'دليل العمرة';

  @override
  String get moreHajjGuide => 'دليل الحج';

  @override
  String get moreSettings => 'الإعدادات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get leaderboardTitle => 'لوحة المتصدرين';

  @override
  String get duaaTitle => 'مجموعة الأدعية';

  @override
  String get duaaEmpty => 'لا توجد أدعية';

  @override
  String get duaaGeneralCategory => 'عام';

  @override
  String get duaaCategoryFallback => 'دعاء';

  @override
  String get athkarTitle => 'الأذكار';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get hajjTitle => 'دليل الحج';

  @override
  String get umrahTitle => 'دليل العمرة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionAccount => 'الحساب';

  @override
  String get settingsSectionNotifications => 'الإشعارات';

  @override
  String get settingsSectionAppearance => 'المظهر';

  @override
  String get settingsSectionLanguage => 'اللغة';

  @override
  String get settingsSectionAbout => 'حول التطبيق';

  @override
  String get settingsEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get settingsPermissionDenied => 'تم رفض إذن الإشعارات';

  @override
  String get settingsPrayerReminders => 'تذكير الصلاة';

  @override
  String get settingsHabitReminders => 'تذكير العادات';

  @override
  String get settingsAppTheme => 'مظهر التطبيق';

  @override
  String get settingsAdhanSound => 'صوت الأذان';

  @override
  String get settingsAdhanSelectTitle => 'اختر صوت الأذان';

  @override
  String get settingsAdhanSelectHint => 'اضغط للاختيار، واضغط زر التشغيل للاستماع';

  @override
  String get settingsAdhanPlaying => 'قيد التشغيل…';

  @override
  String get settingsThemeSelectTitle => 'اختر مظهر التطبيق';

  @override
  String get settingsThemeSelectHint => 'اختر مظهراً لتطبيقك';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyOpenError => 'تعذّر فتح سياسة الخصوصية';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSubtitle => 'لغة التطبيق';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageSystem => 'لغة الجهاز';

  @override
  String get settingsLanguageDialogTitle => 'اختر اللغة';

  @override
  String get settingsLanguageDialogBody => 'سيستخدم تطبيق سكينة هذه اللغة في جميع الشاشات.';

  @override
  String get themeGreen => 'أخضر (افتراضي)';

  @override
  String get themeBlue => 'محيط أزرق';

  @override
  String get themeGold => 'ذهب الصحراء';

  @override
  String get themePurple => 'أرجواني الليل';
}

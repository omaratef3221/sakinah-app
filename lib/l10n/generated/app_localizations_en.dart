import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sakinah Flow';

  @override
  String get navHome => 'Home';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navLeaders => 'Leaders';

  @override
  String get navHabits => 'Habits';

  @override
  String get navProgress => 'Progress';

  @override
  String get navMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonDone => 'Done';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonOr => 'or';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get splashTagline => 'Find Peace in Every Moment';

  @override
  String get loginWelcome => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to back up your progress across devices';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Your password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get loginContinueAsGuest => 'Continue as guest';

  @override
  String get loginErrorEnterPassword => 'Enter your password';

  @override
  String get loginErrorEnterEmail => 'Enter your email';

  @override
  String get loginErrorInvalidEmail => 'Enter a valid email address';

  @override
  String get loginErrorGeneric => 'Sign in failed. Please try again.';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupSubtitle => 'Save your habits, streaks, and progress to the cloud';

  @override
  String get signupNameLabel => 'Name';

  @override
  String get signupNameHint => 'Your name';

  @override
  String get signupNameError => 'Enter your name';

  @override
  String get signupPasswordHint => 'At least 6 characters';

  @override
  String get signupConfirmPasswordLabel => 'Confirm password';

  @override
  String get signupConfirmPasswordHint => 'Re-enter your password';

  @override
  String get signupConfirmEmptyError => 'Confirm your password';

  @override
  String get signupConfirmMismatchError => 'Passwords do not match';

  @override
  String get signupPasswordEmptyError => 'Enter a password';

  @override
  String get signupPasswordShortError => 'At least 6 characters';

  @override
  String get signupButton => 'Create Account';

  @override
  String get signupSuccess => 'Account created. Check your email for a verification link.';

  @override
  String get signupErrorGeneric => 'Sign up failed. Please try again.';

  @override
  String get forgotTitle => 'Reset Password';

  @override
  String get forgotBodyBefore => 'Enter your email and we will send you a link to reset your password.';

  @override
  String get forgotBodyAfter => 'If an account exists for that email, we\'ve sent a reset link. Check your inbox.';

  @override
  String get forgotSendButton => 'Send Reset Link';

  @override
  String get forgotBackButton => 'Back to Sign In';

  @override
  String get forgotErrorGeneric => 'Could not send reset email.';

  @override
  String get socialContinueWithApple => 'Continue with Apple';

  @override
  String get socialContinueWithGoogle => 'Continue with Google';

  @override
  String get socialAppleFailed => 'Apple sign-in failed.';

  @override
  String get socialGoogleFailed => 'Google sign-in failed.';

  @override
  String get authErrInvalidEmail => 'That email address looks invalid.';

  @override
  String get authErrUserDisabled => 'This account has been disabled.';

  @override
  String get authErrCredentials => 'Email or password is incorrect.';

  @override
  String get authErrEmailInUse => 'An account with this email already exists.';

  @override
  String get authErrWeakPassword => 'Password is too weak. Use at least 6 characters.';

  @override
  String get authErrNotAllowed => 'This sign-in method is not enabled.';

  @override
  String get authErrTooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get authErrNetwork => 'Network error. Check your connection and try again.';

  @override
  String get authErrDifferentProvider => 'An account exists with this email but a different sign-in method.';

  @override
  String get authErrRecentLogin => 'Please sign in again to continue.';

  @override
  String get authErrGeneric => 'Authentication failed. Please try again.';

  @override
  String get authErrNotSignedIn => 'Not signed in.';

  @override
  String get authErrAppleOnlyIOS => 'Sign in with Apple is only available on iOS.';

  @override
  String get authErrSignOutFailed => 'Sign out failed.';

  @override
  String get guestBannerTitle => 'Save your progress';

  @override
  String get guestBannerSubtitle => 'Sign in to back up across devices';

  @override
  String get guestBannerCta => 'Sign in';

  @override
  String get accountCardSaveTitle => 'Save your progress';

  @override
  String get accountCardSaveBody => 'Sign in to back up your habits and streaks across devices.';

  @override
  String get accountCardSignInCta => 'Sign In or Create Account';

  @override
  String get accountSignedInLabel => 'Signed in';

  @override
  String accountSignedInWith(String provider) {
    return 'Signed in with $provider';
  }

  @override
  String accountSignedInVerified(String provider) {
    return 'Signed in with $provider • verified';
  }

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountProviderApple => 'Apple';

  @override
  String get accountProviderEmail => 'Email';

  @override
  String get accountProviderEmailLong => 'Email & password';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountConfirmSignOutTitle => 'Sign out?';

  @override
  String get accountConfirmSignOutBody => 'Your local data stays on this device. Sign back in any time to resume cloud backup.';

  @override
  String get accountConfirmDeleteTitle => 'Delete account?';

  @override
  String get accountConfirmDeleteBody => 'This permanently deletes your account and all cloud data. This cannot be undone.';

  @override
  String get accountDeleteConfirmButton => 'Delete';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get accountDeleteFailed => 'Could not delete account.';

  @override
  String get accountReauthFailed => 'Could not re-authenticate.';

  @override
  String get accountPasswordPromptTitle => 'Confirm your password';

  @override
  String get accountPasswordPromptBody => 'For security, please enter your password to confirm account deletion.';

  @override
  String get accountVerifyEmail => 'Verify your email';

  @override
  String get accountVerifyRefresh => 'Refresh';

  @override
  String get accountVerifyResend => 'Resend';

  @override
  String get accountVerifySent => 'Verification email sent.';

  @override
  String get accountVerifySuccess => 'Email verified — thanks!';

  @override
  String get accountVerifyStillNot => 'Not verified yet. Click the link in the email, then tap Refresh again.';

  @override
  String get accountVerifyRefreshFailed => 'Could not refresh.';

  @override
  String get accountScreenTitle => 'Account';

  @override
  String get accountDetailsHeader => 'Account Details';

  @override
  String get accountFieldEmail => 'Email';

  @override
  String get accountFieldName => 'Name';

  @override
  String get accountFieldSignInMethod => 'Sign-in method';

  @override
  String get accountFieldEmailVerified => 'Email verified';

  @override
  String get accountFieldEmailVerifiedYes => 'Yes';

  @override
  String get accountFieldEmailVerifiedNo => 'Not yet';

  @override
  String get accountFieldJoined => 'Joined';

  @override
  String get accountFieldLastSignIn => 'Last sign-in';

  @override
  String get accountFieldUserId => 'User ID';

  @override
  String get dashTitle => 'Dashboard';

  @override
  String get dashGreetingMorning => 'Good Morning';

  @override
  String get dashGreetingAfternoon => 'Good Afternoon';

  @override
  String get dashGreetingEvening => 'Good Evening';

  @override
  String get dashNextPrayer => 'Next Prayer';

  @override
  String get dashDuaTitle => 'Dua of the Day';

  @override
  String get dashDuaTapToRead => 'Tap to read today\'s dua';

  @override
  String get dashStatCompletion => 'Completion';

  @override
  String get dashStatToday => 'Today';

  @override
  String get dashStatStreak => 'Streak';

  @override
  String dashStreakDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashQuickActions => 'Quick Actions';

  @override
  String get dashAddHabit => 'Add Habit';

  @override
  String get dashViewStats => 'View Stats';

  @override
  String get dashTodayProgress => 'Today\'s Progress';

  @override
  String dashCompletedOfTotal(int done, int total) {
    return '$done of $total completed';
  }

  @override
  String get dashLocLoading => 'Loading…';

  @override
  String get dashLocDetecting => 'Detecting location…';

  @override
  String get dashLocDisabled => 'Location services disabled';

  @override
  String get dashLocDenied => 'Location permission denied';

  @override
  String get dashLocDeniedForever => 'Location permission permanently denied';

  @override
  String get dashLocUnknown => 'Unknown Location';

  @override
  String get dashLocDetected => 'Location detected';

  @override
  String get dashLocUnable => 'Unable to detect location';

  @override
  String get habitsTitle => 'My Habits';

  @override
  String get habitsSearchHint => 'Type a habit to search for';

  @override
  String get habitsFilterAll => 'All';

  @override
  String get habitsFilterFard => 'Fard';

  @override
  String get habitsFilterSunnah => 'Sunnah';

  @override
  String get habitsCategoryFard => 'Fard';

  @override
  String get habitsCategorySunnah => 'Sunnah';

  @override
  String get habitsEmptyTitle => 'No Habits Yet';

  @override
  String get habitsEmptySubtitle => 'Start building your spiritual routine by adding habits from our curated collection';

  @override
  String get habitsEmptyAction => 'Add Your First Habit';

  @override
  String habitsDayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String habitsBackdateHelp(String title) {
    return 'Log \"$title\" on…';
  }

  @override
  String get habitsBackdateMarkComplete => 'Mark complete on this day';

  @override
  String get habitsBackdateRemove => 'Remove completion for this day';

  @override
  String get addHabitTitle => 'Add Habits';

  @override
  String addHabitSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get addHabitEmpty => 'No habits found';

  @override
  String get addHabitAdded => 'Added';

  @override
  String addHabitButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count Habits',
      one: 'Add 1 Habit',
    );
    return '$_temp0';
  }

  @override
  String get addHabitSelectAtLeastOne => 'Please select at least one habit';

  @override
  String addHabitSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count habits successfully!',
      one: 'Added 1 habit successfully!',
    );
    return '$_temp0';
  }

  @override
  String get addHabitErrorAdd => 'Error adding habits';

  @override
  String get addHabitErrorLoad => 'Error loading habits';

  @override
  String get prayerTitle => 'Prayer Times';

  @override
  String get prayerSchedule => 'Today\'s Schedule';

  @override
  String get prayerQibla => 'Qibla Direction';

  @override
  String get prayerQiblaPoint => 'Point your phone toward the Kaaba icon';

  @override
  String get prayerQiblaLabel => 'QIBLA';

  @override
  String get prayerTowardMakkah => 'toward Makkah Al-Mukarramah';

  @override
  String get prayerCalibrateButton => 'Calibrate Compass';

  @override
  String get prayerCalibrateTitle => 'Calibrating Compass';

  @override
  String get prayerCalibrateBody => 'Move your phone in a figure-8 pattern';

  @override
  String get prayerNextPrayer => 'Next Prayer';

  @override
  String prayerInHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String prayerInMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String get prayerNext => 'NEXT';

  @override
  String prayerIqamah(String time) {
    return 'Iqamah: $time';
  }

  @override
  String get prayerErrorLoad => 'Unable to load prayer times';

  @override
  String get prayerErrorCheckSettings => 'Please check your location settings';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerLoading => 'Loading';

  @override
  String get compassNorth => 'North';

  @override
  String get compassNortheast => 'Northeast';

  @override
  String get compassEast => 'East';

  @override
  String get compassSoutheast => 'Southeast';

  @override
  String get compassSouth => 'South';

  @override
  String get compassSouthwest => 'Southwest';

  @override
  String get compassWest => 'West';

  @override
  String get compassNorthwest => 'Northwest';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressThisWeek => 'This Week';

  @override
  String get progressActiveStreaks => 'Active Streaks';

  @override
  String get progressNoStreaks => 'No active streaks yet. Start building your habits!';

  @override
  String get progressStatistics => 'Statistics';

  @override
  String get progressTotalHabits => 'Total Habits';

  @override
  String get progressTotalDays => 'Total Days';

  @override
  String get progressCurrentStreak => 'Current Streak';

  @override
  String get progressBestStreak => 'Best Streak';

  @override
  String progressDays(int count) {
    return '$count days';
  }

  @override
  String get progressMonthlyActivity => 'Monthly Activity';

  @override
  String get progressCalGregorian => 'Gregorian';

  @override
  String get progressCalHijri => 'Hijri';

  @override
  String get progressKeepStreak => 'Keep your streak alive! Every day counts 🌟';

  @override
  String get moreTitle => 'More';

  @override
  String get moreAccount => 'Account';

  @override
  String get moreQuran => 'Quran';

  @override
  String get moreAthkar => 'Athkar';

  @override
  String get moreDuaa => 'Duaa';

  @override
  String get moreUmrahGuide => 'Umrah Guide';

  @override
  String get moreHajjGuide => 'Hajj Guide';

  @override
  String get moreSettings => 'Settings';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get duaaTitle => 'Duas Collection';

  @override
  String get duaaEmpty => 'No duas found';

  @override
  String get duaaGeneralCategory => 'General';

  @override
  String get duaaCategoryFallback => 'Dua';

  @override
  String get athkarTitle => 'Athkar';

  @override
  String get quranTitle => 'Quran';

  @override
  String get hajjTitle => 'Hajj Guide';

  @override
  String get umrahTitle => 'Umrah Guide';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsEnableNotifications => 'Enable Notifications';

  @override
  String get settingsPermissionDenied => 'Notification permission denied';

  @override
  String get settingsPrayerReminders => 'Prayer Reminders';

  @override
  String get settingsHabitReminders => 'Habit Reminders';

  @override
  String get settingsAppTheme => 'App Theme';

  @override
  String get settingsAdhanSound => 'Adhan Sound';

  @override
  String get settingsAdhanSelectTitle => 'Select Adhan Sound';

  @override
  String get settingsAdhanSelectHint => 'Tap to select, press play to preview';

  @override
  String get settingsAdhanPlaying => 'Playing…';

  @override
  String get settingsThemeSelectTitle => 'Select App Theme';

  @override
  String get settingsThemeSelectHint => 'Choose a theme for your app';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyOpenError => 'Could not open privacy policy';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'App language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageDialogTitle => 'Choose language';

  @override
  String get settingsLanguageDialogBody => 'Sakinah will use this language across the entire app.';

  @override
  String get themeGreen => 'Green (Default)';

  @override
  String get themeBlue => 'Blue Ocean';

  @override
  String get themeGold => 'Desert Gold';

  @override
  String get themePurple => 'Night Purple';
}

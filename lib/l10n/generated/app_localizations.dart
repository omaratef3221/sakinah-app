import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// App display name
  ///
  /// In en, this message translates to:
  /// **'Sakinah Flow'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navLeaders.
  ///
  /// In en, this message translates to:
  /// **'Leaders'**
  String get navLeaders;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Find Peace in Every Moment'**
  String get splashTagline;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your progress across devices'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get loginContinueAsGuest;

  /// No description provided for @loginErrorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginErrorEnterPassword;

  /// No description provided for @loginErrorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginErrorEnterEmail;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get loginErrorGeneric;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your habits, streaks, and progress to the cloud'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signupNameLabel;

  /// No description provided for @signupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get signupNameHint;

  /// No description provided for @signupNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get signupNameError;

  /// No description provided for @signupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get signupPasswordHint;

  /// No description provided for @signupConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get signupConfirmPasswordLabel;

  /// No description provided for @signupConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get signupConfirmPasswordHint;

  /// No description provided for @signupConfirmEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get signupConfirmEmptyError;

  /// No description provided for @signupConfirmMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get signupConfirmMismatchError;

  /// No description provided for @signupPasswordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get signupPasswordEmptyError;

  /// No description provided for @signupPasswordShortError.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get signupPasswordShortError;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupButton;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email for a verification link.'**
  String get signupSuccess;

  /// No description provided for @signupErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signupErrorGeneric;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotTitle;

  /// No description provided for @forgotBodyBefore.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to reset your password.'**
  String get forgotBodyBefore;

  /// No description provided for @forgotBodyAfter.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, we\'ve sent a reset link. Check your inbox.'**
  String get forgotBodyAfter;

  /// No description provided for @forgotSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotSendButton;

  /// No description provided for @forgotBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get forgotBackButton;

  /// No description provided for @forgotErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email.'**
  String get forgotErrorGeneric;

  /// No description provided for @socialContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get socialContinueWithApple;

  /// No description provided for @socialContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get socialContinueWithGoogle;

  /// No description provided for @socialAppleFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed.'**
  String get socialAppleFailed;

  /// No description provided for @socialGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get socialGoogleFailed;

  /// No description provided for @authErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address looks invalid.'**
  String get authErrInvalidEmail;

  /// No description provided for @authErrUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrUserDisabled;

  /// No description provided for @authErrCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authErrCredentials;

  /// No description provided for @authErrEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authErrEmailInUse;

  /// No description provided for @authErrWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get authErrWeakPassword;

  /// No description provided for @authErrNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled.'**
  String get authErrNotAllowed;

  /// No description provided for @authErrTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrTooManyRequests;

  /// No description provided for @authErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authErrNetwork;

  /// No description provided for @authErrDifferentProvider.
  ///
  /// In en, this message translates to:
  /// **'An account exists with this email but a different sign-in method.'**
  String get authErrDifferentProvider;

  /// No description provided for @authErrRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get authErrRecentLogin;

  /// No description provided for @authErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrGeneric;

  /// No description provided for @authErrNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get authErrNotSignedIn;

  /// No description provided for @authErrAppleOnlyIOS.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is only available on iOS.'**
  String get authErrAppleOnlyIOS;

  /// No description provided for @authErrSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed.'**
  String get authErrSignOutFailed;

  /// No description provided for @guestBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get guestBannerTitle;

  /// No description provided for @guestBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up across devices'**
  String get guestBannerSubtitle;

  /// No description provided for @guestBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get guestBannerCta;

  /// No description provided for @accountCardSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get accountCardSaveTitle;

  /// No description provided for @accountCardSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your habits and streaks across devices.'**
  String get accountCardSaveBody;

  /// No description provided for @accountCardSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign In or Create Account'**
  String get accountCardSignInCta;

  /// No description provided for @accountSignedInLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accountSignedInLabel;

  /// No description provided for @accountSignedInWith.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {provider}'**
  String accountSignedInWith(String provider);

  /// No description provided for @accountSignedInVerified.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {provider} • verified'**
  String accountSignedInVerified(String provider);

  /// No description provided for @accountProviderGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get accountProviderGoogle;

  /// No description provided for @accountProviderApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get accountProviderApple;

  /// No description provided for @accountProviderEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountProviderEmail;

  /// No description provided for @accountProviderEmailLong.
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get accountProviderEmailLong;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteAccount;

  /// No description provided for @accountConfirmSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountConfirmSignOutTitle;

  /// No description provided for @accountConfirmSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your local data stays on this device. Sign back in any time to resume cloud backup.'**
  String get accountConfirmSignOutBody;

  /// No description provided for @accountConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get accountConfirmDeleteTitle;

  /// No description provided for @accountConfirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all cloud data. This cannot be undone.'**
  String get accountConfirmDeleteBody;

  /// No description provided for @accountDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeleteConfirmButton;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account.'**
  String get accountDeleteFailed;

  /// No description provided for @accountReauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not re-authenticate.'**
  String get accountReauthFailed;

  /// No description provided for @accountPasswordPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get accountPasswordPromptTitle;

  /// No description provided for @accountPasswordPromptBody.
  ///
  /// In en, this message translates to:
  /// **'For security, please enter your password to confirm account deletion.'**
  String get accountPasswordPromptBody;

  /// No description provided for @accountVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get accountVerifyEmail;

  /// No description provided for @accountVerifyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get accountVerifyRefresh;

  /// No description provided for @accountVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get accountVerifyResend;

  /// No description provided for @accountVerifySent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get accountVerifySent;

  /// No description provided for @accountVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified — thanks!'**
  String get accountVerifySuccess;

  /// No description provided for @accountVerifyStillNot.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Click the link in the email, then tap Refresh again.'**
  String get accountVerifyStillNot;

  /// No description provided for @accountVerifyRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh.'**
  String get accountVerifyRefreshFailed;

  /// No description provided for @accountScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountScreenTitle;

  /// No description provided for @accountDetailsHeader.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetailsHeader;

  /// No description provided for @accountFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountFieldEmail;

  /// No description provided for @accountFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountFieldName;

  /// No description provided for @accountFieldSignInMethod.
  ///
  /// In en, this message translates to:
  /// **'Sign-in method'**
  String get accountFieldSignInMethod;

  /// No description provided for @accountFieldEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get accountFieldEmailVerified;

  /// No description provided for @accountFieldEmailVerifiedYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get accountFieldEmailVerifiedYes;

  /// No description provided for @accountFieldEmailVerifiedNo.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get accountFieldEmailVerifiedNo;

  /// No description provided for @accountFieldJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get accountFieldJoined;

  /// No description provided for @accountFieldLastSignIn.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in'**
  String get accountFieldLastSignIn;

  /// No description provided for @accountFieldUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get accountFieldUserId;

  /// No description provided for @dashTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashTitle;

  /// No description provided for @dashGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get dashGreetingMorning;

  /// No description provided for @dashGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get dashGreetingAfternoon;

  /// No description provided for @dashGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get dashGreetingEvening;

  /// No description provided for @dashNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get dashNextPrayer;

  /// No description provided for @dashDuaTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua of the Day'**
  String get dashDuaTitle;

  /// No description provided for @dashDuaTapToRead.
  ///
  /// In en, this message translates to:
  /// **'Tap to read today\'s dua'**
  String get dashDuaTapToRead;

  /// No description provided for @dashStatCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get dashStatCompletion;

  /// No description provided for @dashStatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashStatToday;

  /// No description provided for @dashStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get dashStatStreak;

  /// No description provided for @dashStreakDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day} other{{count} days}}'**
  String dashStreakDay(int count);

  /// No description provided for @dashQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashQuickActions;

  /// No description provided for @dashAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get dashAddHabit;

  /// No description provided for @dashViewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get dashViewStats;

  /// No description provided for @dashTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get dashTodayProgress;

  /// No description provided for @dashCompletedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed'**
  String dashCompletedOfTotal(int done, int total);

  /// No description provided for @dashLocLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get dashLocLoading;

  /// No description provided for @dashLocDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting location…'**
  String get dashLocDetecting;

  /// No description provided for @dashLocDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get dashLocDisabled;

  /// No description provided for @dashLocDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get dashLocDenied;

  /// No description provided for @dashLocDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get dashLocDeniedForever;

  /// No description provided for @dashLocUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get dashLocUnknown;

  /// No description provided for @dashLocDetected.
  ///
  /// In en, this message translates to:
  /// **'Location detected'**
  String get dashLocDetected;

  /// No description provided for @dashLocUnable.
  ///
  /// In en, this message translates to:
  /// **'Unable to detect location'**
  String get dashLocUnable;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get habitsTitle;

  /// No description provided for @habitsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type a habit to search for'**
  String get habitsSearchHint;

  /// No description provided for @habitsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get habitsFilterAll;

  /// No description provided for @habitsFilterFard.
  ///
  /// In en, this message translates to:
  /// **'Fard'**
  String get habitsFilterFard;

  /// No description provided for @habitsFilterSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get habitsFilterSunnah;

  /// No description provided for @habitsCategoryFard.
  ///
  /// In en, this message translates to:
  /// **'Fard'**
  String get habitsCategoryFard;

  /// No description provided for @habitsCategorySunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get habitsCategorySunnah;

  /// No description provided for @habitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Habits Yet'**
  String get habitsEmptyTitle;

  /// No description provided for @habitsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your spiritual routine by adding habits from our curated collection'**
  String get habitsEmptySubtitle;

  /// No description provided for @habitsEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Habit'**
  String get habitsEmptyAction;

  /// No description provided for @habitsDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day streak} other{{count} day streak}}'**
  String habitsDayStreak(int count);

  /// No description provided for @habitsBackdateHelp.
  ///
  /// In en, this message translates to:
  /// **'Log \"{title}\" on…'**
  String habitsBackdateHelp(String title);

  /// No description provided for @habitsBackdateMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete on this day'**
  String get habitsBackdateMarkComplete;

  /// No description provided for @habitsBackdateRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove completion for this day'**
  String get habitsBackdateRemove;

  /// No description provided for @addHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Habits'**
  String get addHabitTitle;

  /// No description provided for @addHabitSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String addHabitSelectedCount(int count);

  /// No description provided for @addHabitEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits found'**
  String get addHabitEmpty;

  /// No description provided for @addHabitAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get addHabitAdded;

  /// No description provided for @addHabitButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Add 1 Habit} other{Add {count} Habits}}'**
  String addHabitButton(int count);

  /// No description provided for @addHabitSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one habit'**
  String get addHabitSelectAtLeastOne;

  /// No description provided for @addHabitSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Added 1 habit successfully!} other{Added {count} habits successfully!}}'**
  String addHabitSuccess(int count);

  /// No description provided for @addHabitErrorAdd.
  ///
  /// In en, this message translates to:
  /// **'Error adding habits'**
  String get addHabitErrorAdd;

  /// No description provided for @addHabitErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Error loading habits'**
  String get addHabitErrorLoad;

  /// No description provided for @prayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTitle;

  /// No description provided for @prayerSchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get prayerSchedule;

  /// No description provided for @prayerQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get prayerQibla;

  /// No description provided for @prayerQiblaPoint.
  ///
  /// In en, this message translates to:
  /// **'Point your phone toward the Kaaba icon'**
  String get prayerQiblaPoint;

  /// No description provided for @prayerQiblaLabel.
  ///
  /// In en, this message translates to:
  /// **'QIBLA'**
  String get prayerQiblaLabel;

  /// No description provided for @prayerTowardMakkah.
  ///
  /// In en, this message translates to:
  /// **'toward Makkah Al-Mukarramah'**
  String get prayerTowardMakkah;

  /// No description provided for @prayerCalibrateButton.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Compass'**
  String get prayerCalibrateButton;

  /// No description provided for @prayerCalibrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrating Compass'**
  String get prayerCalibrateTitle;

  /// No description provided for @prayerCalibrateBody.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure-8 pattern'**
  String get prayerCalibrateBody;

  /// No description provided for @prayerNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get prayerNextPrayer;

  /// No description provided for @prayerInHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours}h {minutes}m'**
  String prayerInHoursMinutes(int hours, int minutes);

  /// No description provided for @prayerInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes}m'**
  String prayerInMinutes(int minutes);

  /// No description provided for @prayerNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get prayerNext;

  /// No description provided for @prayerIqamah.
  ///
  /// In en, this message translates to:
  /// **'Iqamah: {time}'**
  String prayerIqamah(String time);

  /// No description provided for @prayerErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayer times'**
  String get prayerErrorLoad;

  /// No description provided for @prayerErrorCheckSettings.
  ///
  /// In en, this message translates to:
  /// **'Please check your location settings'**
  String get prayerErrorCheckSettings;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get prayerLoading;

  /// No description provided for @compassNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get compassNorth;

  /// No description provided for @compassNortheast.
  ///
  /// In en, this message translates to:
  /// **'Northeast'**
  String get compassNortheast;

  /// No description provided for @compassEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get compassEast;

  /// No description provided for @compassSoutheast.
  ///
  /// In en, this message translates to:
  /// **'Southeast'**
  String get compassSoutheast;

  /// No description provided for @compassSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get compassSouth;

  /// No description provided for @compassSouthwest.
  ///
  /// In en, this message translates to:
  /// **'Southwest'**
  String get compassSouthwest;

  /// No description provided for @compassWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get compassWest;

  /// No description provided for @compassNorthwest.
  ///
  /// In en, this message translates to:
  /// **'Northwest'**
  String get compassNorthwest;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get progressThisWeek;

  /// No description provided for @progressActiveStreaks.
  ///
  /// In en, this message translates to:
  /// **'Active Streaks'**
  String get progressActiveStreaks;

  /// No description provided for @progressNoStreaks.
  ///
  /// In en, this message translates to:
  /// **'No active streaks yet. Start building your habits!'**
  String get progressNoStreaks;

  /// No description provided for @progressStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get progressStatistics;

  /// No description provided for @progressTotalHabits.
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get progressTotalHabits;

  /// No description provided for @progressTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get progressTotalDays;

  /// No description provided for @progressCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get progressCurrentStreak;

  /// No description provided for @progressBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get progressBestStreak;

  /// No description provided for @progressDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String progressDays(int count);

  /// No description provided for @progressMonthlyActivity.
  ///
  /// In en, this message translates to:
  /// **'Monthly Activity'**
  String get progressMonthlyActivity;

  /// No description provided for @progressCalGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get progressCalGregorian;

  /// No description provided for @progressCalHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get progressCalHijri;

  /// No description provided for @progressKeepStreak.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive! Every day counts 🌟'**
  String get progressKeepStreak;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccount;

  /// No description provided for @moreQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get moreQuran;

  /// No description provided for @moreAthkar.
  ///
  /// In en, this message translates to:
  /// **'Athkar'**
  String get moreAthkar;

  /// No description provided for @moreDuaa.
  ///
  /// In en, this message translates to:
  /// **'Duaa'**
  String get moreDuaa;

  /// No description provided for @moreUmrahGuide.
  ///
  /// In en, this message translates to:
  /// **'Umrah Guide'**
  String get moreUmrahGuide;

  /// No description provided for @moreHajjGuide.
  ///
  /// In en, this message translates to:
  /// **'Hajj Guide'**
  String get moreHajjGuide;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @duaaTitle.
  ///
  /// In en, this message translates to:
  /// **'Duas Collection'**
  String get duaaTitle;

  /// No description provided for @duaaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No duas found'**
  String get duaaEmpty;

  /// No description provided for @duaaGeneralCategory.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get duaaGeneralCategory;

  /// No description provided for @duaaCategoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get duaaCategoryFallback;

  /// No description provided for @athkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Athkar'**
  String get athkarTitle;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @hajjTitle.
  ///
  /// In en, this message translates to:
  /// **'Hajj Guide'**
  String get hajjTitle;

  /// No description provided for @umrahTitle.
  ///
  /// In en, this message translates to:
  /// **'Umrah Guide'**
  String get umrahTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied'**
  String get settingsPermissionDenied;

  /// No description provided for @settingsPrayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get settingsPrayerReminders;

  /// No description provided for @settingsHabitReminders.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminders'**
  String get settingsHabitReminders;

  /// No description provided for @settingsAppTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingsAppTheme;

  /// No description provided for @settingsAdhanSound.
  ///
  /// In en, this message translates to:
  /// **'Adhan Sound'**
  String get settingsAdhanSound;

  /// No description provided for @settingsAdhanSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Adhan Sound'**
  String get settingsAdhanSelectTitle;

  /// No description provided for @settingsAdhanSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select, press play to preview'**
  String get settingsAdhanSelectHint;

  /// No description provided for @settingsAdhanPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing…'**
  String get settingsAdhanPlaying;

  /// No description provided for @settingsThemeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select App Theme'**
  String get settingsThemeSelectTitle;

  /// No description provided for @settingsThemeSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme for your app'**
  String get settingsThemeSelectHint;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy'**
  String get settingsPrivacyOpenError;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsLanguageDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Sakinah will use this language across the entire app.'**
  String get settingsLanguageDialogBody;

  /// No description provided for @themeGreen.
  ///
  /// In en, this message translates to:
  /// **'Green (Default)'**
  String get themeGreen;

  /// No description provided for @themeBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Ocean'**
  String get themeBlue;

  /// No description provided for @themeGold.
  ///
  /// In en, this message translates to:
  /// **'Desert Gold'**
  String get themeGold;

  /// No description provided for @themePurple.
  ///
  /// In en, this message translates to:
  /// **'Night Purple'**
  String get themePurple;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

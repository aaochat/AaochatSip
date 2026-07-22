/// Central branding constants for Aao VOIP — used across UI and App Store metadata.
class AppBranding {
  AppBranding._();

  static const String appName = 'Aao VOIP';
  static const String appTagline = "Your organization's communication hub";
  static const String brandName = 'AaoChat';
  static const String packageDescription =
      'Secure team calling, directory, and call insights for AaoChat organizations.';

  // Asset paths (distinct from generic SIP template names)
  static const String logoAsset = 'assets/app_logo.png';
  static const String ringtoneAsset = 'assets/aao_ringtone.mp3';
  static const String insightsIconAsset = 'assets/ai.png';

  // Legacy fallbacks until physical files are renamed on disk
  static const String logoAssetFallback = 'assets/app_logo.png';
  static const String ringtoneAssetFallback = 'assets/ringtone.mp3';
  static const String insightsIconFallback = 'assets/ai.png';

  static String resolveLogo() => logoAsset;
  static String resolveRingtone() => ringtoneAsset;
  static String resolveInsightsIcon() => insightsIconAsset;
}

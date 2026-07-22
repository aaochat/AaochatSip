import 'package:flutter/material.dart';

import '../utils/app_branding.dart';

/// Logo with fallback for migration from legacy asset names.
class BrandedLogo extends StatelessWidget {
  const BrandedLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppBranding.resolveLogo(),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(
        AppBranding.logoAssetFallback,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}

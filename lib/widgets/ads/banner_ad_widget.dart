import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/config/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;
  late final BannerAdListener _bannerAdListener;

  @override
  void initState() {
    super.initState();

    // 🔧 광고가 비활성화된 경우 아무것도 하지 않음 + ios 광고 중지중
    if (!AdConfig.isAdEnabled || Platform.isIOS) return;

    _bannerAdListener = BannerAdListener(
      onAdLoaded: (ad) {
        if (!_isDisposed) {
          if (kDebugMode) debugPrint('✅ [Banner] 로드 완료');
          setState(() => _isLoaded = true);
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('❌ [Banner] 로드 실패: ${_getErrorType(error)}');
        ad.dispose();
        if (!_isDisposed) {
          setState(() => _isLoaded = false);
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!_isDisposed && !_isLoaded) {
              if (kDebugMode) debugPrint('🔄 [Banner] 재시도');
              _loadAd();
            }
          });
        }
      },
      onAdClicked: (ad) {
        if (kDebugMode) debugPrint('🎯 [Banner] 클릭됨');
      },
    );

    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isDisposed || !AdConfig.isAdEnabled) return;

    if (kDebugMode) {
      // 🧪 테스트 광고 (고정 사이즈)
      _bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: _bannerAdListener,
      );
      _bannerAd!.load();
    } else {
      // 📱 실제 광고 (적응형 사이즈)
      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate(),
          );

      if (size == null) {
        debugPrint('❌ [Banner] 적응형 배너 크기 계산 실패');
        return;
      }

      _bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: _bannerAdListener,
      );
      _bannerAd!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 광고가 비활성화된 경우 빈 위젯 반환
    if (!AdConfig.isAdEnabled) {
      return const SizedBox.shrink();
    }

    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    if (_bannerAd != null && _isLoaded) {
      return Container(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        color: tc.surface,
        child: Stack(
          children: [
            AdWidget(ad: _bannerAd!),
            if (kDebugMode)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'TEST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: widget.adSize.height.toDouble(),
      color: tc.surface,
      child: Center(
        child: Container(
          width: widget.adSize.width.toDouble(),
          height: widget.adSize.height.toDouble(),
          decoration: BoxDecoration(
            color: tc.background,
            border: Border.all(
              color: tc.textSecondary.withOpacity(0.2),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: _isLoaded == false && _bannerAd == null
                ? _buildErrorState(tc)
                : _buildLoadingState(tc),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(dynamic tc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              tc.primary.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '광고 로딩 중...',
              style: TextStyle(
                color: tc.textSecondary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (kDebugMode)
              Text(
                'TEST MODE',
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(dynamic tc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: tc.textSecondary.withOpacity(0.5),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '광고 로드 실패',
              style: TextStyle(
                color: tc.textSecondary.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 4),
          Text(
            'TEST MODE',
            style: TextStyle(
              color: Colors.red.withOpacity(0.6),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getErrorType(LoadAdError error) {
    switch (error.code) {
      case 0:
        return '내부오류';
      case 1:
        return '네트워크오류';
      case 2:
        return '광고없음';
      case 3:
        return '앱ID오류';
      default:
        return '알수없음(${error.code})';
    }
  }
}

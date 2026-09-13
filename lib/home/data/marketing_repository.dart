import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:flutter/material.dart';

/// Du lieu khoi marketing Trang chu (banner khuyen mai theo khoi lop +
/// trust bar + testimonial) — GET /api/v1/home/marketing. Danh sach khoa
/// hoc trong moi danh muc la [Course] THAT, LOC tu cung 1 nguon voi
/// "Khám phá khóa học" (BE module `marketing`, xem
/// ThietKe/Mobile/KE_HOACH_TRIEN_KHAI.md) — luon dong bo, khong con mock.
abstract class MarketingRepository {
  Future<HomeMarketing> fetchHomeMarketing();
}

class MarketingRepositoryImpl implements MarketingRepository {
  const MarketingRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<HomeMarketing> fetchHomeMarketing() async {
    final data = await _api.get('/api/v1/home/marketing');
    return HomeMarketing.fromJson(data! as Map<String, dynamic>);
  }
}

Color _colorFromHex(String hex) {
  final v = hex.replaceFirst('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

/// 1 nhom danh muc noi bat (vd "Luyện thi vào 10") — banner (cosmetic, admin
/// soan) + danh sach [Course] THAT loc theo khoi lop.
class MarketingCategory {
  const MarketingCategory({
    required this.title,
    required this.emoji,
    required this.bannerTag,
    required this.bannerHeadline,
    required this.bannerGradient,
    required this.accentColor,
    required this.courses,
  });

  final String title;
  final String? emoji;
  final String bannerTag;
  final String bannerHeadline;
  final List<Color> bannerGradient;
  final Color accentColor;
  final List<Course> courses;

  factory MarketingCategory.fromJson(Map<String, dynamic> j) => MarketingCategory(
        title: j['title'] as String,
        emoji: j['emoji'] as String?,
        bannerTag: j['bannerTag'] as String,
        bannerHeadline: j['bannerHeadline'] as String,
        bannerGradient: [
          _colorFromHex(j['gradientStart'] as String),
          _colorFromHex(j['gradientEnd'] as String),
        ],
        accentColor: _colorFromHex(j['accentColor'] as String),
        courses: (j['classes'] as List<dynamic>)
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TrustStats {
  const TrustStats({
    required this.years,
    required this.students,
    required this.teachers,
  });

  final String years;
  final String students;
  final String teachers;

  factory TrustStats.fromJson(Map<String, dynamic> j) => TrustStats(
        years: j['years'] as String? ?? '',
        students: j['students'] as String? ?? '',
        teachers: j['teachers'] as String? ?? '',
      );
}

class Testimonial {
  const Testimonial({
    required this.name,
    required this.meta,
    required this.quote,
  });

  final String name;
  final String meta;
  final String quote;

  factory Testimonial.fromJson(Map<String, dynamic> j) => Testimonial(
        name: j['name'] as String,
        meta: j['meta'] as String,
        quote: j['quote'] as String,
      );
}

/// Noi dung khoi Hero (badge/tieu de/CTA) — cau hinh qua man "Nội Dung" cua
/// ADMIN, dung chung voi khoi Hero cong khai cua WEB. `null` neu chua cau
/// hinh hoac dang tat (`visible = false`, BE khong tra field nay).
class HomeHero {
  const HomeHero({
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  final String? badgeText;
  final String title;
  final String? subtitle;

  factory HomeHero.fromJson(Map<String, dynamic> j) => HomeHero(
        badgeText: j['badgeText'] as String?,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String?,
      );
}

/// Payload day du 1 lan goi cho khoi marketing Trang chu.
class HomeMarketing {
  const HomeMarketing({
    required this.hero,
    required this.categories,
    required this.trustStats,
    required this.testimonials,
  });

  final HomeHero? hero;
  final List<MarketingCategory> categories;
  final TrustStats trustStats;
  final List<Testimonial> testimonials;

  factory HomeMarketing.fromJson(Map<String, dynamic> j) => HomeMarketing(
        hero: j['hero'] == null
            ? null
            : HomeHero.fromJson(j['hero'] as Map<String, dynamic>),
        categories: (j['categories'] as List<dynamic>)
            .map((e) => MarketingCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        trustStats: TrustStats.fromJson(j['trustStats'] as Map<String, dynamic>),
        testimonials: (j['testimonials'] as List<dynamic>)
            .map((e) => Testimonial.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/home/data/marketing_repository.dart';
import 'package:deca_mobile/home/view/widgets/marketing_category_row.dart';
import 'package:deca_mobile/home/view/widgets/testimonials_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Khoi noi bat + danh gia tren Trang chu (danh muc theo khoi lop,
/// testimonial) — GET /api/v1/home/marketing qua [MarketingRepository].
/// Da bo banner khuyen mai + trust bar (yeu cau nguoi dung).
class MarketingSection extends StatefulWidget {
  const MarketingSection({super.key});

  @override
  State<MarketingSection> createState() => _MarketingSectionState();
}

class _MarketingSectionState extends State<MarketingSection> {
  late Future<HomeMarketing> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = context.read<MarketingRepository>().fetchHomeMarketing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeMarketing>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            for (final category in data.categories) ...[
              MarketingCategoryRow(category: category, onEnrolled: _reload),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),
            TestimonialsSection(testimonials: data.testimonials),
          ],
        );
      },
    );
  }
}

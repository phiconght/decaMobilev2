import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/home/data/marketing_repository.dart';
import 'package:deca_mobile/home/view/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// "Phụ huynh & học sinh nói gì" — carousel danh gia. Du lieu MOCK.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({required this.testimonials, super.key});

  final List<Testimonial> testimonials;

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Phụ huynh & học sinh nói gì'),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: testimonials.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => _Card(t: testimonials[i]),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.t});

  final Testimonial t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = t.name.trim().isEmpty
        ? '?'
        : t.name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join();
    return Container(
      width: 230,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.rlg,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.brand,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      t.meta,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (_) => const Icon(
                Icons.star_rounded,
                size: 13,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              t.quote,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

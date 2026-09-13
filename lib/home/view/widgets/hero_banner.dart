import 'package:deca_mobile/catalog/view/catalog_page.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/home/cubit/home_hero_cubit.dart';
import 'package:deca_mobile/home/data/marketing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Khoi Hero (badge/tieu de/mo ta) tren Trang chu — lay tu API cau hinh
/// (man "Nội Dung" cua ADMIN), dung chung 1 nguon voi khoi Hero cong khai
/// cua WEB thay vi hard-code. An hoan neu chua cau hinh/API loi (khac
/// GreetingHeader — la loi chao ca nhan hoa, khong phai Hero).
/// Xem KEHOACH_WEB_TrangChuCongKhai_HeroContent.md.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeHeroCubit, DataState<HomeHero>>(
      builder: (context, state) {
        final hero = state.data;
        if (hero == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E43E8), Color(0xFF5B6CFF)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hero.badgeText != null && hero.badgeText!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        hero.badgeText!,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hero.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hero.subtitle != null && hero.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      hero.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const CatalogPage(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E2FB8),
                    ),
                    child: const Text('Khám phá khóa học'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

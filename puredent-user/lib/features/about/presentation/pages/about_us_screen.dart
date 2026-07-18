import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Converted from about.html.
///
/// The HTML version is a desktop marketing page (top nav, 2-column
/// hero, side-by-side "Our Story", 4-col values grid, 3-col team grid,
/// full footer). This mobile version keeps every section but stacks
/// everything into a single scrollable column, which is the natural
/// mobile-app translation of the same content.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _HeroSection(),
          _OurStorySection(),
          _CoreValuesSection(),
          _TechnologySection(),
          _LeadershipSection(),
          _CtaSection(),
          _ContactFooter(),
        ],
      ),
    );
  }
}

/// Network image with a graceful fallback instead of the default broken
/// image ("X") icon, plus a loading placeholder so there's no flash of
/// empty/error content while the image is fetched.
class _NetworkImage extends StatelessWidget {
  const _NetworkImage(
    this.url, {
    // ignore: unused_element_parameter
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.local_hospital_outlined,
  });

  final String url;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceContainerLow,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceContainerLow,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: AppColors.outline, size: 32),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 340,
          width: double.infinity,
          child: _NetworkImage(
            'https://lh3.googleusercontent.com/aida/AP1WRLtZe2s0pyx_LJYzOQxTf66EHKOfvmMa7dkstdBziv4KGvE9a9PdjfgcO1u7zmA3665FDlUdxj8KxJxU8D1ruk6_ElFK8Hmwn4XIHpeY9Kjt0S0PJLPJKA1LT-2inNfC2ygo6oImRC31T5R6vm4JHXCMVTpqfbWDhpGEU3oEN-6UUtNp-xtuNdgeA7PXNRMvGkV8GQbD68vXNg5AYfeT_mY9rGE9AZiLBtpmhc4BY2k226JVFrUb7jH0qPM',
          ),
        ),
        Container(
          height: 340,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.surface,
                AppColors.surface.withValues(alpha: 0.4),
                Colors.transparent
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.marginMobile,
          right: AppSpacing.marginMobile,
          bottom: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('Setting the Standard',
                    style: AppTypography.labelMd(
                        color: AppColors.onPrimaryContainer)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Clinical Precision.\nHuman Connection.',
                  style: AppTypography.headlineLg(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Experience the next generation of dental care in an environment designed for tranquility and technological excellence.',
                style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Explore Our Tech'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Our Story
// ---------------------------------------------------------------------
class _OurStorySection extends StatelessWidget {
  const _OurStorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.xl, AppSpacing.marginMobile, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCpMecPSEpkYR1y9NQhxpkYd2R1skTcdhTNkC2pgE46YZKOgL5N754R8-j8ooPIkeC8QpTh6UklAuMaxQ5BaNljeakn7JBMeYAjIEbeSnK3MKETxfJUIqVaNJhe3SlpcNsw978vaMXdWudKt_iAwznLyaZ0AhM8U3462sdx5047N9S5n399MR2RZW-I1W9V987EXXDAqLme-pcrhSFJKdle80OkzUOj5XwN6Lv7vjLbS0iYfUZTHsbQ',
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('15+ Years',
                          style: AppTypography.headlineSm(
                              color: AppColors.primary)),
                      Text('of Excellence in Dentistry',
                          style: AppTypography.labelMd()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Our Story',
              style: AppTypography.headlineLg(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'PureDent was founded with a singular vision: to bridge the gap between advanced medical technology and '
            'personalized patient experiences. What began as a boutique clinic in 2008 has evolved into a leading '
            'center for comprehensive oral health.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Our journey has been defined by a commitment to continuous learning and the adoption of minimally '
            'invasive techniques. Every treatment plan at PureDent is as unique as the patients we serve.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('12,000+',
                        style: AppTypography.headlineMd(
                            color: AppColors.secondary)),
                    Text('Happy Smiles Created', style: AppTypography.bodySm()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('98%',
                        style: AppTypography.headlineMd(
                            color: AppColors.secondary)),
                    Text('Patient Satisfaction', style: AppTypography.bodySm()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Core Values (bento grid -> 2-col grid on mobile)
// ---------------------------------------------------------------------
class _CoreValuesSection extends StatelessWidget {
  const _CoreValuesSection();

  static const _values = [
    (
      Icons.verified,
      'Excellence',
      'We strive for perfection in every procedure, utilizing the highest medical standards.'
    ),
    (
      Icons.favorite,
      'Compassion',
      'Care that understands. We prioritize your comfort and peace of mind above all else.'
    ),
    (
      Icons.lightbulb,
      'Innovation',
      'Constantly evolving with the latest digital dentistry tools and methodologies.'
    ),
    (
      Icons.gavel,
      'Integrity',
      'Transparent communication and honest treatment plans you can trust implicitly.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: AppSpacing.xl),
      child: Column(
        children: [
          Text('Our Core Values',
              style: AppTypography.headlineLg(color: AppColors.primary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The pillars that guide our practice, ensuring every interaction reflects our dedication to your health.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            // Was 0.95 (too short for 4 lines of body text at some
            // font-scale settings), causing a RenderFlex bottom overflow.
            // Lowering the ratio gives each card more height.
            childAspectRatio: 0.78,
            children: _values
                .map(
                  (v) => Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child:
                              Icon(v.$1, color: AppColors.onSecondaryContainer),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(v.$2,
                            style: AppTypography.headlineSm(
                                    color: AppColors.primary)
                                .copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        // Flexible + maxLines lets the text shrink to fit
                        // remaining space instead of forcing the Column
                        // taller than its parent, which was the direct
                        // cause of the overflow.
                        Flexible(
                          child: Text(
                            v.$3,
                            style: AppTypography.bodySm(),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Technology
// ---------------------------------------------------------------------
class _TechnologySection extends StatelessWidget {
  const _TechnologySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.xl, AppSpacing.marginMobile, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: AspectRatio(
              aspectRatio: 1,
              child: _NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC1uTp5nXuOS3ByR4RXHMDd2lHnQOh_YAzQsqVvnl9-zb34Z9ZOQP_7PsrRdB38qG4DDheVBCXRpKeUKjj1DBdaB1-UlQUrIFJvzvXBT576mWIzaWr3ackxHpaKAPOTZocO4-gSq2_UQthdu7EW9jl_VHjpNN8e5RHtWOR2o4RZa_swLVDA6wYulsgPuQ_lz1GoWUlnUEhKhjGSdDm8PRVkRFE3PGAL8_3CYG1kX7d5HRnn5XsePF8P',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.precision_manufacturing,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text('Future-Ready Dentistry',
                  style: AppTypography.labelMd(color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('State-of-the-Art Technology',
              style: AppTypography.headlineLg(color: AppColors.primary)
                  .copyWith(fontSize: 24)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We invest in the future of your oral health. Our clinic is equipped with a full suite of digital tools '
            'that reduce appointment times and increase accuracy.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.md),
          const _TechListItem(
            title: '3D Cone Beam CT',
            description:
                'Precise imaging for complex implant and surgical planning.',
          ),
          const SizedBox(height: AppSpacing.md),
          const _TechListItem(
            title: 'Digital Intraoral Scanners',
            description:
                'No more messy molds — just comfortable, high-precision digital impressions.',
          ),
        ],
      ),
    );
  }
}

class _TechListItem extends StatelessWidget {
  const _TechListItem({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.labelMd(color: AppColors.primary)
                      .copyWith(fontSize: 13)),
              Text(description, style: AppTypography.bodySm()),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Leadership team
// ---------------------------------------------------------------------
class _LeadershipSection extends StatelessWidget {
  const _LeadershipSection();

  static const _team = [
    (
      'Dr. Julian Vance',
      'Chief Medical Officer',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSVFLtTQFYG82O71YupVukFC5wt5v9saZiReN7Il8tO7P7taqg__9gBElsks9o5d1AZFgbXE42oXv4ti2r-YgEIEr1jeyMv4rQqGQsQwOvqeicFAYM2EN1VnRo3uGKI9zp8bfNuvLT-vAs-fr7pYIEl7bnXC5J_XXhJ4L7gC5b6JleRe4FL5kkW77PgCLgYIJYGfn1W68Q_C1_H2KvPjCfvFf8bpKNlo8C-G91yMaxOEhVbzsBGr7n',
    ),
    (
      'Dr. Sarah Sterling',
      'Lead Aesthetic Dentist',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAVqN6rafuy-1psKjTG9L42HqBXsTt8C2f4FuyhXqkK7tIZg07ev72vtgAekmuWowUeNxkjIvJl5eQ6iX9WBz9GINFaE9kIT3hOzYr4VRzdviQEp7_5SVPsmJuqJVJxdV5v5HMHoEqXq_9hizChVGSZkb-wtf0bKF0_62V32ZOeW9b-c4X36G6Hmkw5pedxyZ0JxzrCrul-mOTIZykORIeSp1rGFcCjkzoXCO5oMJCe659YkK2OasO3',
    ),
    (
      'Dr. Michael Chen',
      'Specialist Surgeon',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDFexumFSx9FR7g4ZeDL-K9j4wmb3pryeAKDPlY16FT0_VCU3ey4qKpVatALbYR13lLes40O24FL4kO3JJ1EltHcOGzsWkuoBWHN2UIWD1Zb2tNRku9_zTugvoRVZ8D2gZJUWcs58s-A-3bD6gFdNIJyK3DIowu1Zfo-PBMJZGqUrK8k3S4Blhhw4eDp-Pej1GWSaMd_GgW38CtumneDW-8A7-w_Zn6HjJ0HbvAoD9B6BURuJSMsHz0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.xl, AppSpacing.marginMobile, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meet Our Leadership',
              style: AppTypography.headlineLg(color: AppColors.primary)
                  .copyWith(fontSize: 24)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A team of dedicated professionals committed to your oral health and aesthetic goals.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final member in _team) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: _NetworkImage(member.$3,
                        fallbackIcon: Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.$1,
                        style:
                            AppTypography.headlineSm(color: AppColors.primary)),
                    Text(member.$2.toUpperCase(),
                        style: AppTypography.labelMd()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.trending_flat),
              label: const Text('View All Specialists'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// CTA
// ---------------------------------------------------------------------
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.xl, AppSpacing.marginMobile, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text('Ready for a Pure Experience?',
                style: AppTypography.headlineMd(color: AppColors.primary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Join over 12,000 patients who have transformed their smiles with us.',
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: () {}, child: const Text('Book Online')),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary, width: 2)),
              child: const Text('Call Clinic'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Contact footer
// ---------------------------------------------------------------------
class _ContactFooter extends StatelessWidget {
  const _ContactFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.xl,
          AppSpacing.marginMobile, AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PureDent',
              style: AppTypography.headlineSm(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Redefining modern dental care with precision and compassion. Your journey to a perfect smile starts here.',
            style: AppTypography.bodySm(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('CONTACT US',
              style: AppTypography.labelMd(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Text('123 Clinical Plaza, Medical District\nNew York, NY 10001',
              style: AppTypography.bodySm()),
          const SizedBox(height: 4),
          Text('+91 98765 43210', style: AppTypography.bodySm()),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.public,
                      color: AppColors.onSurfaceVariant)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share,
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
          Text('© 2026 PureDent Dental Clinic. All rights reserved.',
              style: AppTypography.bodySm()),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class ListSkeleton extends StatefulWidget {
  const ListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<ListSkeleton> createState() => _ListSkeletonState();
}

class _ListSkeletonState extends State<ListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.38 + (_controller.value * 0.42);
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            96,
          ),
          itemCount: widget.itemCount,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => _SkeletonCard(opacity: opacity),
        );
      },
    );
  }
}

class DetailSkeleton extends StatefulWidget {
  const DetailSkeleton({super.key});

  @override
  State<DetailSkeleton> createState() => _DetailSkeletonState();
}

class _DetailSkeletonState extends State<DetailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.38 + (_controller.value * 0.42);
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          children: [
            _SkeletonBlock(height: 28, width: 220, opacity: opacity),
            const SizedBox(height: AppSpacing.md),
            _SkeletonBlock(height: 16, width: 160, opacity: opacity),
            const SizedBox(height: AppSpacing.xl),
            _SkeletonCard(opacity: opacity),
            const SizedBox(height: AppSpacing.md),
            _SkeletonCard(opacity: opacity),
            const SizedBox(height: AppSpacing.md),
            _SkeletonBlock(height: 120, opacity: opacity),
          ],
        );
      },
    );
  }
}

class FormSkeleton extends StatefulWidget {
  const FormSkeleton({super.key});

  @override
  State<FormSkeleton> createState() => _FormSkeletonState();
}

class _FormSkeletonState extends State<FormSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.38 + (_controller.value * 0.42);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkeletonBlock(height: 56, opacity: opacity),
              const SizedBox(height: AppSpacing.lg),
              _SkeletonBlock(height: 56, opacity: opacity),
              const SizedBox(height: AppSpacing.lg),
              _SkeletonBlock(height: 56, opacity: opacity),
              const SizedBox(height: AppSpacing.lg),
              _SkeletonBlock(height: 120, opacity: opacity),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: palette.border, width: palette.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SkeletonBlock(height: 42, width: 42, opacity: opacity, radius: AppRadii.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBlock(height: 16, width: 180, opacity: opacity),
                const SizedBox(height: AppSpacing.sm),
                _SkeletonBlock(height: 12, width: 240, opacity: opacity),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _SkeletonBlock(height: 24, width: 72, opacity: opacity, radius: AppRadii.pill),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.height,
    required this.opacity,
    this.width,
    this.radius = AppRadii.sm,
  });

  final double height;
  final double? width;
  final double opacity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

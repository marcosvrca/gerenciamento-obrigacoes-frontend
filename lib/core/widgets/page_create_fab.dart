import 'package:material_ui/material_ui.dart';

/// Create FAB shared by list pages.
/// Desktop: extended with [label]. Mobile: compact + icon only, optionally
/// lifted above the in-page pagination footer so it does not cover controls.
class PageCreateFab extends StatelessWidget {
  const PageCreateFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.liftAbovePagination = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// When true on narrow layouts, adds bottom padding above the pagination bar.
  final bool liftAbovePagination;

  static const double _mobilePaginationClearance = 72;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final Widget fab = wide
        ? FloatingActionButton.extended(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: Text(label),
          )
        : FloatingActionButton(
            onPressed: onPressed,
            tooltip: label,
            child: const Icon(Icons.add_rounded),
          );

    final bottom =
        (!wide && liftAbovePagination) ? _mobilePaginationClearance : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: fab,
    );
  }
}

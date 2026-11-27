import 'package:material_ui/material_ui.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class SearchableSelectOption<T> {
  const SearchableSelectOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

/// Searchable select: type to filter options; styled like the status filter dropdown.
class SearchableSelectField<T extends Object> extends StatefulWidget {
  const SearchableSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final List<SearchableSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  State<SearchableSelectField<T>> createState() =>
      _SearchableSelectFieldState<T>();
}

class _SearchableSelectFieldState<T extends Object>
    extends State<SearchableSelectField<T>> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  String? get _selectedLabel {
    for (final o in widget.options) {
      if (o.value == widget.value) return o.label;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _selectedLabel ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SearchableSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final label = _selectedLabel ?? '';
    if (!_focusNode.hasFocus && _textController.text != label) {
      _textController.text = label;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required AppPalette palette,
    required ColorScheme scheme,
    required bool hasError,
  }) {
    final fieldRadius = BorderRadius.circular(AppRadii.md);
    final borderColor = hasError ? scheme.error : palette.border;
    final focusedColor = hasError ? scheme.error : scheme.primary;

    return InputDecoration(
      labelText: widget.label,
      hintText: 'Digite para filtrar',
      filled: true,
      fillColor: palette.surface,
      prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
      suffixIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: scheme.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: borderColor,
          width: palette.borderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: borderColor,
          width: palette.borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: focusedColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.error, width: palette.borderWidth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (formState) {
        // Keep FormField in sync when parent value changes.
        if (formState.value != widget.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) formState.didChange(widget.value);
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final menuWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 420.0;

            return RawAutocomplete<SearchableSelectOption<T>>(
              textEditingController: _textController,
              focusNode: _focusNode,
              displayStringForOption: (option) => option.label,
              optionsBuilder: (textEditingValue) {
                final q = textEditingValue.text.trim().toLowerCase();
                if (q.isEmpty) return widget.options;
                return widget.options.where(
                  (o) => o.label.toLowerCase().contains(q),
                );
              },
              onSelected: (option) {
                _textController.text = option.label;
                formState.didChange(option.value);
                widget.onChanged(option.value);
                _focusNode.unfocus();
              },
              fieldViewBuilder: (
                context,
                textController,
                focusNode,
                onFieldSubmitted,
              ) {
                // TextField (not TextFormField) so only the outer FormField validates.
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  enabled: widget.enabled,
                  style: textTheme.bodyLarge?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _decoration(
                    palette: palette,
                    scheme: scheme,
                    hasError: formState.hasError,
                  ).copyWith(
                    errorText: formState.errorText,
                  ),
                  onTap: () {
                    // Select all so typing replaces and filters immediately.
                    textController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: textController.text.length,
                    );
                  },
                  onChanged: (_) {
                    // Typing clears committed value until a new option is picked.
                    if (formState.value != null) {
                      formState.didChange(null);
                      widget.onChanged(null);
                    }
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                final items = options.toList(growable: false);
                if (items.isEmpty) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 2,
                      color: palette.surface,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        side: BorderSide(
                          color: palette.border,
                          width: palette.borderWidth,
                        ),
                      ),
                      child: SizedBox(
                        width: menuWidth,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Nenhum resultado',
                            style: textTheme.bodyMedium?.copyWith(
                              color: palette.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 2,
                    color: palette.surface,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: BorderSide(
                        color: palette.border,
                        width: palette.borderWidth,
                      ),
                    ),
                    child: SizedBox(
                      width: menuWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final option = items[index];
                            final selected = option.value == widget.value;
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  border: index == items.length - 1
                                      ? null
                                      : Border(
                                          bottom: BorderSide(
                                            color: palette.border
                                                .withValues(alpha: 0.85),
                                            width: palette.borderWidth,
                                          ),
                                        ),
                                ),
                                child: Text(
                                  option.label,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: selected
                                        ? scheme.primary
                                        : palette.ink,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

/// Tappable "Where to?" bar. Opens destination search later.
class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 2,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.search, color: scheme.onSurface),
                const SizedBox(width: 12),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurface.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

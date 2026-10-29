import 'package:flutter/material.dart';

/// Floating button that opens the optional AI commuter assistant.
class AiAssistantButton extends StatelessWidget {
  const AiAssistantButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Open AI commuter assistant',
      child: Material(
        color: scheme.primary,
        elevation: 4,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.smart_toy_outlined,
                size: 32, color: scheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

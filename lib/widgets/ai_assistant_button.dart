import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

// "Ask Larga" pill that opens the optional AI commuter assistant.
class AiAssistantButton extends StatelessWidget {
  const AiAssistantButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const _mascotAsset = 'assets/images/mascot.png';
  static const double _avatarSize = 44;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ask Larga',
      child: Material(
        color: AppTheme.accent,
        elevation: 6,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 20, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    _mascotAsset,
                    width: _avatarSize,
                    height: _avatarSize,
                    fit: BoxFit.cover,

                    // Fallback if the asset if missing.
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: _avatarSize,
                      height: _avatarSize,
                      child: Icon(Icons.smart_toy_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ask Larga',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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

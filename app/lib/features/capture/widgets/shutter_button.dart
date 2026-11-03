import 'package:flutter/material.dart';

import '../../../design/motion/motion.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';

/// Camera shutter button with leveling gating per SPINE_BLUEPRINT.md 7.1.
class ShutterButton extends StatelessWidget {
  const ShutterButton({
    super.key,
    required this.canShoot,
    required this.onPressed,
    this.size = 76.0,
  });

  final bool canShoot;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final motion = context.motion;

    return AnimatedOpacity(
      duration: motion(SpineMotion.stateChange),
      opacity: canShoot ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: canShoot ? onPressed : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: canShoot ? semantic.brass : semantic.hairline,
              width: 3.0,
            ),
          ),
          padding: const EdgeInsets.all(SpineSpacing.xs),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canShoot ? semantic.brass : semantic.hairline,
            ),
          ),
        ),
      ),
    );
  }
}

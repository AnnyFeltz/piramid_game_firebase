import 'package:flutter/material.dart';

/// Widget de rating 1 a 5 estrelas. Modo display ou interativo.
class StarRatingWidget extends StatelessWidget {
  final int value;   // 1 a 5
  final double size;
  final bool interactive;
  final ValueChanged<int>? onChanged;

  const StarRatingWidget({
    super.key,
    required this.value,
    this.size = 28,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        if (!interactive) {
          return Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? color : Colors.grey.shade400,
            size: size,
          );
        }
        return GestureDetector(
          onTap: () => onChanged?.call(i + 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? color : Colors.grey.shade400,
            size: size,
          ),
        );
      }),
    );
  }
}

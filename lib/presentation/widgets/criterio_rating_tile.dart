import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'star_rating_widget.dart';

class CriterioRatingTile extends StatelessWidget {
  final String label;
  final String descricao;
  final int value;
  final bool interactive;
  final ValueChanged<int>? onChanged;

  const CriterioRatingTile({
    super.key,
    required this.label,
    required this.descricao,
    required this.value,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: context.textStyles.labelLarge?.semiBold),
                if (interactive)
                  Text(descricao,
                      style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          StarRatingWidget(
            value: value,
            interactive: interactive,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

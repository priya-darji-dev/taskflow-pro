import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/board_model.dart';

class BoardCard extends StatelessWidget {
  final BoardModel board;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BoardCard({
    super.key,
    required this.board,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(board.colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color swatch icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          board.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          board.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete Board',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Progress Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${board.completedTasks} / ${board.totalTasks} tasks completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(board.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: board.progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
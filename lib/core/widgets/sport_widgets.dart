import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sport-themed card with gradient background and modern styling
class SportCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useGradient;
  final VoidCallback? onTap;
  final bool isSelected;

  const SportCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.useGradient = false,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: useGradient ? AppTheme.cardGradient : null,
              color: useGradient ? null : (isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.cardDark),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status badge for tournaments, matches, etc.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.isLarge = false,
  });

  factory StatusBadge.tournament(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'setup':
      case 'configuração':
        color = AppTheme.warningColor;
        icon = Icons.settings;
        break;
      case 'inprogress':
      case 'em andamento':
        color = AppTheme.successColor;
        icon = Icons.play_circle_filled;
        break;
      case 'finished':
      case 'finalizado':
        color = AppTheme.infoColor;
        icon = Icons.check_circle;
        break;
      default:
        color = AppTheme.textSecondary;
        icon = Icons.help;
    }
    return StatusBadge(text: status, color: color, icon: icon);
  }

  factory StatusBadge.match(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'agendada':
        color = AppTheme.textSecondary;
        icon = Icons.schedule;
        break;
      case 'inprogress':
      case 'em andamento':
        color = AppTheme.successColor;
        icon = Icons.sports_soccer;
        break;
      case 'paused':
      case 'pausada':
        color = AppTheme.warningColor;
        icon = Icons.pause_circle;
        break;
      case 'finished':
      case 'finalizada':
        color = AppTheme.infoColor;
        icon = Icons.flag;
        break;
      default:
        color = AppTheme.textSecondary;
        icon = Icons.help;
    }
    return StatusBadge(text: status, color: color, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(
          color: color ?? AppTheme.primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isLarge ? 16 : 12,
              color: color ?? AppTheme.primaryColor,
            ),
            SizedBox(width: isLarge ? 6 : 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color ?? AppTheme.primaryColor,
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Team score display with colors
class TeamScore extends StatelessWidget {
  final String teamName;
  final int score;
  final bool isHome;
  final bool isSelected;

  const TeamScore({
    super.key,
    required this.teamName,
    required this.score,
    required this.isHome,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHome ? AppTheme.homeTeamColor : AppTheme.awayTeamColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Position indicator for players
class PositionBadge extends StatelessWidget {
  final String position;
  final String abbreviation;
  final double size;

  const PositionBadge({
    super.key,
    required this.position,
    required this.abbreviation,
    this.size = 32,
  });

  factory PositionBadge.fromPlayerPosition(String position, {double size = 32}) {
    String abbrev;
    switch (position.toLowerCase()) {
      case 'goleiro':
        abbrev = 'G';
        break;
      case 'fixo':
        abbrev = 'F';
        break;
      case 'ala':
        abbrev = 'A';
        break;
      case 'pivo':
      case 'pivô':
        abbrev = 'P';
        break;
      default:
        abbrev = position.substring(0, 1).toUpperCase();
    }
    return PositionBadge(
      position: position,
      abbreviation: abbrev,
      size: size,
    );
  }

  Color get _positionColor {
    switch (position.toLowerCase()) {
      case 'goleiro':
        return AppTheme.successColor;
      case 'fixo':
        return AppTheme.errorColor;
      case 'ala':
        return AppTheme.infoColor;
      case 'pivo':
      case 'pivô':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _positionColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _positionColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          abbreviation,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Action button with sport theming
class SportActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isSecondary;
  final bool isExpanded;

  const SportActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isSecondary = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isSecondary ? Colors.transparent : AppTheme.primaryColor);
    final fgColor = foregroundColor ?? (isSecondary ? AppTheme.primaryColor : Colors.black);

    Widget button = isSecondary
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: fgColor,
              side: BorderSide(color: fgColor, width: 1.5),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
            ),
          );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Statistics display widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;

    return SportCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: cardColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: cardColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

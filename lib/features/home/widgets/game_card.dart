import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;
  final String? gameId;
  final bool showNewBadge;

  const GameCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.color,
    required this.onTap,
    this.gameId,
    this.showNewBadge = false,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation controller (only for new games)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerAnimation = Tween<double>(begin: -0.8, end: 1.8).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    if (widget.showNewBadge) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart shimmer animation if showNewBadge changes
    if (widget.showNewBadge != oldWidget.showNewBadge) {
      if (widget.showNewBadge) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 600;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          // Regular shadows for all games
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top section with game icon and title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Larger prominent game icon
                    Container(
                      width: isSmallScreen ? 72 : 88,
                      height: isSmallScreen ? 72 : 88,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 22 : 26,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.2),
                            blurRadius: 48,
                            offset: const Offset(0, 20),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Center(
                          child: Image.asset(
                            widget.iconPath,
                            width: isSmallScreen ? 36 : 44,
                            height: isSmallScreen ? 36 : 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 10 : 12),

                    // Game title with even smaller typography
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 12 : 14,
                        letterSpacing: isSmallScreen ? 0.05 : 0.1,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Bottom section with smaller play button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: isSmallScreen ? 12 : 14,
                        color: widget.color,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Text(
                        AppLocalizations.of(context)!.play,
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 10 : 12,
                          letterSpacing: isSmallScreen ? 0.3 : 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Return card with or without NEW badge
    if (widget.showNewBadge) {
      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // Ana kart - cardContent ile aynı yapı
          cardContent,
          // Shimmer effect overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 16 : 20,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: [
                            0.0,
                            (_shimmerAnimation.value - 0.4).clamp(0.0, 1.0),
                            (_shimmerAnimation.value - 0.2).clamp(0.0, 1.0),
                            _shimmerAnimation.value.clamp(0.0, 1.0),
                            (_shimmerAnimation.value + 0.2).clamp(0.0, 1.0),
                            (_shimmerAnimation.value + 0.4).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Static NEW badge
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: isSmallScreen ? 48 : 56,
                height: isSmallScreen ? 26 : 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600,
                      Colors.pinkAccent.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(isSmallScreen ? 16 : 20),
                    bottomLeft: Radius.circular(isSmallScreen ? 10 : 12),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: isSmallScreen ? 9 : 10,
                      letterSpacing: 0.7,
                      shadows: const [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black26,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return cardContent;
    }
  }
}

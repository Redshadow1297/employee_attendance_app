//  SLIVER HEADER DELEGATE
import 'package:flutter/material.dart';

class PremiumHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const PremiumHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(PremiumHeaderDelegate old) =>
      minHeight != old.minHeight ||
      maxHeight != old.maxHeight ||
      child != old.child;
}

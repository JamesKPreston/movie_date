import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';

class SwipeableIntroStep extends StatefulWidget {
  final Widget Function(BuildContext context, GlobalKey key) builder;
  final int order;
  final String group;
  final void Function(SwipeDirection direction)? onSwipe;
  final VoidCallback? onHighlightWidgetTap;
  final String? text;
  final Widget Function(StepWidgetParams params)? overlayBuilder;
  final OverlayPosition Function({
    required Size size,
    required Size screenSize,
    required Offset offset,
  })? getOverlayPosition;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onWidgetLoad;

  const SwipeableIntroStep({
    Key? key,
    required this.order,
    required this.builder,
    this.text,
    this.overlayBuilder,
    this.getOverlayPosition,
    this.borderRadius,
    this.padding,
    this.onHighlightWidgetTap,
    this.onWidgetLoad,
    this.group = 'default',
    this.onSwipe,
  }) : super(key: key);

  @override
  _SwipeableIntroStepState createState() => _SwipeableIntroStepState();
}

class _SwipeableIntroStepState extends State<SwipeableIntroStep> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onHighlightWidgetTap,
      onHorizontalDragEnd: (details) {
        if (widget.onSwipe != null) {
          final direction = details.primaryVelocity! > 0 ? SwipeDirection.right : SwipeDirection.left;
          widget.onSwipe?.call(direction);
        }
      },
      onVerticalDragEnd: (details) {
        if (widget.onSwipe != null) {
          final direction = details.primaryVelocity! > 0 ? SwipeDirection.down : SwipeDirection.up;
          widget.onSwipe?.call(direction);
        }
      },
      child: IntroStepBuilder(
        order: widget.order,
        builder: widget.builder,
        text: widget.text,
        overlayBuilder: (params) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (widget.onSwipe != null) {
                final direction = details.primaryVelocity! > 0 ? SwipeDirection.right : SwipeDirection.left;
                widget.onSwipe?.call(direction);
              }
            },
            onVerticalDragEnd: (details) {
              if (widget.onSwipe != null) {
                final direction = details.primaryVelocity! > 0 ? SwipeDirection.down : SwipeDirection.up;
                widget.onSwipe?.call(direction);
              }
            },
            child: widget.overlayBuilder != null ? widget.overlayBuilder!(params) : const SizedBox.shrink(),
          );
        },
        getOverlayPosition: widget.getOverlayPosition,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        onHighlightWidgetTap: widget.onHighlightWidgetTap,
        onWidgetLoad: widget.onWidgetLoad,
        group: widget.group,
      ),
    );
  }
}

enum SwipeDirection {
  up,
  down,
  left,
  right,
}

import 'package:flutter/material.dart';

/// A row that can be dragged left to reveal action buttons (add note,
/// delete), without pulling in an extra package for it.
class SwipeActionsTile extends StatefulWidget {
  const SwipeActionsTile({
    super.key,
    required this.child,
    required this.actions,
    this.actionsWidth = 160,
  });

  final Widget child;
  final List<Widget> actions;
  final double actionsWidth;

  @override
  State<SwipeActionsTile> createState() => _SwipeActionsTileState();
}

class _SwipeActionsTileState extends State<SwipeActionsTile> {
  double _dragExtent = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(-widget.actionsWidth, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final open = _dragExtent < -widget.actionsWidth / 2;
    setState(() => _dragExtent = open ? -widget.actionsWidth : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            children: [
              const Spacer(),
              SizedBox(width: widget.actionsWidth, child: Row(children: widget.actions)),
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

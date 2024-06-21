import 'package:flutter/material.dart';
import 'dart:math';

class CircularSelector extends StatefulWidget {
  const CircularSelector({
    super.key,
    required this.children,
    required this.childSize,
    required this.radiusDividend,
    required this.onSelected,
    required this.customOffset,
  });

  /// The number that the device width is divided by to
  /// get the radius of the circle.
  final double radiusDividend;

  /// The children to be displayed in the circular selector.
  final List<Widget> children;

  /// The size of the children.
  final double childSize;

  /// The function to be called when a child is selected.
  ///
  /// The index of the selected child is passed as an argument.
  final Function(int index) onSelected;

  /// A custom offset defined from the top left for the circle.
  final Offset customOffset;

  /// Returns a list of circular containers for testing purposes.
  ///
  /// The number of containers is defined by the [num] parameter.
  static List<Container> getTestContainers(int num, double childSize) {
    List<Container> containers = [];
    for (int i = 0; i < num; i++) {
      containers.add(Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: Center(
          child: Text(
            (i + 1).toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ));
    }
    return containers;
  }

  @override
  // ignore: library_private_types_in_public_api
  _CircularSelectorState createState() => _CircularSelectorState();
}

class _CircularSelectorState extends State<CircularSelector>
    with SingleTickerProviderStateMixin {
  late double rotation;
  late AnimationController _controller;
  late Animation<double> _animation;
  late double startRotation;
  late Offset parentDimensions;

  static double calculateGestureAngle(
      double dx, double dy, double xOrigin, double yOrigin) {
    double angle = atan2(dy - yOrigin, dx - xOrigin) * 180 / pi;
    angle = angle < 0 ? 360 + angle : angle;
    angle = (angle + 90) % 360; // Adjusting the origin to 12 o'clock
    return angle;
  }

  @override
  void initState() {
    super.initState();
    rotation = 0.0;
    startRotation = 0.0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          rotation = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int getTappedChildIndex(
      double dx, double dy, double xOrigin, double yOrigin) {
    final angleDeg = calculateGestureAngle(dx, dy, xOrigin, yOrigin);
    final anglePerChild = 360 / widget.children.length;

    // Adjust angle to account for current rotation
    double adjustedAngle = angleDeg - (rotation * 180 / pi);
    adjustedAngle = adjustedAngle < 0 ? 360 + adjustedAngle : adjustedAngle;

    // Determine the child index based on the adjusted angle
    int index =
        (adjustedAngle / anglePerChild).round() % widget.children.length;
    return index;
  }

  int getIndexAtTop() {
    // Convert rotation from radians to degrees and normalize to 0-360 range
    double rotationDegrees = (rotation * 180 / pi) % 360;
    rotationDegrees =
        rotationDegrees < 0 ? 360 + rotationDegrees : rotationDegrees;

    // Calculate the angle per child
    final anglePerChild = 360 / widget.children.length;

    // Calculate the index of the child at the top
    int indexAtTop = ((360 - rotationDegrees) / anglePerChild).round() %
        widget.children.length;

    return indexAtTop;
  }

  void animateToTop(int index) {
    final anglePerChild = 360 / widget.children.length;
    var targetRotation = -(index * anglePerChild) * pi / 180;
    final currentRotationMod = rotation % (2 * pi);
    var rotationDiff = (currentRotationMod - targetRotation) % (2 * pi);

    // Shortest rotation direction
    if (rotationDiff > pi) {
      rotationDiff -= 2 * pi;
    } else if (rotationDiff < -pi) {
      rotationDiff += 2 * pi;
    }

    targetRotation = currentRotationMod - rotationDiff;

    final rotationDiffDeg = (rotationDiff * 180 / pi).abs().round();

    // Dynamic Duration Calculation
    final duration = Duration(milliseconds: rotationDiffDeg * 2);

    _controller.duration = duration;

    if (_controller.isAnimating) {
      _controller.stop();
    }

    _animation =
        Tween<double>(begin: currentRotationMod, end: targetRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
            setState(() {
              rotation = _animation.value;
            });
          });

    _controller.forward(from: 0);
  }

  void _onPanStart(DragStartDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;

    final xOrigin = parentDimensions.dx / 2;
    final yOrigin = parentDimensions.dy / 2;

    startRotation = calculateGestureAngle(dx, dy, xOrigin, yOrigin);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;

    if (dx <= 1.0 && dy <= 1.0) {
      return;
    }

    final xOrigin = parentDimensions.dx / 2;
    final yOrigin = parentDimensions.dy / 2;

    final angle = calculateGestureAngle(dx, dy, xOrigin, yOrigin);

    final angleDiff = angle - startRotation;

    setState(() {
      // Update the rotation
      rotation += (angleDiff * pi / 180);
      startRotation = angle;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final anglePerChild = 2 * pi / widget.children.length;
    double closestRotation = (rotation / anglePerChild).round() * anglePerChild;

    _controller.duration = const Duration(milliseconds: 100);

    // If the rotation is close to a child, snap to that child
    _animation = Tween<double>(begin: rotation, end: closestRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          rotation = _animation.value;
        });
      });

    _controller.forward(from: 0);

    widget.onSelected(getIndexAtTop());
  }

  @override
  Widget build(BuildContext context) {
    final parentWidth = MediaQuery.of(context).size.width;
    final parentHeight =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    parentDimensions = Offset(parentWidth, parentHeight);

    Point getPosition(int index, double childSize, double? xOrigin,
        double? yOrigin, double? radius) {
      xOrigin ??= (parentWidth / 2);
      yOrigin ??= (parentHeight / 2) - widget.customOffset.dy / 2.5;
      radius ??= min(parentWidth, parentHeight) / widget.radiusDividend;

      // Calculate the position of the child
      final angle = 2 * pi * index / widget.children.length + rotation;
      final dx = xOrigin + radius * cos(-(angle - pi / 2)) - childSize / 2;
      final dy = yOrigin + radius * sin(-(angle - pi / 2)) - childSize / 2;

      return Point(dx, dy);
    }

    List<Widget> positionedChildren = [];
    for (int i = 0; i < widget.children.length; i++) {
      final position = getPosition(i, widget.childSize, null, null, null);
      final child = widget.children[i];
      final positionedChild = Positioned(
        left: position.x.toDouble(),
        bottom: position.y.toDouble(),
        child: SizedBox(
          width: widget.childSize,
          height: widget.childSize,
          child: child,
        ),
      );
      positionedChildren.add(positionedChild);
    }

    return GestureDetector(
      onTapUp: (details) {
        final dx = details.localPosition.dx;
        final dy = details.localPosition.dy;
        final xOrigin = (parentWidth / 2);
        final yOrigin = (parentHeight / 2);

        final index = getTappedChildIndex(dx, dy, xOrigin, yOrigin);
        widget.onSelected(index);
        animateToTop(index);
      },
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Stack(
          children: positionedChildren,
        ),
      ),
    );
  }
}

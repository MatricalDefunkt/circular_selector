import 'package:flutter/material.dart';
import 'dart:math';

class CircularSelector extends StatefulWidget {
  const CircularSelector(
      {super.key,
      required this.children,
      required this.childSize,
      required this.radiusDividend,
      required this.onSelected,
      required this.customOffset,
      this.circleBackgroundColor = Colors.transparent});

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
  static List<Container> getTestContainers(int num, double childSize,
      {bool rainbow = false}) {
    List<Container> containers = [];
    for (int i = 0; i < num; i++) {
      // Calculate the segment length
      int segmentLength = num ~/ 3;
      int r = 0, g = 0, b = 0;

      if (rainbow) {
        if (i < segmentLength) {
          // Red to Green
          r = 255 - (255 * i ~/ segmentLength);
          g = 255 * i ~/ segmentLength;
          b = 0;
        } else if (i < segmentLength * 2) {
          // Green to Blue
          int j = i - segmentLength;
          g = 255 - (255 * j ~/ segmentLength);
          b = 255 * j ~/ segmentLength;
        } else {
          // Blue to Red
          int j = i - segmentLength * 2;
          b = 255 - (255 * j ~/ segmentLength);
          r = 255 * j ~/ segmentLength;
        }
      }

      containers.add(Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: rainbow ? Color.fromARGB(255, r, g, b) : Colors.green,
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

  final Color circleBackgroundColor;

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

  double calculateGestureAngle(
      double dx, double dy, double xOrigin, double yOrigin) {
    double angle = atan2(dy - yOrigin, dx - xOrigin) * 180 / pi;
    angle = angle < 0 ? 360 + angle : angle;
    angle = (angle + 90) % 360; // Adjusting the origin to 12 o'clock
    return angle;
  }

  int getTappedChildIndex(
      double dx, double dy, double xOrigin, double yOrigin) {
    final angleDeg = calculateGestureAngle(dx, dy, xOrigin, yOrigin);
    final anglePerChild = 360 / widget.children.length;

    // Adjust angle to account for current rotation
    double adjustedAngle = angleDeg - (rotation * 180 / pi);
    adjustedAngle = adjustedAngle < 0 ? 360 + adjustedAngle : adjustedAngle;

    // Determine the child index based on the adjusted angle
    double centerOffset = anglePerChild / 2;
    int index = ((adjustedAngle + centerOffset) / anglePerChild).floor() %
        widget.children.length;
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

  double totalRotation = 0;

  Function(DragStartDetails) _onPanStart(double xOrigin, double yOrigin) {
    return (DragStartDetails details) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      final dx = details.localPosition.dx;
      final dy = details.localPosition.dy;

      startRotation = calculateGestureAngle(dx, dy, xOrigin, yOrigin);
      totalRotation = 0;
    };
  }

  Function(DragUpdateDetails) _onPanUpdate(double xOrigin, double yOrigin) {
    return (DragUpdateDetails details) {
      final dx = details.localPosition.dx;
      final dy = details.localPosition.dy;

      final angle = calculateGestureAngle(dx, dy, xOrigin, yOrigin);

      final angleDiff = angle - startRotation;

      setState(() {
        rotation += (angleDiff * pi / 180);
        startRotation = angle;
      });

      totalRotation += angleDiff;
    };
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
    final parentHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;
    final xOrigin =
        (min(parentWidth, parentHeight) / widget.radiusDividend * 2) / 2;
    final yOrigin =
        (min(parentWidth, parentHeight) / widget.radiusDividend * 2) / 2;

    Point getPosition(
        int index, double childSize, double xOrigin, double yOrigin) {
      final double radius =
          min(parentWidth, parentHeight) / widget.radiusDividend;

      // xOrigin += widget.customOffset.dx;
      // yOrigin += widget.customOffset.dy;

      // Calculate the position of the child
      final angle = 2 * pi * index / widget.children.length + rotation;
      final dx = xOrigin + radius * cos(-(angle - pi / 2)) + childSize / 2;
      final dy = yOrigin + radius * sin(-(angle - pi / 2)) + childSize / 2;

      return Point(dx, dy);
    }

    List<Widget> positionedChildren = [];
    for (int i = 0; i < widget.children.length; i++) {
      final position = getPosition(
        i,
        widget.childSize,
        xOrigin,
        yOrigin,
      );
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

    return SizedBox(
        width: min(parentWidth, parentHeight) / widget.radiusDividend * 2 +
            widget.childSize * 2,
        height: min(parentWidth, parentHeight) / widget.radiusDividend * 2 +
            widget.childSize * 2,
        child: GestureDetector(
          onTapUp: (details) {
            final dx = details.localPosition.dx;
            final dy = details.localPosition.dy;

            final index = getTappedChildIndex(dx, dy, xOrigin, yOrigin);
            widget.onSelected(index);
            animateToTop(index);
          },
          onPanStart: _onPanStart(xOrigin, yOrigin),
          onPanUpdate: _onPanUpdate(xOrigin, yOrigin),
          onPanEnd: _onPanEnd,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.circleBackgroundColor,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: positionedChildren,
            ),
          ),
        ));
  }
}

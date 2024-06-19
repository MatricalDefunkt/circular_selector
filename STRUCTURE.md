Class CircularSelector
  - Initialize required properties (children, childSize, etc.)
  - Method: build
    - Calculate device dimensions
    - Generate positioned children based on calculations
    - Return a GestureDetector that handles tap and pan gestures

Class _CircularSelectorState
  - Initialize state variables (rotation, animation controller, etc.)
  - Method: initState
    - Setup animation controller
  - Method: dispose
    - Dispose animation controller
  - Method: calculateGestureAngle
    - Calculate angle based on gesture position
  - Method: getTappedChildIndex
    - Determine which child was tapped based on angle
  - Method: animateToTop
    - Animate selected child to the top position
  - Method: _onPanUpdate
    - Handle pan update gesture
  - Method: _onPanEnd
    - Animate to closest child on pan end

Utility Functions
  - Function: getPosition
    - Calculate position for each child based on index and rotation
  - Function: calculateRotationDiff
    - Calculate the shortest rotation difference for animation

Widget Tests
  - Test widget builds correctly with required parameters
  - Test gesture interactions trigger expected behavior

Unit Tests
  - Test utility functions with various inputs
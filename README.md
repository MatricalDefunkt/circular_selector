A dial like selector for a new way of selecting values.

## Features

1. Modular: The dial has children which you will be able to define.
2. Animated: The dial is animated robustly.
3. Selecting values: The API provides a way to give a callback function for ease of use.
4. Ease of Access: There are 2 ways of interacting with the dial, by dragging or by tapping.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  circular_selector: ^0.0.1
```

In your library add the following import:

```dart
import 'package:circular_selector/circular_selector.dart';
```

That's it, now you can use the CircularSelector widget!

## Usage
You can refer to a simple example below:

```dart
CircularSelector(
    onSelected: (int index) {
        print('Selected: $index');
    },
    childSize: 30.0,
    radiusDividend: 2.5,
    customOffset: Offset(
        0.0,
        AppBar().preferredSize.height,
    ),
    children: CircularSelector.getTestContainers(20, 30.0),
)
```

For an executable example, refer to the `example` folder.

# CONTRIBUTING

If you would like to contribute to the package, please refer to the [CONTRIBUTING.md](

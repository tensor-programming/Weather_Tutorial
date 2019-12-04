import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:weather/model/model_command.dart';

class ModelProvider extends InheritedWidget {
  final ModelCommand modelCommand;

  ModelProvider({Key key, @required this.modelCommand, @required Widget child})
      : assert(modelCommand != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(ModelProvider oldWidget) {
    return modelCommand != oldWidget.modelCommand;
  }

  static ModelCommand of<T extends ModelProvider>(BuildContext context) {
    final ModelProvider inherited =
        context.dependOnInheritedWidgetOfExactType<ModelProvider>();

    return inherited?.modelCommand;
  }
}

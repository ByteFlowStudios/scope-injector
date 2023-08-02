import 'package:flutter/cupertino.dart';
import 'package:flutter_scope/scoped_state.dart';

extension EntryPointContext on BuildContext {
  T inject<T>() {
    final provider = ScopedState.of(this);
    if (provider != null) {
      return provider.inject<T>();
    } else {
      throw Exception("Provider has not been found");
    }
  }
}

extension EntryPointState on State {
  T inject<T>({String? qualifier}) {
    if (this is ScopedState) {
      return (this as ScopedState).inject<T>(qualifier: qualifier);
    }
    final provider = ScopedState.of(context);
    if (provider != null) {
      return provider.inject<T>(qualifier: qualifier);
    } else {
      throw Exception("Provider has not been found");
    }
  }
}

import 'package:flutter/foundation.dart';

abstract class AbstractProvider<T> {
  T getInstance({String? qualifier});

  List<T> provideAll();

  List<T> getAllInstances();

  register({
    String? qualifier,
    bool? singleton,
    required T Function() builder,
  });
}

class QualifierProvider<T> extends AbstractProvider<T> {
  final Map<String, T Function()> _builders = {};
  final Map<String, T> _instances = {};
  final Set<String> _singletons = {};

  @override
  T getInstance({String? qualifier}) {
    qualifier ??= "default";
    // if not singleton, always create new instance
    if (!_singletons.contains(qualifier)) {
      if (kDebugMode) {
        print("New instance of $T with \"$qualifier\" qualifier");
      }
      return _builders[qualifier]?.call() ??
          (throw Exception("No builder for $T with \"$qualifier\" qualifier"));
    }
    T? instance = _instances[qualifier];
    if (instance != null) {
      return instance;
    } else {
      T? provided = _builders[qualifier]?.call();
      if (provided == null) {
        throw Exception("No builder for $T with \"$qualifier\" qualifier");
      }
      _instances[qualifier] = provided;
      if (kDebugMode) {
        print("Initialized $T with \"$qualifier\" qualifier");
      }
      return provided;
    }
  }

  @override
  register({
    String? qualifier,
    bool? singleton,
    required T Function() builder,
  }) {
    qualifier ??= "default";
    singleton ??= true;
    _builders[qualifier] = builder;
    if (singleton == true) {
      _singletons.add(qualifier);
    }
  }

  @override
  List<T> provideAll() {
    return _builders.values.map((e) => e.call()).toList();
  }

  @override
  List<T> getAllInstances() {
    return _instances.values.toList();
  }
}

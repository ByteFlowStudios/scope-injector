import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_scope/provider.dart';
import 'package:flutter_scope/subscription_handler.dart';

abstract class ScopedState<T extends StatefulWidget> extends State<T>
    implements SubscriptionHandler {
  final Map<Type, AbstractProvider> _registry = {};

  final List<StreamSubscription> _subscriptions = [];

  @override
  void handleSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  static ScopedState? of(BuildContext context) {
    return context.findAncestorStateOfType<ScopedState>();
  }

  ScopedState? getPreviousScope() {
    return of(context);
  }

  E inject<E>({String? qualifier}) {
    AbstractProvider? provider = _registry[E];
    if (provider != null) {
      return provider.getInstance(qualifier: qualifier);
    } else {
      final previousScope = getPreviousScope();
      if (previousScope != null) {
        return previousScope.inject(qualifier: qualifier);
      } else {
        throw Exception("$E has not been provided");
      }
    }
  }

  bool isProvided<E>({String? qualifier}) {
    try {
      inject<E>(qualifier: qualifier);
      return true;
    } on Exception {
      return false;
    }
  }

  void _provide<E>(E Function() builder, {String? qualifier, bool? singleton}) {
    final provider = _registry[E];
    if (provider != null) {
      provider.register(
        builder: builder,
        qualifier: qualifier,
        singleton: singleton,
      );
    } else {
      _registry[E] = QualifierProvider<E>();
      _registry[E]!.register(
        builder: builder,
        qualifier: qualifier,
        singleton: singleton,
      );
    }
  }

  @protected
  List<Module> provideModules() => [];

  @override
  void initState() {
    super.initState();
    provideModules().forEach((module) {
      module.onProvide();
    });
  }

  void disposeSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _registry.forEach((key, value) {
      final dependency = value.getAllInstances();
      for (var dependency in dependency) {
        if (dependency is Disposable) {
          dependency.dispose();
        }
      }
    });
    _registry.clear();
    super.dispose();
  }
}

abstract class Module {
  final ScopedState _scopedState;

  Module(this._scopedState);

  void onProvide();

  E inject<E>({String? qualifier}) => _scopedState.inject();

  void provide<E>(E Function() builder, {String? qualifier, bool? singleton}) {
    _scopedState._provide(builder, qualifier: qualifier, singleton: singleton);
  }
}

abstract class Disposable {
  void dispose();
}

abstract class Initializable {
  void initialize();
}

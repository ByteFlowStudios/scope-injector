## Features

- [x] Dependency injection with singletons and factories
- [x] Scope system
- [x] Dependency injection with qualifiers
- [x] Module System

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  scope_injector: ^0.0.1
```

## Usage

First is necessary to create a class that extends from `Module` and override the `onProvide` method.
Inside this method you can use the `provide` method to register your dependencies.

```dart
class RepositoryDiModule extends Module {
  RepositoryDiModule(super.scopedState);

  @override
  void onProvide() {
    provide<ProjectRepository>(() => ProjectRepositoryImp(inject()));
    provide<UserRepository>(() => UserRepositoryImp(inject(), inject()));

    // provide with qualifier
    provide<PaymentRepository>(() => PaymentRepositoryImpA(inject()), qualifier: 'payment.a');
    provide<PaymentRepository>(() => PaymentRepositoryImpB(inject()), qualifier: 'payment.b');

    // provide a non singleton dependency, by default all dependencies are singletons
    provide<PaymentService>(() => PaymentServiceImp(inject()), singleton: false);
  }
}
```

Then you have to create a stateful widget with a state that extends from `ScopedState` and override
the `getModules` method. And inject your dependencies by using the `inject` method.

```dart
class ScopedWidget extends StatefulWidget {
  const ExampleWidget({Key? key}) : super(key: key);

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends ScopedState<ExampleWidget> {

  // inject your dependencies here
  late final ProjectRepository projectRepository = inject();
  late final UserRepository userRepository = inject();
  late final PaymentRepository paymentRepository = inject(qualifier: 'payment.a');

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  // initialize the modules here
  @override
  List<Module> getModules() => [RepositoryDiModule(this)];

}
```

Finally you can use the `inject` method to get your dependencies.

```dart
class ChildWidget extends StatefulWidget {
  const ChildWidget({Key? key}) : super(key: key);

  @override
  State<ChildWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {

  // inject your dependencies here
  late final ProjectRepository projectRepository = inject();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

## Additional information


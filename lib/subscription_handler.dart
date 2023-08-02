import 'dart:async';

abstract class SubscriptionHandler {
  void handleSubscription(StreamSubscription subscription);
}

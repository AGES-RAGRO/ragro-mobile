import 'package:flutter/material.dart';

/// Shared RouteObserver registered on the orders shell-branch navigator.
/// Allows widgets inside that branch to detect when a sub-route is popped
/// (e.g. returning from OrderDetailPage to CustomerOrdersPage).
final RouteObserver<ModalRoute<void>> ordersRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// Same idea for the producer shell-branch navigator: lets ProducerOrdersPage
/// refresh when a sub-route (route screen / order detail) is popped back to it.
final RouteObserver<ModalRoute<void>> producerRouteObserver =
    RouteObserver<ModalRoute<void>>();

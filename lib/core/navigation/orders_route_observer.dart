import 'package:flutter/material.dart';

/// Shared RouteObserver registered on the orders shell-branch navigator.
/// Allows widgets inside that branch to detect when a sub-route is popped
/// (e.g. returning from OrderDetailPage to CustomerOrdersPage).
final RouteObserver<ModalRoute<void>> ordersRouteObserver =
    RouteObserver<ModalRoute<void>>();

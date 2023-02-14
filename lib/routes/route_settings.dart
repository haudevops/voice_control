import 'package:driver_vm/page/page.dart';
import 'package:flutter/material.dart';

import 'screen_arguments.dart';
import 'slide_left_route.dart';

class CustomRouter {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    late ScreenArguments arg;
    final Object? arguments = settings.arguments;
    if (arguments != null) {
      arg = arguments as ScreenArguments;
    }
    switch (settings.name) {
      case HomePage.routeName:
        return SlideLeftRoute(const HomePage());
      case DriverMapPage.routeName:
        return SlideLeftRoute(DriverMapPage(data: arg,));
      case DrawMapPage.routeName:
        return SlideLeftRoute(DrawMapPage(data: arg,));
      default:
        throw ('this route name does not exist');
    }
  }
}

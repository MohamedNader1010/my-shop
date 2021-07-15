// import 'package:flutter/material.dart';

// class CustomRoute<T> extends MaterialPageRoute<T> {
//   CustomRoute({
//     WidgetBuilder builder,
//     RouteSettings settings,
//   }) : super(
//           builder: builder,
//           settings: settings,
//         );

//   @override
//   Widget buildTransitions(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     if (settings.isInitialRoutes) { // i read the docs which says that the flutter team removed isInitialRoutes
//     // and replace it with onGenerateInitialRoutes.
//       return child;
//     }
//     return FadeTransition(
//       opacity: animation,
//       child: child,
//     );
//   }
// }

// class CustomPageTransitionBuilder extends PageTransitionsBuilder {
//   @override
//   Widget buildTransitions<T>(
//     PageRoute<T> route,
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     if (route.settings.isInitialRoute) {
//       return child;
//     }
//     return FadeTransition(
//       opacity: animation,
//       child: child,
//     );
//   }
// }

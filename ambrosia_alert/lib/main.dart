import 'dart:async';
import 'package:ambrosia_alert/cubits/auth/auth_cubit.dart';
import 'package:ambrosia_alert/views/login/login_view.dart';
import 'package:ambrosia_alert/views/signup/signup_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ambrosia_alert/blocs/geolocation/geolocation_bloc.dart';
import 'package:ambrosia_alert/repositories/geolocation/geolocation_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_routes.dart';
import 'views/home/home_view.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark
        .copyWith(statusBarIconBrightness: Brightness.dark),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GeolocationRepository>(
          create: (_) => GeolocationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GeolocationBloc(
                geolocationRepository: context.read<GeolocationRepository>())
              ..add(LoadGeolocation()),
          ),
          BlocProvider(create: (_) => AuthCubit()),
        ],
        child: MaterialApp(
          title: 'Ambrosia Alert',
          home: MapHomePage(),
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          initialRoute: AppRoutes.home,
          routes: <String, WidgetBuilder>{
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.signup: (_) => const RegistrationScreen(),
            // AppRoutes.forgotPassword: (_) => ForgotPasswordView(),
            AppRoutes.home: (_) => MapHomePage(),
          },
        ),
      ),
    );
  }
}

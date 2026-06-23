import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/auth_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

class AnukaApp extends StatelessWidget {
  const AnukaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anuka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const AuthScreen();
        }

        return StreamBuilder<AppUser?>(
          stream: UserService.instance.watchUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final appUser = userSnapshot.data;
            if (appUser == null || appUser.name.trim().isEmpty) {
              return OnboardingScreen(firebaseUser: firebaseUser);
            }

            return FeedScreen(currentUser: appUser);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


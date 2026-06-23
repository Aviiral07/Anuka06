import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum AuthMethod { email, phone }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  AuthMethod _method = AuthMethod.email;
  bool _isLogin = true;
  bool _isSubmitting = false;
  String? _verificationId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isLogin) {
        await AuthService.instance.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.instance.signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Authentication failed.');
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitPhone() async {
    if (!_phoneFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_verificationId == null) {
        await AuthService.instance.sendPhoneCode(
          phoneNumber: _phoneController.text,
          onCodeSent: (verificationId) {
            if (!mounted) {
              return;
            }
            setState(() {
              _verificationId = verificationId;
              _isSubmitting = false;
            });
            _showMessage('Verification code sent.');
          },
          onError: (error) {
            if (!mounted) {
              return;
            }
            setState(() => _isSubmitting = false);
            _showMessage(error.message ?? 'Could not send verification code.');
          },
          onAutoVerified: (_) {
            if (!mounted) {
              return;
            }
            setState(() => _isSubmitting = false);
          },
        );
        return;
      }

      await AuthService.instance.verifySmsCode(
        verificationId: _verificationId!,
        smsCode: _smsController.text,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Phone sign-in failed.');
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Anuka',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Post a need. Let someone nearby help.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SegmentedButton<AuthMethod>(
                        segments: const [
                          ButtonSegment(
                            value: AuthMethod.email,
                            label: Text('Email'),
                          ),
                          ButtonSegment(
                            value: AuthMethod.phone,
                            label: Text('Phone'),
                          ),
                        ],
                        selected: {_method},
                        onSelectionChanged: (value) {
                          setState(() {
                            _method = value.first;
                            _verificationId = null;
                            _smsController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_method == AuthMethod.email) _buildEmailForm(),
                      if (_method == AuthMethod.phone) _buildPhoneForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? 'Sign in with email' : 'Create account',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Use at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitEmail,
            child: Text(_isSubmitting
                ? 'Please wait...'
                : (_isLogin ? 'Sign In' : 'Create Account')),
          ),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    setState(() => _isLogin = !_isLogin);
                  },
            child: Text(
              _isLogin
                  ? 'Need an account? Create one'
                  : 'Already have an account? Sign in',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign in with phone',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+919876543210',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your phone number';
              }
              if (!value.trim().startsWith('+')) {
                return 'Use international format, e.g. +91...';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          if (_verificationId != null)
            TextFormField(
              controller: _smsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SMS Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_verificationId != null &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the SMS code';
                }
                return null;
              },
            ),
          if (_verificationId != null) const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitPhone,
            child: Text(
              _isSubmitting
                  ? 'Please wait...'
                  : (_verificationId == null ? 'Send Code' : 'Verify Code'),
            ),
          ),
          if (_verificationId != null)
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _verificationId = null;
                        _smsController.clear();
                      });
                    },
              child: const Text('Use a different phone number'),
            ),
        ],
      ),
    );
  }
}


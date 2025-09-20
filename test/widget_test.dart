// This is a basic Flutter widget test for the Optimizer app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:optimizer/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptimizerApp());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptimizerApp());

    // Wait for the splash screen to build
    await tester.pump();

    // Verify that the splash screen is displayed
    expect(find.text('OPTIMIZER'), findsOneWidget);
    expect(find.text('Optimize Your Performance'), findsOneWidget);
  });

  testWidgets('Splash screen navigates to signup after delay', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptimizerApp());

    // Wait for initial build
    await tester.pump();

    // Verify splash screen is initially shown
    expect(find.text('OPTIMIZER'), findsOneWidget);

    // Fast forward time to trigger navigation (6 seconds)
    await tester.pump(const Duration(seconds: 6));

    // Verify that signup screen is now displayed
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Optimizer to get started'), findsOneWidget);
  });

  testWidgets('Signup form validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptimizerApp());

    // Wait for initial build
    await tester.pump();

    // Fast forward to signup screen
    await tester.pump(const Duration(seconds: 6));

    // Find the signup button
    final signupButton = find.text('Create Account');
    expect(signupButton, findsOneWidget);

    // Tap the signup button without filling form
    await tester.tap(signupButton);
    await tester.pump();

    // Verify validation messages appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Email field accepts valid input', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptimizerApp());

    // Wait for initial build
    await tester.pump();

    // Fast forward to signup screen
    await tester.pump(const Duration(seconds: 6));

    // Find email field by looking for CustomTextField
    final emailField = find.byType(TextFormField).first;
    expect(emailField, findsOneWidget);

    // Enter valid email
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    // Verify the text was entered
    expect(find.text('test@example.com'), findsOneWidget);
  });
}

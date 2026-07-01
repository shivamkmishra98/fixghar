import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixghar/providers/cart_provider.dart';
import 'package:fixghar/providers/auth_provider.dart';
import 'package:fixghar/screens/cart/cart_screen.dart';
import 'package:fixghar/models/cart_item_model.dart';
import 'package:fixghar/models/user_model.dart';

class FakeCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItemModel> get items => [
        CartItemModel(
          id: 'test_item',
          providerId: 'p1',
          providerName: 'Test Provider',
          serviceId: 's1',
          serviceName: 'Test Service',
          serviceCategory: 'Cleaning',
          price: 500.0,
          quantity: 2,
          iconName: 'cleaning',
          addedAt: DateTime.now(),
        )
      ];

  @override
  double get total => 1000.0;

  @override
  double get subtotal => 1000.0;
  
  @override
  int get itemCount => 1;

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserModel? get currentUser => UserModel(
    uid: 'test_user',
    email: 'test@example.com',
    fullName: 'Test User',
    phoneNumber: '1234567890',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    role: 'customer',
    savedAddresses: ['123 Main St, Test City'],
  );
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Test Cart Navigation', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR_CAUGHT: ${details.exception}');
    };

    final fakeCartProvider = FakeCartProvider();
    final fakeAuthProvider = FakeAuthProvider();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
          ChangeNotifierProvider<CartProvider>.value(value: fakeCartProvider),
        ],
        child: const MaterialApp(
          home: CartScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify button exists
    final proceedBtn = find.text('Proceed to Checkout');
    expect(proceedBtn, findsOneWidget);

    // Tap it
    print('--- TAPPING PROCEED BUTTON ---');
    await tester.tap(proceedBtn);
    await tester.pumpAndSettle();
  });
}

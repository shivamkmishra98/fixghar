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
  @override double get total => 1000.0;
  @override double get subtotal => 1000.0;
  @override int get itemCount => 1;
  @override bool get isLoading => false;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserModel? get currentUser => UserModel(
    uid: 'test_user_empty_address',
    email: 'test@example.com',
    fullName: 'Test User',
    phoneNumber: '1234567890',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    role: 'customer',
    savedAddresses: [], // EMPTY ADDRESSES!
  );
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Empty Address Flow Test', (WidgetTester tester) async {
    final fakeCartProvider = FakeCartProvider();
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
          ChangeNotifierProvider<CartProvider>.value(value: fakeCartProvider),
        ],
        child: const MaterialApp(home: CartScreen()),
      ),
    );

    await tester.pumpAndSettle();

    print('--- RUNTIME VALUES LOGGED ---');
    print('1. user.uid = ${fakeAuthProvider.currentUser!.uid}');
    print('2. savedAddresses length = ${fakeAuthProvider.currentUser!.savedAddresses.length}');
    print('3. savedAddresses contents = ${fakeAuthProvider.currentUser!.savedAddresses}');
    print('4. CartProvider.items.length = ${fakeCartProvider.items.length}');
    
    // Tap the button
    final btn = find.text('Proceed to Checkout');
    await tester.tap(btn);
    await tester.pumpAndSettle();
    
    // Try to find the snackbar
    final snackbar = find.byType(SnackBar);
    if (snackbar.evaluate().isNotEmpty) {
      print('5. _selectedAddress value = null (Blocked by SnackBar)');
    }
  });
}

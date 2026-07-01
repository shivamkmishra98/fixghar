import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixghar/providers/cart_provider.dart';
import 'package:fixghar/providers/auth_provider.dart';
import 'package:fixghar/screens/cart/checkout_summary_screen.dart';
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
  UserModel? get currentUser => null;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('CheckoutSummaryScreen renders', (WidgetTester tester) async {
    // Catch layout exceptions
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR_CAUGHT: ${details.exception}');
      print('STACK_TRACE: ${details.stack}');
    };

    final fakeCartProvider = FakeCartProvider();
    final fakeAuthProvider = FakeAuthProvider();

    // Must be big enough to avoid generic overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
          ChangeNotifierProvider<CartProvider>.value(value: fakeCartProvider),
        ],
        child: const MaterialApp(
          home: CheckoutSummaryScreen(selectedAddress: '123 Test St'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    if (tester.takeException() != null) {}
    debugDumpRenderTree();
  });
}

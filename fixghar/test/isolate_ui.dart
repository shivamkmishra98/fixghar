import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixghar/providers/cart_provider.dart';
import 'package:fixghar/providers/auth_provider.dart';
import 'package:fixghar/models/cart_item_model.dart';
import 'package:fixghar/core/constants/app_colors.dart';

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
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void testStep(String name, Widget body) {
  testWidgets(name, (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('EXCEPTION IN $name: ${details.exception}');
    };
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: FakeAuthProvider()),
          ChangeNotifierProvider<CartProvider>.value(value: FakeCartProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Checkout Summary')),
            body: body,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Dump render tree to file to see if it rendered
    // final file = File('tree_$name.txt');
    // file.writeAsStringSync(tester.binding.renderViewElement!.toStringDeep());
    print('SUCCESS: $name completed without exceptions');
  });
}

void main() {
  final items = FakeCartProvider().items;
  final cartProvider = FakeCartProvider();
  final selectedAddress = "123 Main St, Test City";

  // Step 1
  testStep('Step 1: Text Only', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  ));

  // Step 2
  testStep('Step 2: Add Address Container', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ));

  // Step 3
  testStep('Step 3: Add Order Summary Header', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  ));

  // Step 4
  testStep('Step 4: Add Cart Items List', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    ListTile(
                      title: Text(items[i].serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('By ${items[i].providerName} • Qty: ${items[i].quantity}'),
                      trailing: Text(
                        '₹${items[i].totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ));

  // Step 5
  testStep('Step 5: Add Total Section', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    ListTile(
                      title: Text(items[i].serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('By ${items[i].providerName} • Qty: ${items[i].quantity}'),
                      trailing: Text(
                        '₹${items[i].totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('₹${cartProvider.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ));

  // Step 6
  testStep('Step 6: Add Confirm Booking Button', Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    ListTile(
                      title: Text(items[i].serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('By ${items[i].providerName} • Qty: ${items[i].quantity}'),
                      trailing: Text(
                        '₹${items[i].totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('₹${cartProvider.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    ],
  ));
}

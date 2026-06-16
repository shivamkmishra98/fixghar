import 'package:cloud_firestore/cloud_firestore.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAddress({
    required String userId,
    required String title,
    required String address,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add({
      'title': title,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';

class ScanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addScan(GarmentAnalysis analysis, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scans')
        .doc(analysis.id)
        .set(analysis.toJson());
  }

  Stream<List<GarmentAnalysis>> getScans(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GarmentAnalysis.fromJson(doc.data());
          }).toList();
        });
  }
}

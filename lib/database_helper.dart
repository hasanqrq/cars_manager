import 'package:cloud_firestore/cloud_firestore.dart';
import 'car.dart';

class DatabaseHelper {
  final CollectionReference carsCollection =
      FirebaseFirestore.instance.collection('cars');

  /// Inserts a car into the Firestore collection.
  Future<void> insertCar(Car car) async {
    try {
      await carsCollection.doc(car.id).set(car.toMap());
    } catch (e) {
      // Handle error here if needed
      print('Error inserting car: $e');
    }
  }

  /// Fetches a car from Firestore using the shieldNumber.
  Future<Car?> getCarByChassisNumber(String shieldNumber) async {
    try {
      QuerySnapshot querySnapshot = await carsCollection
          .where('shieldNumber', isEqualTo: shieldNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Car.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // Handle error here if needed
      print('Error fetching car by shield number: $e');
    }
    return null;
  }

  /// Fetches a car from Firestore using the vehicleNumber.
  Future<Car?> getCarByVehicleNumber(int vehicleNumber) async {
    try {
      QuerySnapshot querySnapshot = await carsCollection
          .where('vehicleNumber', isEqualTo: vehicleNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Car.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // Handle error here if needed
      print('Error fetching car by vehicle number: $e');
    }
    return null;
  }

  /// Fetches all cars from the Firestore collection.
  Future<List<Car>> getCars() async {
    try {
      QuerySnapshot querySnapshot = await carsCollection.get();

      return querySnapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle error here if needed
      print('Error fetching cars: $e');
      return [];
    }
  }

  /// Deletes a car from Firestore using the document ID.
  Future<void> deleteCar(String id) async {
    try {
      await carsCollection.doc(id).delete();
    } catch (e) {
      // Handle error here if needed
      print('Error deleting car: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'car.dart';

class DatabaseHelper {
  final CollectionReference carsCollection =
      FirebaseFirestore.instance.collection('cars');

  Future<void> insertCar(Car car) async {
    await carsCollection.doc(car.id).set(car.toMap());
    print("Car saved: ${car.toMap()}");
  }

  Future<Car?> getCarByChassisNumber(String chassisNumber) async {
    QuerySnapshot querySnapshot = await carsCollection
        .where('chassisNumber', isEqualTo: chassisNumber)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return Car.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Car>> getCars() async {
    QuerySnapshot querySnapshot = await carsCollection.get();
    return querySnapshot.docs
        .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCar(String id) async {
    await carsCollection.doc(id).delete();
    print("Car with ID $id deleted");
  }
}

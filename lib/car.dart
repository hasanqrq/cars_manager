class Car {
  final String id;
  final String typeOfCar;
  final int numberOfCar;
  final String chassisNumber;
  final String make;
  final String model;
  final String color;
  final DateTime productionDate;
  final double engineCapacity;

  Car({
    required this.id,
    required this.typeOfCar,
    required this.numberOfCar,
    required this.chassisNumber,
    required this.make,
    required this.model,
    required this.color,
    required this.productionDate,
    required this.engineCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeOfCar': typeOfCar,
      'numberOfCar': numberOfCar,
      'chassisNumber': chassisNumber,
      'make': make,
      'model': model,
      'color': color,
      'productionDate': productionDate.toIso8601String(),
      'engineCapacity': engineCapacity,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      typeOfCar: map['typeOfCar'],
      numberOfCar: map['numberOfCar'],
      chassisNumber: map['chassisNumber'],
      make: map['make'],
      model: map['model'],
      color: map['color'],
      productionDate: DateTime.parse(map['productionDate']),
      engineCapacity: map['engineCapacity'],
    );
  }
}

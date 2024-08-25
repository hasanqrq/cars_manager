class Car {
  final String id;
  final String
      contractNumber; // Update this if the field name in Firestore is 'typeOfCar'
  final int vehicleNumber;
  final String shieldNumber;
  final String manufacturer;
  final String tradeNickname;
  final String colour; // This should match 'color' in Firestore
  final DateTime yearOfmanufacture;
  final double engineCapacity;
  final String notes;

  Car({
    required this.id,
    required this.contractNumber,
    required this.vehicleNumber,
    required this.shieldNumber,
    required this.manufacturer,
    required this.tradeNickname,
    required this.colour,
    required this.yearOfmanufacture,
    required this.engineCapacity,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeOfCar':
          contractNumber, // Update this key if Firestore uses 'typeOfCar'
      'vehicleNumber': vehicleNumber,
      'shieldNumber': shieldNumber,
      'manufacturer': manufacturer,
      'tradeNickname': tradeNickname,
      'color': colour, // Ensure this key matches Firestore
      'yearOfmanufacture': yearOfmanufacture.toIso8601String(),
      'engineCapacity': engineCapacity,
      'notes': notes,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] ?? '', // Add default empty string to avoid null errors
      contractNumber: map['typeOfCar'] ??
          '', // Use 'typeOfCar' based on your Firestore data
      vehicleNumber: map['vehicleNumber'] ?? 0, // Add default value for int
      shieldNumber: map['shieldNumber'] ??
          '', // Add default empty string to avoid null errors
      manufacturer: map['manufacturer'] ??
          '', // Add default empty string to avoid null errors
      tradeNickname: map['tradeNickname'] ??
          '', // Add default empty string to avoid null errors
      colour: map['color'] ??
          '', // Ensure this matches Firestore and add default value
      yearOfmanufacture: DateTime.parse(map['yearOfmanufacture'] ??
          DateTime.now().toString()), // Add fallback for date parsing
      engineCapacity: map['engineCapacity']?.toDouble() ??
          0.0, // Convert to double and add default value
      notes:
          map['notes'] ?? '', // Add default empty string to avoid null errors
    );
  }
}

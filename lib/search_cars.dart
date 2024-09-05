import 'car.dart';

List<Car> filterCars(List<Car> cars, String searchQuery) {
  if (searchQuery.isEmpty) {
    return cars;
  } else {
    return cars.where((car) {
      return car.contractNumber
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          car.vehicleNumber.toString().contains(searchQuery) ||
          car.shieldNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          car.manufacturer.toLowerCase().contains(searchQuery.toLowerCase()) ||
          car.tradeNickname.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }
}

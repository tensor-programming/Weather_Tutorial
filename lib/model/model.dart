import 'package:weather/json/response.dart';

class WeatherModel {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final double lat;
  final double long;

  WeatherModel({
    this.city,
    this.temperature,
    this.description,
    this.icon,
    this.lat,
    this.long,
  });

  WeatherModel.fromResponse(City response)
      : city = response.name,
        temperature = (response.main.temp * (9 / 5)) - 459.67,
        description = response.weather[0]?.description,
        icon = response.weather[0]?.icon,
        lat = response.coord.lat,
        long = response.coord.lon;
}

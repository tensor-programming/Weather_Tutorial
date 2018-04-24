import 'package:rx_command/rx_command.dart';
import 'package:geolocation/geolocation.dart';

import 'package:weather/model/model.dart';
import 'package:weather/model/weather_repo.dart';

class ModelCommand {
  final WeatherRepo weatherRepo;

  final RxCommand<Null, LocationResult> updateLocationCommand;
  final RxCommand<LocationResult, List<WeatherModel>> updateWeatherCommand;
  final RxCommand<Null, bool> getGpsCommand;
  final RxCommand<bool, bool> radioCheckedCommand;

  ModelCommand._(
    this.weatherRepo,
    this.updateLocationCommand,
    this.updateWeatherCommand,
    this.getGpsCommand,
    this.radioCheckedCommand,
  );

  factory ModelCommand(WeatherRepo repo) {
    final _getGpsCommand = RxCommand.createAsync2<bool>(repo.getGps);

    final _radioCheckedCommand = RxCommand.createSync3<bool, bool>((b) => b);

    final _updateLocationCommand = RxCommand.createAsync2<LocationResult>(
        repo.updateLocation, _getGpsCommand.results);

    final _updateWeatherCommand =
        RxCommand.createAsync3<LocationResult, List<WeatherModel>>(
            repo.updateWeather, _radioCheckedCommand.results);

    _updateLocationCommand.results
        .listen((data) => _updateWeatherCommand(data));

    _updateWeatherCommand(null);

    return ModelCommand._(
      repo,
      _updateLocationCommand,
      _updateWeatherCommand,
      _getGpsCommand,
      _radioCheckedCommand,
    );
  }
}

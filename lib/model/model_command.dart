import 'package:rx_command/rx_command.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:rxdart/streams.dart';

import 'package:weather/model/model.dart';
import 'package:weather/model/weather_repo.dart';

class ModelCommand {
  final WeatherRepo weatherRepo;

  final RxCommand<Position, List<WeatherModel>> updateWeatherCommand;
  final RxCommand<void, bool> getGpsCommand;
  final RxCommand<bool, bool> radioCheckedCommand;
  final RxCommand<int, void> addCitiesCommand;
  final RxCommand<String, void> changeLocaleCommand;
  final RxCommand<dynamic, Position> updateLocationStreamCommand;

  ModelCommand._(
    this.weatherRepo,
    this.updateWeatherCommand,
    this.getGpsCommand,
    this.radioCheckedCommand,
    this.addCitiesCommand,
    this.updateLocationStreamCommand,
    this.changeLocaleCommand,
  );

  factory ModelCommand(WeatherRepo repo) {
    final _getGpsCommand = RxCommand.createAsyncNoParam<bool>(repo.getGps);

    final _radioCheckedCommand = RxCommand.createSync<bool, bool>((b) => b);

    final _changeLocaleCommand =
        RxCommand.createSyncNoResult<String>(repo.setLanguage);

    //Two Observables needed because they are only cold observables (single subscription).
    final _boolCombineA =
        CombineObs(_getGpsCommand, _radioCheckedCommand).combinedObservable;
    final _boolCombineB =
        CombineObs(_getGpsCommand, _radioCheckedCommand).combinedObservable;

    final _updateWeatherCommand =
        RxCommand.createAsync<Position, List<WeatherModel>>(repo.updateWeather,
            canExecute: _boolCombineA);

    final _addCitiesCommand = RxCommand.createSyncNoResult<int>(repo.addCities);

    final _updateLocationStreamCommand =
        RxCommand.createAsync<dynamic, Position>(repo.updateLocation,
            canExecute: _boolCombineB);

    _updateLocationStreamCommand.listen((data) => _updateWeatherCommand(data));

    // _updateWeatherCommand(null);

    return ModelCommand._(
      repo,
      _updateWeatherCommand,
      _getGpsCommand,
      _radioCheckedCommand,
      _addCitiesCommand,
      _updateLocationStreamCommand,
      _changeLocaleCommand,
    );
  }
}

class CombineObs {
  final Observable<bool> _combinedObservable;
  Observable<bool> get combinedObservable => _combinedObservable;
  CombineObs._(this._combinedObservable);

  factory CombineObs(a, b) {
    Observable<bool> c = Observable.combineLatest2(a, b, (x, y) => x && y);
    return CombineObs._(c);
  }
}

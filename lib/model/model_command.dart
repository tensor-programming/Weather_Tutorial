import 'package:rx_command/rx_command.dart';
import 'package:geolocation/geolocation.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:rxdart/streams.dart';

import 'package:weather/model/model.dart';
import 'package:weather/model/weather_repo.dart';

class ModelCommand {
  final WeatherRepo weatherRepo;

  // final RxCommand<Null, LocationResult> updateLocationCommand;
  final RxCommand<LocationResult, List<WeatherModel>> updateWeatherCommand;
  final RxCommand<void, bool> getGpsCommand;
  final RxCommand<bool, bool> radioCheckedCommand;
  final RxCommand<int, void> addCitiesCommand;
  final RxCommand<String, void> changeLocaleCommand;
  final RxCommand<dynamic, LocationResult> updateLocationStreamCommand;

  ModelCommand._(
    this.weatherRepo,
    // this.updateLocationCommand,
    this.updateWeatherCommand,
    this.getGpsCommand,
    this.radioCheckedCommand,
    this.addCitiesCommand,
    this.updateLocationStreamCommand,
    this.changeLocaleCommand,
  );

  factory ModelCommand(WeatherRepo repo) {
    final _getGpsCommand = RxCommand.createAsyncNoParam(repo.getGps);

    final _radioCheckedCommand = RxCommand.createSync<bool, bool>((b) => b);

    final _changeLocaleCommand =
        RxCommand.createSyncNoResult<String>(repo.setLanguage);

    //A combined Observable of the GPS and Radio observables using And logic.  If one is false then false will be returned.
    //This allows us to have a more dynamic set of circumstances for shutting down the buttons.
    // final Observable<bool> _boolCombine = Observable
    //     .combineLatest2(_getGpsCommand.results, _radioCheckedCommand.results,
    //         (gps, radio) => gps && radio)
    //     .distinctUnique();

    //Two Observables needed because they are only cold observables (single subscription).
    final _boolCombineA =
        CombineObs(_getGpsCommand, _radioCheckedCommand.results)
            .combinedObservable;
    final _boolCombineB =
        CombineObs(_getGpsCommand, _radioCheckedCommand.results)
            .combinedObservable;

    // final _updateLocationCommand =
    //     RxCommand.createAsync2<LocationResult>(repo.updateLocation);

    final _updateWeatherCommand = RxCommand
        .createAsync<LocationResult, List<WeatherModel>>(repo.updateWeather,
            canExecute: _boolCombineA);

    final _addCitiesCommand = RxCommand.createSyncNoResult<int>(repo.addCities);

    final _updateLocationStreamCommand = RxCommand
        .createFromStream<dynamic, LocationResult>(repo.updateLocationStream,
            canExecute: _boolCombineB);

    // _updateLocationCommand.results.listen(_updateWeatherCommand);
    //using a stream based command now because lastKnownLocation is not as consistent as [currentLocation]
    _updateLocationStreamCommand.results
        .listen((data) => new CommandResult(data, null, null));

    _updateWeatherCommand();

    return ModelCommand._(
      repo,
      // _updateLocationCommand,
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

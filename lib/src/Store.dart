import 'dart:async';
import 'package:dva_dart/src/Model.dart';
import 'package:dva_dart/src/Action.dart';

class DvaStore {
  List<DvaModel> models;

  DvaStore({models}) {
    this.models = models;
  }
  Stream stateStream = Stream.fromIterable([0]);
  void dispatch(Action action) {
    var found = this._extractAction(action);
    DvaModel foundModel = found[0];
    var foundEffect = found[1];
    var foundPayload = found[2];
    foundModel.dispatch(foundEffect(foundPayload));
    stateStream = foundModel.state;
  }

  _extractAction(Action action) {
    var type = action.type;
    String nameSpace = type.split(RegExp(r"/"))[0];
    String effectName = type.split(RegExp(r"/"))[1];

    var model = this.models.singleWhere((m) => m.nameSpace == nameSpace,
        orElse: () => throw NullThrownError);
    var effect = this._getEffect(effectName, model);
    var payload = this._getPayload(action);
    return [model, effect, payload];
  }

  _getEffect(String effectName, DvaModel model) {
    return model.effects.containsKey(effectName)
        ? model.effects[effectName]
        : throw NullThrownError;
  }

  _getPayload(Action action) {
    return action.payload;
  }
}

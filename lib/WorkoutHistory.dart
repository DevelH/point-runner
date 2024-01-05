class WorkoutHistory{
  DateTime? _workoutAt;
  double? distance;

  WorkoutHistory(DateTime this._workoutAt, double this.distance);

  DateTime get workoutAt{
    return _workoutAt!;
  }

  void set workoutAt(DateTime workoutAt){
    this._workoutAt = _workoutAt;
  }
}
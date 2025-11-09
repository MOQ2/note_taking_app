import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeOverview extends HomeEvent {
  const LoadHomeOverview();
}

class RefreshHomeOverview extends HomeEvent {
  const RefreshHomeOverview();
}

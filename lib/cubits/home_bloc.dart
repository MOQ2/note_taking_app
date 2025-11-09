import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_notes_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeNotesService _homeService;

  HomeBloc({
    HomeNotesService? homeService,
  })  : _homeService = homeService ?? HomeNotesService(),
        super(const HomeInitial()) {
    on<LoadHomeOverview>(_onLoadHomeOverview);
    on<RefreshHomeOverview>(_onRefreshHomeOverview);
  }

  Future<void> _onLoadHomeOverview(
      LoadHomeOverview event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final overview = await _homeService.loadHomeOverview();
      emit(HomeLoaded(overview));
    } catch (e) {
      emit(HomeError('Failed to load home overview: $e'));
    }
  }

  Future<void> _onRefreshHomeOverview(
      RefreshHomeOverview event, Emitter<HomeState> emit) async {
    // Don't show loading for refresh, just update the data
    try {
      final overview = await _homeService.loadHomeOverview();
      emit(HomeLoaded(overview));
    } catch (e) {
      emit(HomeError('Failed to refresh home overview: $e'));
    }
  }
}

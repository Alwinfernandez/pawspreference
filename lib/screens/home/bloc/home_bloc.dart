import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pawspreferences_afs/screens/home/model/cat.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<FetchCatImage>(_onFetchCatImage);
  }

  Future<void> _onFetchCatImage(
    FetchCatImage event,
    Emitter<HomeState> emit,
  ) async {
    emit(LoadFetchCatImage());
    try {
      final images = await CatService.fetchRandomCats();
      emit(SuccessFetchCatImage(
          images)); // if api is success emit the images in list
    } catch (e) {
      emit(ErrorFetchCatImage(
          "Failed to fetch cat images.")); // if error show text message
    }
  }
}

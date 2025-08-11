part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class LoadFetchCatImage extends HomeState {}

// if error show message through pass it in state
class ErrorFetchCatImage extends HomeState {
  final String message;
  ErrorFetchCatImage(this.message);
}

// if success state, populate list of images

class SuccessFetchCatImage extends HomeState {
  final List<Cat> images;
  SuccessFetchCatImage(this.images);
}

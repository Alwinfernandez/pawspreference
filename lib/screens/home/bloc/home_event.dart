part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

// event to fetch cat images
// empty because no query parameters
class FetchCatImage extends HomeEvent {}

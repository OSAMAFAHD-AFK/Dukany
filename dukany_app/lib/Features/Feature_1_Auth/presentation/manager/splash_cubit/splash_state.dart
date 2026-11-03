part of 'splash_cubit.dart';

enum SplashDestination { login, home, subscriptionEnded }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashDeciding extends SplashState {
  const SplashDeciding();
}

final class SplashDecided extends SplashState {
  const SplashDecided(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}

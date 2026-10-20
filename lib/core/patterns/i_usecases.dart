abstract interface class IUseCase<T, Params extends Object?> {
  Future<T> call(Params params);
}

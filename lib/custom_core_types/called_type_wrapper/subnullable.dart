
/// Nullable の値を保有するクラス
///
/// `null` を指定することと、何も指定しないことを区別できる。
class Subnullable<T> {
  final T? value;
  const Subnullable(this.value);
}
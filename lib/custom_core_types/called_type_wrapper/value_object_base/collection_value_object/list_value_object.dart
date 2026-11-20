// import 'package:flutter/foundation.dart';
//
// abstract class _ListValueObjectBase<E>{
//   _ListValueObjectBase(List<E> list)
//       : _data = List<E>.unmodifiable(list);
//
//   @protected
//   final List<E> _data;
//
//   List<E> get data => _data;
// }
//
// abstract class IntListValueObject extends _ListValueObjectBase<int>{
//   IntListValueObject(super.list);
// }
//
// abstract class DoubleListValueObject extends _ListValueObjectBase<double>{
//   DoubleListValueObject(super.list);
// }
//
// abstract class StringListValueObject extends _ListValueObjectBase<String>{
//   StringListValueObject(super.list);
// }
//
// abstract class BoolListValueObject extends _ListValueObjectBase<bool>{
//   BoolListValueObject(super.list);
// }
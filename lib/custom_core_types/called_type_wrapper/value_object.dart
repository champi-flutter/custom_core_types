

import 'package:flutter/foundation.dart';



abstract class _ValueObjectComponentBase<T> {
  @protected
  final T _data;
  T get data {
    return _data;
  }

  const _ValueObjectComponentBase(this._data);
}

abstract class ObjectData<T> extends _ValueObjectComponentBase<T>{
  const ObjectData(super.data);
}

abstract class ObjectDataFactory<T> extends _ValueObjectComponentBase<T>{
  ObjectDataFactory(T Function() constructor): super(constructor());
}

class StringData extends _ValueObjectComponentBase<String> {
  const StringData(super.data);
}

class IntData extends _ValueObjectComponentBase<int> {
  const IntData(super.data);
}

class DoubleData extends _ValueObjectComponentBase<double> {
  const DoubleData(super.data);
}

class BoolData extends _ValueObjectComponentBase<bool> {
  const BoolData(super.data);
}

class ID extends IntData {
  ID(super.id);
}
//
// class TaskTitle extends StringData{
//   const TaskTitle(super.data);
// }
//
// class Task {
//   final ID id;
//   final TaskTitle title;
//
//   const Task({required this.id, required this.title});
// }
//
// class HogeData extends ObjectData<HogeSub>{
//   HogeData(super.data);
// }
//
// class HogeSub {
//   String s;
//   HogeSub(this.s);
// }
//
// class Hoge{
  // static void hoge (){
  //   final Task task = Task(id: ID(1), title: TaskTitle("data"));
  //   final HogeObject hogeObject = HogeObject(HogeSub("hoge"));
  //   hoge2(hogeObject);
  //   print(hogeObject.data.s);
  // }
//
//   static void hoge (){
//     final Task task = Task(TaskData("initial"));
//     hoge2(task);
//     print(task.taskData.title);
//   }
//
//   static void hoge2(Task task){
//     task.taskData.title = "hoge is changed.";
//   }
// }
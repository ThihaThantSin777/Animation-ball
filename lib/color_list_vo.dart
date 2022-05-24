import 'package:flutter/material.dart';

class ColorListVO{
  Color color;
  bool isSelect;
  String name;

  ColorListVO(this.color, this.isSelect, this.name);

  @override
  String toString() {
    return 'ColorListVO{color: $color, isSelect: $isSelect, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorListVO &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          isSelect == other.isSelect &&
          name == other.name;

  @override
  int get hashCode => color.hashCode ^ isSelect.hashCode ^ name.hashCode;
}
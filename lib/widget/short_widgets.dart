import 'package:flutter/material.dart';

class ContainerX extends StatelessWidget {
  const ContainerX({
    super.key,
    this.child,
    this.alignment,
    this.color,
    this.gradient,
    this.height,
    this.padding,
    this.width,
  });

  final Widget? child;
  final AlignmentGeometry? alignment;
  final Color? color;
  final Gradient? gradient;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: gradient == null ? color : null,
      decoration: gradient == null ? null : BoxDecoration(gradient: gradient),
      height: height,
      padding: padding,
      width: width,
      child: child,
    );
  }
}

class TextX extends StatelessWidget {
  const TextX({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.overflow,
  });

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: overflow,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
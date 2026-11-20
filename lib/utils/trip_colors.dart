import 'package:flutter/material.dart';

// One palette for both the map lines and the card stripes.
// Blue and red are left out: they mark the start and destination.
const _hex = [
  '#F5C518', // yellow
  '#65D957', // green
  '#B05AFF', // purple
  '#FF8A3D', // orange
  '#F06292', // pink
  '#26C6DA', // teal
  '#8D6E63', // brown
  '#9CCC65', // lime
];

String tripColorHex(int index) => _hex[index % _hex.length];

Color tripColor(int index) =>
    Color(int.parse('FF${tripColorHex(index).substring(1)}', radix: 16));
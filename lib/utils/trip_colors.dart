import 'package:flutter/material.dart';

// One palette for both the map lines and the card stripes.
// Blue and red are left out: they mark the start and destination.
const _hex = [
  '#D97706', // deeop amber
  '#15803D', // Forest Green
  '#6D28D9', // Royal purple
  '#0F766E', // Deep teal 
  '#BE185D', // Deep magenta 
  '#4338CA', // Deep indigo 
  '#B45309', // Burnt copper
  '#0369A1', // Deep ocean cyna
];

String tripColorHex(int index) => _hex[index % _hex.length];

Color tripColor(int index) =>
    Color(int.parse('FF${tripColorHex(index).substring(1)}', radix: 16));
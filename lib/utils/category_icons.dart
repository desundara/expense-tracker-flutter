import 'package:flutter/material.dart';

/// Maps the icon identifier stored on a Category row to a Flutter icon.
IconData iconForCategory(String icon) {
  switch (icon) {
    case 'utensils':
      return Icons.restaurant_rounded;
    case 'car':
      return Icons.directions_car_rounded;
    case 'bag':
      return Icons.shopping_bag_rounded;
    case 'bills':
      return Icons.receipt_long_rounded;
    case 'health':
      return Icons.favorite_rounded;
    case 'briefcase':
      return Icons.work_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    default:
      return Icons.more_horiz_rounded;
  }
}
import 'package:flutter/material.dart';

class AvatarUtil {
  static const List<Map<String, dynamic>> opcoes = [
    {
      'id': '1',
      'icon': Icons.person,
      'colors': [Color(0xFFF97316), Color(0xFF10B981)],
    },
    {
      'id': '2',
      'icon': Icons.pets,
      'colors': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    },
    {
      'id': '3',
      'icon': Icons.rocket_launch,
      'colors': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    },
    {
      'id': '4',
      'icon': Icons.sports_esports,
      'colors': [Color(0xFFF97316), Color(0xFFEF4444)],
    },
    {
      'id': '5',
      'icon': Icons.monetization_on,
      'colors': [Color(0xFFFACC15), Color(0xFFF97316)],
    },
    {
      'id': '6',
      'icon': Icons.cruelty_free,
      'colors': [Color(0xFF6B7280), Color(0xFF374151)],
    },
  ];

  static Map<String, dynamic> obterAvatar(String? id) {
    return opcoes.firstWhere(
      (avatar) => avatar['id'] == id,
      orElse: () => opcoes.first,
    );
  }

  static Widget construirAvatar(String? id, {double size = 48, double iconSize = 28}) {
    final avatar = obterAvatar(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: avatar['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(avatar['icon'], color: Colors.white, size: iconSize),
    );
  }
}

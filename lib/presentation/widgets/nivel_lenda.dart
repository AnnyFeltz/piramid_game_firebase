import 'package:flutter/material.dart';

/// Cor associada à pontuação (Nível Lenda) — de 15 a 75 pontos.
Color corNivelLenda(num pontos) {
  if (pontos >= 65) return Colors.amber;
  if (pontos >= 50) return Colors.green;
  if (pontos >= 35) return Colors.blue;
  return Colors.grey;
}

/// 65.0 -> "65"; 64.8 -> "64,8" (média do ranking global, com vírgula).
String formatarPontos(double pontos) {
  final inteiro = pontos == pontos.roundToDouble();
  return inteiro
      ? pontos.toStringAsFixed(0)
      : pontos.toStringAsFixed(1).replaceAll('.', ',');
}

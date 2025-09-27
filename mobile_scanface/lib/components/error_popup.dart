import 'package:flutter/material.dart';

/// Mostra um popup de erro com uma mensagem e botão OK
Future<void> showErrorPopup(BuildContext context, String message) {
  return showDialog(
    context: context,
    barrierDismissible: false, // O usuário não pode fechar tocando fora
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text("Erro de detecção"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o popup
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

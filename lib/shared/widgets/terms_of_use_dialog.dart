import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

Future<void> showTermsOfUseDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Termos de uso'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<String>(
          future: rootBundle.loadString('assets/terms/termos_de_uso.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final md = snapshot.data ?? 'Conteúdo dos Termos indisponível.';
            return SingleChildScrollView(
              child: MarkdownBody(data: md),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}

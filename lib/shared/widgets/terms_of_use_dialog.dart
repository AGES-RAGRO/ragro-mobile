import 'package:flutter/material.dart';

/// Shows the Terms of Use to the user.
///
/// The body is a placeholder — replace it with the real Terms of Use text (or open the hosted
/// terms URL via `url_launcher`) once legal provides the final content.
Future<void> showTermsOfUseDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Termos de uso'),
      content: const SingleChildScrollView(
        child: Text(
          'Ao usar o RAGRO você concorda em fornecer informações verídicas, '
          'utilizar a plataforma de forma legal e respeitar produtores e '
          'consumidores.\n\n'
          'A versão completa dos Termos de Uso e da Política de Privacidade '
          'será disponibilizada em breve.',
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

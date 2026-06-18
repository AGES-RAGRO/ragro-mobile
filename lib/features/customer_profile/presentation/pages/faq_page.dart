import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'Como faço para realizar um pedido?',
      answer:
          'Navegue até a tela inicial, escolha um produtor ou produto de sua preferência e adicione os itens ao carrinho. Depois, vá ao carrinho e finalize a compra informando seu endereço de entrega.',
    ),
    _FaqItem(
      question: 'Como acompanho o status do meu pedido?',
      answer:
          'Acesse a aba "Pedidos" no menu inferior. Lá você encontrará todos os seus pedidos e poderá acompanhar o status de cada um em tempo real.',
    ),
    _FaqItem(
      question: 'Posso cancelar um pedido após realizá-lo?',
      answer:
          'O cancelamento está disponível enquanto o pedido ainda está pendente. Entre em contato diretamente com o produtor pelo aplicativo caso precise cancelar após a confirmação.',
    ),
    _FaqItem(
      question: 'Como altero meu endereço de entrega?',
      answer:
          'Vá em Perfil → Editar perfil e atualize o endereço desejado. Você também pode informar um endereço diferente ao finalizar cada pedido.',
    ),
    _FaqItem(
      question: 'Como redefinir minha senha?',
      answer:
          'Acesse Perfil → Alterar senha. Enviaremos um e-mail com as instruções para criar uma nova senha.',
    ),
    _FaqItem(
      question: 'Os produtos são realmente orgânicos?',
      answer:
          'Todos os produtores cadastrados no RAGRO passam por verificação. Consulte o perfil do produtor para ver suas certificações e informações de cultivo.',
    ),
    _FaqItem(
      question: 'Como avalio um produtor?',
      answer:
          'Após a entrega de um pedido, você poderá avaliar o produtor diretamente na tela de detalhes do pedido. Sua avaliação ajuda outros consumidores a escolherem melhor.',
    ),
    _FaqItem(
      question: 'O aplicativo é gratuito?',
      answer:
          'Sim, o RAGRO é gratuito para consumidores. Você paga apenas pelos produtos que adquirir dos produtores.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.darkGreen,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'FAQ',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.darkGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Text(
            'Perguntas Frequentes',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Encontre respostas para as dúvidas mais comuns sobre o RAGRO.',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          ..._faqs.map((faq) => _FaqTile(item: faq)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? AppColors.darkGreen.withValues(alpha: 0.3)
                  : const Color(0x1A2E5729),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        size: 18,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.question,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.darkGreen,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0x1A2E5729)),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.answer,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

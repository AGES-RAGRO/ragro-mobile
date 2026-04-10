// Screen: Admin Create Producer (Criar Conta Produtor)
// User Story: US-31 — Admin Create Producer Account
// Epic: EPIC 5 — Admin Features
// Routes: POST /admin/producers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';

class AdminCreateProducerPage extends StatelessWidget {
  const AdminCreateProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminProducerFormBloc>(),
      child: const _AdminCreateProducerView(),
    );
  }
}

class _AdminCreateProducerView extends StatefulWidget {
  const _AdminCreateProducerView();

  @override
  State<_AdminCreateProducerView> createState() =>
      _AdminCreateProducerViewState();
}

class _AdminCreateProducerViewState extends State<_AdminCreateProducerView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bankController = TextEditingController();
  final _agencyController = TextEditingController();
  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _numberController = TextEditingController();
  final _scheduleStartController = TextEditingController(text: '08:00');
  final _scheduleEndController = TextEditingController(text: '18:00');

  final List<bool> _weekdays = List.filled(7, false);
  bool _termsAccepted = false;

  static const _weekdayLabels = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bankController.dispose();
    _agencyController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _cpfCnpjController.dispose();
    _passwordController.dispose();
    _scheduleStartController.dispose();
    _scheduleEndController.dispose();
    _farmNameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os Termos de Uso para continuar.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final cleanFiscal = _cpfCnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final type = cleanFiscal.length <= 11 ? 'CPF' : 'CNPJ';

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    context.read<AdminProducerFormBloc>().add(
          AdminProducerFormSubmitted(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            cep: _cepController.text.trim(),
            address: _addressController.text.trim(),
            number: _numberController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            bank: _bankController.text.trim(),
            agency: _agencyController.text.trim(),
            account: _accountController.text.trim(),
            accountHolder: _holderController.text.trim(),
            fiscalNumber: cleanFiscal,
            fiscalNumberType: type,
            farmName: _farmNameController.text.trim(),
            password: _passwordController.text.trim(),
            scheduleWeekdays: List.from(_weekdays),
            scheduleStart: _scheduleStartController.text.trim(),
            scheduleEnd: _scheduleEndController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProducerFormBloc, AdminProducerFormState>(
      listener: (context, state) {
        if (state is AdminProducerFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produtor criado com sucesso!'),
              backgroundColor: AppColors.darkGreen,
            ),
          );
          context.pop();
        }
        if (state is AdminProducerFormFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminProducerFormLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Criar conta',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Dados Pessoais'),
                const SizedBox(height: 12),
                _FieldLabel('Nome Completo'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _nameController,
                    hint: 'Nome do produtor',
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('Telefone'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _phoneController,
                    hint: '(XX) XXXXX-XXXX',
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('Email'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _emailController,
                    hint: 'email@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('Senha'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _passwordController,
                    hint: 'Senha de acesso',
                    obscure: true,
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('Nome da Fazenda'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _farmNameController,
                    hint: 'Ex: Fazenda Santa Luzia',
                    enabled: !isLoading),

                const SizedBox(height: 20),
                _sectionTitle('Endereço'),
                const SizedBox(height: 12),
                _FieldLabel('CEP'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _cepController,
                    hint: '00000-000',
                    keyboardType: TextInputType.number,
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('Endereço'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TextField(
                        controller: _addressController,
                        hint: 'Rua / Avenida',
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TextField(
                        controller: _numberController,
                        hint: 'Nº',
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Cidade'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _cityController,
                              hint: 'Cidade',
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Estado'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _stateController,
                              hint: 'UF',
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _sectionTitle('Dados Bancários'),
                const SizedBox(height: 12),
                _FieldLabel('Banco'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _bankController,
                    hint: 'Nome do banco',
                    enabled: !isLoading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Agência'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _agencyController,
                              hint: '0000',
                              keyboardType: TextInputType.number,
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Conta'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _accountController,
                              hint: '000000-0',
                              keyboardType: TextInputType.number,
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FieldLabel('Nome do Titular'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _holderController,
                    hint: 'Nome completo do titular',
                    enabled: !isLoading),
                const SizedBox(height: 12),
                _FieldLabel('CPF / CNPJ'),
                const SizedBox(height: 8),
                _TextField(
                    controller: _cpfCnpjController,
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                    enabled: !isLoading),

                const SizedBox(height: 20),
                _sectionTitle('Horário de atendimento'),
                const SizedBox(height: 12),
                // Weekday toggles
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (i) {
                    final isSelected = _weekdays[i];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _weekdays[i] = !_weekdays[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkGreen
                              : AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _weekdayLabels[i],
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.placeholder,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Início'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _scheduleStartController,
                              hint: '08:00',
                              keyboardType: TextInputType.datetime,
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 28, left: 12, right: 12),
                      child: Icon(Icons.arrow_forward,
                          color: AppColors.placeholder, size: 18),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Fim'),
                          const SizedBox(height: 8),
                          _TextField(
                              controller: _scheduleEndController,
                              hint: '18:00',
                              keyboardType: TextInputType.datetime,
                              enabled: !isLoading),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Terms checkbox
                GestureDetector(
                  onTap: () =>
                      setState(() => _termsAccepted = !_termsAccepted),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (v) =>
                            setState(() => _termsAccepted = v ?? false),
                        activeColor: AppColors.darkGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const Expanded(
                        child: Text(
                          'Eu concordo com os Termos de Uso e Política de Privacidade',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.darkGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Criar conta',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: AppColors.darkGreen,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.black,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          color: AppColors.placeholder,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        color: AppColors.black,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_bloc.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_event.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_state.dart';

class CustomerEditProfilePage extends StatefulWidget {
  const CustomerEditProfilePage({super.key});

  @override
  State<CustomerEditProfilePage> createState() =>
      _CustomerEditProfilePageState();
}

class _CustomerEditProfilePageState extends State<CustomerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _didHydrateProfile = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _zipCodeController = TextEditingController();
    _streetController = TextEditingController();
    _numberController = TextEditingController();
    _complementController = TextEditingController();
    _neighborhoodController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();

    _hydrateControllers(context.read<CustomerProfileBloc>().state);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerProfileBloc, CustomerProfileState>(
      listener: (context, state) {
        _hydrateControllers(state);
        if (state is CustomerProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.lightGreen,
            ),
          );
          context.pop();
        } else if (state is CustomerProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        } else if (state is CustomerProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Editar Perfil',
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Nome Completo',
                          controller: _nameController,
                          icon: Icons.person_outline,
                          hint: 'João da Silva',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Email',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hint: 'exemplo@email.com',
                          readOnly: true,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Telefone',
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          hint: '51999999999',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            final digits = (value ?? '').replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            if (digits.isEmpty) return 'Informe o telefone';
                            if (digits.length > 20) {
                              return 'Telefone deve ter no maximo 20 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'CEP',
                          controller: _zipCodeController,
                          icon: Icons.markunread_mailbox_outlined,
                          hint: '90010120',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final digits = (value ?? '').replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            if (digits.length != 8) {
                              return 'CEP deve ter 8 digitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Rua',
                          controller: _streetController,
                          icon: Icons.home_outlined,
                          hint: 'Rua das Flores',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Numero',
                          controller: _numberController,
                          icon: Icons.pin_outlined,
                          hint: '123',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Complemento',
                          controller: _complementController,
                          icon: Icons.apartment_outlined,
                          hint: 'Apto 42',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Bairro',
                          controller: _neighborhoodController,
                          icon: Icons.location_city_outlined,
                          hint: 'Centro',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Cidade',
                          controller: _cityController,
                          icon: Icons.location_on_outlined,
                          hint: 'Porto Alegre',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Estado',
                          controller: _stateController,
                          icon: Icons.map_outlined,
                          hint: 'RS',
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.length != 2) {
                              return 'Estado deve ter 2 letras';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<CustomerProfileBloc, CustomerProfileState>(
                          builder: (context, state) {
                            final isLoading = state is CustomerProfileUpdating;
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: isLoading ? null : _onSave,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGreen,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x40000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (isLoading)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: AppColors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        else ...[
                                          const Icon(
                                            Icons.save_outlined,
                                            color: AppColors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        const Text(
                                          'Salvar Alteracoes',
                                          style: TextStyle(
                                            fontFamily: 'Figtree',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hydrateControllers(CustomerProfileState state) {
    if (_didHydrateProfile) return;

    final profile = switch (state) {
      CustomerProfileLoaded(:final profile) => profile,
      CustomerProfileUpdating(:final profile) => profile,
      CustomerProfileUpdateSuccess(:final profile) => profile,
      CustomerProfileUpdateFailure(:final profile) => profile,
      _ => null,
    };

    if (profile == null) return;

    final address = profile.primaryAddress;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _zipCodeController.text = address?.zipCode ?? '';
    _streetController.text = address?.street ?? '';
    _numberController.text = address?.number ?? '';
    _complementController.text = address?.complement ?? '';
    _neighborhoodController.text = address?.neighborhood ?? '';
    _cityController.text = address?.city ?? '';
    _stateController.text = address?.state ?? '';
    _didHydrateProfile = true;
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x332E5729)),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.placeholder),
              prefixIcon: Icon(icon, color: AppColors.placeholder, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    return null;
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<CustomerProfileBloc>().add(
      CustomerProfileUpdateSubmitted(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim().toUpperCase(),
        zipCode: _zipCodeController.text.trim(),
        complement: _complementController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
      ),
    );
  }
}

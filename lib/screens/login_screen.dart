import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final app = context.read<AppProvider>();
    final success = await app.login(_userController.text, _passwordController.text);
    if (!mounted) return;
    if (!success && app.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha para continuar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Consumer<AppProvider>(
                builder: (context, app, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.travel_explore, size: 72, color: Color(0xFF9BE564)),
                    const SizedBox(height: 18),
                    const Text('RICK & MORTY', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const Text('EXPLORER', textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF9BE564), letterSpacing: 5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Entre para explorar o multiverso.', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 34),
                    TextField(controller: _userController, textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Usuário', prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 14),
                    TextField(controller: _passwordController, obscureText: _obscure,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        ))),
                    if (app.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(app.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(height: 52, child: ElevatedButton(
                      onPressed: app.isLoading ? null : _submit,
                      child: app.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('ENTRAR / CADASTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                    const SizedBox(height: 14),
                    const Text('Primeiro acesso: informe um usuário e uma senha para criar sua conta local neste aparelho.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

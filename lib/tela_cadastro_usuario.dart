import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final TextEditingController _confirmarSenhaCtrl = TextEditingController();
  bool _carregando = false;

  static const Color slateBlue = Color(0xFF8AAAB4);
  static const Color deepEspresso = Color(0xFF5C433C);
  static const Color warmTerracotta = Color(0xFFB98971);

  Future<void> _cadastrar() async {
    String email = _emailCtrl.text.trim();
    String senha = _senhaCtrl.text.trim();
    String confirmarSenha = _confirmarSenhaCtrl.text.trim();

    if (email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem('Preencha todos os campos!');
      return;
    }

    if (senha != confirmarSenha) {
      _mostrarMensagem('As palavras-passe não coincidem!');
      return;
    }

    if (senha.length < 6) {
      _mostrarMensagem('A palavra-passe deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => _carregando = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (!mounted) return;
      _mostrarMensagem('Conta criada com sucesso!');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao registar.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este e-mail já se encontra registado.';
      } else if (e.code == 'invalid-email') {
        msg = 'Formato de e-mail inválido.';
      } else if (e.code == 'weak-password') {
        msg = 'A palavra-passe é demasiado fraca.';
      }
      _mostrarMensagem(msg);
    } catch (e) {
      _mostrarMensagem('Ocorreu um erro ao criar a conta.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: warmTerracotta,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: slateBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 60,
                  color: slateBlue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registo de Leitor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: deepEspresso,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A sua identidade permanecerá totalmente anónima nos debates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: deepEspresso.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined, color: slateBlue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Palavra-passe',
                  prefixIcon: Icon(Icons.lock_outline, color: slateBlue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmarSenhaCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Palavra-passe',
                  prefixIcon: Icon(Icons.lock_reset, color: slateBlue),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CRIAR CONTA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
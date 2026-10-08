import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'tela_cadastro_usuario.dart';
import 'tela_principal.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  bool _carregando = false;

  static const Color slateBlue = Color(0xFF8AAAB4);
  static const Color deepEspresso = Color(0xFF5C433C);
  static const Color warmTerracotta = Color(0xFFB98971);

  Future<void> _fazerLogin() async {
    String email = _emailCtrl.text.trim();
    String senha = _senhaCtrl.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarMensagem('Por favor, preencha todos os campos.');
      return;
    }

    setState(() => _carregando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaPrincipal()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Ocorreu um erro ao iniciar sessão.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        msg = 'E-mail ou palavra-passe incorretos.';
      } else if (e.code == 'invalid-email') {
        msg = 'Formato de e-mail inválido.';
      }
      _mostrarMensagem(msg);
    } catch (e) {
      _mostrarMensagem('Erro ao estabelecer ligação.');
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: slateBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 72,
                    color: slateBlue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Clube do Livro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: deepEspresso,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Partilhe e debata as suas leituras anonimamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: deepEspresso.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 36),
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
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _fazerLogin,
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENTRAR'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ainda não tem conta?',
                      style: TextStyle(color: deepEspresso.withOpacity(0.8)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaCadastro(),
                          ),
                        );
                      },
                      child: const Text(
                        'Registe-se',
                        style: TextStyle(
                          color: warmTerracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
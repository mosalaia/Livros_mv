import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaDetalheLivro extends StatefulWidget {
  final String idLivro;
  final String titulo;

  const TelaDetalheLivro({
    super.key,
    required this.idLivro,
    required this.titulo,
  });

  @override
  State<TelaDetalheLivro> createState() => _TelaDetalheLivroState();
}

class _TelaDetalheLivroState extends State<TelaDetalheLivro> {
  int _capituloLido = 1;

  static const Color slateBlue = Color(0xFF8AAAB4);
  static const Color dustyBlue = Color(0xFFB8C8D4);
  static const Color softBeige = Color(0xFFF5EBE6);
  static const Color cardBeige = Color(0xFFEADBC8);
  static const Color warmTerracotta = Color(0xFFB98971);
  static const Color deepEspresso = Color(0xFF5C433C);

  final List<Map<String, dynamic>> _avatares = [
    {'icon': Icons.pets, 'color': warmTerracotta},
    {'icon': Icons.face, 'color': slateBlue},
    {'icon': Icons.sentiment_satisfied_alt, 'color': deepEspresso},
    {'icon': Icons.emoji_nature, 'color': deepEspresso},
    {'icon': Icons.cruelty_free, 'color': dustyBlue},
    {'icon': Icons.star, 'color': warmTerracotta},
  ];

  Map<String, dynamic> _getAvatarParaUsuario(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _avatares[0];
    }
    int hashCode = userId.hashCode.abs();
    int index = hashCode % _avatares.length;
    return _avatares[index];
  }

  @override
  void initState() {
    super.initState();
    _carregarCapituloLido();
  }

  Future<void> _carregarCapituloLido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _capituloLido = prefs.getInt('capitulo_${widget.idLivro}') ?? 1;
    });
  }

  Future<void> _salvarCapituloLido(int cap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('capitulo_${widget.idLivro}', cap);
    setState(() {
      _capituloLido = cap;
    });
  }

  void _responderPost(String idSanitizado, String postId) {
    final respostaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: softBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: dustyBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Respostas do Debate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: deepEspresso,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('livros')
                    .doc(idSanitizado)
                    .collection('debates_capitulo')
                    .doc(postId)
                    .collection('respostas')
                    .orderBy('criadoEm', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: slateBlue));
                  }
                  var respostas = snapshot.data!.docs;
                  if (respostas.isEmpty) {
                    return Center(
                      child: Text(
                        'Sem comentários. Seja o primeiro a responder!',
                        style: TextStyle(color: deepEspresso.withOpacity(0.6)),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: respostas.length,
                    itemBuilder: (context, index) {
                      var doc = respostas[index];
                      var r = doc.data() as Map<String, dynamic>;

                      String? autorId = r['userId'];
                      var avatar = _getAvatarParaUsuario(autorId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: avatar['color'].withOpacity(0.2),
                              child: Icon(avatar['icon'],
                                  size: 18, color: avatar['color']),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBeige,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  r['texto'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: deepEspresso),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: respostaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Escrever resposta anónima...',
                      isDense: true,
                      fillColor: cardBeige,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: warmTerracotta),
                  onPressed: () async {
                    if (respostaCtrl.text.isNotEmpty) {
                      String? currentUserId =
                          FirebaseAuth.instance.currentUser?.uid;

                      await FirebaseFirestore.instance //faz o aplicativo esperar o banco de dados do Google processar o salvamento antes de prosseguir.
                          .collection('livros')
                          .doc(idSanitizado)
                          .collection('debates_capitulo')
                          .doc(postId)
                          .collection('respostas')//Cria um novo documento dentro da subcoleção
                          .add({
                        'texto': respostaCtrl.text.trim(),
                        'userId': currentUserId,
                        'criadoEm': FieldValue.serverTimestamp(),
                      });
                      respostaCtrl.clear();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String idSanitizado = widget.titulo.toLowerCase().replaceAll(' ', '_');

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: dustyBlue.withOpacity(0.25),
              border: Border(
                bottom: BorderSide(color: dustyBlue.withOpacity(0.4)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: deepEspresso, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Capítulo atual: $_capituloLido',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: deepEspresso,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Alterar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: slateBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        TextEditingController capCtrl = TextEditingController(
                            text: _capituloLido.toString());
                        return AlertDialog(
                          backgroundColor: softBeige,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text('Atualizar Leitura',
                              style: TextStyle(color: deepEspresso)),
                          content: TextField(
                            controller: capCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capítulo que concluiu:',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                int? novoCap =
                                    int.tryParse(capCtrl.text.trim());
                                if (novoCap != null) {
                                  _salvarCapituloLido(novoCap);
                                  Navigator.pop(ctx);
                                }
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('livros')
                  .doc(idSanitizado)
                  .collection('debates_capitulo')
                  .where('numeroCapitulo', isLessThanOrEqualTo: _capituloLido)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: slateBlue));
                }
                var postsDocs = snapshot.data!.docs;
                if (postsDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Ainda não existem posts disponíveis até ao capítulo $_capituloLido.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: deepEspresso.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: postsDocs.length,
                  itemBuilder: (context, index) {
                    var doc = postsDocs[index];
                    var post = doc.data() as Map<String, dynamic>;

                    String texto = post['texto'] ?? '';
                    String? autorId = post['userId'];
                    int cap = post['numeroCapitulo'] ?? 1;

                    var avatar = _getAvatarParaUsuario(autorId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBeige,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: deepEspresso.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    avatar['color'].withOpacity(0.2),
                                child: Icon(avatar['icon'],
                                    color: avatar['color'], size: 20),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: softBeige,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Capítulo $cap',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: deepEspresso,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            texto,
                            style: const TextStyle(
                              fontSize: 15,
                              color: deepEspresso,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _responderPost(idSanitizado, doc.id),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16, color: warmTerracotta),
                              label: const Text(
                                'Responder',
                                style: TextStyle(
                                  color: warmTerracotta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
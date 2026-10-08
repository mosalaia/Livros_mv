import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_login.dart';
import 'tela_detalhe_livro.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final TextEditingController _buscaCtrl = TextEditingController();
  List _livros = [];
  bool _carregando = false;

  static const Color slateBlue = Color(0xFF8AAAB4);
  static const Color dustyBlue = Color(0xFFB8C8D4);
  static const Color deepEspresso = Color(0xFF5C433C);
  static const Color warmTerracotta = Color(0xFFB98971);
  static const Color cardBeige = Color(0xFFEADBC8);

  @override
  void initState() {
    super.initState();
    _buscarLivrosAPI('livros');
  }

  Future<void> _buscarLivrosAPI(String termo) async {
    String busca = termo.trim().isEmpty ? 'livros' : termo.trim();
    setState(() => _carregando = true);

    try {
      final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': busca,
        'maxResults': '20',
      });
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _livros = data['items'] ?? _getLivrosPadrao();
          _carregando = false;
        });
      } else {
        _carregarFallback();
      }
    } catch (e) {
      _carregarFallback();
    }
  }

  void _carregarFallback() {
    setState(() {
      _livros = _getLivrosPadrao();
      _carregando = false;
    });
  }

  List _getLivrosPadrao() {
    return [
      {
        'id': 'oiluminado',
        'volumeInfo': {
          'title': 'O Iluminado',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/8147kKLLvOL._AC_UF1000,1000_QL80_.jpg'
          }
        }
      },

      {
         'id': 'Meu pé de laranja lima',
        'volumeInfo': {
          'title': 'Meu pé de laranja lima',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/816a7zMD+FL.jpg'
          }
        }
      },

            {
         'id': 'Para todos os garotos que já amei',
        'volumeInfo': {
          'title': 'Para todos os garotos que já amei',
          'imageLinks': {
            'thumbnail':
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCH678RoIG6JsIMHFP3aN3u1SpX1fAFSlLr7X-gKsaYaLHLztWa91Omjc&s=10'
          }
        }
      },

            {
         'id': 'Para todos os garotos que já amei ps: Ainda amo você',
        'volumeInfo': {
          'title': 'Para todos os garotos que já amei ps: Ainda amo você',
          'imageLinks': {
            'thumbnail':
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1_6Ki4xi2db0NPrlF3U9pLGw57EEmzjyDbHK2jIkDHlzscVsg7wjW1EA8&s=10'
          }
        }
      },

            {
         'id': 'Para todos os garotos que já amei: Para sempre e para sempre, Lara Jean',
        'volumeInfo': {
          'title': 'Para todos os garotos que já amei: Para sempre e para sempre, Lara Jean',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/61Q-b3VGXcL.jpg'
          }
        }
      },

            {
         'id': 'verity',
        'volumeInfo': {
          'title': 'verity',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/71TdL08SmUL._AC_UF1000,1000_QL80_.jpg'
          }
        }
      },

            {
         'id': 'Cinquenta tons de cinza',
        'volumeInfo': {
          'title': 'Cinquenta tons de cinza',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/61TfhwBAMaL._AC_UF1000,1000_QL80_.jpg'
          }
        }
      },

            {
         'id': 'Cinquenta tons mais escuros',
        'volumeInfo': {
          'title': 'Cinquenta tons mais escuros',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/61FiMvkzsnL.jpg'
          }
        }
      },

            {
         'id': 'Cinquanta tons de liberdade',
        'volumeInfo': {
          'title': 'Cinquanta tons de liberdade',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/61JmhOAZhfL.jpg'
          }
        }
      },

            {
         'id': 'É assim que acaba',
        'volumeInfo': {
          'title': 'É assim que acaba',
          'imageLinks': {
            'thumbnail':
                'https://http2.mlstatic.com/D_NQ_NP_806350-MLU73794905138_012024-O.webp'
          }
        }
      },

            {
         'id': 'O pequeno príncipe',
        'volumeInfo': {
          'title': 'O pequeno príncipe',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/81TmOZIXvzL.jpg'
          }
        }
      },

            {
         'id': 'O objeto do poder',
        'volumeInfo': {
          'title': 'O objeto do poder',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/81F40zBXD2L._UF1000,1000_QL80_.jpg'
          }
        }
      },

      {
        'id': 'domcasmurro',
        'volumeInfo': {
          'title': 'Dom Casmurro',
          'imageLinks': {
            'thumbnail':
                'https://images.tcdn.com.br/img/img_prod/1271663/dom_casmurro_edicao_de_luxo_almofadada_89_1_038fb70c564eb50f71ea49f6027e827a.jpg'
          }
        }
      },
      {
        'id': '1984',
        'volumeInfo': {
          'title': '1984',
          'imageLinks': {
            'thumbnail':
                'https://m.media-amazon.com/images/I/819js3EQwbL._AC_UF1000,1000_QL80_.jpg'
          }
        }
      }
    ];
  }

  Future<void> _fazerLogoff() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TelaLogin()),
    );
  }

  void _abrirModalNovoPost() {
    if (_livros.isEmpty) return;
    //sub coleção comentarios

    String livroSelecionado = _livros.first['volumeInfo']['title'] ?? 'Livro';
    final capCtrl = TextEditingController();
    final textoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          backgroundColor: const Color(0xFFF5EBE6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Novo Post Anónimo',
            style: TextStyle(color: deepEspresso, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: livroSelecionado,
                  dropdownColor: cardBeige,
                  decoration: const InputDecoration(
                    labelText: 'Selecione o Livro',
                  ),
                  isExpanded: true,
                  items: _livros.map<DropdownMenuItem<String>>((item) {
                    String titulo = item['volumeInfo']['title'] ?? 'Sem Título';
                    return DropdownMenuItem<String>(
                      value: titulo,
                      child: Text(titulo, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (novoValor) {
                    if (novoValor != null) {
                      setStateModal(() => livroSelecionado = novoValor);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: capCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nº do Capítulo',
                    prefixIcon: Icon(Icons.bookmark_outline, color: slateBlue),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: textoCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comentário ou Spoiler',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: deepEspresso)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: warmTerracotta),
              onPressed: () async {
                int? numeroCapitulo = int.tryParse(capCtrl.text.trim());
                if (numeroCapitulo != null && textoCtrl.text.isNotEmpty) {
                  String idLivroSanitizado =
                      livroSelecionado.toLowerCase().replaceAll(' ', '_');

                  String? currentUserId =
                      FirebaseAuth.instance.currentUser?.uid;

                  await FirebaseFirestore.instance
                      .collection('livros')
                      .doc(idLivroSanitizado)
                      .collection('debates_capitulo')
                      .add({
                    'texto': textoCtrl.text.trim(),
                    'numeroCapitulo': numeroCapitulo,
                    'userId': currentUserId,
                    'criadoEm': FieldValue.serverTimestamp(),
                  });

                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Post publicado com sucesso!'),
                      backgroundColor: slateBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaPerfil()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _fazerLogoff,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _buscaCtrl,
              decoration: InputDecoration(
                hintText: 'Pesquisar livro...',
                prefixIcon: const Icon(Icons.search, color: slateBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: slateBlue),
                  onPressed: () => _buscarLivrosAPI(_buscaCtrl.text),
                ),
              ),
              onSubmitted: _buscarLivrosAPI,
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: slateBlue),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: _livros.length,
                    itemBuilder: (context, index) {
                      var volumeInfo = _livros[index]['volumeInfo'];
                      String idLivro = _livros[index]['id'] ?? 'id';
                      String titulo = volumeInfo['title'] ?? 'Sem Título';
                      String? capaUrl = volumeInfo['imageLinks']?['thumbnail'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TelaDetalheLivro(
                                idLivro: idLivro,
                                titulo: titulo,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBeige,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: deepEspresso.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: capaUrl != null
                                      ? Image.network(
                                          capaUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: dustyBlue.withOpacity(0.3),
                                          child: const Icon(Icons.book,
                                              size: 60, color: slateBlue),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: deepEspresso,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalNovoPost,
        backgroundColor: warmTerracotta,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment),
        label: const Text('Novo Post', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
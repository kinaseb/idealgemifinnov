import 'package:flutter/material.dart';
import '../class/client.dart';
import '../class/article.dart';
import '../services/database_helper.dart';

class ArticlesPage extends StatefulWidget {
  final Client client;

  const ArticlesPage({super.key, required this.client});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _refreshArticles();
  }

  void _refreshArticles() {
    setState(() {
      _articlesFuture =
          DatabaseHelper().getArticlesByClient(widget.client.id!).then((data) {
        return data.map((e) => Article.fromMap(e)).toList();
      });
    });
  }

  void _addArticle() {
    final nameController = TextEditingController();
    final dimController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Article Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dimController,
              decoration: const InputDecoration(labelText: 'Dimensions'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final article = Article(
                  clientId: widget.client.id!,
                  name: nameController.text,
                  dimensions: dimController.text,
                );
                await DatabaseHelper().insertArticle(article.toMap());
                if (mounted) Navigator.pop(context);
                _refreshArticles();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.client.name} Articles'),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                child: ListTile(
                  title: Text(article.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dimensions: ${article.dimensions}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper().deleteArticle(article.id!);
                      _refreshArticles();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addArticle,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../class/client.dart';
import '../class/article.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../widgets/avatar_image.dart';
import 'article_form_page.dart';

class ArticlesPage extends StatefulWidget {
  final Client client;

  const ArticlesPage({super.key, required this.client});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late Future<List<Article>> _articlesFuture;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _refreshArticles();
    _searchController.addListener(_filterArticles);

    // Listen for realtime updates
    _syncSubscription = SyncService().onChange.listen((_) {
      if (mounted) {
        _refreshArticles();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _refreshArticles() {
    setState(() {
      _articlesFuture =
          DatabaseHelper().getArticlesByClient(widget.client.id!).then((data) {
        final articles = data.map((e) => Article.fromMap(e)).toList();
        _allArticles = articles;
        _filterArticles();
        return articles;
      });
    });
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles.where((article) {
          return article.name.toLowerCase().contains(query) ||
              article.type.toLowerCase().contains(query) ||
              article.machine.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.client.name} Articles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (_filteredArticles.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          return ListView.builder(
            itemCount: _filteredArticles.length,
            itemBuilder: (context, index) {
              final article = _filteredArticles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: AvatarImage(
                    imagePath: article.photo,
                    fallbackText: article.type,
                  ),
                  title: Text(article.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${article.type.toUpperCase()} - ${article.machine}'),
                      Text(
                          'Size: ${article.width}mm | Colors: ${article.colorCount}'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleFormPage(
                          client: widget.client,
                          article: article,
                        ),
                      ),
                    );
                    _refreshArticles();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Article'),
                          content: const Text(
                              'Are you sure you want to delete this article?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await DatabaseHelper().deleteArticle(article.id!);
                        _refreshArticles();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleFormPage(client: widget.client),
            ),
          );
          _refreshArticles();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../class/client.dart';
import '../class/article.dart';
import '../services/database_helper.dart';

class ArticleSelectionDialog extends StatefulWidget {
  const ArticleSelectionDialog({super.key});

  @override
  State<ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<ArticleSelectionDialog> {
  List<Client> _clients = [];
  List<Article> _articles = [];
  Client? _selectedClient;
  bool _isLoadingClients = true;
  bool _isLoadingArticles = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final data = await DatabaseHelper().getClients();
    if (mounted) {
      setState(() {
        _clients = data.map((e) => Client.fromMap(e)).toList();
        _isLoadingClients = false;
      });
    }
  }

  Future<void> _loadArticles(Client client) async {
    setState(() {
      _isLoadingArticles = true;
      _selectedClient = client;
      _articles = [];
    });

    final data = await DatabaseHelper().getArticlesByClient(client.id!);
    if (mounted) {
      setState(() {
        _articles = data.map((e) => Article.fromMap(e)).toList();
        _isLoadingArticles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _selectedClient == null ? 'Select Client' : 'Select Article',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedClient == null
                      ? _buildClientList()
                      : _buildArticleList(),
            ),
            if (_selectedClient != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedClient = null;
                      _articles = [];
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Clients'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
    if (_clients.isEmpty) {
      return const Center(child: Text('No clients found.'));
    }
    return ListView.builder(
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        final client = _clients[index];
        return ListTile(
          leading: client.logoPath != null
              ? CircleAvatar(backgroundImage: FileImage(File(client.logoPath!)))
              : CircleAvatar(child: Text(client.name[0].toUpperCase())),
          title: Text(client.name),
          subtitle: Text(client.contactInfo ?? ''),
          onTap: () => _loadArticles(client),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }

  Widget _buildArticleList() {
    if (_isLoadingArticles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_articles.isEmpty) {
      return const Center(child: Text('No articles found for this client.'));
    }
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return ListTile(
          leading: article.photo != null
              ? CircleAvatar(backgroundImage: FileImage(File(article.photo!)))
              : CircleAvatar(child: Text(article.type[0].toUpperCase())),
          title: Text(article.name),
          subtitle: Text('${article.width}mm | Repeat: ${article.repeat}'),
          onTap: () {
            Navigator.pop(context, article);
          },
        );
      },
    );
  }
}

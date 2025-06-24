import 'package:flutter/material.dart';

class UrlInputOverlay extends StatefulWidget {
  final List<String> initialUrls;
  const UrlInputOverlay({super.key, required this.initialUrls});

  @override
  State<UrlInputOverlay> createState() => _UrlInputOverlayState();
}

class _UrlInputOverlayState extends State<UrlInputOverlay> {
  late List<String> _urls;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urls = List.from(widget.initialUrls);
  }

  void _addUrl() {
    final url = _textController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _urls.add(url);
        _textController.clear();
      });
    }
  }

  void _removeUrl(int index) {
    setState(() {
      _urls.removeAt(index);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("戻る"),
                  ),
                  const Text("Webサイトを選択",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_urls),
                    child: const Text("完了"),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 入力欄とリストをスクロール可能に
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8,
                ),
                child: Column(
                  children: [
                    // 入力フォーム
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              labelText: 'ブロックしたいURLの一部を入力',
                              hintText: '例: youtube.com',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addUrl(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: _addUrl,
                          iconSize: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // URLリスト
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _urls.length,
                      itemBuilder: (context, index) {
                        final url = _urls[index];
                        return Card(
                          child: ListTile(
                            title: Text(url),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeUrl(index),
                            ),
                          ),
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
    );
  }
}

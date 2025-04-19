import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAIPane extends ConsumerStatefulWidget {
  OpenAIPane({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OpenAIPaneState();
}

class _OpenAIPaneState extends ConsumerState<ConsumerStatefulWidget> {
  TextEditingController _controller = TextEditingController();
  static const String kOpenAIApiKeyPref = 'openai_api_key';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }
  
  _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(kOpenAIApiKeyPref) ?? '';
    setState(() {
      _controller.text = apiKey;
      _isLoading = false;
    });
  }

  _saveApiKey(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOpenAIApiKeyPref, value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'OpenAI API Key',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoading)
          Center(child: CircularProgressIndicator())
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _controller,
              onChanged: _saveApiKey,
              decoration: InputDecoration(
                hintText: 'Enter your OpenAI API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: 'Clear',
                  onPressed: () {
                    _controller.clear();
                    _saveApiKey('');
                  },
                ),
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Your API key is stored securely on your device and used for OpenAI service integration.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class OpenAISettingsPage extends StatelessWidget {
  const OpenAISettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAI Settings'),
      ),
      body: OpenAIPane(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class OpenAISheetPane extends StatelessWidget {
  const OpenAISheetPane({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              OpenAIPane(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Continue'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

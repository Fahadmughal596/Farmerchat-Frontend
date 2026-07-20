import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  String selectedLanguage = 'English';

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  final List<Map<String, String>> _messages = [];

  final Map<String, Map<String, String>> translations = {
    'English': {
      'welcome': 'Hello! Ask me about market rates, government schemes, IoT sensors, fertilizer, or crop diseases.',
      'hint': 'Ask about wheat rate, subsidy scheme, soil moisture...',
      'error': 'Could not connect. Please check your internet connection.',
      'thinking': 'Thinking...',
      'title': 'Agri Dost AI',
      'sample1': 'Wheat rate in Faisalabad',
      'sample2': 'Any subsidy scheme in Punjab?',
      'sample3': 'What is my soil moisture?',
    },
    'اردو': {
      'welcome': 'السلام علیکم! مارکیٹ ریٹ، سرکاری اسکیم، سینسر، کھاد یا فصل کی بیماری کے بارے میں پوچھیں۔',
      'hint': 'گندم ریٹ، سبسڈی اسکیم، نمی...',
      'error': 'کنکشن نہیں ہوا۔ انٹرنیٹ چیک کریں۔',
      'thinking': 'سوچ رہا ہوں...',
      'title': 'ایگری دوست اے آئی',
      'sample1': 'فیصل آباد میں گندم کا ریٹ',
      'sample2': 'پنجاب میں سبسڈی اسکیم؟',
      'sample3': 'مٹی کی نمی کیا ہے؟',
    },
    'سنڌي': {
      'welcome': 'اسلام عليڪم! مارڪيٽ ريٽ، سرڪاري اسڪيم، سينسر، ڀاڻ يا فصل جي بيماري بابت پڇو.',
      'hint': 'ڪڻڪ ريٽ، سبسڊي اسڪيم، نمي...',
      'error': 'ڪنيڪشن نه ٿيو. انٽرنيٽ چيڪ ڪريو.',
      'thinking': 'سوچي رهيو آهيان...',
      'title': 'ايگري دوست AI',
      'sample1': 'فيصل آباد ۾ ڪڻڪ جو ريٽ',
      'sample2': 'پنجاب ۾ سبسڊي اسڪيم؟',
      'sample3': 'مٽي جي نمي ڇا آهي؟',
    },
  };

  String get _languageCode {
    if (selectedLanguage == 'اردو') return 'ur';
    if (selectedLanguage == 'سنڌي') return 'sd';
    return 'en';
  }

Future<void> _sendMessage({String? quickText}) async {
  final text = (quickText ?? _controller.text).trim();

  if (text.isEmpty || _isLoading) return;

  setState(() {
    _messages.add({
      'role': 'user',
      'text': text,
    });
    _isLoading = true;
  });

  _controller.clear();
  _scrollToBottom();

  try {
    final result = await _apiService.sendChatMessage(
      message: text,
      language: _languageCode,
    );

    final bool success = result['success'] == true;

    final String botReply = success
        ? (result['reply']?.toString() ?? 'No response received.')
        : (result['reply']?.toString() ??
            translations[selectedLanguage]!['error']!);

    final String intent =
        result['intent']?.toString() ?? 'general';

    if (!mounted) return;

    setState(() {
      _messages.add({
  'role': 'bot',
  'text': botReply,
  'intent': intent,
  'source': result['source']?.toString() ?? '',
});

      _isLoading = false;
    });

    _scrollToBottom();
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        'role': 'bot',
        'text': translations[selectedLanguage]!['error']!,
        'intent': 'error',
      });

      _isLoading = false;
    });

    _scrollToBottom();
  }
}

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndPredictDisease(ImageSource source) async {
    if (_isLoading) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final File imageFile = File(picked.path);

    setState(() {
      _messages.add({
        'role': 'user',
        'text': '📷 [Photo sent for disease detection]',
        'imagePath': imageFile.path,
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final result = await _apiService.predictDisease(imageFile: imageFile);
      final bool success = result['success'] == true;

      final String label = result['label']?.toString() ?? 'Unknown';
      final double confidence = (result['confidence'] is num)
          ? (result['confidence'] as num).toDouble()
          : 0.0;

      final String botReply = success
          ? 'Prediction: $label\nConfidence: ${(confidence * 100).toStringAsFixed(1)}%'
          : (result['message']?.toString() ??
              translations[selectedLanguage]!['error']!);

      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': botReply,
          'intent': 'disease_prediction',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': translations[selectedLanguage]!['error']!,
          'intent': 'error',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPredictDisease(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPredictDisease(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildQuickQuestion(String text) {
    return InkWell(
      onTap: () => _sendMessage(quickText: text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.18)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppConstants.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = translations[selectedLanguage]!;
    final isRTL = selectedLanguage != 'English';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture,
                size: 46,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t['welcome']!,
              textAlign: TextAlign.center,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildQuickQuestion(t['sample1']!),
                _buildQuickQuestion(t['sample2']!),
                _buildQuickQuestion(t['sample3']!),
              ],
            ),
          ],
        ),
      ),
    );
  }
Widget _buildSourceChip(String? source) {
  if (source == null) return const SizedBox();

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      source.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
  Widget _buildIntentChip(String? intent) {
    if (intent == null || intent.isEmpty || intent == 'general') {
      return const SizedBox.shrink();
    }

    

    String label = intent.replaceAll('_', ' ').toUpperCase();

    IconData icon = Icons.smart_toy_outlined;

    if (intent == 'market_rate') icon = Icons.trending_up;
    if (intent == 'government_scheme') icon = Icons.account_balance;
    if (intent == 'iot_status') icon = Icons.sensors;
    if (intent == 'fertilizer_advice') icon = Icons.grass;
    if (intent == 'pest_disease_advice') icon = Icons.bug_report;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppConstants.secondaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppConstants.secondaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    final isRTL = selectedLanguage != 'English';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppConstants.primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
children: [
  if (!isUser) ...[
    Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildIntentChip(msg['intent']),
        _buildSourceChip(msg['source']),
      ],
    ),
    const SizedBox(height: 6),
  ],

  if (msg['imagePath'] != null && msg['imagePath']!.isNotEmpty) ...[
    ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(msg['imagePath']!),
        width: 180,
        height: 180,
        fit: BoxFit.cover,
      ),
    ),
    const SizedBox(height: 6),
  ],

  SelectableText(
    msg['text'] ?? '',
    textAlign: isRTL ? TextAlign.right : TextAlign.left,
    textDirection:
        isRTL ? TextDirection.rtl : TextDirection.ltr,
    style: TextStyle(
      color: isUser ? Colors.white : Colors.black87,
      fontSize: 14.5,
      height: 1.45,
    ),
  ),
],
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              translations[selectedLanguage]!['thinking']!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String lang) {
    final isSelected = selectedLanguage == lang;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = lang;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 11),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            lang,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final t = translations[selectedLanguage]!;
    final isRTL = selectedLanguage != 'English';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFF0F2F5),
              radius: 22,
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: AppConstants.primaryGreen, size: 20),
                tooltip: 'Detect crop disease from photo',
                onPressed: _isLoading ? null : _showImageSourceSheet,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  onSubmitted: (_) => _sendMessage(),
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: t['hint'],
                    hintTextDirection:
                        isRTL ? TextDirection.rtl : TextDirection.ltr,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor:
                  _isLoading ? Colors.grey : AppConstants.primaryGreen,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = translations[selectedLanguage]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          t['title']!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppConstants.primaryGreen,
        elevation: 2,
        actions: [
          _buildLanguageButton('English'),
          _buildLanguageButton('سنڌي'),
          _buildLanguageButton('اردو'),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildThinkingIndicator();
                      }

                      return _buildBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
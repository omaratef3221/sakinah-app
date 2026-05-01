import 'package:flutter/material.dart';
import 'package:sakinah_flow/core/services/asset_data_cache.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';

class DuaaScreen extends StatefulWidget {
  const DuaaScreen({super.key});

  @override
  State<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends State<DuaaScreen> {
  List<dynamic> _duas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDuas();
  }

  Future<void> _loadDuas() async {
    try {
      final data = await AssetDataCache.loadJson('assets/data/duas.json');
      if (!mounted) return;
      setState(() {
        _duas = data['duas'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDuaDetails(Map<String, dynamic> dua) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A5F4E),
                Color(0xFF0F3D30),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: Color(0xFF0A1F1A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dua['category'] ?? 'Dua',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                            Text(
                              dua['reference'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dua Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arabic Text
                        Text(
                          dua['arabic'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: Color(0xFFD4AF37),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),

                        // Transliteration
                        Text(
                          dua['transliteration'],
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Translation
                        Text(
                          dua['translation'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Done Button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0A1F1A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A5F4E),
              Color(0xFF0F3D30),
              Color(0xFF0A1F1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duas Collection',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          Text(
                            'مجموعة الأدعية',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      )
                    : _duas.isEmpty
                        ? Center(
                            child: Text(
                              'No duas found',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _duas.length,
                            itemBuilder: (context, index) {
                              final dua = _duas[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _showDuaDetails(dua),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFD4AF37),
                                                    Color(0xFFB8941C)
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0A1F1A),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dua['category'] ?? 'General',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFD4AF37),
                                                    ),
                                                  ),
                                                  Text(
                                                    dua['reference'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white.withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: const Color(0xFFD4AF37),
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          dua['arabic'],
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            height: 1.8,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dua['translation'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 0.7),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

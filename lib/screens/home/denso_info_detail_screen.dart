import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/denso_info_model.dart';
import '../../widgets/language_toggle_button.dart';
import '../../providers/language_provider.dart';
import '../../data/denso_info_data.dart';

class DensoInfoDetailScreen extends StatefulWidget {
  final DensoInfoModel info;

  const DensoInfoDetailScreen({super.key, required this.info});

  @override
  State<DensoInfoDetailScreen> createState() => _DensoInfoDetailScreenState();
}

class _DensoInfoDetailScreenState extends State<DensoInfoDetailScreen> {
  final _languageProvider = LanguageProvider();
  late DensoInfoModel _currentInfo;

  @override
  void initState() {
    super.initState();
    _currentInfo = widget.info;
    _languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    // Reload data with new language
    final newData = DensoInfoData.getList(_languageProvider.currentLocale.languageCode);
    final updatedInfo = newData.firstWhere(
      (item) => item.id == _currentInfo.id,
      orElse: () => _currentInfo,
    );
    setState(() {
      _currentInfo = updatedInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: _getThemeColor(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _currentInfo.previewInfo.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _getThemeColor(),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 64, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Text(
                            _currentInfo.previewInfo.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentInfo.previewInfo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentInfo.previewInfo.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              LanguageToggleIconButton(),
              SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentInfo.detailContent['full_title'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getThemeColor(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildContent(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor() {
    try {
      return Color(int.parse(_currentInfo.previewInfo.themeColor.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppColors.brand500;
    }
  }

  Widget _buildContent() {
    switch (_currentInfo.type) {
      case 'GLOBAL':
        return _buildGlobalContent();
      case 'LOCAL':
        return _buildLocalContent();
      case 'ENTITY':
        return _buildEntityContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGlobalContent() {
    final content = _currentInfo.detailContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content['slogan'] != null)
          _buildQuoteBox(content['slogan']),
        const SizedBox(height: 20),
        Text(
          content['introduction'] ?? '',
          style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.gray800),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Core Values'),
        ...(content['core_values'] as List? ?? []).map((e) => _buildBulletPoint(e)),
        const SizedBox(height: 24),
        _buildSectionTitle('Vision 2030'),
        if (content['vision_2030'] != null) ...[
          _buildInfoCard(
            icon: Icons.eco,
            title: 'Green',
            content: content['vision_2030']['goal_1'],
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.favorite,
            title: 'Peace of Mind',
            content: content['vision_2030']['goal_2'],
            color: Colors.pink,
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle('Global Stats'),
        if (content['global_stats'] != null)
          Row(
            children: [
              Expanded(child: _buildStatItem('Countries', content['global_stats']['countries'])),
              Expanded(child: _buildStatItem('Employees', content['global_stats']['employees'])),
            ],
          ),
      ],
    );
  }

  Widget _buildLocalContent() {
    final content = _currentInfo.detailContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Timeline'),
        ...(content['timeline'] as List? ?? []).map((e) => _buildTimelineItem(e)),
        const SizedBox(height: 24),
        _buildSectionTitle('Scale Info'),
        if (content['scale_info'] != null) ...[
          _buildInfoRow(Icons.landscape, 'Land Area', content['scale_info']['land_area']),
          _buildInfoRow(Icons.business, 'Floor Area', content['scale_info']['floor_area']),
          _buildInfoRow(Icons.people, 'Employees', content['scale_info']['total_employees']),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle('Certifications'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (content['certifications'] as List? ?? [])
              .map((e) => Chip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.gray100,
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        if (content['awards'] != null) ...[
          _buildSectionTitle('Awards'),
          _buildInfoCard(
            icon: Icons.emoji_events,
            title: 'Recognition',
            content: content['awards'],
            color: Colors.amber,
          ),
        ],
      ],
    );
  }

  Widget _buildEntityContent() {
    final content = _currentInfo.detailContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Legal Info'),
        if (content['legal_info'] != null) ...[
          _buildInfoRow(Icons.business, 'Name', content['legal_info']['official_name']),
          _buildInfoRow(Icons.monetization_on, 'Capital', content['legal_info']['investment_capital']),
          _buildInfoRow(Icons.pie_chart, 'Ownership', content['legal_info']['ownership']),
          _buildInfoRow(Icons.location_on, 'Address', content['legal_info']['address']),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle('Products & Services'),
        ...(content['products_services'] as List? ?? []).map((group) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['group'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.gray800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (group['items'] as List? ?? [])
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getThemeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getThemeColor().withOpacity(0.3)),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(color: _getThemeColor(), fontSize: 13),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        )),
        const SizedBox(height: 24),
        _buildSectionTitle('Contact Info'),
        if (content['contact_info'] != null) ...[
          _buildInfoRow(Icons.phone, 'Phone', content['contact_info']['phone']),
          _buildInfoRow(Icons.fax, 'Fax', content['contact_info']['fax']),
          _buildInfoRow(Icons.language, 'Website', content['contact_info']['website']),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
      ),
    );
  }

  Widget _buildQuoteBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getThemeColor().withOpacity(0.1),
        border: Border(left: BorderSide(color: _getThemeColor(), width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: _getThemeColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: _getThemeColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: AppColors.gray800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getThemeColor(),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _getThemeColor(),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item['year'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item['event'],
              style: const TextStyle(fontSize: 15, color: AppColors.gray800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, color: AppColors.gray800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

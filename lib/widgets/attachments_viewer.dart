import 'package:flutter/material.dart';
import '../models/attachment_model.dart';
import '../services/api_service.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Widget to display a list of attachments from MongoDB GridFS
class AttachmentsViewer extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final bool showPreview;
  final double previewHeight;

  const AttachmentsViewer({
    super.key,
    required this.attachments,
    this.showPreview = true,
    this.previewHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.attachments} (${attachments.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: previewHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              return _AttachmentItem(
                attachment: attachments[index],
                onTap: () => _showAttachmentDialog(context, attachments[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAttachmentDialog(BuildContext context, AttachmentModel attachment) {
    showDialog(
      context: context,
      builder: (context) => _AttachmentDialog(attachment: attachment),
    );
  }
}

class _AttachmentItem extends StatefulWidget {
  final AttachmentModel attachment;
  final VoidCallback onTap;

  const _AttachmentItem({required this.attachment, required this.onTap});

  @override
  State<_AttachmentItem> createState() => _AttachmentItemState();
}

class _AttachmentItemState extends State<_AttachmentItem> {
  String? _fullUrl;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final baseUrl = await ApiService.getBaseUrl();
    if (mounted) {
      setState(() {
        _fullUrl = widget.attachment.getFullUrl(baseUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.attachment.isImage && _fullUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _fullUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(Icons.broken_image);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }

    if (widget.attachment.isVideo) {
      return _buildPlaceholder(Icons.videocam, label: 'Video');
    }

    if (widget.attachment.isAudio) {
      return _buildPlaceholder(Icons.audiotrack, label: 'Audio');
    }

    if (widget.attachment.isDocument) {
      return _buildPlaceholder(Icons.description, label: 'Doc');
    }

    return _buildPlaceholder(Icons.attach_file, label: 'File');
  }

  Widget _buildPlaceholder(IconData icon, {String? label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: AppColors.gray500),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        ],
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            widget.attachment.originalName,
            style: TextStyle(fontSize: 10, color: AppColors.gray500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _AttachmentDialog extends StatefulWidget {
  final AttachmentModel attachment;

  const _AttachmentDialog({required this.attachment});

  @override
  State<_AttachmentDialog> createState() => _AttachmentDialogState();
}

class _AttachmentDialogState extends State<_AttachmentDialog> {
  String? _fullUrl;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final baseUrl = await ApiService.getBaseUrl();
    if (mounted) {
      setState(() {
        _fullUrl = widget.attachment.getFullUrl(baseUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.attachment.originalName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.gray600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(child: _buildDialogContent()),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatSize(widget.attachment.size),
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                  TextButton.icon(
                    onPressed: _fullUrl != null ? () => _openInBrowser() : null,
                    icon: Icon(Icons.open_in_new, size: 16),
                    label: Text(l10n.viewDetail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    if (_fullUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.attachment.isImage) {
      return InteractiveViewer(
        child: Image.network(
          _fullUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        ),
      );
    }

    // For non-image files, show info
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIconForType(), size: 64, color: AppColors.brand500),
          const SizedBox(height: 16),
          Text(
            widget.attachment.originalName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.attachment.mimeType,
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error500),
          const SizedBox(height: 8),
          Text('Failed to load', style: TextStyle(color: AppColors.gray600)),
        ],
      ),
    );
  }

  IconData _getIconForType() {
    if (widget.attachment.isVideo) return Icons.videocam;
    if (widget.attachment.isAudio) return Icons.audiotrack;
    if (widget.attachment.isDocument) return Icons.description;
    return Icons.attach_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  void _openInBrowser() {
    // TODO: Implement open in browser using url_launcher
  }
}

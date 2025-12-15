import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../config/app_colors.dart';
import '../../utils/toast_utils.dart';
import '../../widgets/text_field_with_mic.dart';
import '../../widgets/expanded_text_dialog.dart';
import '../../services/incident_service.dart';
import '../../l10n/app_localizations.dart';
import '../../components/loading_infinity.dart';
import '../../widgets/language_toggle_button.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String? _selectedPriority;
  String? _selectedCategory;
  bool _showCustomCategory = false;

  // Priority and category lists will be built in build method with l10n
  List<String> _getPriorities(AppLocalizations l10n) => [
    l10n.priorityLow,
    l10n.priorityMedium,
    l10n.priorityHigh,
    l10n.priorityUrgent,
  ];

  List<String> _getCategories(AppLocalizations l10n) => [
    l10n.categoryEquipment,
    l10n.categorySafety,
    l10n.categoryQuality,
    l10n.categoryProcess,
    l10n.categoryOther,
  ];

  String _mapCategoryToBackend(String category, AppLocalizations l10n) {
    if (category == l10n.categorySafety) return 'safety';
    if (category == l10n.categoryQuality) return 'quality';
    if (category == l10n.categoryEquipment) return 'equipment';
    return 'other';
  }

  String _mapPriorityToBackend(String priority, AppLocalizations l10n) {
    if (priority == l10n.priorityLow) return 'low';
    if (priority == l10n.priorityMedium) return 'medium';
    if (priority == l10n.priorityHigh) return 'high';
    if (priority == l10n.priorityUrgent) return 'critical';
    return 'medium';
  }

  // Media attachments
  final List<File> _images = [];
  final List<File> _videos = [];
  String? _audioPath;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _openExpandedTextDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ExpandedTextDialog(
          controller: _descriptionController,
          title: l10n.reportDescription,
          hintText: l10n.enterReportDescription,
        ),
      ),
    );
    // Trigger rebuild to show updated text
    setState(() {});
  }

  // Camera functions
  Future<void> _takePicture() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        // Kiểm tra nếu là lỗi quyền bị từ chối vĩnh viễn
        final status = await Permission.camera.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog('camera');
        } else {
          ToastUtils.showError(
            '${AppLocalizations.of(context)!.error}: ${e.toString()}',
          );
        }
      }
    }
  }

  // Gallery functions
  Future<void> _pickMedia() async {
    try {
      final picker = ImagePicker();
      final l10n = AppLocalizations.of(context)!;

      // Show dialog to choose between image or video
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.addMedia),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: AppColors.brand500),
                title: Text(l10n.photo),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: AppColors.brand500),
                title: Text(l10n.video),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (choice == 'image') {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            _images.add(File(image.path));
          });
        }
      } else if (choice == 'video') {
        final XFile? video = await picker.pickVideo(
          source: ImageSource.gallery,
        );
        if (video != null) {
          setState(() {
            _videos.add(File(video.path));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if permission is permanently denied
        final status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog(
            AppLocalizations.of(context)!.galleryPermission,
          );
        } else {
          ToastUtils.showError(
            '${AppLocalizations.of(context)!.error}: ${e.toString()}',
          );
        }
      }
    }
  }

  // Audio recording functions
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      try {
        final path = await _audioRecorder.stop();
        if (path != null) {
          setState(() {
            _audioPath = path;
            _isRecording = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(
            '${AppLocalizations.of(context)!.error}: ${e.toString()}',
          );
        }
      }
    } else {
      // Start recording - để package record tự xử lý quyền
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        if (mounted) {
          // Check if permission is permanently denied
          final status = await Permission.microphone.status;
          if (status.isPermanentlyDenied) {
            _showPermissionDialog(
              AppLocalizations.of(context)!.microphonePermission,
            );
          } else {
            ToastUtils.showError(
              '${AppLocalizations.of(context)!.error}: ${e.toString()}',
            );
          }
        }
      }
    }
  }

  void _showPermissionDialog(String permissionType) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(permissionType),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.goToSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.gray800),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context)!.incidentReport,
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: const [LanguageToggleIconButton(), SizedBox(width: 8)],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tiêu đề sự cố
              _buildSectionTitle(
                AppLocalizations.of(context)!.incidentTitle,
                isRequired: true,
              ),
              const SizedBox(height: 8),
              TextFieldWithMic(
                controller: _titleController,
                hintText: AppLocalizations.of(context)!.enterIncidentTitle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Vị trí / Thiết bị
              _buildSectionTitle(
                AppLocalizations.of(context)!.location,
                isRequired: true,
              ),
              const SizedBox(height: 8),
              TextFieldWithMic(
                controller: _locationController,
                hintText: AppLocalizations.of(context)!.enterLocation,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterLocation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Mức độ ưu tiên
              _buildSectionTitle(
                AppLocalizations.of(context)!.priority,
                isRequired: true,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getPriorities(AppLocalizations.of(context)!).map((
                  priority,
                ) {
                  final isSelected = _selectedPriority == priority;
                  return FilterChip(
                    label: Text(priority),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = selected ? priority : null;
                      });
                    },
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.error500,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.gray700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.error500
                          : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Phân loại vấn đề
              _buildSectionTitle(
                AppLocalizations.of(context)!.category,
                isRequired: true,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getCategories(AppLocalizations.of(context)!).map((
                  category,
                ) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.error500,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.gray700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.error500
                          : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      final l10n = AppLocalizations.of(context)!;
                      setState(() {
                        _selectedCategory = selected ? category : null;
                        if (category == l10n.categoryOther) {
                          _showCustomCategory = selected;
                          if (!selected) _customCategoryController.clear();
                        } else {
                          _showCustomCategory = false;
                          _customCategoryController.clear();
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              // Custom category input (only show when "Other" is selected)
              if (_showCustomCategory) ...[
                const SizedBox(height: 12),
                TextFieldWithMic(
                  controller: _customCategoryController,
                  hintText: AppLocalizations.of(context)!.categoryOther,
                ),
              ],
              const SizedBox(height: 20),

              // Mô tả chi tiết
              _buildSectionTitle(AppLocalizations.of(context)!.description),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openExpandedTextDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _descriptionController.text.isEmpty
                              ? AppLocalizations.of(context)!.enterDescription
                              : _descriptionController.text,
                          style: TextStyle(
                            color: _descriptionController.text.isEmpty
                                ? AppColors.gray400
                                : AppColors.black,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit_note,
                        color: AppColors.brand500,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Đính kèm bằng chứng
              _buildSectionTitle(AppLocalizations.of(context)!.attachEvidence),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAttachmentButton(
                      icon: Icons.camera_alt,
                      label: AppLocalizations.of(context)!.takePhoto,
                      onTap: _takePicture,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAttachmentButton(
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context)!.uploadMedia,
                      onTap: _pickMedia,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAttachmentButton(
                icon: _isRecording ? Icons.stop : Icons.mic,
                label: _isRecording
                    ? AppLocalizations.of(context)!.stopRecording
                    : AppLocalizations.of(context)!.record,
                onTap: _toggleRecording,
                isRecording: _isRecording,
              ),

              // Display attached media
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMediaPreview(
                  AppLocalizations.of(context)!.selectedImages,
                  _images,
                  Icons.image,
                ),
              ],
              if (_videos.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMediaPreview(
                  AppLocalizations.of(context)!.selectedVideos,
                  _videos,
                  Icons.videocam,
                ),
              ],
              if (_audioPath != null) ...[
                const SizedBox(height: 16),
                _buildAudioPreview(),
              ],
              const SizedBox(height: 32),

              // Nút gửi báo cáo
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        print('🔵 Submit button pressed');

                        if (_formKey.currentState!.validate()) {
                          print('🔵 Form validation passed');

                          if (_selectedPriority == null) {
                            print('🔴 No priority selected');
                            ToastUtils.showError(
                              AppLocalizations.of(
                                context,
                              )!.pleaseSelectPriority,
                            );
                            return;
                          }

                          if (_selectedCategory == null) {
                            print('🔴 No category selected');
                            ToastUtils.showError(
                              AppLocalizations.of(
                                context,
                              )!.pleaseSelectCategory,
                            );
                            return;
                          }

                          print('🔵 Setting isSubmitting = true');
                          setState(() {
                            _isSubmitting = true;
                          });

                          final l10n = AppLocalizations.of(context)!;

                          print('🔵 Mapping category and priority...');
                          // Map category
                          String incidentType = _mapCategoryToBackend(
                            _selectedCategory!,
                            l10n,
                          );
                          String priority = _mapPriorityToBackend(
                            _selectedPriority!,
                            l10n,
                          );

                          print(
                            '🔵 incident_type: $incidentType, priority: $priority',
                          );

                          // Append category info to description if needed
                          String description = _descriptionController.text;
                          if (_selectedCategory == l10n.categoryOther &&
                              _customCategoryController.text.isNotEmpty) {
                            description =
                                '${l10n.category}: ${_customCategoryController.text}\n\n$description';
                          } else if (![
                            l10n.categorySafety,
                            l10n.categoryQuality,
                            l10n.categoryEquipment,
                          ].contains(_selectedCategory)) {
                            description =
                                '${l10n.category}: $_selectedCategory\n\n$description';
                          }

                          print('🔵 Preparing to send incident...');
                          print(
                            '🔵 Images: ${_images.length}, Videos: ${_videos.length}, Audio: ${_audioPath != null ? "yes" : "no"}',
                          );

                          try {
                            final result = await IncidentService.createIncident(
                              title: _titleController.text,
                              description: description,
                              location: _locationController.text,
                              priority: priority,
                              incidentType: incidentType,
                              images: _images,
                              videos: _videos,
                              audioPath: _audioPath,
                            );

                            print('🔵 Got response from server');

                            setState(() {
                              _isSubmitting = false;
                            });

                            if (result['success'] == true) {
                              if (mounted) {
                                print('✅ Incident created successfully');
                                ToastUtils.showSuccess(
                                  AppLocalizations.of(
                                    context,
                                  )!.reportSubmitSuccess,
                                );
                                Navigator.pop(context);
                              }
                            } else {
                              if (mounted) {
                                print('❌ Failed: ${result['message']}');
                                ToastUtils.showError(
                                  result['message'] ??
                                      AppLocalizations.of(
                                        context,
                                      )!.reportSubmitFailed,
                                );
                              }
                            }
                          } catch (e) {
                            print('❌ Exception during submit: $e');
                            setState(() {
                              _isSubmitting = false;
                            });
                            if (mounted) {
                              ToastUtils.showError('Error: $e');
                            }
                          }
                        } else {
                          print('🔴 Form validation failed');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingInfinity(size: 20),
                      )
                    : Text(
                        AppLocalizations.of(context)!.submitReport,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: AppColors.error500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isRecording = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isRecording
              ? AppColors.error500.withOpacity(0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecording ? AppColors.error500 : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isRecording ? AppColors.error500 : AppColors.brand500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isRecording ? AppColors.error500 : AppColors.gray700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(String title, List<File> files, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${files.length})',
          style: TextStyle(
            color: AppColors.gray700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(icon, color: AppColors.gray400, size: 32),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            files.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error500,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brand500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brand500),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brand500,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.recordedAudio,
                  style: TextStyle(
                    color: AppColors.brand500,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPlaying
                      ? AppLocalizations.of(context)!.processing
                      : AppLocalizations.of(context)!.tapToSpeak,
                  style: TextStyle(
                    color: AppColors.brand500.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _audioPath = null;
                _isPlaying = false;
              });
              _audioPlayer.stop();
            },
            child: Icon(Icons.close, color: AppColors.error500),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() {
        _isPlaying = true;
      });

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
        });
      });
    }
  }
}

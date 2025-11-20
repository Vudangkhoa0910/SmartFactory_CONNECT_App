import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../config/app_colors.dart';
import '../../widgets/text_field_with_mic.dart';
import '../../widgets/expanded_text_dialog.dart';
import '../../services/incident_service.dart';

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

  final List<String> _priorities = ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'];

  final List<String> _categories = [
    'Kỹ thuật',
    'An toàn',
    'Chất lượng',
    'Quy trình',
    'Nhân sự',
    'Khác',
  ];

  String _mapCategoryToBackend(String category) {
    switch (category) {
      case 'An toàn':
        return 'safety';
      case 'Chất lượng':
        return 'quality';
      case 'Kỹ thuật':
        return 'equipment';
      default:
        return 'other';
    }
  }

  String _mapPriorityToBackend(String priority) {
    switch (priority) {
      case 'Thấp':
        return 'low';
      case 'Trung bình':
        return 'medium';
      case 'Cao':
        return 'high';
      case 'Khẩn cấp':
        return 'critical';
      default:
        return 'medium';
    }
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
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ExpandedTextDialog(
          controller: _descriptionController,
          title: 'Mô tả chi tiết',
          hintText: 'Mô tả chi tiết về sự cố...',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi mở camera: ${e.toString()}'),
              backgroundColor: AppColors.error500,
            ),
          );
        }
      }
    }
  }

  // Gallery functions
  Future<void> _pickMedia() async {
    try {
      final picker = ImagePicker();

      // Show dialog to choose between image or video
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn loại file'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: AppColors.brand500),
                title: const Text('Ảnh'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: AppColors.brand500),
                title: const Text('Video'),
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
        // Kiểm tra nếu là lỗi quyền bị từ chối vĩnh viễn
        final status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog('thư viện ảnh');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi mở thư viện: ${e.toString()}'),
              backgroundColor: AppColors.error500,
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi dừng ghi âm: ${e.toString()}'),
              backgroundColor: AppColors.error500,
            ),
          );
        }
      }
    } else {
      // Start recording
      try {
        PermissionStatus status = await Permission.microphone.status;
        
        // Nếu chưa được cấp quyền, yêu cầu quyền
        if (!status.isGranted) {
          status = await Permission.microphone.request();
        }
        
        if (status.isGranted) {
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
        } else if (status.isPermanentlyDenied) {
          // Chỉ hiển thị dialog khi quyền bị từ chối vĩnh viễn
          _showPermissionDialog('microphone');
        }
        // Nếu denied (chưa vĩnh viễn), không làm gì - người dùng có thể thử lại
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi bắt đầu ghi âm: ${e.toString()}'),
              backgroundColor: AppColors.error500,
            ),
          );
        }
      }
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quyền truy cập bị từ chối'),
        content: Text(
          'Ứng dụng cần quyền truy cập $permissionType để sử dụng chức năng này. Vui lòng cấp quyền trong Cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
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
            'Báo cáo sự cố / Yêu cầu hỗ trợ',
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tiêu đề sự cố
              _buildSectionTitle('Tiêu đề sự cố', isRequired: true),
              const SizedBox(height: 8),
              TextFieldWithMic(
                controller: _titleController,
                hintText: 'Nhập tiêu đề sự cố',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề sự cố';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Vị trí / Thiết bị
              _buildSectionTitle('Vị trí / Thiết bị', isRequired: true),
              const SizedBox(height: 8),
              TextFieldWithMic(
                controller: _locationController,
                hintText: 'Nhập vị trí hoặc tên thiết bị',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí hoặc thiết bị';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Mức độ ưu tiên
              _buildSectionTitle('Mức độ ưu tiên', isRequired: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorities.map((priority) {
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
              _buildSectionTitle('Phân loại vấn đề', isRequired: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
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
                      setState(() {
                        _selectedCategory = selected ? category : null;
                        if (category == 'Khác') {
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

              // Custom category input (only show when "Khác" is selected)
              if (_showCustomCategory) ...[
                const SizedBox(height: 12),
                TextFieldWithMic(
                  controller: _customCategoryController,
                  hintText: 'Nhập loại vấn đề khác...',
                ),
              ],
              const SizedBox(height: 20),

              // Mô tả chi tiết
              _buildSectionTitle('Mô tả chi tiết'),
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
                              ? 'Nhấn để nhập mô tả chi tiết...'
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
              _buildSectionTitle('Đính kèm bằng chứng'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAttachmentButton(
                      icon: Icons.camera_alt,
                      label: 'Chụp ảnh',
                      onTap: _takePicture,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAttachmentButton(
                      icon: Icons.photo_library,
                      label: 'Tải ảnh/Video',
                      onTap: _pickMedia,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAttachmentButton(
                icon: _isRecording ? Icons.stop : Icons.mic,
                label: _isRecording ? 'Dừng ghi âm' : 'Ghi âm',
                onTap: _toggleRecording,
                isRecording: _isRecording,
              ),

              // Display attached media
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMediaPreview('Ảnh đã chọn', _images, Icons.image),
              ],
              if (_videos.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMediaPreview('Video đã chọn', _videos, Icons.videocam),
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
                        if (_formKey.currentState!.validate()) {
                          if (_selectedPriority == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vui lòng chọn mức độ ưu tiên'),
                                backgroundColor: AppColors.error500,
                              ),
                            );
                            return;
                          }

                          if (_selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vui lòng chọn loại vấn đề'),
                                backgroundColor: AppColors.error500,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isSubmitting = true;
                          });

                          // Map category
                          String incidentType = _mapCategoryToBackend(
                            _selectedCategory!,
                          );
                          String priority = _mapPriorityToBackend(
                            _selectedPriority!,
                          );

                          // Append category info to description if needed
                          String description = _descriptionController.text;
                          if (_selectedCategory == 'Khác' &&
                              _customCategoryController.text.isNotEmpty) {
                            description =
                                'Loại sự cố: ${_customCategoryController.text}\n\n$description';
                          } else if (![
                            'An toàn',
                            'Chất lượng',
                            'Kỹ thuật',
                          ].contains(_selectedCategory)) {
                            description =
                                'Loại sự cố: $_selectedCategory\n\n$description';
                          }

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

                          setState(() {
                            _isSubmitting = false;
                          });

                          if (result['success'] == true) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã gửi báo cáo thành công!'),
                                  backgroundColor: AppColors.success500,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ?? 'Gửi báo cáo thất bại',
                                  ),
                                  backgroundColor: AppColors.error500,
                                ),
                              );
                            }
                          }
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
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'GỬI BÁO CÁO NGAY',
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
                  'Ghi âm đã lưu',
                  style: TextStyle(
                    color: AppColors.brand500,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPlaying ? 'Đang phát...' : 'Nhấn để nghe',
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

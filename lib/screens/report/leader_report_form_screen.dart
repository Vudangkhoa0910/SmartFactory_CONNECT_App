import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../config/app_colors.dart';

class LeaderReportFormScreen extends StatefulWidget {
  const LeaderReportFormScreen({super.key});

  @override
  State<LeaderReportFormScreen> createState() => _LeaderReportFormScreenState();
}

class _LeaderReportFormScreenState extends State<LeaderReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _componentController = TextEditingController();
  final _productionLineController = TextEditingController();
  final _workStationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _leaderNotesController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedPriority;
  List<String> _selectedCategories = [];

  final List<String> _priorities = ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'];

  final List<String> _categories = [
    'Kỹ thuật',
    'An toàn',
    'Chất lượng',
    'Quy trình',
    'Nhân sự',
    'Khác',
  ];

  // Media attachments
  final List<File> _images = [];
  final List<File> _videos = [];
  String? _audioPath;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;

  // Speech to text
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastRecognizedWords = '';

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _componentController.dispose();
    _productionLineController.dispose();
    _workStationController.dispose();
    _departmentController.dispose();
    _leaderNotesController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Speech to text function
  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);

          String errorMessage = 'Lỗi nhận dạng giọng nói';
          if (error.errorMsg.toLowerCase().contains('not_allowed') ||
              error.errorMsg.toLowerCase().contains('permission')) {
            errorMessage =
                'Vui lòng cấp quyền Speech Recognition trong Settings > Privacy > Speech Recognition';
          } else {
            errorMessage = 'Lỗi: ${error.errorMsg}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error500,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppColors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);

      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _lastRecognizedWords = result.recognizedWords;

              if (result.hasConfidenceRating && result.confidence > 0) {
                final currentText = _descriptionController.text;
                final newText = result.recognizedWords;

                if (result.finalResult) {
                  if (currentText.isEmpty) {
                    _descriptionController.text = newText;
                  } else {
                    _descriptionController.text = '$currentText $newText';
                  }
                  _descriptionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionController.text.length),
                  );
                } else {
                  if (currentText.isEmpty) {
                    _descriptionController.text = newText;
                  } else {
                    _descriptionController.text = '$currentText $newText';
                  }
                  _descriptionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionController.text.length),
                  );
                }
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {},
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: 'vi_VN',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech recognition không khả dụng'),
          backgroundColor: AppColors.error500,
        ),
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  // Camera functions
  Future<void> _takePicture() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } else {
      _showPermissionDialog('Camera');
    }
  }

  Future<void> _pickMedia() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();

      final String? choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Ảnh'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Video'),
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
    } else {
      _showPermissionDialog('Photos/Gallery');
    }
  }

  // Audio recording functions
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _audioPath = path;
          _isRecording = false;
        });
      }
    } else {
      // Start recording
      final status = await Permission.microphone.request();
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
      } else {
        _showPermissionDialog('Microphone');
      }
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quyền truy cập bị từ chối'),
        content: Text(
          'Ứng dụng cần quyền truy cập $permissionType để sử dụng chức năng này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Cài đặt'),
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
            'Báo cáo sự cố Leader',
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
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề sự cố',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
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
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Nhập vị trí hoặc tên thiết bị',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí hoặc thiết bị';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tên linh kiện
              _buildSectionTitle('Tên linh kiện'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _componentController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên linh kiện',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tên dây chuyền
              _buildSectionTitle('Tên dây chuyền'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _productionLineController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên dây chuyền',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Công đoạn
              _buildSectionTitle('Công đoạn'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _workStationController,
                decoration: InputDecoration(
                  hintText: 'Nhập công đoạn',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bộ phận phát hiện
              _buildSectionTitle('Bộ phận phát hiện'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  hintText: 'Nhập bộ phận phát hiện',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
                  ),
                ),
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
              _buildSectionTitle('Phân loại vấn đề'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
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

              // Mô tả chi tiết
              _buildSectionTitle('Mô tả chi tiết'),
              const SizedBox(height: 8),
              Stack(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    style: TextStyle(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết về sự cố...',
                      hintStyle: TextStyle(color: AppColors.gray400),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.gray200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.gray200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.brand500,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(
                        12,
                        12,
                        50,
                        12,
                      ), // Right padding for mic button
                    ),
                  ),
                  // Mic button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onLongPressStart: (_) => _startListening(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.error500
                              : AppColors.error500,
                          shape: BoxShape.circle,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: AppColors.error500.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.mic, size: 16, color: AppColors.error500),
                      const SizedBox(width: 4),
                      Text(
                        'Đang nghe... Thả ra để dừng',
                        style: TextStyle(
                          color: AppColors.error500,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Ghi chú của Leader
              _buildSectionTitle('Ghi chú của Leader'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _leaderNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú của Leader...',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brand500, width: 2),
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
                onPressed: () {
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
                    // TODO: Submit form
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã gửi báo cáo thành công!'),
                        backgroundColor: AppColors.success500,
                      ),
                    );
                    Navigator.pop(context);
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
                child: Text(
                  'GỬI BÁO CÁO LEADER NGAY',
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
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.error500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecording ? AppColors.error50 : AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecording ? AppColors.error500 : AppColors.gray200,
            width: isRecording ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isRecording ? AppColors.error500 : AppColors.gray600,
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
          title,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: icon == Icons.image
                          ? Image.file(files[index], fit: BoxFit.cover)
                          : Icon(icon, color: AppColors.gray600, size: 24),
                    ),
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
                        width: 20,
                        height: 20,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio đã ghi',
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Icon(Icons.audiotrack, color: AppColors.gray600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Audio recording',
                  style: TextStyle(color: AppColors.gray700, fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (_isPlaying) {
                    await _audioPlayer.stop();
                    setState(() => _isPlaying = false);
                  } else {
                    await _audioPlayer.play(DeviceFileSource(_audioPath!));
                    setState(() => _isPlaying = true);
                  }
                },
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.play_arrow,
                  color: AppColors.brand500,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _audioPath = null;
                    _isPlaying = false;
                  });
                },
                icon: Icon(Icons.delete, color: AppColors.error500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

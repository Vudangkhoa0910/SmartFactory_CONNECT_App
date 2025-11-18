import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../config/app_colors.dart';

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
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Speech to text function
  Future<void> _startListening() async {
    // Không xin quyền trước, để speech_to_text tự xử lý
    // Điều này cho phép iOS hiển thị popup quyền đúng cách
    
    // Initialize speech_to_text - nó sẽ tự động request tất cả permissions cần thiết
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
            errorMessage = 'Vui lòng cấp quyền Speech Recognition trong Settings > Privacy > Speech Recognition';
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

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể khởi tạo nhận dạng giọng nói. Vui lòng kiểm tra quyền trong Settings.'),
            backgroundColor: AppColors.error500,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Mở Settings',
              textColor: AppColors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    if (available) {
      // Save current text before listening
      _lastRecognizedWords = _descriptionController.text;
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            // Real-time update: append recognized words to existing text
            if (_lastRecognizedWords.isNotEmpty &&
                !_lastRecognizedWords.endsWith(' ')) {
              _descriptionController.text =
                  '$_lastRecognizedWords ${result.recognizedWords}';
            } else {
              _descriptionController.text =
                  '$_lastRecognizedWords${result.recognizedWords}';
            }
            // Move cursor to end
            _descriptionController.selection = TextSelection.fromPosition(
              TextPosition(offset: _descriptionController.text.length),
            );
          });
        },
        localeId: 'vi_VN', // Vietnamese
        listenMode:
            stt.ListenMode.confirmation, // Get partial and final results
        partialResults: true, // Enable real-time partial results
        listenFor: const Duration(minutes: 1), // Maximum listening duration
        pauseFor: const Duration(seconds: 3), // Pause after silence
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  // Camera functions
  Future<void> _takePicture() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } else {
      _showPermissionDialog('Camera');
    }
  }

  // Gallery functions
  Future<void> _pickMedia() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      final picker = ImagePicker();

      // Show dialog to choose between image or video
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Chọn loại file'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: AppColors.brand500),
                title: Text('Ảnh'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: AppColors.brand500),
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

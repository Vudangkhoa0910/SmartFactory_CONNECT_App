import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../config/app_colors.dart';

/// Reusable text field widget with integrated microphone button
class TextFieldWithMic extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const TextFieldWithMic({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<TextFieldWithMic> createState() => _TextFieldWithMicState();
}

class _TextFieldWithMicState extends State<TextFieldWithMic> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastRecognizedWords = '';

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

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
            errorMessage = 'Vui lòng cấp quyền Speech Recognition trong Settings';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error500,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Settings',
                textColor: AppColors.white,
                onPressed: () => openAppSettings(),
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
            content: const Text('Không thể khởi tạo nhận dạng giọng nói'),
            backgroundColor: AppColors.error500,
            action: SnackBarAction(
              label: 'Settings',
              textColor: AppColors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    _lastRecognizedWords = widget.controller.text;
    setState(() => _isListening = true);
    _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            if (_lastRecognizedWords.isNotEmpty &&
                !_lastRecognizedWords.endsWith(' ')) {
              widget.controller.text =
                  '$_lastRecognizedWords ${result.recognizedWords}';
            } else {
              widget.controller.text =
                  '$_lastRecognizedWords${result.recognizedWords}';
            }
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
          });
        }
      },
      localeId: 'vi_VN',
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _speechToText.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Stack(
            children: [
              TextFormField(
                controller: widget.controller,
                maxLines: widget.maxLines,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                style: TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: widget.hintText,
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
                  contentPadding: EdgeInsets.fromLTRB(
                    12,
                    widget.maxLines > 1 ? 12 : 16,
                    widget.readOnly ? 12 : 56,
                    widget.maxLines > 1 ? 12 : 16,
                  ),
                ),
                validator: widget.validator,
              ),
              if (!widget.readOnly)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onLongPressStart: (_) => _startListening(),
                        onLongPressEnd: (_) => _stopListening(),
                        child: Container(
                          width: 40,
                          height: 40,
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
                  ),
                ),
            ],
          ),
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
      ],
    );
  }
}

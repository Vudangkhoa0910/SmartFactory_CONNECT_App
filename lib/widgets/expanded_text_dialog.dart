import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/toast_utils.dart';

/// Full-screen dialog for expanded text input with microphone support
class ExpandedTextDialog extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;

  const ExpandedTextDialog({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
  });

  @override
  State<ExpandedTextDialog> createState() => _ExpandedTextDialogState();
}

class _ExpandedTextDialogState extends State<ExpandedTextDialog> {
  late TextEditingController _localController;
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastRecognizedWords = '';

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.controller.text);
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
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

          String errorMessage = AppLocalizations.of(
            context,
          )!.voiceRecognitionError;
          if (error.errorMsg.toLowerCase().contains('not_allowed') ||
              error.errorMsg.toLowerCase().contains('permission')) {
            errorMessage = AppLocalizations.of(context)!.microphonePermission;
          }

          ToastUtils.showError(errorMessage);
        }
      },
    );

    if (!available) {
      if (mounted) {
        ToastUtils.showError(
          AppLocalizations.of(context)!.speechRecognitionNotAvailable,
        );
      }
      return;
    }

    _lastRecognizedWords = _localController.text;
    setState(() => _isListening = true);
    _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            if (_lastRecognizedWords.isNotEmpty &&
                !_lastRecognizedWords.endsWith(' ')) {
              _localController.text =
                  '$_lastRecognizedWords ${result.recognizedWords}';
            } else {
              _localController.text =
                  '$_lastRecognizedWords${result.recognizedWords}';
            }
            _localController.selection = TextSelection.fromPosition(
              TextPosition(offset: _localController.text.length),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.gray200, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.gray800),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: AppColors.gray800,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.controller.text = _localController.text;
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.done,
                    style: TextStyle(
                      color: AppColors.brand500,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    children: [
                      if (_isListening)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, size: 20, color: AppColors.white),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.listeningRelease,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: TextField(
                          controller: _localController,
                          maxLines: null,
                          autofocus: true,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                          ),
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
                              borderSide: BorderSide(
                                color: AppColors.brand500,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mic button at bottom center
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onLongPressStart: (_) => _startListening(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.error500
                              : AppColors.error500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isListening
                                          ? AppColors.error500
                                          : AppColors.error500)
                                      .withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: _isListening ? 4 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

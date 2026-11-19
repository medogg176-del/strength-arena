import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'progression_ranks.dart';

enum ChallengeType { pushup, pullup, situp }

class AiRefereeMatchScreen extends StatefulWidget {
  final ChallengeType challengeType;
  final String challengeTitle;
  final Color accentColor;
  final String playerName;
  final bool isAr;

  const AiRefereeMatchScreen({
    super.key,
    required this.challengeType,
    required this.challengeTitle,
    required this.accentColor,
    required this.playerName,
    required this.isAr,
  });

  @override
  State<AiRefereeMatchScreen> createState() => _AiRefereeMatchScreenState();
}

class _AiRefereeMatchScreenState extends State<AiRefereeMatchScreen> {
  List<CameraDescription> _cameras = const [];
  int _selectedCameraIndex = 0;
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  bool _isCameraReady = false;
  String? _cameraError;
  bool _isProcessingFrame = false;

  // مؤقت التحدي: دقيقتين = 120 ثانية
  static const int _totalMatchSeconds = 120;
  int _remainingSeconds = _totalMatchSeconds;
  Timer? _countdownTimer;
  bool _matchFinished = false;
  int _earnedXp = 0;

  // عدّاد اللاعب والخصم
  int _myValidReps = 0;
  int _opponentReps = 0;
  Timer? _opponentSimulationTimer;
  final math.Random _rng = math.Random();

  late String _refereeStatus;
  String? _antiCheatWarning;

  // حالة العدّة ومنع الغش
  bool _inDownPhase = false;
  double _extremeAngleReached = 999;
  DateTime? _downPhaseEnteredAt;
  DateTime? _lastValidRepAt;

  @override
  void initState() {
    super.initState();
    _refereeStatus = widget.isAr
        ? 'استعد أمام الكاميرا... الذكاء الاصطناعي يراقب حركتك'
        : 'Get ready in frame... AI referee is tracking form';
    _initCamera();
    _startMatchTimer();
    _startOpponentActivity();
  }

  Future<void> _initCamera({int? cameraIndex}) async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError =
              widget.isAr ? 'لم يتم العثور على كاميرا' : 'No camera found');
        }
        return;
      }

      if (cameraIndex != null) {
        _selectedCameraIndex = cameraIndex % _cameras.length;
      } else {
        final frontIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontIdx >= 0 ? frontIdx : 0;
      }

      final oldController = _cameraController;
      _cameraController = null;
      if (mounted) setState(() => _isCameraReady = false);
      if (oldController != null) {
        try {
          await oldController.stopImageStream();
        } catch (_) {}
        await oldController.dispose();
      }

      final controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();
      await controller.startImageStream(_processCameraImage);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError =
            widget.isAr ? 'تعذر تشغيل الكاميرا: $e' : 'Camera error: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _matchFinished) return;
    await _initCamera(cameraIndex: _selectedCameraIndex + 1);
  }

  void _startMatchTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _finishMatch();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _startOpponentActivity() {
    _opponentSimulationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_matchFinished || !mounted) return;
      if (_rng.nextDouble() < 0.72) {
        setState(() => _opponentReps++);
      }
    });
  }

  Future<void> _finishMatch() async {
    if (_matchFinished) return;
    _opponentSimulationTimer?.cancel();
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}

    final won = _myValidReps > _opponentReps;
    final draw = _myValidReps == _opponentReps;
    final stats = await ProgressionService.recordMatchResult(
      validReps: _myValidReps,
      wonMatch: won,
      drawMatch: draw,
    );

    if (!mounted) return;
    setState(() {
      _matchFinished = true;
      _earnedXp = stats.gainedXp;
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || _matchFinished) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return;

      _evaluatePose(poses.first);
    } catch (_) {
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  double _angleBetween(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final abX = a.x - b.x;
    final abY = a.y - b.y;
    final cbX = c.x - b.x;
    final cbY = c.y - b.y;

    final dot = (abX * cbX) + (abY * cbY);
    final magAB = math.sqrt((abX * abX) + (abY * abY));
    final magCB = math.sqrt((cbX * cbX) + (cbY * cbY));
    if (magAB == 0 || magCB == 0) return 180;

    final cosVal = (dot / (magAB * magCB)).clamp(-1.0, 1.0);
    return math.acos(cosVal) * (180.0 / math.pi);
  }

  void _evaluatePose(Pose pose) {
    final now = DateTime.now();

    if (_lastValidRepAt != null &&
        now.difference(_lastValidRepAt!).inMilliseconds < 450) {
      _setWarning(
        widget.isAr
            ? 'حركة سريعة جداً — تم منع الغش'
            : 'Too fast — anti-cheat blocked rep',
      );
      return;
    }

    switch (widget.challengeType) {
      case ChallengeType.pushup:
        final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder] ??
            pose.landmarks[PoseLandmarkType.rightShoulder];
        final elbow = pose.landmarks[PoseLandmarkType.leftElbow] ??
            pose.landmarks[PoseLandmarkType.rightElbow];
        final wrist = pose.landmarks[PoseLandmarkType.leftWrist] ??
            pose.landmarks[PoseLandmarkType.rightWrist];
        final hip = pose.landmarks[PoseLandmarkType.leftHip] ??
            pose.landmarks[PoseLandmarkType.rightHip];
        final ankle = pose.landmarks[PoseLandmarkType.leftAnkle] ??
            pose.landmarks[PoseLandmarkType.rightAnkle];

        if (shoulder == null || elbow == null || wrist == null) return;

        if (hip != null && ankle != null) {
          final bodyAngle = _angleBetween(shoulder, hip, ankle);
          if (bodyAngle < 140) {
            _setWarning(
              widget.isAr
                  ? 'حافظ على استقامة الجسم (لا ترفع الحوض)'
                  : 'Keep body aligned (do not pike hips)',
            );
            return;
          }
        }

        final elbowAngle = _angleBetween(shoulder, elbow, wrist);
        if (!_inDownPhase) {
          if (elbowAngle < 95) {
            _inDownPhase = true;
            _extremeAngleReached = elbowAngle;
            _downPhaseEnteredAt = now;
            _setStatus(
              widget.isAr
                  ? 'نزول جيد — اصعد لفرد الذراعين'
                  : 'Good depth — push up to extend',
            );
          }
        } else {
          if (elbowAngle < _extremeAngleReached) {
            _extremeAngleReached = elbowAngle;
          }
          if (elbowAngle > 160) {
            final durationMs = _downPhaseEnteredAt == null
                ? 600
                : now.difference(_downPhaseEnteredAt!).inMilliseconds;
            if (_extremeAngleReached <= 95 && durationMs >= 350) {
              _acceptRep(
                now,
                widget.isAr ? 'عدّة ضغط صحيحة!' : 'Valid push-up rep!',
              );
            } else {
              _setWarning(
                widget.isAr
                    ? 'عدّة غير مكتملة — انزل بعمق أكبر'
                    : 'Incomplete rep — go deeper',
              );
            }
            _resetRepCycle();
          }
        }
        break;

      case ChallengeType.pullup:
        final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder] ??
            pose.landmarks[PoseLandmarkType.rightShoulder];
        final elbow = pose.landmarks[PoseLandmarkType.leftElbow] ??
            pose.landmarks[PoseLandmarkType.rightElbow];
        final wrist = pose.landmarks[PoseLandmarkType.leftWrist] ??
            pose.landmarks[PoseLandmarkType.rightWrist];

        if (shoulder == null || elbow == null || wrist == null) return;

        final elbowAngle = _angleBetween(shoulder, elbow, wrist);
        if (!_inDownPhase) {
          if (elbowAngle > 155) {
            _inDownPhase = true;
            _extremeAngleReached = elbowAngle;
            _downPhaseEnteredAt = now;
            _setStatus(
              widget.isAr
                  ? 'فرد كامل — اسحب للأعلى'
                  : 'Full extension — pull up',
            );
          }
        } else {
          if (elbowAngle < _extremeAngleReached) {
            _extremeAngleReached = elbowAngle;
          }
          if (elbowAngle < 75) {
            final durationMs = _downPhaseEnteredAt == null
                ? 600
                : now.difference(_downPhaseEnteredAt!).inMilliseconds;
            if (durationMs >= 400) {
              _acceptRep(
                now,
                widget.isAr ? 'عدّة عقلة صحيحة!' : 'Valid pull-up rep!',
              );
            } else {
              _setWarning(
                widget.isAr
                    ? 'حركة متأرجحة سريعة — عدّة مرفوضة'
                    : 'Jerky swing — rep rejected',
              );
            }
            _resetRepCycle();
          }
        }
        break;

      case ChallengeType.situp:
        final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder] ??
            pose.landmarks[PoseLandmarkType.rightShoulder];
        final hip = pose.landmarks[PoseLandmarkType.leftHip] ??
            pose.landmarks[PoseLandmarkType.rightHip];
        final knee = pose.landmarks[PoseLandmarkType.leftKnee] ??
            pose.landmarks[PoseLandmarkType.rightKnee];

        if (shoulder == null || hip == null || knee == null) return;

        final torsoAngle = _angleBetween(shoulder, hip, knee);
        if (!_inDownPhase) {
          if (torsoAngle > 125) {
            _inDownPhase = true;
            _extremeAngleReached = torsoAngle;
            _downPhaseEnteredAt = now;
            _setStatus(
              widget.isAr
                  ? 'ارتفع بالجذع نحو الركبتين'
                  : 'Crunch torso toward knees',
            );
          }
        } else {
          if (torsoAngle < _extremeAngleReached) {
            _extremeAngleReached = torsoAngle;
          }
          if (torsoAngle < 75) {
            final durationMs = _downPhaseEnteredAt == null
                ? 600
                : now.difference(_downPhaseEnteredAt!).inMilliseconds;
            if (durationMs >= 350) {
              _acceptRep(
                now,
                widget.isAr ? 'عدّة بطن صحيحة!' : 'Valid sit-up rep!',
              );
            } else {
              _setWarning(
                widget.isAr
                    ? 'عدّة بطن غير مكتملة'
                    : 'Incomplete sit-up rep',
              );
            }
            _resetRepCycle();
          }
        }
        break;
    }
  }

  void _acceptRep(DateTime now, String message) {
    _lastValidRepAt = now;
    if (!mounted) return;
    setState(() {
      _myValidReps++;
      _antiCheatWarning = null;
      _refereeStatus = message;
    });
  }

  void _setStatus(String msg) {
    if (!mounted) return;
    setState(() {
      _refereeStatus = msg;
      _antiCheatWarning = null;
    });
  }

  void _setWarning(String warning) {
    if (!mounted) return;
    setState(() => _antiCheatWarning = warning);
  }

  void _resetRepCycle() {
    _inDownPhase = false;
    _extremeAngleReached = 999;
    _downPhaseEnteredAt = null;
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String get _resultText {
    if (_myValidReps > _opponentReps) {
      return widget.isAr ? 'فزت في التحدي!' : 'YOU WON THE MATCH!';
    }
    if (_myValidReps < _opponentReps) {
      return widget.isAr ? 'الخصم تفوق هذه المرة' : 'OPPONENT TOOK THE WIN';
    }
    return widget.isAr ? 'تعادل قوي!' : 'DRAW MATCH!';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _opponentSimulationTimer?.cancel();
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.challengeTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_cameras.length > 1 && !_matchFinished)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch_rounded),
              tooltip: widget.isAr ? 'تبديل الكاميرا' : 'Switch Camera',
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141821),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.accentColor.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                _formatTimer(_remainingSeconds),
                style: TextStyle(
                  color: widget.accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141821),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.playerName,
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                        Text(
                          '$_myValidReps',
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.isAr ? 'الخصم' : 'OPPONENT',
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                        Text(
                          '$_opponentReps',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF141821),
                    child: _cameraError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _cameraError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          )
                        : (!_isCameraReady || _cameraController == null)
                            ? Center(
                                child: CircularProgressIndicator(color: widget.accentColor),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(_cameraController!),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.65),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.isAr
                                            ? 'تحكيم AI خاص — الفيديو غير مرئي للخصم'
                                            : 'Private AI Referee — Video hidden from opponent',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141821),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _antiCheatWarning != null
                        ? Colors.amber.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _matchFinished ? _resultText : _refereeStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    if (_matchFinished) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.isAr
                            ? '+$_earnedXp XP مضافة لمستواك وترتيبك'
                            : '+$_earnedXp XP added to your level & rank',
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            widget.isAr ? 'العودة للرئيسية' : 'Back to Arena',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ] else if (_antiCheatWarning != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _antiCheatWarning!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        setState(() => _cameraError

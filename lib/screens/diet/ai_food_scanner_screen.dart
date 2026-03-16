// Elevate AI Food Scanner — Uses Gemini Vision to recognize food and estimate nutrition.

import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/api_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'diet_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════════════

const Color _kProteinBlue = Color(0xFF4DA8FF);
const Color _kCarbsGreen = Color(0xFF00E096);
const Color _kFatPurple = Color(0xFFB44DFF);

// ═══════════════════════════════════════════════════════════════════════════
//  STATE ENUM & DETECTED FOOD MODEL
// ═══════════════════════════════════════════════════════════════════════════

enum _ScanState { camera, loading, results, error }

class _DetectedFood {
  final String name;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final double confidence;

  const _DetectedFood({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });

  factory _DetectedFood.fromJson(Map<String, dynamic> json) {
    return _DetectedFood(
      name: json['name'] as String? ?? 'Unknown',
      portion: json['portion'] as String? ?? '1 serving',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  FoodItem toFoodItem() => FoodItem(
        name: name,
        quantity: portion,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  AI FOOD SCANNER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AiFoodScannerScreen extends StatefulWidget {
  final String mealName;
  final int mealIndex;

  const AiFoodScannerScreen({
    super.key,
    required this.mealName,
    required this.mealIndex,
  });

  @override
  State<AiFoodScannerScreen> createState() => _AiFoodScannerScreenState();
}

class _AiFoodScannerScreenState extends State<AiFoodScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  _ScanState _state = _ScanState.camera;
  Uint8List? _capturedImageBytes;
  List<_DetectedFood> _detectedFoods = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _state = _ScanState.error;
          _errorMessage = 'No camera found on this device.';
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ScanState.error;
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();

      setState(() {
        _capturedImageBytes = bytes;
        _state = _ScanState.loading;
      });

      await _analyzeImage(bytes);
    } catch (e) {
      setState(() {
        _state = _ScanState.error;
        _errorMessage = 'Failed to capture image: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _capturedImageBytes = bytes;
      _state = _ScanState.loading;
    });

    await _analyzeImage(bytes);
  }

  Future<void> _analyzeImage(Uint8List bytes) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: ApiKeys.geminiApiKey,
      );

      final prompt = TextPart(
        'Analyze this food image. Identify each food item visible and estimate '
        'its nutritional information. Return ONLY valid JSON (no markdown fences) '
        'as an array of objects with these fields: '
        '"name" (string), "portion" (string like "1 bowl • 150g"), '
        '"calories" (int), "protein" (int grams), "carbs" (int grams), '
        '"fat" (int grams), "confidence" (float 0-1). '
        'If no food is detected, return an empty array [].',
      );

      final imagePart = DataPart('image/jpeg', bytes);
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text ?? '[]';
      // Strip markdown fences if present
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final decoded = jsonDecode(cleaned);
      final List<dynamic> list = decoded is List ? decoded : [];

      if (list.isEmpty) {
        setState(() {
          _state = _ScanState.error;
          _errorMessage = 'No food items detected. Try taking a clearer photo.';
        });
        return;
      }

      setState(() {
        _detectedFoods = list
            .map((e) => _DetectedFood.fromJson(e as Map<String, dynamic>))
            .toList();
        _state = _ScanState.results;
      });
    } on GenerativeAIException catch (e) {
      setState(() {
        _state = _ScanState.error;
        _errorMessage = 'AI analysis failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _state = _ScanState.error;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _retake() {
    setState(() {
      _state = _ScanState.camera;
      _capturedImageBytes = null;
      _detectedFoods = [];
      _errorMessage = '';
    });
  }

  void _addToMeal() {
    final items = _detectedFoods.map((f) => f.toFoodItem()).toList();
    Navigator.of(context).pop(items);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  // ─────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: switch (_state) {
        _ScanState.camera => _buildCameraView(),
        _ScanState.loading => _buildLoadingView(),
        _ScanState.results => _buildResultsView(),
        _ScanState.error => _buildErrorView(),
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  CAMERA VIEW
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview or loading placeholder
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          )
        else
          const Positioned.fill(
            child: Center(
              child: CupertinoActivityIndicator(color: AppColors.accentOrange),
            ),
          ),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Food Scanner',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _toggleFlash,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isFlashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash,
                        color: _isFlashOn ? AppColors.accentGold : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scanning guide frame
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.7), width: 2.5),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.04, duration: 1500.ms, curve: Curves.easeInOut),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Point camera at your food',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _pickFromGallery,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(CupertinoIcons.photo, color: Colors.white, size: 24),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _captureAndAnalyze,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.accentGradient,
                          ),
                        ),
                      ),
                    ),

                    // Flash toggle
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleFlash,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isFlashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash,
                          color: _isFlashOn ? AppColors.accentGold : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  LOADING VIEW
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildLoadingView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Captured image preview
              if (_capturedImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _capturedImageBytes!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 32),
              const CupertinoActivityIndicator(
                radius: 16,
                color: AppColors.accentOrange,
              ),
              const SizedBox(height: 20),
              Text(
                'AI is analyzing your food...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
              const SizedBox(height: 8),
              Text(
                'Detecting ingredients & nutrition',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  RESULTS VIEW
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildResultsView() {
    final totalCal = _detectedFoods.fold(0, (s, f) => s + f.calories);
    final totalP = _detectedFoods.fold(0, (s, f) => s + f.protein);
    final totalC = _detectedFoods.fold(0, (s, f) => s + f.carbs);
    final totalF = _detectedFoods.fold(0, (s, f) => s + f.fat);

    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(CupertinoIcons.back, color: Theme.of(context).colorScheme.onSurface, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Results',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Image thumbnail + badge
                  if (_capturedImageBytes != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _capturedImageBytes!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'AI Detected',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Detected food cards
                  ...List.generate(_detectedFoods.length, (i) {
                    return _DetectedFoodCard(food: _detectedFoods[i])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (i * 100).ms)
                        .slideY(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 12),

                  // Total summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Nutrition',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SummaryItem(value: '$totalCal', label: 'kcal', color: AppColors.accentOrange),
                            _SummaryItem(value: '${totalP}g', label: 'Protein', color: _kProteinBlue),
                            _SummaryItem(value: '${totalC}g', label: 'Carbs', color: _kCarbsGreen),
                            _SummaryItem(value: '${totalF}g', label: 'Fat', color: _kFatPurple),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      // Retake
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _retake,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentOrange),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Retake',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add to meal
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          height: 52,
                          onPressed: _addToMeal,
                          child: Text(
                            'Add to ${widget.mealName}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ERROR VIEW
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildErrorView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 56,
                color: AppColors.accentOrange.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                height: 48,
                onPressed: _retake,
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DETECTED FOOD CARD
// ═══════════════════════════════════════════════════════════════════════════

class _DetectedFoodCard extends StatelessWidget {
  final _DetectedFood food;

  const _DetectedFoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  food.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${food.calories} kcal',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            food.portion,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                'Confidence',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: food.confidence,
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(food.confidence * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Macro pills
          Row(
            children: [
              _MacroPill(label: '${food.protein}g P', color: _kProteinBlue),
              const SizedBox(width: 6),
              _MacroPill(label: '${food.carbs}g C', color: _kCarbsGreen),
              const SizedBox(width: 6),
              _MacroPill(label: '${food.fat}g F', color: _kFatPurple),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

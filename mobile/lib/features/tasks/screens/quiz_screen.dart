import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../providers/task_feed_provider.dart';
import '../../browser/providers/tracking_session_provider.dart';

/// Screen for completing post-video verification quizzes.
class QuizScreen extends ConsumerStatefulWidget {
  final String attemptId;

  const QuizScreen({
    super.key,
    required this.attemptId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<QuizQuestionModel> _questions = const [];
  final Map<String, String> _selectedAnswers = {};
  QuizResultModel? _result;

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  Future<void> _fetchQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(taskRepositoryProvider);
      final questions = await repo.getQuiz(widget.attemptId);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer for all questions.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(taskRepositoryProvider);
      final payload = _selectedAnswers.entries
          .map((e) => {'question_id': e.key, 'selected_answer': e.value})
          .toList();

      final result = await repo.submitQuiz(widget.attemptId, payload);
      setState(() {
        _result = result;
        _isSubmitting = false;
      });

      if (result.passed) {
        // Trigger server completion verification
        await ref
            .read(trackingSessionProvider.notifier)
            .verifyCompletion();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Quiz'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined, color: AppColors.error, size: 48),
              const SizedBox(height: AppConstants.space16),
              Text(
                'Quiz Unavailable',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.space16),
              AppButton(
                text: 'Try Again',
                onPressed: _fetchQuiz,
              ),
            ],
          ),
        ),
      );
    }

    if (_result != null) {
      return _buildResultView(_result!);
    }

    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 54),
              const SizedBox(height: AppConstants.space16),
              Text(
                'No Quiz Required',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                'Your video watch time has already satisfied all verification requirements.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.space24),
              AppButton(
                text: 'Claim Reward',
                onPressed: () async {
                  await ref
                      .read(trackingSessionProvider.notifier)
                      .verifyCompletion();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.tasks,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.space16),
      children: [
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Text(
                  'Answer correctly to confirm authentic engagement and claim your reward coins.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space16),
        ..._questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value;
          return _buildQuestionCard(idx + 1, q);
        }),
        const SizedBox(height: AppConstants.space24),
        AppButton(
          text: _isSubmitting ? 'Submitting Answers...' : 'Submit Quiz',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitQuiz,
        ),
        const SizedBox(height: AppConstants.space32),
      ],
    );
  }

  Widget _buildQuestionCard(int number, QuizQuestionModel question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space8,
                    vertical: AppConstants.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    'Q$number',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (question.sourceTimestampSeconds != null)
                  Text(
                    '~${question.sourceTimestampSeconds}s in video',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.space12),
            Text(
              question.questionText,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            ...question.options.map((option) {
              final isSelected = _selectedAnswers[question.id] == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[question.id] = option;
                    });
                  },
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space16,
                      vertical: AppConstants.space12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.space12),
                        Expanded(
                          child: Text(
                            option,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(QuizResultModel result) {
    final passed = result.passed;
    final trackingState = ref.watch(trackingSessionProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_rounded : Icons.cancel_rounded,
              color: passed ? AppColors.success : AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              passed ? 'Quiz Passed!' : 'Quiz Not Passed',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              passed
                  ? 'Score: ${result.score.toStringAsFixed(0)}% (Required: ${result.passPercentage}%)\nReward verified and granted.'
                  : 'Score: ${result.score.toStringAsFixed(0)}% (Required: ${result.passPercentage}%)\nPlease review the video and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.space24),
            if (passed && trackingState.completionResult != null)
              Container(
                padding: const EdgeInsets.all(AppConstants.space16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: AppConstants.space8),
                    Text(
                      '+${trackingState.completionResult!.rewardCoins} Coins Credited!',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppConstants.space24),
            AppButton(
              text: passed ? 'Back to Earn' : 'Retry Quiz',
              onPressed: () {
                if (passed) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.tasks,
                    (route) => false,
                  );
                } else {
                  setState(() {
                    _result = null;
                    _selectedAnswers.clear();
                  });
                  _fetchQuiz();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

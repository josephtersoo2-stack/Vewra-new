import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_attempt_model.dart';
import 'task_feed_provider.dart';

final taskAttemptsProvider =
    FutureProvider.autoDispose<List<TaskAttemptModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAttempts();
});

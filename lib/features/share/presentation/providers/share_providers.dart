import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/share_review_card_use_case.dart';

final shareReviewCardUseCaseProvider = Provider(
  (ref) => sl<ShareReviewCardUseCase>(),
);

import 'package:share_plus/share_plus.dart';

import '../../../../core/services/image_export_service.dart';
import '../../../feed/domain/entities/review_entity.dart';
import '../../presentation/widgets/review_share_card_widget.dart';

class ShareReviewCardUseCase {
  ShareReviewCardUseCase(this._exportService);

  final ImageExportService _exportService;

  Future<void> call(ReviewEntity review) async {
    final pngBytes = await _exportService.captureWidget(
      ReviewShareCardWidget(review: review),
      pixelRatio: 3,
    );

    final file = XFile.fromData(
      pngBytes,
      mimeType: 'image/png',
      name: 'tulimovie_${review.tmdbMovieId}.png',
    );

    await Share.shareXFiles(
      [file],
      text: '${review.movieTitle} · ${review.groupAverageRating.toStringAsFixed(1)}★ no TuliMovie',
    );
  }
}

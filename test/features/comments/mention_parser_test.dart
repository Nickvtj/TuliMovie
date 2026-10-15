import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/features/comments/domain/utils/mention_parser.dart';

void main() {
  test('extrai menções normalizadas e sem repetição', () {
    final usernames = MentionParser.usernames('Vem ver @Ana e @bia_92, né @ana?');
    expect(usernames, {'ana', 'bia_92'});
  });

  test('ignora @ curto demais e texto sem menção', () {
    expect(MentionParser.usernames('oi @ab, tudo bem?'), isEmpty);
    expect(MentionParser.usernames('sem menção nenhuma'), isEmpty);
  });
}

import '../data/models/dictionary_entry.dart';
import '../data/repository/dictionary_repository.dart';

class DictionaryController {
  final DictionaryRepository _repository = DictionaryRepository();

  Future<void> initDictionary() {
    return _repository.seedIfNeeded();
  }

  Future<List<DictionaryEntry>> search(String query) {
    return _repository.searchWords(query);
  }
}

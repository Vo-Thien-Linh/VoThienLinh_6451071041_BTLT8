import '../models/dictionary_entry.dart';
import '../services/dictionary_database_service.dart';

class DictionaryRepository {
  Future<void> seedIfNeeded() async {
    final db = await DictionaryDatabaseService.database;
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM dictionary',
    );
    final count = (countResult.first['count'] as int?) ?? 0;

    if (count == 0) {
      await DictionaryDatabaseService.seedFromJson(db);
    }
  }

  Future<List<DictionaryEntry>> searchWords(String query) async {
    final db = await DictionaryDatabaseService.database;
    final normalizedQuery = query.trim().toLowerCase();

    final result = normalizedQuery.isEmpty
        ? await db.query('dictionary', orderBy: 'word ASC', limit: 30)
        : await db.query(
            'dictionary',
            where: 'LOWER(word) LIKE ?',
            whereArgs: ['%$normalizedQuery%'],
            orderBy: 'word ASC',
          );

    return result.map(DictionaryEntry.fromMap).toList();
  }
}

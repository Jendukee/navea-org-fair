import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Sanity (hosted headless CMS), HTTP Query API with GROQ.
///
/// Schema type in your Studio: name 'fairEvent', fields title (string),
/// orgId (string), startsAt (datetime), venue (string),
/// description (text), cancelled (boolean).
///
/// Sanity answers:
/// { "query": "*[_type == ...]",
///   "result": [ { "_id": "4f1c...", "title": "Hour of Code", "orgId": "csc",
///                 "startsAt": "2026-11-08T05:00:00.000Z",
///                 "venue": "CICT Lab 2", "description": null,
///                 "cancelled": null } ],
///   "ms": 4 }
/// The projection {...} asks for exactly these fields; a field that was
/// never filled in comes back as null.
class SanityEventSource implements EventSource {
  SanityEventSource(
    this.client, {
    required this.projectId,
    this.dataset = 'production',
    this.token = '',
  });

  final http.Client client;
  final String projectId;
  final String dataset;

  /// Empty when the dataset is public.
  final String token;

  /// The query, in GROQ: all fairEvent documents, oldest first,
  /// with only the fields the app needs.
  static const query =
      '*[_type == "fairEvent"] | order(startsAt asc) '
      '{_id, title, orgId, startsAt, venue, description, cancelled}';

  @override
  String get name => 'Sanity';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.https(
      '$projectId.apicdn.sanity.io',
      '/v2025-02-19/data/query/$dataset',
      {'query': query},
    );
    final headers = {if (token.isNotEmpty) 'Authorization': 'Bearer $token'};
    // EXPLAIN E3: Open one of the other two CMS files and compare. Which
    // lines differ, and which are the same? Why is the parsing the part
    // that changes most from one CMS to another?
    final json = await getJson(client, uri, cms: name, headers: headers);

    final items = (json as Map<String, dynamic>)['result'] as List<dynamic>;
    return [
      for (final item in items.cast<Map<String, dynamic>>())
        FairEvent(
          id: item['_id'] as String,
          orgId: item['orgId'] as String,
          title: item['title'] as String,
          startsAt: DateTime.parse(item['startsAt'] as String),
          venue: item['venue'] as String,
          description: item['description'] as String? ?? '',
          cancelled: item['cancelled'] as bool? ?? false,
        ),
    ];
  }
}

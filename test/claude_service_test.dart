import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:whetstone/models/sharpened_prompt.dart';
import 'package:whetstone/services/claude_service.dart';

// Builds one "data:" line the way the API sends it.
String event(Map<String, dynamic> data) => 'event: ${data['type']}\ndata: ${jsonEncode(data)}\n\n';

String textDelta(String text) => event({
  'type': 'content_block_delta',
  'index': 0,
  'delta': {'type': 'text_delta', 'text': text},
});

ClaudeService serviceReturning(String body, {int status = 200, void Function(http.BaseRequest)? onRequest}) {
  final client = MockClient.streaming((request, bodyStream) async {
    onRequest?.call(request);
    return http.StreamedResponse(Stream.value(utf8.encode(body)), status);
  });
  return ClaudeService(client: client);
}

Stream<String> run(ClaudeService service) {
  return service.sharpen(apiKey: 'test-key', rough: 'explain recursion', focus: SharpenFocus.clear);
}

void main() {
  test('joins the text pieces from the stream', () async {
    final body = [
      event({'type': 'message_start', 'message': {}}),
      textDelta('You are '),
      textDelta('a teacher.'),
      event({'type': 'message_stop'}),
    ].join();

    final pieces = await run(serviceReturning(body)).toList();
    expect(pieces.join(), 'You are a teacher.');
  });

  test('ignores thinking blocks', () async {
    final body = [
      event({
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'thinking_delta', 'thinking': 'hmm'},
      }),
      textDelta('Answer'),
    ].join();

    expect((await run(serviceReturning(body)).toList()).join(), 'Answer');
  });

  test('sends the key, the model and the rough prompt', () async {
    late http.Request sent;
    final service = serviceReturning('', onRequest: (request) => sent = request as http.Request);
    await run(service).toList();

    expect(sent.headers['x-api-key'], 'test-key');
    final json = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(json['model'], 'claude-opus-5-5');
    expect(json['stream'], true);
    expect(jsonEncode(json['messages']), contains('explain recursion'));
  });

  test('a 401 gives a clear message about the key', () async {
    final service = serviceReturning('{"type":"error"}', status: 401);
    expect(
      run(service).toList(),
      throwsA(isA<ClaudeException>().having((e) => e.message, 'message', contains('API key'))),
    );
  });

  test('a refusal stop reason becomes an error', () async {
    final body = event({
      'type': 'message_delta',
      'delta': {'stop_reason': 'refusal'},
    });
    expect(run(serviceReturning(body)).toList(), throwsA(isA<ClaudeException>()));
  });

  test('an error event in the stream becomes an error', () async {
    final body = event({
      'type': 'error',
      'error': {'type': 'overloaded_error', 'message': 'Overloaded'},
    });
    expect(
      run(serviceReturning(body)).toList(),
      throwsA(isA<ClaudeException>().having((e) => e.message, 'message', contains('Overloaded'))),
    );
  });

  test('a network failure becomes a friendly error', () async {
    final client = MockClient.streaming((_, _) async => throw http.ClientException('no internet'));
    expect(run(ClaudeService(client: client)).toList(), throwsA(isA<ClaudeException>()));
  });
}

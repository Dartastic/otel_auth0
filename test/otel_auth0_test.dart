// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_auth0/otel_auth0.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_auth0-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span span) {
    return {for (final a in span.attributes.toList()) a.key: a.value};
  }

  test('emits CLIENT span with auth0.* attrs', () async {
    await tracedAuth0<String>(
      operation: 'login',
      connection: 'Username-Password-Authentication',
      audience: 'https://api.example.com',
      scope: 'openid profile',
      clientId: 'CLIENT_X',
      domain: 'example.us.auth0.com',
      invoke: () async => 'token-123',
      onSuccessUserId: (_) => 'auth0|user-42',
    );
    final span = spans.findSpanByName('auth0 login');
    expect(span, isNotNull);
    expect(span!.kind, SpanKind.client);
    final a = attrsOf(span);
    expect(a['auth0.operation'], 'login');
    expect(a['auth0.connection'], 'Username-Password-Authentication');
    expect(a['auth0.audience'], 'https://api.example.com');
    expect(a['auth0.scope'], 'openid profile');
    expect(a['auth0.client_id'], 'CLIENT_X');
    expect(a['auth0.domain'], 'example.us.auth0.com');
    expect(a['user.id'], 'auth0|user-42');
  });

  test('records exception on throw', () async {
    await expectLater(
      tracedAuth0<String>(
        operation: 'login',
        invoke: () async => throw StateError('invalid_password'),
      ),
      throwsA(isA<StateError>()),
    );
    final span = spans.findSpanByName('auth0 login');
    expect(span!.status, SpanStatusCode.Error);
    expect(attrsOf(span)['error.type'], 'StateError');
  });

  test('logout / signup get distinct spans', () async {
    await tracedAuth0<String>(
      operation: 'signup',
      invoke: () async => 'ok',
    );
    await tracedAuth0<String>(
      operation: 'logout',
      invoke: () async => 'ok',
    );
    expect(spans.findSpanByName('auth0 signup'), isNotNull);
    expect(spans.findSpanByName('auth0 logout'), isNotNull);
  });

  test('suppression skips span', () async {
    await runWithoutAuth0InstrumentationAsync(() async {
      await tracedAuth0<String>(
        operation: 'login',
        invoke: () async => 'ok',
      );
    });
    expect(spans.findSpansStartingWith('auth0 '), isEmpty);
  });
}

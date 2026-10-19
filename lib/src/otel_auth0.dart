// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'auth0_semantics.dart';
import 'otel_auth0_suppression.dart';

const _tracerName = 'dartastic_otel_libs_auth0';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

/// Wraps an Auth0 Authentication API call in a CLIENT span.
///
/// Works with `package:auth0_flutter` and any Auth0 client — pass
/// your call inside [invoke]. Span name `auth0 <operation>` (e.g.
/// `auth0 login`).
///
/// ```dart
/// final creds = await tracedAuth0<Credentials>(
///   operation: 'login',
///   connection: 'Username-Password-Authentication',
///   audience: 'https://api.example.com',
///   scope: 'openid profile email',
///   invoke: () => auth0.api.login(
///     usernameOrEmail: email,
///     password: password,
///     connectionOrRealm: 'Username-Password-Authentication',
///   ),
/// );
/// ```
///
/// On success, optionally pass the resolved user id back via
/// [onSuccessUserId] so it's recorded as `user.id` on the span.
Future<T> tracedAuth0<T>({
  required String operation,
  required Future<T> Function() invoke,
  String? connection,
  String? audience,
  String? scope,
  String? clientId,
  String? domain,
  String? Function(T)? onSuccessUserId,
}) async {
  if (auth0InstrumentationSuppressed()) return invoke();

  final m = <String, Object>{
    Auth0BridgeSemantics.operation.key: operation,
  };
  if (connection != null) m[Auth0BridgeSemantics.connection.key] = connection;
  if (audience != null) m[Auth0BridgeSemantics.audience.key] = audience;
  if (scope != null) m[Auth0BridgeSemantics.scope.key] = scope;
  if (clientId != null) m[Auth0BridgeSemantics.clientId.key] = clientId;
  if (domain != null) m[Auth0BridgeSemantics.domain.key] = domain;

  final span = _tracer().startSpan(
    'auth0 $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final result = await invoke();
    final userId = onSuccessUserId?.call(result);
    if (userId != null) {
      span.addAttributes(OTelAPI.attributes([
        OTelAPI.attributeString(User.userId.key, userId),
      ]));
    }
    return result;
  } catch (e, st) {
    span.addAttributes(
      OTelAPI.attributes([
        OTelAPI.attributeString(
          ErrorAttributes.errorType.key,
          e.runtimeType.toString(),
        ),
      ]),
    );
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

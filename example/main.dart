// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_auth0/otel_auth0.dart';

/// Traces Auth0 Authentication calls with OpenTelemetry.
///
/// `otel_auth0` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Auth0 Authentication call in
/// [tracedAuth0]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'auth0-example');

  // Wraps an Auth0 Authentication API call in a CLIENT span.
  final auth0Id = await tracedAuth0<String>(
    operation: 'user.id',
    connection: 'example',
    audience: 'example',
    scope: 'example',
    clientId: 'client_8f3a2c',
    domain: 'example',
    invoke: () async {
      // Make the Auth0 Authentication call here, then report what it returned.
      return 'auth0_8f3a2c';
    },
  );
  OTelLog.info('tracedAuth0 user.id returned $auth0Id');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAuth0InstrumentationAsync.
  await runWithoutAuth0InstrumentationAsync(
    () => tracedAuth0<String>(
      operation: 'user.id',
      connection: 'example',
      audience: 'example',
      scope: 'example',
      clientId: 'client_8f3a2c',
      domain: 'example',
      invoke: () async {
        return 'auth0_8f3a2c';
      },
    ),
  );

  await OTel.shutdown();
}

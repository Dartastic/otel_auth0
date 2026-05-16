// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

/// OpenTelemetry instrumentation for Auth0 Authentication API calls.
///
/// Single helper `tracedAuth0(...)` wraps any Auth0 operation
/// (`login`, `logout`, `signup`, `refreshToken`, ...) in a CLIENT
/// span carrying `auth0.*` attributes plus optional `user.id`.
library;

export 'src/auth0_semantics.dart';
export 'src/otel_auth0.dart';
export 'src/otel_auth0_suppression.dart';

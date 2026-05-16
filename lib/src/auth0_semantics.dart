// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

/// Attribute keys for the Auth0 → OTel bridge.
///
/// Auth0 is universal identity infrastructure; user identity uses
/// the OTel `user.*` semconv directly. The `auth0.*` keys below
/// cover Auth0-specific concepts (operation type, connection,
/// audience).
enum Auth0BridgeSemantics implements OTelSemantic {
  /// `auth0.operation` — `login`, `logout`, `signup`, `refreshToken`,
  /// `passwordlessStart`, `passwordlessLogin`, `userInfo`, etc.
  operation('auth0.operation'),

  /// `auth0.connection` — Auth0 connection name (`Username-Password
  /// -Authentication`, `google-oauth2`, `apple`, custom).
  connection('auth0.connection'),

  /// `auth0.audience` — token audience (API identifier).
  audience('auth0.audience'),

  /// `auth0.scope` — space-joined OAuth scopes.
  scope('auth0.scope'),

  /// `auth0.client_id` — Auth0 application client_id.
  clientId('auth0.client_id'),

  /// `auth0.domain` — Auth0 tenant domain (`example.auth0.com`,
  /// `example.us.auth0.com`).
  domain('auth0.domain');

  const Auth0BridgeSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web implementation — posts a `{type: 'logout'}` message to the
/// patient-portal service worker (which then wipes its Cache + claims
/// all tabs) and removes any `portal:` / `auth:` prefixed keys from
/// localStorage / sessionStorage.
///
/// Direct browser-Cache wipe is the service worker's job (see
/// `web/sw.js` — `activate` and `message:logout` handlers). The
/// Firebase Hosting `Cache-Control: no-store` headers on `/portal/**`
/// are the third layer of defence.
Future<void> purgePortalCaches() async {
  try {
    final sw = html.window.navigator.serviceWorker;
    sw?.controller?.postMessage(<String, dynamic>{'type': 'logout'});
  } catch (_) {
    // SW absent / unreachable — headers + storage purge below still apply.
  }

  try {
    final local = html.window.localStorage;
    local.removeWhere(
      (k, _) => k.startsWith('portal:') || k.startsWith('auth:'),
    );
  } catch (_) {}
  try {
    final session = html.window.sessionStorage;
    session.removeWhere(
      (k, _) => k.startsWith('portal:') || k.startsWith('auth:'),
    );
  } catch (_) {}
}

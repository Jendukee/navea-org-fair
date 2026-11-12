# CICT Org Fair App Part 4

**Live Web App:** https://jendukee.github.io/navea-org-fair/

Flutter web and Android application for the CICT Org Fair, powered by Contentful CMS and automated with GitHub Actions.

## Code explanation answers

### E1: Switching CMS providers

The screens depend only on the `EventSource` interface and the shared `FairEvent` model. To switch CMS providers, add or select another `EventSource` implementation in the app configuration. The CMS-specific URL, query, authentication, and JSON parsing change; the screens, repository, and shared event model stay the same.

### E2: CMS tokens in client apps

Values passed with `--dart-define` are compiled into the app. A user can inspect a web bundle or an installed app, so a token included this way is not secret. Use only a public, read-only delivery token (or no token if the CMS allows public reads); never include a write-capable or administrative token.

### E3: CMS adapter differences

The adapters share the `EventSource` interface, `getJson` HTTP/error handling, and conversion to `FairEvent`. Their request URLs, query formats, and response parsing differ:

- Strapi returns events in `data`, with fields directly on each item.
- Contentful returns `items`, with fields nested under `fields` and IDs under `sys`.
- Sanity runs a GROQ query and returns events in `result`, using `_id` for IDs.

Parsing changes most because each CMS returns a different JSON shape; the app maps each shape into the same `FairEvent` fields.

### E4: HTTP errors

- **401/403:** The request has invalid credentials or insufficient read permission. The developer or CMS administrator must fix the token or permissions.
- **404:** The requested endpoint or content type was not found. The developer should check the URL and query; the CMS administrator may need to create or publish the expected content type.
- **500 or higher:** The CMS server failed. The CMS operator must resolve the service problem; the user can retry later.

### E5: Offline copy

Showing the last successful event list with an offline banner is a feature: it keeps useful information visible during a temporary connection loss. The copy is only in memory. Closing the app discards it, so reopening without internet cannot use that copy and the app shows a connection error.

### E6: Loading requests and widget builds

The screen creates one load future in `initState`, then creates another only when the user refreshes. If `repository.load()` were called inside `build`, every build would create a new future and start another request. Flutter can rebuild a widget many times, so the request count would be unpredictable and could repeatedly reload the CMS. Keeping the future in state avoids that.

### E7: Refresh indicator

`RefreshIndicator` hides its spinner when the future from `onRefresh` completes. If `_refresh` returned before the CMS request finished, the spinner would disappear immediately while the old events were still shown. Awaiting the request keeps the spinner visible until refresh finishes.

### E8: UTC timestamps and local time

The `Z` suffix means the timestamp is in UTC. `2026-11-08T05:00:00.000Z` is 5:00 AM UTC, which is 1:00 PM in Iloilo (UTC+8). Calling `toLocal()` converts it to the phone's time zone before formatting; without it, a student in Iloilo would see a time eight hours too early.
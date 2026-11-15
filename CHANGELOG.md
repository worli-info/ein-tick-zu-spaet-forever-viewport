# Changelog

## 0.3.0 — Unreleased

- German settings, help and messages on deDE; English fallback for all other locales.
- English Current / New built-in profile labels and `/fvp current` / `/fvp new` aliases.
- English and German inset, toggle, background, help, reset and profile-management commands work in every locale.
- Existing SavedVariables keys, custom profiles and active settings remain unchanged across locale switches.
- API-mock regression tests for eight locales, bilingual commands and combat deferral. Live visual verification is still pending.

## 0.2.0 — Initial release — 2026-11-11

- Real WorldFrame insets for WoW Forever (Interface 16001).
- Optional black backgrounds for reserved screen edges.
- Built-in Aktuell (full view) and Neu (bottom inset) profiles.
- Settings window and slash commands: /fvp and /viewport.
- Custom account-wide profiles and configurable four-edge insets.
- Deferred viewport application while in combat.
- Event handlers for loading, cinematics and display/UI-scale changes.
- In-game verified: settings window, built-in profile switching, UI reload
  and profile persistence. Other event paths still require live testing.

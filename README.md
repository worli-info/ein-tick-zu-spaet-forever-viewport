# Ein Tick zu spät – Forever Viewport

A small **WoW Forever** addon that resizes the actual 3D viewport rather than
covering part of it with a panel. The camera and character remain centered in
the remaining game world. Author: **olqs**. License: **MIT**.

## English quick start

- Supported client: **WoW Forever 1.60.1, Interface 16001**.
- Extract the release ZIP into `_forever_/Interface/AddOns/`.
- The resulting path must be
  `Interface/AddOns/EinTickZuSpaetForeverViewport/EinTickZuSpaetForeverViewport.toc`.
- Restart WoW after installing the addon for the first time.
- Open settings with `/fvp`.
- `/fvp current` restores the full viewport; `/fvp new` enables the bottom inset.
- The default profile is **New**, reserving **145 UI units** at the bottom.
- Adjust top, bottom, left and right insets independently (0–500 UI units).
- Settings and named profiles are shared account-wide.
- UI elements from other addons are **not** moved or reprofiled automatically.
- No external addon dependencies are required.

### Languages and commands (0.3.0)

The settings window, help and chat messages are **German on deDE clients** and
**English on every other client language**. The addon name is unchanged.
Both English and German commands work in every language:

| English | German | Action |
|---|---|---|
| `/fvp current` | `/fvp aktuell` | Restore full view |
| `/fvp new` | `/fvp neu` | Activate inset profile |
| `/fvp top 20` | `/fvp oben 20` | Set top inset |
| `/fvp bottom 145` | `/fvp unten 145` | Set bottom inset |
| `/fvp left 0` | `/fvp links 0` | Set left inset |
| `/fvp right 0` | `/fvp rechts 0` | Set right inset |
| `/fvp on` / `/fvp off` | `/fvp an` / `/fvp aus` | Enable / disable viewport |
| `/fvp background on` | `/fvp hintergrund an` | Enable background (`off` / `aus` disables it) |
| `/fvp profile list` | `/fvp profil liste` | List profiles |
| `/fvp profile use Raid` | `/fvp profil verwenden Raid` | Activate a profile |
| `/fvp profile save Raid` | `/fvp profil speichern Raid` | Save current settings as a profile |
| `/fvp profile delete Raid` | `/fvp profil löschen Raid` | Delete a custom profile (`loeschen` also works) |
| `/fvp reset` | `/fvp zurücksetzen` | Reset active profile (`zuruecksetzen` also works) |
| `/fvp help` | `/fvp hilfe` | Show help |

`/fvp status` works in both languages. `/fvp reload` and the existing
`/fvp apply` alias reload the UI. Profile names containing spaces are not supported.

Built-in profiles are displayed as **Current / New** in English and
**Aktuell / Neu** in German. Existing SavedVariables keys and custom profile
names are not translated or renamed. Changing the client language preserves
settings and the selected profile. `profile use current|new` also resolves the
built-in aliases, unless a custom profile already has that exact name; direct
`/fvp current` and `/fvp new` always select the built-ins.

### Testing status and limitations

Version **0.2.0** is the initial public release. Opening settings, switching the two built-in
profiles and preserving settings across `/reload` have been tested in the live
Forever client. Combat, cinematics, resolution changes and a full relog have
not yet been verified in-game. Combat changes are designed to be deferred
until combat ends, but this still needs live testing.

The **0.3.0** localization changes have API-mock regression tests for German,
English and the English fallback in other locales, bilingual commands,
profile preservation and combat deferral. These changes still need visual
verification in the live client. Run them with `lua tests/test-localization.lua .`.

Do not combine it with another addon that also resizes `WorldFrame`.
Insets are UI units, not physical display pixels; UI scale affects their size.
The initial layout does not reposition chat, action bars, minimap or meters.
Use `/fvp current` to recover the full view or disable the addon from character
selection. Report bugs through the repository's Issues page with client build,
UI scale, reproduction steps and any BugSack error. Remove private chat/account
details from screenshots before uploading them.

## Deutsche Anleitung

Ein kleines Addon für **WoW Forever**, das den echten `WorldFrame` verkleinert.
Die Spielfigur wird dadurch im verbleibenden 3D-Bereich zentriert, statt dass ein
schwarzes Panel lediglich einen Teil des Bildes verdeckt.

## Installation

Den kompletten Ordner `EinTickZuSpaetForeverViewport` nach folgendem Pfad kopieren:

```text
World of Warcraft/_forever_/Interface/AddOns/EinTickZuSpaetForeverViewport
```

Danach WoW vollständig neu starten. Im Addon-Menü muss **Ein Tick zu
spät – Forever Viewport** aktiviert sein.

## Profile und Bedienung

Das Addon enthält zwei Profile:

- **Aktuell** stellt den vollen Spielbereich wieder her.
- **Neu** reserviert unten 145 UI-Einheiten für das neue Interface.

`/fvp` öffnet das Einstellungsfenster. Dort lassen sich das Profil wechseln,
alle vier Ränder einstellen und der schwarze Hintergrund ein- oder ausschalten.
Der Wechsel wird außerhalb des Kampfes sofort angewendet.

Ab Version **0.3.0** ist die Oberfläche bei deutscher Spielsprache deutsch,
ansonsten englisch. Deutsche und englische Befehle funktionieren unabhängig
von der Spielsprache. Zum Beispiel entsprechen `/fvp current` und `/fvp new`
den bisherigen Befehlen `/fvp aktuell` und `/fvp neu`. Die vollständige Tabelle
steht oben. Bestehende Profile und Einstellungen bleiben beim Sprachwechsel erhalten.

```text
/fvp
/fvp aktuell
/fvp neu
/fvp status
/fvp 145
/fvp bottom 145
/fvp top 0
/fvp left 0
/fvp right 0
/fvp background on
/fvp off
/fvp on
/fvp reset
/fvp reload
```

Eigene Profile sind ebenfalls möglich:

```text
/fvp profile list
/fvp profile save MeinProfil
/fvp profile use MeinProfil
/fvp profile delete MeinProfil
```

Während eines Kampfes wird ein Wechsel vorgemerkt und danach angewendet. Falls
ein anderes Addon den `WorldFrame` verändert, kann `/reload` nötig sein.

## Notfall-Reset

Falls der sichtbare Bereich durch eine falsche Einstellung zu klein geworden
ist, im Chat eingeben:

```text
/fvp aktuell
```

Alternativ das Addon in der Charakterauswahl deaktivieren.

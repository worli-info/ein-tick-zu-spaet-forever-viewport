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
- `/fvp aktuell` restores the full viewport; `/fvp neu` enables the bottom inset.
- The default profile is **Neu**, reserving **145 UI units** at the bottom.
- Adjust top, bottom, left and right insets independently (0–500 UI units).
- Settings and named profiles are shared account-wide.
- UI elements from other addons are **not** moved or reprofiled automatically.
- No external addon dependencies are required.

### Beta status and limitations

Version **0.2.0** is a public beta. Opening settings, switching the two built-in
profiles and preserving settings across `/reload` have been tested in the live
Forever client. Combat, cinematics, resolution changes and a full relog have
not yet been verified in-game. Combat changes are designed to be deferred
until combat ends, but this still needs live testing.

Do not combine it with another addon that also resizes `WorldFrame`.
Insets are UI units, not physical display pixels; UI scale affects their size.
The initial layout does not reposition chat, action bars, minimap or meters.
Use `/fvp aktuell` to recover the full view or disable the addon from character
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

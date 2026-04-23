# Audio Assets — Download & Drop-In Guide

This folder contains all music, SFX, and ambient sounds used by `AudioManager`
(`res://Tools/AudioManager/AudioManager.gd`). Pixabay blocks bots, so files
must be downloaded **manually** through a browser. Once dropped into the right
folder with the right name, the game wires them up automatically — no code
changes needed.

> Missing a file? **Nothing breaks.** `AudioManager` silently skips any audio
> key whose file isn't found, so you can ship the game and add audio
> incrementally.

---

## How to add a file

1. Open the link below in your browser.
2. Click **Free Download** on Pixabay (MP3 format is fine).
3. Rename the downloaded file to the **target filename** in the table.
4. Drop it into the indicated folder under `Audio/`.
5. Re-open the project in Godot — the importer picks it up automatically.

Supported extensions (any one is fine, AudioManager auto-detects):
`.mp3`, `.ogg`, `.wav`.

---

## 1. Music (background loops)

Folder: `Audio/Music/`

| Target filename       | Used for                | Suggested track (Pixabay) |
|-----------------------|-------------------------|---------------------------|
| `bgm_main_menu.mp3`   | Main menu BGM           | [Flaing Piano (loop)](https://pixabay.com/music/solo-piano-flaing-piano-loop-8782/) |
| `bgm_gameplay_loop.mp3` | In-game BGM           | [Corporate Background Loop - Positive Flow](https://pixabay.com/music/upbeat-corporate-background-loop-positive-flow-259733/) |
| `bgm_relaxed.mp3`     | Backup / quiet moments  | Pick anything mellow from [background loop search](https://pixabay.com/music/search/background%20loop/) |

These two tracks were shortlisted by the team (Priyanka & Will).

---

## 2. SFX (one-shot, on-demand)

Folder: `Audio/SFX/`

Per the GitHub issue, on-demand SFX should be **0.5 – 1 second**.

| Target filename        | Trigger                                                                 | Suggested Pixabay search |
|------------------------|-------------------------------------------------------------------------|--------------------------|
| `paper_rustle.mp3`     | Open/close Kanban (Backlog), main menu button presses, back button     | [paper rustle](https://pixabay.com/sound-effects/search/paper-rustle/) |
| `pc_click.mp3`         | PC power, PC sub-window buttons (Upgrades / Hiring / Project / etc.)   | [mouse click](https://pixabay.com/sound-effects/search/mouse-click/) / [computer click](https://pixabay.com/sound-effects/search/computer-click/) |
| `cash_register.mp3`    | Successful purchase (Hire, Upgrade, Office tier)                       | [cash register](https://pixabay.com/sound-effects/search/cash-register/) / [cha-ching](https://pixabay.com/sound-effects/search/cha-ching/) |
| `buzzer_error.mp3`     | Insufficient funds / blocked purchase                                  | [buzzer](https://pixabay.com/sound-effects/search/buzzer/) / [error buzzer](https://pixabay.com/sound-effects/search/error-buzzer/) |
| `worker_sigh.mp3`      | A worker's stamina just hit zero                                       | [sigh](https://pixabay.com/sound-effects/search/sigh/) |

---

## 3. Ambient (random / contextual loops)

Folder: `Audio/Ambient/`

Per the GitHub issue, ambient clips should be **1.5 – 3 seconds** each
(`gibberish_chat` is the only one that loops continuously while two workers
rest at the same time).

| Target filename         | Plays when…                                                  | Suggested Pixabay search |
|-------------------------|--------------------------------------------------------------|--------------------------|
| `coffee_brew.mp3`       | Random — every 45–120 s while in level                       | [coffee machine](https://pixabay.com/sound-effects/search/coffee-machine/) / [espresso](https://pixabay.com/sound-effects/search/espresso/) |
| `keyboard_typing.mp3`   | Random — every 8–25 s while in level                         | [keyboard typing](https://pixabay.com/sound-effects/search/keyboard-typing/) |
| `gibberish_chat.mp3`    | Loops while **2 or more workers** are resting simultaneously | [gibberish](https://pixabay.com/sound-effects/search/gibberish/) / [office chatter](https://pixabay.com/sound-effects/search/office-chatter/) |

The random intervals can be tuned in
`Tools/AudioManager/AudioManager.gd` via
`COFFEE_INTERVAL_RANGE` and `KEYBOARD_INTERVAL_RANGE`.

---

## 4. Volume / mixing

Defaults live as `@export` vars on `AudioManager` (visible in the autoload
inspector):

| Variable          | Default | Notes                          |
|-------------------|---------|--------------------------------|
| `master_volume`   | 1.0     | Multiplied with the others     |
| `music_volume`    | 0.55    | BGM is intentionally quieter   |
| `sfx_volume`      | 1.0     | One-shot SFX                   |
| `ambient_volume`  | 0.45    | Coffee / keyboard / gibberish  |

You can tweak these from code at runtime, e.g. in a settings menu:

```gdscript
AudioManager.master_volume = settings_slider.value
```

---

## 5. Adding a new sound

1. Pick a **new logical key**, e.g. `"phone_ring"`.
2. Add it to one of the three dictionaries
   (`MUSIC_FILES`, `SFX_FILES`, `AMBIENT_FILES`) in `AudioManager.gd`.
3. (Optional) If it should loop, add it to `LOOP_KEYS`.
4. Drop the audio file into the matching folder using the configured filename.
5. Call `AudioManager.play_sfx("phone_ring")` from anywhere in the codebase.

---

## 6. License reminder

Pixabay audio is royalty-free under the
[Pixabay Content License](https://pixabay.com/service/license-summary/). No
attribution is required for use in this game, but consider crediting the
artists in the in-game credits screen anyway — it's good practice and free.

# Codex Prompt Cookbook

This short guide collects example prompts for generating Teatro assets with Codex.

## Example: Two-Scene Storyboard

Use this prompt to create a minimal `Storyboard` consisting of two scenes with a crossfade:

```
Storyboard {
    Scene "Intro" {
        frames 30
    }
    Scene "End" {
        frames 30
    }
    Transition crossfade from 30 to 60
}
```

## Example: MIDI Sequence for `TeatroPlayerView`

A matching prompt to produce a `MIDISequence` that drives `TeatroPlayerView`:

```
MIDISequence {
    tempo 120
    track "main" {
        note C4 duration 30
        note D4 duration 30
    }
}
```

### Automating via the Dispatcher

Prompts like these can be stored alongside your project and fed into the dispatcher. The loop then renders the storyboard and MIDI output automatically during each build cycle.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

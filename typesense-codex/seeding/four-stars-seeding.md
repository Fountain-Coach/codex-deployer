# Seeding the "Four Stars" Text Corpus

This file summarizes the analysis and recommendations for importing `the-four-stars.txt` into Typesense.

## Source Overview

- Location: `repos/typesense-codex/the-four-stars.txt`
- Size: roughly 231k lines (about 1.4 million words)
- Content: complete works of Shakespeare
- Structure: each play begins with its title followed by act and scene markers using four asterisks.

Example:

```
As You Like It
**** ACT I ****
**** SCENE I. Orchard of Oliver's house. ****
     Enter ORLANDO and ADAM
ORLANDO
     As I remember, Adam, it was upon this fashion
```

## Suggested Import Strategy

1. **Define a Schema**
   Create a collection named `shakespeare` with fields:
   - `id` (string)
   - `play` (string)
   - `act` (string)
   - `scene` (string)
   - `position` (int32) – order within the scene
   - `text` (string)

2. **Parse the File**
   Use a Python script to detect play titles, act markers and scene markers. For each line or stage direction create a document with metadata for play, act, scene and position.

3. **Batch Import**
   Send documents via `/documents/import?action=upsert`, using batches of 100–1000 documents to avoid timeouts.

4. **Optional Enhancements**
   - Track a numeric scene index to preserve ordering.
   - Enable duplicate dropping or configure a default sorting field for better relevance.

This approach turns the raw text into structured records that can be queried efficiently by play, act, scene or line.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

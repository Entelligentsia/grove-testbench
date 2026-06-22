# scenes/

One scene per repo. Each scene is a comprehension/navigation task — find a
definition and its call sites/methods — chosen to favour grove's structural
access.

## Files

- `<id>.prompt.txt` — the **exact** prompt both agents run. Single source of
  truth; `run-race.sh <id>` reads this verbatim. Edit here to change a race.
- `scenes.yaml` — per-scene metadata for the video cards: `intro`, `language`,
  `repo`, `target`, and `expected_shape`.

`expected_shape` is an **off-screen** sanity note for you to eyeball each
transcript before publishing. Correctness is not scored on screen (per the
plan), so an obviously-wrong-but-fast answer should be caught here manually.

## IDs

`tokio · hugo · django · typescript · webpack · redis · bitcoin · spring-boot ·
rails · laravel` — must match `repos.manifest` names and the `<id>.prompt.txt`
filenames.

## Adding / editing a scene

1. Edit or add `<id>.prompt.txt` (keep it unambiguous and structural).
2. Add/update the matching entry in `scenes.yaml`.
3. Ensure `<id>` exists in `../repos.manifest`.

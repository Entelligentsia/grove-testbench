# transcript: Where is the `Site` struct defined? Give the exact file and line.

  ▸ Bash(grep -rn "^type Site struct" /home/bench/repos/hugo --include="*.go" | head -20)

💬 `hugolib/site.go:103`

──────── RESULT (success, 5006ms, 2 turns) ────────
`hugolib/site.go:103`

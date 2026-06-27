# transcript: Where is the `QuerySet` class defined? Give the exact file and line.

  ▸ Bash(grep -rn "^class QuerySet" /home/bench/repos/django --include="*.py" | head -5)
  ▸ Bash(grep -rn "^class QuerySet[^A-Za-z]" /home/bench/repos/django --include="*.py" | head -5)

💬 `django/db/models/query.py:326`

──────── RESULT (success, 7306ms, 3 turns) ────────
`django/db/models/query.py:326`

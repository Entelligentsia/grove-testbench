# transcript: Where is the Eloquent `Model` class (Illuminate\\Database\\Eloquent\\Model) defined? Give the exact file and line.


💬 I'll use grove to locate the symbol directly.
  ▸ ToolSearch(select:mcp__grove__symbols)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/laravel","kind":"class","name":"Model"})
  ▸ Bash(grep -i '"Model"' /home/bench/.claude/projects/-home-bench-repos-laravel/368c1dff-aa41-4854-bed3-c672afa2e23f/tool-results/mcp-grove-symbols-1782181021732.tx...)
  ▸ Bash(python3 -c " import json, re data = open('/home/bench/.claude/projects/-home-bench-repos-laravel/368c1dff-aa41-4854-bed3-c672afa2e23f/tool-results/mcp-grove-...)

💬 The `Illuminate\Database\Eloquent\Model` class is defined at:  **`src/Illuminate/Database/Eloquent/Model.php`, line 41**  It's declared as: ```php abstract c...

──────── RESULT (success, 27328ms, 5 turns) ────────
The `Illuminate\Database\Eloquent\Model` class is defined at:

**`src/Illuminate/Database/Eloquent/Model.php`, line 41**

It's declared as:
```php
abstract class Model implements Arrayable, ArrayAccess, CanBeEscapedWhenCastToString, HasBroadcastChannel, Jsonable, JsonSerializable, QueueableEntity, Stringable, UrlRoutable
```

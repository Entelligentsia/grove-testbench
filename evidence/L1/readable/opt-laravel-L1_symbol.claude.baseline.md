# transcript: Where is the Eloquent `Model` class (Illuminate\\Database\\Eloquent\\Model) defined? Give the exact file and line.

  ▸ Bash(grep -rn "^class Model" /home/bench/repos/laravel/src/Illuminate/Database/Eloquent/ 2>/dev/null | head -5)
  ▸ Bash(grep -rn "^class Model$\|^class Model " /home/bench/repos/laravel/src/Illuminate/Database/Eloquent/ 2>/dev/null)
  ▸ Bash(find /home/bench/repos/laravel -name "Model.php" -path "*/Eloquent/*" 2>/dev/null)
  ▸ Bash(grep -n "^class Model" /home/bench/repos/laravel/src/Illuminate/Database/Eloquent/Model.php)
  ▸ Bash(grep -n "class Model" /home/bench/repos/laravel/src/Illuminate/Database/Eloquent/Model.php | head -5)

💬 The `Illuminate\Database\Eloquent\Model` class is defined at:  **`src/Illuminate/Database/Eloquent/Model.php`, line 42**  It's declared as an `abstract class...

──────── RESULT (success, 22708ms, 6 turns) ────────
The `Illuminate\Database\Eloquent\Model` class is defined at:

**`src/Illuminate/Database/Eloquent/Model.php`, line 42**

It's declared as an `abstract class Model` implementing several interfaces (`Arrayable`, `ArrayAccess`, `Jsonable`, `JsonSerializable`, `QueueableEntity`, `Stringable`, `UrlRoutable`, and others).

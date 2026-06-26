# transcript: Give the complete end-to-end picture of Action Dispatch routing in Rails as a subsystem: from how routes are declared (the Mapper DSL), through RouteSet and ...

  ▸ ToolSearch(select:mcp__grove__map,mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition)

💬 I'll do a multi-pronged parallel investigation of the routing subsystem — map the top-level structure while simultaneously probing the key classes.
  ▸ mcp__grove__map({"dir":"actionpack/lib/action_dispatch/routing"})
  ▸ mcp__grove__map({"dir":"actionpack/lib/action_dispatch/journey"})
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/action_dispatch/routing","kind":"class"})

💬 Now I'll read the critical methods across all three layers in parallel.
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/routing/route_set.rb","kind":"method"})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/routing/mapper.rb","kind":"method","detail":0})

💬 Now let me read the critical method bodies in parallel across all three layers.
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#draw@457"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#call@903"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#add_route@643"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#serve@46"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#recognize_path_with_request@924"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#build@90"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#match@587"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#add_route@2195"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/router.rb#serve@30"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/router.rb#recognize@43"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#initialize@132"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#make_route@183"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#app@290"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#decomposed_match@2180"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#match@1837"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#initialize@2530"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#eval_block@472"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#finalize!@482"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#dispatch@64"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/journey/routes.rb#add_route@67"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/routes.rb#add_route@67"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#dispatcher@369"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#map_match@2131"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#get@738"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#initialize@386"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/routes.rb#simulator@60"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/routes.rb#partition_route@45"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/routes.rb#ast@53"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#controller@60"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/mapper.rb#serve@59"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#recognize_path@909"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/router.rb#filter_routes@111"})

💬 I now have everything needed. Here is the complete end-to-end picture.  ---  ## Action Dispatch Routing — Complete Subsystem Walkthrough  ---  ### Key Classe...

──────── RESULT (success, 250843ms, 39 turns) ────────
I now have everything needed. Here is the complete end-to-end picture.

---

## Action Dispatch Routing — Complete Subsystem Walkthrough

---

### Key Classes and Files

| Class | File | Role |
|---|---|---|
| `ActionDispatch::Routing::RouteSet` | `actionpack/lib/action_dispatch/routing/route_set.rb` | Central hub: owns all routes, is the Rack app |
| `Routing::Mapper` | `actionpack/lib/action_dispatch/routing/mapper.rb` | DSL layer — all `get`, `resources`, `match`, `scope` etc. |
| `Mapper::Mapping` | `mapper.rb:83` | Converts one DSL call into a normalized route descriptor |
| `Mapper::Constraints` | `mapper.rb:29` | Wraps an app with constraint-checking (mounted engines, lambda constraints) |
| `RouteSet::Dispatcher` | `route_set.rb:39` | Final Rack endpoint; looks up controller, calls `.dispatch` |
| `RouteSet::StaticDispatcher` | `route_set.rb:69` | Variant of Dispatcher when `to:` names a specific class |
| `RouteSet::NamedRouteCollection` | `route_set.rb:82` | Hash of named routes; defines `*_path`/`*_url` helpers |
| `ActionDispatch::Journey::Routes` | `actionpack/lib/action_dispatch/journey/routes.rb` | Ordered list of `Journey::Route` objects |
| `ActionDispatch::Journey::Route` | `actionpack/lib/action_dispatch/journey/route.rb` | A single compiled route: path pattern, verb matcher, defaults, app |
| `Journey::Path::Pattern` | `actionpack/lib/action_dispatch/journey/path/pattern.rb` | Compiled regex for one route path |
| `Journey::Router` | `actionpack/lib/action_dispatch/journey/router.rb` | Rack middleware that runs the match loop |
| `Journey::Parser` | `actionpack/lib/action_dispatch/journey/parser.rb` | Recursive-descent parser; route string → AST |
| `Journey::Ast` / `Journey::Nodes::*` | `actionpack/lib/action_dispatch/journey/nodes/node.rb` | AST node types: `Cat`, `Or`, `Symbol`, `Literal`, `Star`, `Group`, `Slash`, `Dot` |
| `Journey::GTG::Builder` | `actionpack/lib/action_dispatch/journey/gtg/builder.rb` | Builds a DFA `TransitionTable` from the OR-combined AST |
| `Journey::GTG::TransitionTable` | `actionpack/lib/action_dispatch/journey/gtg/transition_table.rb` | DFA transition table with `move()` |
| `Journey::GTG::Simulator` | `actionpack/lib/action_dispatch/journey/gtg/simulator.rb` | Runs the DFA against a path string → returns matching route memos |
| `Journey::Formatter` | `actionpack/lib/action_dispatch/journey/formatter.rb` | URL generation (reverse routing) |
| `Journey::Router::Utils` | `actionpack/lib/action_dispatch/journey/router/utils.rb` | `normalize_path`, URI encoding |

---

## Phase 1 — Route Declaration (boot time)

The user writes `Rails.application.routes.draw { ... }`. That calls:

### 1. `RouteSet#draw` — `route_set.rb:457`
```
clear!
eval_block(block)
finalize!
```

### 2. `RouteSet#eval_block` — `route_set.rb:472`
```
mapper = Mapper.new(self)         # Mapper#initialize, mapper.rb:2530
mapper.instance_exec(&block)      # executes the routes block in Mapper's context
```
`Mapper#initialize` stores the `RouteSet` as `@set` and creates a root `Mapper::Scope`.

---

Inside the block the user calls DSL methods. Example path: `get "/articles/:id", to: "articles#show"`.

### 3. `Mapper::HttpHelpers#get` — `mapper.rb:738`
Normalizes deprecated hash-style arguments, then delegates:
```
match(*path_or_actions, ..., via: :get)
```

### 4. `Mapper::Resources#match` — `mapper.rb:1837`
(This is the `Resources` module's override; `Base#match` at line 587 is the empty abstract stub.)
- Extracts `path_or_action`, resolves `to`, `controller`, `action`, `on`, `constraints`
- For each path calls:
```
map_match(path_or_action, as:, via:, to:, ...)
```

### 5. `Mapper::Resources#map_match` — `mapper.rb:2131`
- Resolves `to`, `controller`, `via`, `format`, `anchor`
- Delegates to:
```
decomposed_match(path, controller, as, action, _path, to, via, format, anchor, constraints, ...)
```

### 6. `Mapper::Resources#decomposed_match` — `mapper.rb:2180`
Looks at `@scope.scope_level`. For a plain route, falls through to:
```
add_route(path, controller, as, action, _path, to, via, formatted, anchor, ...)
```
For a `:resources` scope it wraps in `nested { ... }`, for `:resource` in `member { ... }`.

### 7. `Mapper::Resources#add_route` — `mapper.rb:2195`
```
path  = path_for_action(action, _path)               # builds "/articles/:id"
path  = Mapping.normalize_path(URI.escape(path), formatted)
ast   = Journey::Parser.parse(path)                  # → AST
mapping = Mapping.build(@scope, @set, ast, ...)       # → Mapping instance
@set.add_route(mapping, as)                          # → RouteSet#add_route
```

### 8. `Journey::Parser.parse(path)` — `parser.rb:11`
- Creates a `Parser` instance, sets up a `Scanner` (StringScanner subclass, `scanner.rb:20`)
- Runs recursive descent: `parse_expressions` → `parse_or` → `parse_expression` → `parse_star` / `parse_group` / `parse_terminal`
- Returns a tree of `Journey::Nodes::*` (`Cat`, `Symbol`, `Literal`, `Slash`, `Star`, `Group`, `Or`, `Dot`)

### 9. `Mapper::Mapping.build` — `mapper.rb:90`
Pulls scope state (`blocks`, `constraints`, `defaults`, `module`, `options`) and calls `Mapping.new(...)`.

### 10. `Mapper::Mapping#initialize` — `mapper.rb:132`
The main normalizer:
```
ast = Journey::Ast.new(ast, formatted)     # annotates AST with wildcard_options, names, etc.
normalize_options!(options, ast.path_params, scope_module)
split_options = constraints(options, ast.path_params)  # separates path vs. non-path constraints
requirements, conditions = split_constraints(...)
@requirements = formats_requirements + Hash[requirements]
@conditions   = Hash[conditions]
@defaults     = format_defaults + scope_defaults + normalize_defaults(options)
@path = Journey::Path::Pattern.new(ast, @requirements, JOINED_SEPARATORS, @anchor)
```
`Journey::Path::Pattern#initialize` (`path/pattern.rb:19`) stores the AST. The regex (`to_regexp`) is built lazily via `AnchoredRegexp`/`UnanchoredRegexp` visitors.

### 11. `RouteSet#add_route(mapping, name)` — `route_set.rb:643`
```
route = @set.add_route(name, mapping)      # Journey::Routes#add_route
named_routes[name] = route if name        # register in NamedRouteCollection
```

### 12. `Journey::Routes#add_route(name, mapping)` — `journey/routes.rb:67`
```
route = mapping.make_route(name, routes.length)   # Mapping#make_route
routes << route
partition_route(route)
clear_cache!                               # invalidates @ast and @simulator
```

### 13. `Mapping#make_route(name, precedence)` — `mapper.rb:183`
```
Journey::Route.new(name:, app: application, path: @path, constraints: conditions, ...)
```
`application` calls `app(blocks)` at `mapper.rb:290`:
- `to.respond_to?(:action)` → `RouteSet::StaticDispatcher.new(to)` (for a controller class)
- `to.respond_to?(:call)` → `Constraints.new(to, blocks, CALL)` (plain Rack app)
- `blocks.any?` → `Constraints.new(dispatcher(...), blocks, SERVE)` (lambda constraints)
- default → `RouteSet::Dispatcher.new(raise_on_name_error)` via `dispatcher()` at `mapper.rb:369`

### 14. `Journey::Routes#partition_route(route)` — `journey/routes.rb:45`
```
if route.path.anchored && route.path.requirements_anchored?
  anchored_routes << route     # will be included in the combined DFA
else
  custom_routes << route       # matched linearly each request
end
```

### 15. `RouteSet#finalize!` — `route_set.rb:482`
Evaluates any `@append` blocks (added via `routes.append { ... }`), sets `@finalized = true`.

---

## Phase 2 — DFA / Simulator Construction (lazy, first request)

`Journey::Routes` compiles all anchored routes into a single combined DFA on first access.

### `Journey::Routes#simulator` — `journey/routes.rb:60`
```
gtg = GTG::Builder.new(ast).transition_table    # compile DFA
GTG::Simulator.new(gtg)
```

### `Journey::Routes#ast` — `journey/routes.rb:53`
```
nodes = anchored_routes.map(&:ast)   # each route's Journey::Ast
Nodes::Or.new(nodes)                 # single Or-node combining all routes
```

### `GTG::Builder#transition_table` — `gtg/builder.rb:21`
Classic "followpos" DFA construction:
- `Builder#nullable?(node)`, `#firstpos(node)`, `#lastpos(node)` — computes position sets
- `#build_followpos` — computes follow-position table
- iterates unmarked D-states, computes transitions, returns `GTG::TransitionTable`

`GTG::TransitionTable` (`gtg/transition_table.rb:10`) maps `(from_state, symbol) → next_state` and tracks accepting states plus **memos** (the `Journey::Route` objects) attached to accepting states.

---

## Phase 3 — Request Matching (every request)

### 1. `RouteSet#call(env)` — `route_set.rb:903`
The Rack entry point:
```
req = make_request(env)                              # ActionDispatch::Request
req.path_info = Journey::Router::Utils.normalize_path(req.path_info)
@router.serve(req)                                   # Journey::Router#serve
```
`normalize_path` (`router/utils.rb:19`) squeezes duplicate slashes, ensures leading `/`, upcases percent-encoding.

### 2. `Journey::Router#serve(req)` — `router.rb:30`
```
recognize(req) do |route, parameters|
  req.path_parameters = parameters
  req.route = route
  _, headers, _ = response = route.app.serve(req)   # → dispatch
  return response unless headers[X_CASCADE] == "pass"
end
[404, { X_CASCADE => "pass" }, ["Not Found"]]
```

### 3. `Journey::Router#recognize(req, &block)` — `router.rb:43`
The core matching loop:

**Step A — DFA pre-filter:**
```
routes = filter_routes(path_info)    # Journey::Router#filter_routes, router.rb:111
```
`filter_routes` calls `simulator.memos(path_info)`.

### `GTG::Simulator#memos(string)` — `gtg/simulator.rb:31`
Walks the string byte by byte, calling `GTG::TransitionTable#move(t, full_string, token, start_index, ...)` (`transition_table.rb:49`) at each token boundary. At the end collects memos from any accepting states reached — these are the candidate `Journey::Route` objects.

**Step B — custom routes (unanchored, glob):**
```
custom_routes.each { |r| routes << r if r.path.match?(path_info) }
```

**Step C — verb/constraint filter:**
```
if req.head?
  routes = match_head_routes(routes, req)    # router.rb:115
else
  routes.select! { |r| r.matches?(req) }
end
```
`Journey::Route#matches?(request)` (`route.rb:169`) checks the `VerbMatchers` (one of `VerbMatchers::All`, `VerbMatchers::Or`, or a per-verb class generated via `class_eval`) plus any constraint hashes or lambdas.

**Step D — sort by precedence, then extract captures:**
```
routes.sort! { |a, b| a.precedence <=> b.precedence }
routes.each do |r|
  match_data = r.path.match(path_info)          # Journey::Path::Pattern#match, path/pattern.rb:167
  path_parameters = req_params.merge(r.defaults)
  # fill named captures from match_data into path_parameters
  yield(r, path_parameters)
end
```
`Journey::Path::Pattern#match` builds the regex lazily (via `to_regexp` → `AnchoredRegexp` / `UnanchoredRegexp` visitor over the AST) and returns a `Pattern::MatchData` wrapping the native `MatchData`.

---

## Phase 4 — Dispatch to Controller

The block inside `Journey::Router#serve` now has `(route, path_parameters)`. It calls:

```
route.app.serve(req)
```

**Path A — with lambda/engine constraints (`Mapper::Constraints`):**

### `Mapper::Constraints#serve(req)` — `mapper.rb:59`
```
return [404, {X_CASCADE=>"pass"}, []] unless matches?(req)   # runs constraint blocks/lambdas
@strategy.call(@app, req)
# SERVE strategy → @app.serve(req)  (used for Rack endpoints, engines)
# CALL  strategy → @app.call(req.env)  (used for pure Rack apps)
```

**Path B — normal controller route (`RouteSet::Dispatcher`):**

### `RouteSet::Dispatcher#serve(req)` — `route_set.rb:46`
```
params     = req.path_parameters           # {:controller=>"articles", :action=>"show", :id=>"42"}
controller = controller(req)               # Dispatcher#controller, route_set.rb:60
res        = controller.make_response!(req)
dispatch(controller, params[:action], req, res)
```

### `RouteSet::Dispatcher#controller(req)` — `route_set.rb:60`
```
req.controller_class
# → params[:controller].camelize + "Controller" → .constantize
# e.g. "articles" → ArticlesController
```

### `RouteSet::Dispatcher#dispatch(controller, action, req, res)` — `route_set.rb:64`
```
controller.dispatch(action, req, res)
# → ActionController::Metal.dispatch (class method)
#      creates instance, calls instance.process(action)
#      → calls the action method (e.g. #show)
```

---

## Unified Call Graph

```
ROUTE DECLARATION (boot)
════════════════════════════════════════════════════════════════════
RouteSet#draw                                     route_set.rb:457
  ├─ RouteSet#clear!                              route_set.rb:488
  ├─ RouteSet#eval_block                          route_set.rb:472
  │    └─ Mapper.new(@set)                        mapper.rb:2530
  │         └─ mapper.instance_exec(&block)
  │              │
  │              ├─ Mapper::HttpHelpers#get       mapper.rb:738
  │              │    └─╮
  │              │      │ (all HTTP helpers delegate to #match with via: set)
  │              │
  │              ├─ Mapper::Resources#resources   mapper.rb:1663
  │              │    └─ [generates #match calls per action]
  │              │
  │              └─ Mapper::Resources#match       mapper.rb:1837
  │                   └─ Mapper::Resources#map_match            mapper.rb:2131
  │                        └─ Mapper::Resources#decomposed_match mapper.rb:2180
  │                             └─ Mapper::Resources#add_route   mapper.rb:2195
  │                                  ├─ Mapping.normalize_path
  │                                  ├─ Journey::Parser.parse(path) parser.rb:11
  │                                  │    └─ Parser#parse_expressions  parser.rb:35
  │                                  │         ├─ Parser#parse_or      parser.rb:52
  │                                  │         ├─ Parser#parse_expression  parser.rb:58
  │                                  │         │    ├─ Parser#parse_star     parser.rb:68
  │                                  │         │    ├─ Parser#parse_group    parser.rb:74
  │                                  │         │    └─ Parser#parse_terminal parser.rb:86
  │                                  │         └─ → AST (Nodes::Cat/Or/Symbol/Literal/…)
  │                                  │
  │                                  ├─ Mapper::Mapping.build(scope, set, ast, …) mapper.rb:90
  │                                  │    └─ Mapper::Mapping#initialize           mapper.rb:132
  │                                  │         ├─ Journey::Ast.new(ast, formatted) node.rb:13
  │                                  │         ├─ normalize_options!               mapper.rb:212
  │                                  │         ├─ constraints / split_constraints  mapper.rb:355,248
  │                                  │         └─ Journey::Path::Pattern.new(ast,…) path/pattern.rb:19
  │                                  │
  │                                  └─ RouteSet#add_route(mapping, name)         route_set.rb:643
  │                                       ├─ Journey::Routes#add_route(name, m)   routes.rb:67
  │                                       │    ├─ Mapping#make_route(name, prec)  mapper.rb:183
  │                                       │    │    ├─ Mapping#app(blocks)        mapper.rb:290
  │                                       │    │    │    ├─ RouteSet::StaticDispatcher.new  route_set.rb:70
  │                                       │    │    │    ├─ Mapper::Constraints.new         mapper.rb:29
  │                                       │    │    │    └─ RouteSet::Dispatcher.new        route_set.rb:40
  │                                       │    │    └─ Journey::Route.new(…)      route.rb:79
  │                                       │    ├─ routes << route
  │                                       │    └─ Journey::Routes#partition_route routes.rb:45
  │                                       │         ├─ anchored_routes << route   (DFA path)
  │                                       │         └─ custom_routes << route     (linear path)
  │                                       └─ named_routes[name] = route
  │
  └─ RouteSet#finalize!                           route_set.rb:482

DFA CONSTRUCTION (lazy, on first request)
════════════════════════════════════════════════════════════════════
Journey::Router#filter_routes
  └─ Journey::Router#simulator                    router.rb:103
       └─ Journey::Routes#simulator               routes.rb:60
            ├─ Journey::Routes#ast                routes.rb:53
            │    └─ Nodes::Or.new(anchored_routes.map(&:ast))
            └─ GTG::Builder.new(ast)
                 └─ GTG::Builder#transition_table gtg/builder.rb:21
                      ├─ Builder#nullable?        gtg/builder.rb:66
                      ├─ Builder#firstpos         gtg/builder.rb:87
                      ├─ Builder#lastpos          gtg/builder.rb:108
                      ├─ Builder#build_followpos  gtg/builder.rb:130
                      └─ GTG::TransitionTable     gtg/transition_table.rb:10
       └─ GTG::Simulator.new(transition_table)    gtg/simulator.rb:16

REQUEST MATCHING (runtime, every request)
════════════════════════════════════════════════════════════════════
RouteSet#call(env)                                route_set.rb:903
  ├─ RouteSet#make_request(env)                   route_set.rb:433
  ├─ Journey::Router::Utils.normalize_path(path)  router/utils.rb:19
  └─ Journey::Router#serve(req)                   router.rb:30
       └─ Journey::Router#recognize(req)          router.rb:43
            │
            ├─ Journey::Router#filter_routes(path_info) router.rb:111
            │    └─ GTG::Simulator#memos(string)        gtg/simulator.rb:31
            │         └─ GTG::TransitionTable#move(…)   gtg/transition_table.rb:49
            │              → returns candidate Journey::Route objects (memos)
            │
            ├─ custom_routes: Journey::Path::Pattern#match?(path)  path/pattern.rb:173
            │
            ├─ Journey::Route#matches?(req)              route.rb:169
            │    └─ VerbMatchers::Or#call / class.call   route.rb:14–65
            │       + constraint hash/lambda checks
            │
            ├─ [HEAD: Journey::Router#match_head_routes  router.rb:115]
            │
            ├─ routes.sort! by Route#precedence
            │
            └─ [per route r:]
                 ├─ Journey::Path::Pattern#match(path_info)  path/pattern.rb:167
                 │    └─ Pattern#to_regexp                   path/pattern.rb:181
                 │         └─ AnchoredRegexp/UnanchoredRegexp visitor  path/pattern.rb:76,125
                 │    → Pattern::MatchData (named captures)
                 ├─ merge r.defaults + captures → path_parameters
                 └─ yield(r, path_parameters)  → Journey::Router#serve's block

DISPATCH (runtime, matched route)
════════════════════════════════════════════════════════════════════
[Journey::Router#serve block:]
  req.path_parameters = parameters           ← {:controller, :action, :id, …}
  req.route = route
  route.app.serve(req)
       │
       ├─ [Mapper::Constraints] ──────────────────────────────────────
       │    Mapper::Constraints#serve(req)           mapper.rb:59
       │      ├─ Mapper::Constraints#matches?(req)   mapper.rb:52
       │      │    └─ constraint_args / lambda.call
       │      └─ @strategy.call(@app, req)
       │           ├─ SERVE: @app.serve(req)   (engine / nested RouteSet)
       │           └─ CALL:  @app.call(req.env)(pure Rack app)
       │
       └─ [RouteSet::Dispatcher] ────────────────────────────────────
            RouteSet::Dispatcher#serve(req)         route_set.rb:46
              ├─ Dispatcher#controller(req)          route_set.rb:60
              │    └─ req.controller_class
              │         └─ params[:controller].camelize + "Controller"
              │              → .constantize → e.g. ArticlesController
              ├─ controller.make_response!(req)
              └─ Dispatcher#dispatch(controller, action, req, res)
                                                    route_set.rb:64
                   └─ controller.dispatch(action, req, res)
                        └─ ActionController::Metal.dispatch
                             └─ controller_instance.process(action)
                                  └─ ArticlesController#show (etc.)
```

---

### Summary of the Three Distinct Lifetimes

| Phase | Trigger | Key Work |
|---|---|---|
| **Declaration** | `routes.draw { }` at boot | `Mapper` DSL → `Journey::Parser` → `Mapping` → `Journey::Route` stored in `Journey::Routes` |
| **Compilation** | First request (lazy) | `Journey::Routes#ast` builds OR-node; `GTG::Builder` compiles DFA; `GTG::Simulator` created |
| **Match + Dispatch** | Every Rack call | `RouteSet#call` → `Router#serve` → `Router#recognize` (DFA filter → verb/constraint filter → regex capture) → `Dispatcher#serve` → `controller.dispatch` |

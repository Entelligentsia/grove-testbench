# transcript: I need a very thorough structural map of the Action Dispatch routing subsystem in this Rails monorepo at /home/bench/repos/rails.   Please read the following...


💬 I'll do a thorough exploration of the Action Dispatch routing subsystem across the codebase before synthesizing the answer.
  ▸ Agent(Deep exploration of Action Dispatch routing subsystem)
  ▸ Bash(find /home/bench/repos/rails -type f -name "*.rb" | grep -E "(routing|journey)" | head -30)
  ▸ Bash(ls -la /home/bench/repos/rails 2>/dev/null | head -20)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/router.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/journey/router.rb)
  ▸ Bash(find /home/bench/repos/rails/actionpack/lib/action_dispatch/routing -type f -name "*.rb" 2>&1 | head -30)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/url_for.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/journey.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/router.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/gtg/simulator.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/route.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/routes.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/middleware/router.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/middleware)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/router.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/endpoint.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/router/utils.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/parser.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_controller/metal.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_controller/metal.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/gtg/builder.rb)

💬 Good. Let me verify the key line numbers in the most critical files before synthesizing.
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/router.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/routes.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/route_set.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/gtg/simulator.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/route.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/route.rb)
  ▸ Bash(grep -n "def dispatch\|def process\|def action\|class Metal" /home/bench/repos/rails/actionpack/lib/action_controller/metal.rb | head -30)
  ▸ Bash(grep -n "def dispatch\|def process\|def self.dispatch\|def self.action\|class Metal" /home/bench/repos/rails/actionpack/lib/action_controller/metal.rb | head...)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_controller/metal.rb)

💬 Now I have all the verified line numbers. Let me check a few more key pieces:
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/journey/gtg/builder.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)
  ▸ Read(/home/bench/repos/rails/actionpack/lib/action_dispatch/routing/mapper.rb)

💬 I now have all verified line numbers. Here is the complete picture.  ---  ## Action Dispatch Routing: End-to-End  There are two distinct phases: **declaratio...

──────── RESULT (success, 356764ms, 22 turns) ────────
I now have all verified line numbers. Here is the complete picture.

---

## Action Dispatch Routing: End-to-End

There are two distinct phases: **declaration** (at boot) and **dispatch** (per request). They share the same data structures but run independently.

---

## Phase 1 — Route Declaration

### Entry point: `config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :posts
  get "photos/:id", to: "photos#show"
end
```

### `RouteSet#draw` — `actionpack/lib/action_dispatch/routing/route_set.rb:457`

```ruby
def draw(&block)
  clear! unless @disable_clear_and_finalize   # wipes @set (Journey::Routes)
  eval_block(block)                            # runs the DSL block
  finalize! unless @disable_clear_and_finalize # appends any deferred blocks
  nil
end
```

### `RouteSet#eval_block` — `route_set.rb:472`

```ruby
def eval_block(block)
  mapper = Mapper.new(self)                    # Mapper holds a reference to the RouteSet (@set)
  mapper.instance_exec(&block)                 # executes config/routes.rb in Mapper's context
end
```

`RouteSet#initialize` (`route_set.rb:386`) wires up three collaborators:

```
@set       = Journey::Routes.new   # the flat list of compiled routes
@router    = Journey::Router.new(@set)
@formatter = Journey::Formatter.new(self)
```

---

### The Mapper DSL — `actionpack/lib/action_dispatch/routing/mapper.rb`

`Mapper` (`mapper.rb:14`) is the object on which the block is `instance_exec`'d. Its methods are organised into four nested modules: `Base`, `HttpHelpers`, `Scoping`, `Resources`.

#### HTTP verb helpers — `mapper.rb:738`

```ruby
def get(*path_or_actions, ...)
  match(*path_or_actions, ..., via: :get)  # mapper.rb:754
end
# post:738, patch:786, put:~822, delete:~856 — all identical shape
```

All delegate immediately to `match`.

#### `Mapper#match` — `mapper.rb:1837`

Unpacks arguments, then for each path calls either directly or via a `defaults` wrapper:

```ruby
map_match(path_or_action, as:, via:, to:, ...)   # mapper.rb:1885
```

#### `Mapper#map_match` — `mapper.rb:2131` (private)

Resolves controller/action from scope stack, validates `via:` via `Mapping.check_via` (`mapper.rb:2145`), then calls:

```ruby
decomposed_match(path, controller, as, action, ...)   # mapper.rb:2157
```

#### `Mapper#decomposed_match` — `mapper.rb:2180` (private)

Handles `on: :member/:collection` nesting and `:resources`/`:resource` scope levels by re-entering itself recursively. In the plain case:

```ruby
add_route(path, controller, as, action, ...)   # mapper.rb:2190
```

#### `Mapper#add_route` — `mapper.rb:2195` (private) — **the heart of registration**

```ruby
def add_route(action, controller, as, ...)
  path     = path_for_action(action, _path)                   # builds the full path string
  path     = Mapping.normalize_path(URI::RFC2396_PARSER.escape(path), formatted)  # :2210
  ast      = Journey::Parser.parse(path)                      # :2211 — string → AST
  mapping  = Mapping.build(@scope, @set, ast, controller, ...) # :2213
  @set.add_route(mapping, as)                                 # :2214 → RouteSet#add_route
end
```

#### `Journey::Parser.parse` — `actionpack/lib/action_dispatch/journey/parser.rb`

Converts the path string (`"/photos/:id(.:format)"`) into a tree of `Journey::Nodes` — `Literal`, `Symbol`, `Group`, `Star`, `Slash`, `Dot`, `Cat`, `Or`. This AST is what everything downstream compiles.

#### `Mapping.build` / `Mapping#initialize` — `mapper.rb:90` / `mapper.rb:132`

`Mapping` is a value object that encapsulates everything about one route. During `initialize`:

- merges scope defaults, constraints, module prefix
- calls `Journey::Ast.new(ast, formatted)` to annotate the AST
- computes `@requirements`, `@conditions`, `@defaults`
- builds the compiled pattern: `Journey::Path::Pattern.new(ast, @requirements, JOINED_SEPARATORS, @anchor)` — `mapper.rb:178`

`Mapping#make_route` (`mapper.rb:183`) creates the actual `Journey::Route`:

```ruby
def make_route(name, precedence)
  Journey::Route.new(
    name: name,
    app: application,          # Dispatcher or Constraints wrapper
    path: path,                # Journey::Path::Pattern
    constraints: conditions,
    defaults: defaults,
    via: @via,
    precedence: precedence,
    ...
  )
end
```

`application` (`mapper.rb:190`) builds the endpoint: if there are constraint blocks, it wraps `Dispatcher.new` in `Constraints.new(dispatcher, blocks, SERVE)`.

---

### `RouteSet#add_route` — `route_set.rb:643`

```ruby
def add_route(mapping, name)
  # validates name uniqueness
  route = @set.add_route(name, mapping)   # :654 → Journey::Routes
  named_routes[name] = route if name      # registers helper (posts_path, posts_url)
  route
end
```

---

### `Journey::Routes#add_route` — `actionpack/lib/action_dispatch/journey/routes.rb:67`

```ruby
def add_route(name, mapping)
  route = mapping.make_route(name, routes.length)  # :68 → Journey::Route.new
  routes << route                                   # :69 — appended to flat list
  partition_route(route)                            # :70
  clear_cache!                                      # :71 — clears @ast and @simulator
  route
end
```

`partition_route` (`routes.rb:45`) splits routes into two buckets:

- **`anchored_routes`** — static-prefix routes whose path is fully anchored and requirements-anchored. These get compiled into the GTG automaton.
- **`custom_routes`** — dynamic/unanchored routes (e.g. mounted engines, `match "*path"`). Matched by regex at request time.

---

### `Journey::Route.new` — `actionpack/lib/action_dispatch/journey/route.rb:79`

Stores: `@name`, `@app` (the endpoint), `@path` (Pattern), `@request_method_match` (a `VerbMatchers::GET`, `Or`, `All`, etc.), `@constraints`, `@defaults`, `@precedence`.

`VerbMatchers` (`route.rb:14`) are tiny classes; `VerbMatchers.for(via)` (`route.rb:65`) selects or composes them.

---

### GTG Simulator: built lazily on first request

`Journey::Routes#simulator` (`routes.rb:60`):

```ruby
def simulator
  @simulator ||= begin
    gtg = GTG::Builder.new(ast).transition_table   # compiles NFA→DFA from the Or-of-all-anchored-routes AST
    GTG::Simulator.new(gtg)
  end
end
```

`GTG::Builder#transition_table` (`gtg/builder.rb:21`) runs the standard subset-construction algorithm over the AST's first-pos / follow-pos sets, producing a `TransitionTable` — a hash-of-hashes keyed by `(state, token)`.

---

## Phase 2 — Request Dispatch

Every request enters via the Rack interface.

### `RouteSet#call` — `route_set.rb:903`

```ruby
def call(env)
  req = make_request(env)                                      # ActionDispatch::Request.new(env)
  req.path_info = Journey::Router::Utils.normalize_path(req.path_info)  # strip trailing slash, etc.
  @router.serve(req)
end
```

---

### `Journey::Router#serve` — `actionpack/lib/action_dispatch/journey/router.rb:30`

```ruby
def serve(req)
  recognize(req) do |route, parameters|
    req.path_parameters = parameters   # merges into rack env
    req.route = route

    _, headers, _ = response = route.app.serve(req)   # :35 — calls endpoint

    return response unless headers[Constants::X_CASCADE] == "pass"
    # if endpoint passes (cascade), try next matched route
  end

  [404, { Constants::X_CASCADE => "pass" }, ["Not Found"]]
end
```

---

### `Journey::Router#recognize` — `router.rb:43`

```ruby
def recognize(req, &block)
  path_info = req.path_info

  routes = filter_routes(path_info)    # :48 — GTG fast path

  custom_routes.each { |r|             # :50 — regex fallback for unanchored routes
    routes << r if r.path.match?(path_info)
  }

  if req.head?
    routes = match_head_routes(routes, req)   # :55 — HEAD → try GET
  else
    routes.select! { |r| r.matches?(req) }   # :57 — verb + constraints filter
  end

  if routes.size > 1
    routes.sort! { |a, b| a.precedence <=> b.precedence }  # :61
  end

  routes.each do |r|
    match_data = r.path.match(path_info)           # :67 — Regexp named captures

    path_parameters = req_params.merge r.defaults  # :69

    match_data.names.each do |name|                # :72 — populate :id, :format, etc.
      val = match_data[index]
      val = CGI.unescapeURIComponent(val) if val.include?("%")  # :75
      path_parameters[name.to_sym] = val
    end

    yield(r, path_parameters)                      # :86 — back to serve's block
  end
end
```

#### `Journey::Router#filter_routes` — `router.rb:111` (private)

```ruby
def filter_routes(path)
  simulator.memos(path) { [] }
end
```

---

### `GTG::Simulator#memos` — `actionpack/lib/action_dispatch/journey/gtg/simulator.rb:31`

```ruby
def memos(string)
  state = INITIAL_STATE   # [0, nil]

  pos = 0
  while pos < string.bytesize
    # classify byte: ".", "/", "?" are STATIC_TOKENS; everything else is a dynamic token
    token = STATIC_TOKENS[string.getbyte(pos)] || read_dynamic_token(string, pos)
    state = tt.move(state, string, token, start_index, dynamic?)  # walk DFA
  end

  # collect all accepting DFA states
  acceptance_states = state.each_slice(2).filter_map { |s, _|
    tt.memo(s) if tt.accepting?(s)
  }.flatten

  acceptance_states.empty? ? yield : acceptance_states  # :66 — yield = [] (no match)
end
```

Each DFA accepting state carries a `memo` — the `Journey::Route` objects that terminate at that state. The return value is the list of candidate routes, not yet verb-filtered.

---

### `Journey::Route#matches?` — `route.rb:169`

Called by `router.rb:57` (`routes.select! { |r| r.matches?(req) }`):

```ruby
def matches?(request)
  @request_method_match.call(request) &&   # :170 — e.g. VerbMatchers::GET.call(req) → req.get?
  constraints.all? { |method, value|       # :171 — host, subdomain, custom constraints
    value === request.send(method).to_s
  }
end
```

---

### `route.app.serve(req)` — the endpoint chain

The `app` stored on a route is one of:

1. **`Mapper::Constraints`** (`mapper.rb:29`) — a wrapper that adds runtime constraint objects (lambdas, objects with `matches?`). Its `serve` (`mapper.rb:59`) checks `matches?` then delegates to its inner app.
2. **`RouteSet::Dispatcher`** (`route_set.rb:39`) — the standard controller dispatcher.
3. A raw Rack app (from `mount SomeEngine`).

### `RouteSet::Dispatcher#serve` — `route_set.rb:46`

```ruby
def serve(req)
  params     = req.path_parameters              # {:controller=>"photos", :action=>"show", :id=>"1"}
  controller = controller(req)                  # req.controller_class → Photos::PhotosController
  res        = controller.make_response!(req)   # ActionDispatch::Response
  dispatch(controller, params[:action], req, res)
end

def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)         # :65 → class-level dispatch
end
```

`req.controller_class` (`ActionDispatch::Request`) resolves `params[:controller]` to a constant — `"photos"` → `PhotosController`.

---

### `ActionController::Metal.dispatch` — `actionpack/lib/action_controller/metal.rb:331` (class method)

```ruby
def self.dispatch(name, req, res)
  if middleware_stack.any?
    middleware_stack.build(name) { |env| new.dispatch(name, req, res) }.call(req.env)  # :333
  else
    new.dispatch(name, req, res)   # :335
  end
end
```

If the controller has per-controller middleware (`use AuthMiddleware`), it is applied here.

---

### `ActionController::Metal#dispatch` — `metal.rb:249` (instance method)

```ruby
def dispatch(name, request, response)
  set_request!(request)    # :250 — @_request = request; request.controller_instance = self
  set_response!(response)  # :251
  process(name)            # :252 — AbstractController::Base#process → calls action method
  request.commit_flash     # :253
  to_a                     # :254 → response.to_a → [status, headers, body]
end
```

`process(name)` is inherited from `AbstractController::Base`. It calls `send(name)` (after action callbacks from `ActionController::Callbacks`), which is the actual controller action method — `show`, `index`, etc.

`to_a` (`metal.rb:280`) returns `response.to_a`, which is `[status_code, headers_hash, body_array]` — the Rack triple that travels back up the stack.

---

## Unified Call Graph

```
═══════════════ DECLARATION PHASE (boot) ═══════════════

RouteSet#draw                            route_set.rb:457
 └─ RouteSet#eval_block                  route_set.rb:472
     └─ Mapper.new(route_set)            route_set.rb:473
         └─ Mapper#instance_exec(&block)
             │
             ├─ Mapper#get / #post / ...  mapper.rb:738
             │   └─ Mapper#match          mapper.rb:1837
             │       └─ Mapper#map_match  mapper.rb:2131
             │           └─ Mapper#decomposed_match   mapper.rb:2180
             │               └─ Mapper#add_route [private]   mapper.rb:2195
             │                   ├─ Mapping.normalize_path   mapper.rb:2210
             │                   ├─ Journey::Parser.parse    mapper.rb:2211  → AST nodes
             │                   ├─ Mapping.build            mapper.rb:2213
             │                   │   └─ Mapping#initialize   mapper.rb:132
             │                   │       └─ Journey::Path::Pattern.new  mapper.rb:178
             │                   └─ RouteSet#add_route       route_set.rb:643
             │                       └─ Journey::Routes#add_route  routes.rb:67
             │                           ├─ Mapping#make_route      routes.rb:68
             │                           │   └─ Journey::Route.new  route.rb:79
             │                           ├─ routes << route          routes.rb:69
             │                           ├─ Routes#partition_route   routes.rb:70
             │                           └─ Routes#clear_cache!      routes.rb:71
             │
             └─ Mapper#resources          mapper.rb:1663
                 └─ (calls get/post/patch/put/delete for 7 standard actions)
                    └─ (same chain as above)

[lazy on first request]
Journey::Routes#simulator               routes.rb:60
 ├─ GTG::Builder.new(ast).transition_table   gtg/builder.rb:21
 └─ GTG::Simulator.new(transition_table)     gtg/simulator.rb:27

═══════════════ DISPATCH PHASE (per request) ═══════════════

Rack env
 └─ RouteSet#call                        route_set.rb:903
     ├─ ActionDispatch::Request.new(env) route_set.rb:904
     ├─ Journey::Router::Utils.normalize_path  route_set.rb:905
     └─ Journey::Router#serve            router.rb:30
         └─ Journey::Router#recognize    router.rb:43
             ├─ Router#filter_routes     router.rb:48, 111
             │   └─ GTG::Simulator#memos  gtg/simulator.rb:31
             │       ├─ tt.move(state, string, token, ...)  [per byte]  simulator.rb:42,49
             │       ├─ tt.accepting?(s) + tt.memo(s)       simulator.rb:59-60
             │       └─ → [Journey::Route, ...]  (anchored candidates)
             ├─ custom_routes path.match?(path_info)        router.rb:50-52
             ├─ Router#match_head_routes (HEAD fallback)    router.rb:115
             ├─ routes.select! { r.matches?(req) }          router.rb:57
             │   └─ Journey::Route#matches?                 route.rb:169
             │       ├─ @request_method_match.call(req)     route.rb:170  (VerbMatchers::GET etc.)
             │       └─ constraints.all? { value === req.send(method) }  route.rb:171
             ├─ routes.sort! by precedence                  router.rb:61
             └─ for each route:
                 ├─ r.path.match(path_info)                router.rb:67  (named captures)
                 ├─ merge r.defaults + URL-decode          router.rb:69-81
                 └─ yield(route, path_parameters)          router.rb:86
                     │
                     [back in Journey::Router#serve block, router.rb:31]
                     ├─ req.path_parameters = parameters   router.rb:32
                     ├─ req.route = route                  router.rb:33
                     └─ route.app.serve(req)               router.rb:35
                         │
                         ├─ [if Constraints wrapper]
                         │   Constraints#serve             mapper.rb:59
                         │    ├─ Constraints#matches?      mapper.rb:52
                         │    └─ inner_app.serve(req)
                         │
                         └─ RouteSet::Dispatcher#serve     route_set.rb:46
                             ├─ req.path_parameters        route_set.rb:47
                             ├─ req.controller_class       route_set.rb:61
                             │   → resolves "photos" → PhotosController
                             ├─ controller.make_response!(req)   route_set.rb:49
                             └─ Dispatcher#dispatch(ctrl, action, req, res)  route_set.rb:64
                                 └─ controller.dispatch(action, req, res)    route_set.rb:65
                                     └─ ActionController::Metal.dispatch     metal.rb:331
                                         └─ [middleware_stack.build if any]
                                             └─ Metal.new.dispatch(name, req, res)  metal.rb:335
                                                 └─ Metal#dispatch [instance]       metal.rb:249
                                                     ├─ set_request!(request)       metal.rb:250
                                                     ├─ set_response!(response)     metal.rb:251
                                                     ├─ process(name)               metal.rb:252
                                                     │   └─ AbstractController::Base#process
                                                     │       └─ send(action_name)
                                                     │           → PhotosController#show
                                                     ├─ request.commit_flash        metal.rb:253
                                                     └─ to_a → [status, headers, body]  metal.rb:254
```

---

## Key Classes Summary

| Class | File | Role |
|---|---|---|
| `RouteSet` | `routing/route_set.rb:17` | Owns all routes; Rack entry point (`call`); drives declaration |
| `RouteSet::Dispatcher` | `route_set.rb:39` | Terminal endpoint; resolves controller, calls `.dispatch` |
| `NamedRouteCollection` | `route_set.rb:82` | Stores named routes; generates `posts_path`/`posts_url` helpers |
| `Mapper` | `routing/mapper.rb:14` | DSL surface; `instance_exec`'d on the routes block |
| `Mapper::Mapping` | `mapper.rb:83` | Value object: one route's path, constraints, defaults, app |
| `Mapper::Constraints` | `mapper.rb:29` | Endpoint wrapper: runtime constraint checking |
| `Journey::Routes` | `journey/routes.rb:9` | Flat list of `Journey::Route`; partitions anchored vs custom; owns simulator |
| `Journey::Router` | `journey/router.rb:16` | `serve` + `recognize`; orchestrates matching loop |
| `Journey::Route` | `journey/route.rb:8` | One compiled route: app, path, verb matcher, constraints, defaults |
| `Journey::Path::Pattern` | `journey/path/pattern.rb` | Compiled Regexp from AST; `match(path)` extracts captures |
| `GTG::Builder` | `journey/gtg/builder.rb:10` | Compiles route AST set → DFA transition table |
| `GTG::Simulator` | `journey/gtg/simulator.rb:16` | Walks DFA byte-by-byte; returns memo'd `Journey::Route` candidates |
| `ActionController::Metal` | `action_controller/metal.rb` | `self.dispatch` → `new.dispatch` → `process(action)` → `to_a` |

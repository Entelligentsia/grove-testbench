# transcript: Trace how Rails dispatches an incoming HTTP request to a controller action: name every method it passes through, in order, from the Rack entry point where th...


💬 I'll load the grove tools and then trace the dispatch path systematically.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__outline,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me map the key dispatch path across actionpack. I'll start with the routing and middleware layers in parallel.
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/routing/route_set.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_controller/metal.rb","detail":0})

💬 Now let me read the key methods in the dispatch chain in parallel.
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#call@903"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#serve@46"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#dispatch@64"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#recognize_path_with_request@924"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#action@315"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#dispatch@331"})

💬 Now let me read the Metal instance `dispatch`, find `process_action`, and find the Journey router's `serve`.
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#dispatch@249"})
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/action_dispatch/journey","name":"serve","kind":"method"})
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/action_controller","name":"process_action","kind":"method"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/journey/router.rb#serve@30"})
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/abstract_controller","name":"process","kind":"method"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/rescue.rb#process_action@35"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/base.rb#process@146"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/instrumentation.rb#process_action@59"})

💬 Now let me find `process_action` in AbstractController (the base implementation that actually invokes the action method) and the callbacks layer.
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/abstract_controller","name":"process_action","kind":"method"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/rendering.rb#process_action@202"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/callbacks.rb#process_action@265"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/base.rb#process_action@223"})
  ▸ mcp__grove__symbols({"dir":"actionpack/lib/abstract_controller","name":"send_action"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#controller@60"})

💬 I now have everything needed. Here is the complete method-by-method dispatch trace.  ---  ## Rails HTTP Dispatch — Full Call Chain  ### 1. Rack entry point —...

──────── RESULT (success, 131409ms, 24 turns) ────────
I now have everything needed. Here is the complete method-by-method dispatch trace.

---

## Rails HTTP Dispatch — Full Call Chain

### 1. Rack entry point — `ActionDispatch::Routing::RouteSet#call`
`actionpack/lib/action_dispatch/routing/route_set.rb:903`

```ruby
def call(env)
  req = make_request(env)                        # wraps env in ActionDispatch::Request
  req.path_info = Journey::Router::Utils.normalize_path(req.path_info)
  @router.serve(req)                             # → step 2
end
```

`RouteSet` is itself a Rack app (it sits at the end of the middleware stack). The middleware stack finishes, and control lands here.

---

### 2. `ActionDispatch::Journey::Router#serve`
`actionpack/lib/action_dispatch/journey/router.rb:30`

```ruby
def serve(req)
  recognize(req) do |route, parameters|          # tree-walk of the compiled route trie
    req.path_parameters = parameters             # sets :controller, :action, etc.
    req.route = route
    _, headers, _ = response = route.app.serve(req)   # → step 3
    return response unless headers[X_CASCADE] == "pass"
  end
  [404, { X_CASCADE => "pass" }, ["Not Found"]]
end
```

`recognize` walks the Journey route trie and yields the first matching `route` with its decoded parameters. `route.app` is the route's endpoint — for a normal controller route it is a `RouteSet::Dispatcher`.

---

### 3. `ActionDispatch::Routing::RouteSet::Dispatcher#serve`
`actionpack/lib/action_dispatch/routing/route_set.rb:46`

```ruby
def serve(req)
  params     = req.path_parameters              # {:controller=>"posts", :action=>"show", …}
  controller = controller(req)                  # → step 4
  res        = controller.make_response!(req)
  dispatch(controller, params[:action], req, res)  # → step 5
end
```

---

### 4. `req.controller_class` (inside `Dispatcher#controller`)
`actionpack/lib/action_dispatch/routing/route_set.rb:60`

```ruby
def controller(req)
  req.controller_class     # constantizes "posts" → PostsController
end
```

`ActionDispatch::Request#controller_class` camelizes `params[:controller]` and calls `constantize`, returning the actual class object.

---

### 5. `ActionDispatch::Routing::RouteSet::Dispatcher#dispatch`
`actionpack/lib/action_dispatch/routing/route_set.rb:64`

```ruby
def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)    # calls the class method → step 6
end
```

---

### 6. `ActionController::Metal.dispatch` *(class method)*
`actionpack/lib/action_controller/metal.rb:331`

```ruby
def self.dispatch(name, req, res)
  if middleware_stack.any?
    middleware_stack.build(name) { |env| new.dispatch(name, req, res) }.call(req.env)
  else
    new.dispatch(name, req, res)     # → step 7
  end
end
```

This is where the **per-controller middleware stack** (e.g. `ActionController::Base` includes `Flash`, `Cookies`, etc. via `use`) runs. Each middleware wraps the block `{ |env| new.dispatch(name, req, res) }`. After all middleware have called `next`, that block fires step 7.

---

### 7. `ActionController::Metal#dispatch` *(instance method)*
`actionpack/lib/action_controller/metal.rb:249`

```ruby
def dispatch(name, request, response)
  set_request!(request)    # stores request, sets up params proxy
  set_response!(response)  # stores response
  process(name)            # → step 8
  request.commit_flash
  to_a
end
```

---

### 8. `AbstractController::Base#process`
`actionpack/lib/abstract_controller/base.rb:146`

```ruby
def process(action, ...)
  @_action_name = action.to_s
  unless action_name = _find_action_name(@_action_name)
    raise ActionNotFound, …
  end
  @_response_body = nil
  process_action(action_name, ...)    # → step 9
end
```

`_find_action_name` checks the method is public and not in `AbstractController::Base` itself (preventing dispatch to internal methods).

---

### 9–13. The `process_action` override chain

Each module calls `super`, forming a nested wrapper. From outermost to innermost:

**9. `ActionController::Metal::Rescue#process_action`**
`actionpack/lib/action_controller/metal/rescue.rb:35`
Wraps the entire chain in `rescue Exception` to handle `rescue_from` declarations.

**10. `ActionController::Metal::Instrumentation#process_action`**
`actionpack/lib/action_controller/metal/instrumentation.rb:59`
Fires `start_processing.action_controller`, then wraps `super` in a `process_action.action_controller` notification block (populates the log line).

**11. `ActionController::Metal::ParamsWrapper#process_action`**
`actionpack/lib/action_controller/metal/params_wrapper.rb:257`
Wraps request params into a model-named key if `wrap_parameters` is configured, then calls `super`.

**12. `ActionController::Metal::Rendering#process_action`**
`actionpack/lib/action_controller/metal/rendering.rb:202`
Sets `self.formats` from `request.formats`, then calls `super`.

**13. `AbstractController::Callbacks#process_action`**
`actionpack/lib/abstract_controller/callbacks.rb:265`

```ruby
def process_action(...)
  run_callbacks(:process_action) do
    super     # → step 14
  end
end
```

`run_callbacks` executes all **`before_action`** filters, then yields (step 14), then executes all **`after_action`** filters. `around_action` filters straddle the yield.

---

### 14. `AbstractController::Base#process_action`
`actionpack/lib/abstract_controller/base.rb:223`

```ruby
def process_action(...)
  send_action(...)
end
```

---

### 15. `AbstractController::Base#send_action` = `send`
`actionpack/lib/abstract_controller/base.rb:231`

```ruby
alias send_action send
```

`send_action(action_name)` is plain Ruby `send` — it invokes the public instance method by name on the controller instance. **This is where the user-defined action method runs.**

---

## Summary table

| # | Method | File | What it does |
|---|--------|------|--------------|
| 1 | `RouteSet#call` | `action_dispatch/routing/route_set.rb:903` | Rack entry; wraps `env` in `Request`, normalizes path |
| 2 | `Journey::Router#serve` | `action_dispatch/journey/router.rb:30` | Walks route trie via `recognize`, finds matching route |
| 3 | `RouteSet::Dispatcher#serve` | `route_set.rb:46` | Resolves controller class, builds response object |
| 4 | `req.controller_class` | `action_dispatch/http/request.rb` | Constantizes `:controller` param → class object |
| 5 | `RouteSet::Dispatcher#dispatch` | `route_set.rb:64` | Calls `controller.dispatch` (the class method) |
| 6 | `Metal.dispatch` *(class)* | `action_controller/metal.rb:331` | Runs per-controller middleware stack |
| 7 | `Metal#dispatch` *(instance)* | `action_controller/metal.rb:249` | Wires request/response into the instance; calls `process` |
| 8 | `AbstractController::Base#process` | `abstract_controller/base.rb:146` | Validates action exists; calls `process_action` |
| 9 | `Rescue#process_action` | `metal/rescue.rb:35` | Exception rescue wrapper |
| 10 | `Instrumentation#process_action` | `metal/instrumentation.rb:59` | `ActiveSupport::Notifications` instrumentation |
| 11 | `ParamsWrapper#process_action` | `metal/params_wrapper.rb:257` | Optional param wrapping |
| 12 | `Rendering#process_action` | `metal/rendering.rb:202` | Sets response formats |
| 13 | `Callbacks#process_action` | `abstract_controller/callbacks.rb:265` | `run_callbacks` → `before_action` / `around_action` filters |
| 14 | `AbstractController::Base#process_action` | `abstract_controller/base.rb:223` | Delegates to `send_action` |
| 15 | `send_action` (= `send`) | `abstract_controller/base.rb:231` | Ruby `send(action_name)` — **action method invoked** |

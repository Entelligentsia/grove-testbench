# transcript: Give a complete architectural walkthrough of Rails's full request lifecycle from the Rack entry to a rendered response — the cross-cutting request architectu...


💬 I'll use grove's map tool to trace the architecture across all subsystems in parallel. Let me load the grove schemas first.
  ▸ ToolSearch(select:mcp__grove__map,mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition)

💬 Now let me fan out parallel map calls across every subsystem involved in the request lifecycle.
  ▸ mcp__grove__map({"dir":"actionpack/lib/action_dispatch"})
  ▸ mcp__grove__map({"dir":"actionpack/lib/action_controller"})
  ▸ mcp__grove__map({"dir":"actionview/lib/action_view"})
  ▸ mcp__grove__map({"dir":"activerecord/lib/active_record"})
  ▸ mcp__grove__map({"dir":"activesupport/lib/active_support"})

💬 The directories are too large. I'll target the specific key files for each lifecycle stage in parallel.
  ▸ mcp__grove__outline({"file":"railties/lib/rails/application.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/routing/route_set.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_controller/metal.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/middleware/stack.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/http/request.rb","detail":0})

💬 Now let me pull the source for the critical lifecycle methods in parallel.
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/application.rb#to_app@637"})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/application.rb#build_middleware_stack@672"})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/application.rb#default_middleware_stack@740"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#call@903"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#recognize_path_with_request@924"})
  ▸ mcp__grove__outline({"file":"railties/lib/rails/engine.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#serve@46"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#dispatch@249"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#action@315"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#dispatch@331"})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/engine.rb#call@532"})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/engine.rb#app@515"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/middleware/stack.rb#build@166"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_dispatch/routing/route_set.rb#dispatch@64"})
  ▸ mcp__grove__outline({"file":"actionpack/lib/abstract_controller/base.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/base.rb#process@146"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/base.rb#process_action@223"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/base.rb#send_action@231"})
  ▸ mcp__grove__outline({"file":"actionpack/lib/abstract_controller/callbacks.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_controller/metal/rendering.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/callbacks.rb#process_action@265"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/rendering.rb#render@176"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/rendering.rb#render_to_body@196"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal/rendering.rb#process_action@202"})
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/base.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/renderer/renderer.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/renderer/template_renderer.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/template.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/lookup_context.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/middleware/flash.rb","detail":0})

💬 Now let me pull the key rendering methods and the default middleware stack definition.
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/renderer.rb#render@23"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/template_renderer.rb#render@5"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/template_renderer.rb#render_with_layout@71"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/template.rb#render@280"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/template.rb#compile!@433"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/base.rb#_run@264"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/template.rb#compile@515"})
  ▸ mcp__grove__outline({"file":"railties/lib/rails/application/default_middleware_stack.rb","detail":0})
  ▸ mcp__grove__outline({"file":"actionpack/lib/action_dispatch/middleware/router.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/application/default_middleware_stack.rb#build_stack@14"})
  ▸ mcp__grove__source({"id":"ruby:railties/lib/rails/engine.rb#build_middleware@779"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/renderer.rb#render_to_object@27"})
  ▸ mcp__grove__outline({"file":"actionpack/lib/abstract_controller/rendering.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/renderer.rb#render_template_to_object@57"})
  ▸ mcp__grove__outline({"file":"activerecord/lib/active_record/relation.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:activerecord/lib/active_record/relation.rb#exec_queries@1429"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/rendering.rb#render@26"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/abstract_controller/rendering.rb#render_to_body@50"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#set_request!@275"})

💬 One more batch — view context wiring and the AR query path.
  ▸ mcp__grove__outline({"file":"actionview/lib/action_view/rendering.rb","detail":0})
  ▸ mcp__grove__source({"id":"ruby:activerecord/lib/active_record/relation.rb#exec_main_query@1453"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/renderer/template_renderer.rb#render_template@58"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#response_body=@234"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/rendering.rb#render_to_body@119"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/rendering.rb#_render_template@127"})
  ▸ mcp__grove__source({"id":"ruby:actionview/lib/action_view/rendering.rb#view_context@109"})
  ▸ mcp__grove__source({"id":"ruby:actionpack/lib/action_controller/metal.rb#to_a@280"})

💬 I now have everything needed for a complete, precise walkthrough. Let me write it up.  ---  # Rails Full Request Lifecycle: Architectural Walkthrough  ---  #...

──────── RESULT (success, 330046ms, 69 turns) ────────
I now have everything needed for a complete, precise walkthrough. Let me write it up.

---

# Rails Full Request Lifecycle: Architectural Walkthrough

---

## 0. Boot: assembling the Rack app

Before the first request arrives Rails builds the frozen middleware chain exactly once (lazily, on the first `call`).

**`Rails::Engine#app`** — `railties/lib/rails/engine.rb:515`
```ruby
def app
  @app || @app_build_lock.synchronize {
    @app ||= begin
      stack = default_middleware_stack              # step A
      config.middleware = build_middleware.merge_into(stack)
      config.middleware.build(endpoint)             # step B — endpoint is RouteSet
    end
  }
end
```

**Step A — `Rails::Application#default_middleware_stack`** — `railties/lib/rails/application.rb:740`
Creates `DefaultMiddlewareStack.new(self, config, paths).build_stack`.

**`DefaultMiddlewareStack#build_stack`** — `railties/lib/rails/application/default_middleware_stack.rb:14`
Returns a populated `ActionDispatch::MiddlewareStack` with these layers, in order:

| Position | Middleware | Purpose |
|---|---|---|
| 1 | `ActionDispatch::HostAuthorization` | Validate `Host` header against allowlist |
| 2 | `ActionDispatch::AssumeSSL` / `::SSL` | HTTPS enforcement / redirect |
| 3 | `Rack::Sendfile` | Offload large sends via X-Sendfile |
| 4 | `ActionDispatch::Static` | Serve `public/` files before hitting app |
| 5 | `Rack::Cache` | Optional HTTP cache (rack-cache gem) |
| 6 | `Rack::Lock` | Mutex when `allow_concurrency: false` |
| 7 | `ActionDispatch::Executor` | `ActiveSupport::Executor` — code reload, thread isolation |
| 8 | `ActionDispatch::ServerTiming` | `Server-Timing` header |
| 9 | `Rack::Runtime` | `X-Runtime` header |
| 10 | `Rack::MethodOverride` | Rewrite `_method` param to HTTP verb |
| 11 | `ActionDispatch::RequestId` | Assign / propagate `X-Request-Id` |
| 12 | `ActionDispatch::RemoteIp` | Compute client IP, strip spoofed headers |
| 13 | `Rails::Rack::SilenceRequest` | Suppress healthcheck log noise |
| 14 | `Rails::Rack::Logger` | Tagged logging via `ActiveSupport::TaggedLogging` |
| 15 | `ActionDispatch::ShowExceptions` | Catch unhandled exceptions → error app |
| 16 | `ActionDispatch::DebugExceptions` | Dev: detailed exception pages |
| 17 | `ActionDispatch::ActionableExceptions` | Dev: pending-migration buttons |
| 18 | `ActionDispatch::Reloader` | Dev: reload changed source files |
| 19 | `ActionDispatch::Callbacks` | `ActiveSupport::Callbacks` around-request hooks |
| 20 | `ActionDispatch::Cookies` | Cookie jar (`ActionDispatch::CookieJar`) |
| 21 | session store | e.g. `ActionDispatch::Session::CookieStore` |
| 22 | `ActionDispatch::Flash` | `FlashHash` keyed to session |
| 23 | `ActionDispatch::ContentSecurityPolicy::Middleware` | Inject CSP headers |
| 24 | `ActionDispatch::PermissionsPolicy::Middleware` | Inject Permissions-Policy header |
| 25 | `Rack::Head` | Strip body from HEAD responses |
| 26 | `Rack::ConditionalGet` | Return 304 when ETag/Last-Modified matches |
| 27 | `Rack::ETag` | Generate ETag from body digest |
| 28 | `Rack::TempfileReaper` | Clean up multipart tempfiles |
| 29 | `ActiveRecord::Middleware::DatabaseSelector` | Route reads to replica |
| 30 | `ActiveRecord::Middleware::ShardSelector` | Route requests to shards |
| **inner** | `ActionDispatch::Routing::RouteSet` | **The router — final Rack endpoint** |

**Step B — `ActionDispatch::MiddlewareStack#build`** — `actionpack/lib/action_dispatch/middleware/stack.rb:166`
```ruby
def build(app = nil, &block)
  instrumenting = ActiveSupport::Notifications.notifier.listening?(...)
  middlewares.freeze.reverse.inject(app || block) do |a, e|
    instrumenting ? e.build_instrumented(a) : e.build(a)
  end
end
```
Each `Middleware#build(app)` calls `klass.new(app, *args, **kwargs)`. The result is a single callable object — each middleware holds a reference to the next one.

---

## 1. Rack entry point

The Rack server (Puma, Unicorn, etc.) calls `app.call(env)` with a plain Hash.

**`Rails::Engine#call`** — `railties/lib/rails/engine.rb:532`
```ruby
def call(env)
  req = build_request env          # ActionDispatch::Request.new(env)
  app.call req.env
end
```
`app` is the frozen middleware chain from §0. From here execution descends through each middleware's `call` method.

---

## 2. The middleware stack

Each middleware follows the Rack contract: `call(env)` → do pre-work → `@app.call(env)` → do post-work → return `[status, headers, body]`.

Notable mechanics:

- **`ActionDispatch::Executor#call`** wraps the inner call in `app.executor.wrap { }`, which resets thread-locals, runs autoload hooks, and handles code reloading (in development).
- **`ActionDispatch::Callbacks#call`** runs `ActiveSupport::Callbacks` `:call` chain, enabling `before_action`-like hooks at the application level.
- **`ActionDispatch::Cookies#call`** builds a `CookieJar` and stores it in `env["action_dispatch.cookies"]`; on the way back out it writes `Set-Cookie` headers.
- **`ActionDispatch::Session::CookieStore#call`** decrypts the session cookie inbound and re-encrypts it outbound.
- **`ActionDispatch::Flash#call`** loads the `FlashHash` from the session; `commit_flash` (called later in the controller) sweeps stale entries and writes back.
- **`Rack::ConditionalGet` + `Rack::ETag`** on the return path: ETag generates a digest of the body; ConditionalGet returns 304 if the client's `If-None-Match` matches.

---

## 3. Routing — `ActionDispatch::Routing::RouteSet`

**`RouteSet#call`** — `actionpack/lib/action_dispatch/routing/route_set.rb:903`
```ruby
def call(env)
  req = make_request(env)           # ActionDispatch::Request wrapping env
  req.path_info = Journey::Router::Utils.normalize_path(req.path_info)
  @router.serve(req)                # Journey::Router
end
```

`@router` is a **`ActionDispatch::Journey::Router`**. Its `serve(req)` method runs the compiled finite automaton (NFA/DFA) built at route-definition time from all `get`/`post`/`resources` declarations. When a route matches:

1. `req.path_parameters` is set to e.g. `{controller: "posts", action: "show", id: "1"}`.
2. The route's endpoint app is called. For a normal REST route that is a **`RouteSet::Dispatcher`** instance.

**`RouteSet::Dispatcher#serve`** — `route_set.rb:46`
```ruby
def serve(req)
  params     = req.path_parameters
  controller = controller req               # constantizes "posts" → PostsController
  res        = controller.make_response! req
  dispatch(controller, params[:action], req, res)
rescue ActionController::RoutingError
  [404, { X_CASCADE => "pass" }, []]
end
```

`controller req` calls `req.controller_class` which does `"posts".camelize + "Controller"` → `PostsController`.

**`RouteSet::Dispatcher#dispatch`** — `route_set.rb:64`
```ruby
def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)     # class method on PostsController
end
```

---

## 4. Controller dispatch — class level

**`ActionController::Metal.dispatch`** (class method) — `actionpack/lib/action_controller/metal.rb:331`
```ruby
def self.dispatch(name, req, res)
  if middleware_stack.any?
    middleware_stack.build(name) { |env| new.dispatch(name, req, res) }.call req.env
  else
    new.dispatch(name, req, res)
  end
end
```

`middleware_stack` is the **per-controller** `ActionController::MiddlewareStack` populated by `use` calls in the controller class. If any per-controller middleware exist they get a mini Rack chain wrapping the action dispatch — the same `build → reverse.inject` pattern as the global stack. Most controllers have an empty stack and skip straight to `new.dispatch`.

---

## 5. Controller dispatch — instance level

**`ActionController::Metal#dispatch`** (instance) — `metal.rb:249`
```ruby
def dispatch(name, request, response)
  set_request!(request)        # @_request = request; request.controller_instance = self
  set_response!(response)      # @_response = response
  process(name)                # AbstractController::Base#process
  request.commit_flash
  to_a                         # response.to_a → [status, headers, body]
end
```

**`ActionController::Metal#set_request!`** — `metal.rb:275`
Sets `@_request` and back-links `request.controller_instance = self`, so request objects can reach their controller.

---

## 6. AbstractController — finding and calling the action

**`AbstractController::Base#process`** — `actionpack/lib/abstract_controller/base.rb:146`
```ruby
def process(action, ...)
  @_action_name = action.to_s
  unless action_name = _find_action_name(@_action_name)
    raise ActionNotFound.new("The action '#{action}' could not be found ...")
  end
  @_response_body = nil
  process_action(action_name, ...)
end
```

`_find_action_name` checks `action_methods` — the public methods minus `internal_methods` (inherited framework methods). This prevents calling inherited helpers as actions.

`process_action` is **overridden by multiple modules** stacked via `super` calls:

### Layer A — `ActionController::Rendering#process_action` — `metal/rendering.rb:202`
```ruby
def process_action(*)
  self.formats = request.formats.filter_map(&:ref)  # [:html], [:json], etc.
  super
end
```

### Layer B — `AbstractController::Callbacks#process_action` — `abstract_controller/callbacks.rb:265`
```ruby
def process_action(...)
  run_callbacks(:process_action) do
    super
  end
end
```
`run_callbacks` executes the compiled `ActiveSupport::Callbacks` chain for `:process_action`. This is where **`before_action`**, **`around_action`**, and **`after_action`** filters fire. Each filter is an `ActionFilter` (`callbacks.rb:41`) that wraps the check for `only:`/`except:` constraints against the current action name.

### Layer C — `AbstractController::Base#process_action` — `base.rb:223`
```ruby
def process_action(...)
  send_action(...)   # aliased to Ruby's send
end
```
`send_action` is `alias send_action send` (`base.rb:231`). This calls `send("show")` on the controller — i.e. it invokes the actual action method.

---

## 7. The action method — Active Record

Inside `PostsController#show` (user code), queries happen through Active Record.

```ruby
def show
  @post = Post.find(params[:id])
end
```

**`ActiveRecord::Base.find`** delegates through `FinderMethods`, builds a `Relation`, then triggers `load`:

**`Relation#exec_queries`** — `activerecord/lib/active_record/relation.rb:1429`
```ruby
def exec_queries(&block)
  skip_query_cache_if_necessary do
    rows = exec_main_query            # or future_result.result for async
    records = instantiate_records(rows, &block)
    preload_associations(records) unless skip_preloading_value
    records
  end
end
```

**`Relation#exec_main_query`** — `relation.rb:1453`
```ruby
def exec_main_query(async: false)
  skip_query_cache_if_necessary do
    # eager_loading? → JOIN strategy; otherwise:
    model.with_connection do |c|
      model._query_by_sql(c, arel, async: async)
    end
  end
end
```

The path: `_query_by_sql` → `arel.to_sql` (Arel AST → SQL string) → connection adapter's `select_all` → adapter-specific `execute` (e.g. `ActiveRecord::ConnectionAdapters::SQLite3Adapter#execute`) → raw DB call → result set.

`instantiate_records` allocates `Post` objects and calls `init_internals` + `after_find` callbacks. `preload_associations` runs a second `SELECT ... WHERE id IN (...)` per `includes` to prevent N+1 queries.

---

## 8. Rendering — from controller to HTML

After the action method returns Rails checks `performed?` (whether `response_body` was set). If not, implicit rendering fires. Either way the path is:

**`ActionController::Rendering#render`** — `metal/rendering.rb:176`
```ruby
def render(*args)
  raise DoubleRenderError if response_body
  super
end
```

**`AbstractController::Rendering#render`** — `abstract_controller/rendering.rb:26`
```ruby
def render(*args, &block)
  options = _normalize_render(*args, &block)
  rendered_body = render_to_body(options)
  _set_html_content_type   # or _set_rendered_content_type
  _set_vary_header
  self.response_body = rendered_body
end
```

`render_to_body` is another `super` chain. The load-bearing override is:

**`ActionView::Rendering#render_to_body`** — `actionview/lib/action_view/rendering.rb:119`
```ruby
def render_to_body(options = {}, &block)
  _process_options(options)
  _process_render_template_options(options)
  _render_template(options, &block)
end
```

**`ActionView::Rendering#_render_template`** — `rendering.rb:127`
```ruby
def _render_template(options, &block)
  variant = options.delete(:variant)
  assigns = options.delete(:assigns)
  context = view_context       # ← key step

  context.assign assigns if assigns
  lookup_context.variants = variant if variant

  rendered_template = context.in_rendering_context(options) do |renderer|
    renderer.render_to_object(context, options, &block)
  end

  rendered_format = rendered_template.format || lookup_context.formats.first
  @_rendered_format = Template::Types[rendered_format]
  rendered_template.body
end
```

**`ActionView::Rendering#view_context`** — `rendering.rb:109`
```ruby
def view_context
  view_context_class.new(lookup_context, view_assigns, self)
end
```
`view_context_class` is a dynamically built `ActionView::Base` subclass that incorporates all helper modules for this controller. `view_assigns` copies all controller instance variables (`@post`, `@user`, etc.) into the new view object.

---

## 9. The view renderer

**`ActionView::Renderer#render_to_object`** — `actionview/lib/action_view/renderer/renderer.rb:27`
```ruby
def render_to_object(context, options, &block)
  if options.key?(:partial)
    render_partial_to_object(context, options)
  else
    render_template_to_object(context, options, &block)
  end
end
```

**`ActionView::Renderer#render_template_to_object`** — `renderer.rb:57`
```ruby
def render_template_to_object(context, options, &block)
  TemplateRenderer.new(@lookup_context).render(context, options, &block)
end
```

**`TemplateRenderer#render`** — `actionview/lib/action_view/renderer/template_renderer.rb:5`
```ruby
def render(context, options, &block)
  @details = extract_details(options)
  template = determine_template(options, &block)   # template lookup
  prepend_formats(template.format)
  render_template(context, template, options[:layout], options[:locals] || {})
end
```

`determine_template` delegates to **`LookupContext#find`** — `lookup_context.rb:130`. `LookupContext` holds the view-paths array and a `DetailsKey` (locale, format, variant) cache. It resolves `"posts/show"` + `{format: :html, locale: :en}` → `app/views/posts/show.html.erb` by walking each resolver in order.

**`TemplateRenderer#render_template`** — `template_renderer.rb:58`
```ruby
def render_template(view, template, layout_name, locals)
  render_with_layout(view, template, layout_name, locals) do |layout|
    ActiveSupport::Notifications.instrument("render_template.action_view", ...) do
      template.render(view, locals) { |*name| view._layout_for(*name) }
    end
  end
end
```

**`TemplateRenderer#render_with_layout`** — `template_renderer.rb:71`
```ruby
def render_with_layout(view, template, path, locals)
  layout = path && find_layout(path, locals.keys, [formats.first])
  body = if layout
    ActiveSupport::Notifications.instrument("render_layout.action_view", ...) do
      view.view_flow.set(:layout, yield(layout))
      layout.render(view, locals) { |*name| view._layout_for(*name) }
    end
  else
    yield
  end
  build_rendered_template(body, template)
end
```
The block `yield(layout)` renders the action template first; that string is stored as the `layout` content-flow slot. Then the layout template is rendered, and `yield` inside the layout ERB reads from `view_flow`.

---

## 10. Template compilation and execution

**`ActionView::Template#render`** — `actionview/lib/action_view/template.rb:280`
```ruby
def render(view, locals, buffer = nil, implicit_locals: [], add_to_stack: true, &block)
  instrument_render_template do
    compile!(view)
    # strict_locals handling ...
    result = view._run(method_name, self, locals, OutputBuffer.new,
                       add_to_stack: add_to_stack,
                       has_strict_locals: strict_locals?, &block)
    result.is_a?(OutputBuffer) ? result.to_s : result
  end
rescue => e
  handle_render_error(view, e)
end
```

**`Template#compile!`** — `template.rb:433` — thread-safe, once-only:
```ruby
def compile!(view)
  return if @compiled
  @compile_mutex.synchronize do
    return if @compiled
    mod = view.compiled_method_container   # anonymous Module on the view context class
    instrument("!compile_template") do
      compile(mod)                          # Template#compile
    end
    @compiled = true
  end
end
```

**`Template#compile`** — `template.rb:515`
```ruby
def compile(mod)
  mod.module_eval(compiled_source, identifier, offset)
  # strict_locals: validate parameter types, freeze @strict_local_keys
end
```
`compiled_source` is the ERB/Haml/etc. handler's output: a Ruby method body that concatenates into `output_buffer`. `module_eval` defines this method on the anonymous module mixed into the `ActionView::Base` instance — so the template method lives directly on the view object, making `@post`, helpers, and `output_buffer` all available via `self`.

**`ActionView::Base#_run`** — `base.rb:264`
```ruby
def _run(method, template, locals, buffer, add_to_stack: true, has_strict_locals: false, &block)
  _old_output_buffer, _old_virtual_path, _old_template =
    @output_buffer, @virtual_path, @current_template
  @current_template = template if add_to_stack
  @output_buffer = buffer
  # dispatch to the compiled method:
  public_send(method, locals, buffer, &block)
ensure
  @output_buffer, @virtual_path, @current_template =
    _old_output_buffer, _old_virtual_path, _old_template
end
```
`public_send(method_name, ...)` calls the compiled template method on the `ActionView::Base` instance. The method appends HTML into `@output_buffer` (an `ActiveSupport::SafeBuffer`) and returns it.

---

## 11. Response assembly and return

Back in `AbstractController::Rendering#render`:
```ruby
self.response_body = rendered_body    # the HTML string
```

**`ActionController::Metal#response_body=`** — `metal.rb:234`
```ruby
def response_body=(body)
  if body
    body = [body] if body.is_a?(String)
    response.body = body
    super
  else
    response.reset_body!
  end
end
```

Back in `Metal#dispatch`:
```ruby
request.commit_flash   # ActionDispatch::Flash writes updated FlashHash back to session
to_a                   # → response.to_a → [status_code, headers_hash, body_array]
```

The `[200, {"Content-Type"=>"text/html", ...}, ["<html>..."]]` triple is the return value of `RouteSet#call`. It travels back up the middleware stack. On the return path:

- `Rack::ETag` computes a digest of the body, sets `ETag:` header.
- `Rack::ConditionalGet` checks `If-None-Match` / `If-Modified-Since`; returns `304 Not Modified` with empty body if matched.
- `ActionDispatch::Cookies` sets `Set-Cookie:` headers from the dirty cookie jar.
- `ActionDispatch::Executor` releases thread-local state (clears `ActiveRecord::Base.connection_handler` per-thread state, etc.).
- `Rails::Rack::Logger` logs the completed request line.

The Rack server receives the final `[status, headers, body]` and writes it to the socket.

---

## Unified architecture diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RACK SERVER (Puma / Unicorn / …)   env Hash → app.call(env)               │
└────────────────────────────┬────────────────────────────────────────────────┘
                             │
                             ▼
          Rails::Engine#call  [railties/lib/rails/engine.rb:532]
          builds ActionDispatch::Request; calls app.call(req.env)
                             │
                             ▼
┌─────────────────────────── MIDDLEWARE CHAIN ────────────────────────────────┐
│  built by MiddlewareStack#build [middleware/stack.rb:166]                   │
│  (reverse.inject → each middleware wraps the next)                          │
│                                                                             │
│   ActionDispatch::HostAuthorization   — validate Host header                │
│   ActionDispatch::SSL                 — HTTPS redirect / HSTS               │
│   ActionDispatch::Static              — serve public/ files                 │
│   ActionDispatch::Executor            — thread isolation + code reload      │
│   ActionDispatch::ServerTiming        — Server-Timing header                │
│   Rack::Runtime                       — X-Runtime                           │
│   Rack::MethodOverride                — _method param override              │
│   ActionDispatch::RequestId           — X-Request-Id                        │
│   ActionDispatch::RemoteIp            — compute client IP                   │
│   Rails::Rack::Logger                 — tagged request logging              │
│   ActionDispatch::ShowExceptions      — rescue → error app                  │
│   ActionDispatch::DebugExceptions     — dev: detailed exception pages       │
│   ActionDispatch::Reloader            — dev: reload changed files           │
│   ActionDispatch::Callbacks           — around-request AS::Callbacks        │
│   ActionDispatch::Cookies             — CookieJar                           │
│   ActionDispatch::Session::CookieStore— encrypt/decrypt session cookie      │
│   ActionDispatch::Flash               — FlashHash ↔ session                 │
│   ActionDispatch::ContentSecurityPolicy::Middleware                         │
│   Rack::Head / Rack::ConditionalGet / Rack::ETag                            │
│   ActiveRecord::Middleware::DatabaseSelector / ShardSelector                │
│                            │                                                │
│                     ┌──────▼───────┐                                        │
│                     │  INNER APP   │                                        │
│                     │  RouteSet    │                                        │
│                     └──────────────┘                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
          RouteSet#call  [routing/route_set.rb:903]
          make_request(env) → normalize path → @router.serve(req)
                             │
                             ▼
          Journey::Router#serve
          NFA/DFA pattern match on all routes
          req.path_parameters = {controller:, action:, id:, …}
                             │
                             ▼
          RouteSet::Dispatcher#serve  [route_set.rb:46]
          controller = PostsController   (constantize "posts")
          res = PostsController.make_response!(req)
                             │
                             ▼
          RouteSet::Dispatcher#dispatch  [route_set.rb:64]
          PostsController.dispatch(:show, req, res)
                             │
                             ▼
          ActionController::Metal.dispatch  (class)  [metal.rb:331]
          [optional per-controller middleware chain]
          PostsController.new.dispatch(:show, req, res)
                             │
                             ▼
          ActionController::Metal#dispatch  (instance)  [metal.rb:249]
          set_request!   →  @_request = req
                            req.controller_instance = self
          set_response!
          process(:show)
                             │
                             ▼
          AbstractController::Base#process  [abstract_controller/base.rb:146]
          _find_action_name("show") → validates action is public & not internal
          process_action("show")
                             │
          ┌──────────────────▼──────────────────────────────────┐
          │         process_action  SUPER CHAIN                  │
          │                                                      │
          │  ActionController::Rendering#process_action          │
          │  [metal/rendering.rb:202]                            │
          │  self.formats = request.formats.filter_map(&:ref)    │
          │              │ super                                  │
          │              ▼                                       │
          │  AbstractController::Callbacks#process_action        │
          │  [callbacks.rb:265]                                  │
          │  run_callbacks(:process_action) {                    │
          │    ┌──────────────────────────────┐                  │
          │    │  before_action filters run   │                  │
          │    │  (ActionFilter#match? check) │                  │
          │    └──────────────┬───────────────┘                  │
          │              │ super                                  │
          │              ▼                                       │
          │  AbstractController::Base#process_action             │
          │  [base.rb:223]                                       │
          │  send_action("show")  ←  alias for Ruby send         │
          └──────────────────┬──────────────────────────────────┘
                             │
                             ▼
          PostsController#show  (user code)
          @post = Post.find(params[:id])
          │
          │  Relation#exec_queries  [relation.rb:1429]
          │    exec_main_query      [relation.rb:1453]
          │      model.with_connection { |c|
          │        model._query_by_sql(c, arel)  ← Arel AST → SQL
          │        c.select_all(...)              ← adapter execute
          │      }
          │    instantiate_records  → Array<Post>
          │    preload_associations → N+1 guard (includes)
          │
          render :show   (or implicit)
                             │
                             ▼
          AbstractController::Rendering#render  [rendering.rb:26]
          _normalize_render → options hash
          render_to_body(options) → …
          self.response_body = rendered_body
                             │
          ┌──────────────────▼──────────────────────────────────┐
          │            render_to_body  SUPER CHAIN               │
          │                                                      │
          │  ActionController::Rendering#render_to_body          │
          │  [metal/rendering.rb:196]                            │
          │  super || _render_in_priorities || " "               │
          │              │ super                                  │
          │              ▼                                       │
          │  ActionView::Rendering#render_to_body                │
          │  [action_view/rendering.rb:119]                      │
          │  _process_options                                     │
          │  _render_template(options)                           │
          └──────────────────┬──────────────────────────────────┘
                             │
                             ▼
          ActionView::Rendering#_render_template  [rendering.rb:127]
          view_context = view_context_class.new(
            lookup_context, view_assigns, self)
          (ActionView::Base subclass; @post etc. copied in)
          context.in_rendering_context(options) { |renderer|
            renderer.render_to_object(context, options)
          }
                             │
                             ▼
          ActionView::Renderer#render_to_object  [renderer.rb:27]
          → render_template_to_object
          → TemplateRenderer.new(lookup_context).render(context, options)
                             │
                             ▼
          TemplateRenderer#render  [template_renderer.rb:5]
          determine_template(options)
            LookupContext#find "posts/show" + {format: :html, locale: :en}
            → resolves to app/views/posts/show.html.erb
          render_template(context, template, layout, locals)
                             │
                             ▼
          TemplateRenderer#render_template  [template_renderer.rb:58]
          instrument "render_template.action_view"
          render_with_layout(view, template, layout, locals) { |l|
            template.render(view, locals)   ← action template first
          }
                             │
                             ▼
          TemplateRenderer#render_with_layout  [template_renderer.rb:71]
          find_layout → app/views/layouts/application.html.erb
          view.view_flow.set(:layout, yield(layout))  ← action body stored
          layout.render(view, locals) { view._layout_for }  ← wraps it
                             │
                             ▼  (for each template/layout)
          ActionView::Template#render  [template.rb:280]
          compile!(view)  →  Template#compile  [template.rb:515]
            mod = view.compiled_method_container  (anon Module)
            mod.module_eval(compiled_source, file, line)
            ← defines method "__erb_12345__" on view context
          view._run(method_name, self, locals, OutputBuffer.new)
                             │
                             ▼
          ActionView::Base#_run  [base.rb:264]
          @output_buffer = OutputBuffer.new
          public_send(method_name, locals, buffer)
          ← executes compiled ERB; appends to SafeBuffer
          returns OutputBuffer → .to_s → HTML string
                             │
                             ▼
          rendered HTML string bubbles back through super chain
          ActionController::Metal#response_body=  [metal.rb:234]
          response.body = [html_string]
                             │
                             ▼
          Metal#dispatch finishes:
          request.commit_flash   ← sweep + write flash to session
          to_a  →  response.to_a
                             │
                             ▼
          [200, {"Content-Type"=>"text/html; charset=utf-8", …},
                ["<!DOCTYPE html>…"]]
                             │
          ┌──────────────────▼──────────────────────────────────┐
          │   MIDDLEWARE RETURN PATH (innermost → outermost)     │
          │                                                      │
          │   Rack::ETag         — compute + set ETag header     │
          │   Rack::ConditionalGet — 304 if ETag matches         │
          │   ActionDispatch::Cookies — write Set-Cookie headers │
          │   ActionDispatch::Flash  — (already committed)       │
          │   ActionDispatch::Callbacks — after-request hooks    │
          │   ActionDispatch::Executor — release thread state    │
          │   Rails::Rack::Logger — log "Completed 200 OK"       │
          │   ActionDispatch::ShowExceptions — (passthrough)     │
          └──────────────────┬──────────────────────────────────┘
                             │
                             ▼
     RACK SERVER writes [200, headers, body] to TCP socket
```

---

## Key invariants to hold in mind

1. **Every class-method `dispatch` runs controller-scoped middleware** before the instance `dispatch`, making per-controller rate-limiting or auth middleware possible without touching global config.

2. **`process_action` is pure module stacking** — every concern (`Rendering`, `Callbacks`, `Instrumentation`, `Rescue`) overrides `process_action` and calls `super`. The order of module inclusion in `ActionController::Base` determines the nesting.

3. **Templates are compiled once, cached forever** (in production). `compile!` is protected by a per-template `Mutex` so concurrent first-requests don't double-compile. The compiled method lives on an anonymous module owned by the view-context class, making each request a plain `public_send` with zero eval overhead after the first call.

4. **Active Record is never called by the framework** — it lives entirely in user-code action methods. The middleware provides connection-pool cleanup (`Executor`) and optional read/write splitting (`DatabaseSelector`/`ShardSelector`), but the ORM itself is invoked only when the action runs `Model.find` or `Model.where`.

5. **The response object is a `Rack::Response` wrapper** and the final `to_a` is its only Rack-contract method. Everything above that level speaks in higher-level `ActionDispatch::Response` / `ActionDispatch::Request` terms, insulated from raw Rack strings by the request/response abstraction layer.

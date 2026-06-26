# transcript: Trace how a Spring Boot application bootstraps when `SpringApplication.run` is called: name every method it passes through, in order, from `SpringApplication...


💬 I'll load the grove tools first as required, then trace the bootstrap sequence.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__definition,mcp__grove__source,mcp__grove__callers,mcp__grove__outline,mcp__grove__map)

💬 Now let me locate `SpringApplication` and its `run` method.
  ▸ mcp__grove__symbols({"dir":".","name":"SpringApplication","kind":"class"})

💬 Let me outline the `SpringApplication.java` file to see all its methods.
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","kind":"method","detail":1})

💬 Now I'll read the bodies of all key methods in the bootstrap sequence in parallel.
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#run@1353"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#run@304"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#prepareEnvironment@350"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#prepareContext@380"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#refreshContext@441"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#refresh@755"})

💬 Let me grab the remaining methods needed to complete the chain.
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#run@1364"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#createBootstrapContext@344"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#createApplicationContext@579"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#configureEnvironment@498"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#getRunListeners@453"})

💬 I have everything needed. Here is the complete ordered trace.  ---  ## Spring Boot bootstrap: `SpringApplication.run` → `applicationContext.refresh()`  All r...

──────── RESULT (success, 87924ms, 15 turns) ────────
I have everything needed. Here is the complete ordered trace.

---

## Spring Boot bootstrap: `SpringApplication.run` → `applicationContext.refresh()`

All references are in `core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java`.

---

### Phase 1 — Static entry points (lines 1353–1364)

```
SpringApplication.run(Class<?> primarySource, String... args)       :1353
  └─ SpringApplication.run(Class<?>[] primarySources, String[] args) :1364
       └─ new SpringApplication(primarySources)
          └─ .run(args)   ← hands off to the instance method
```

`run(Class<?>[],String[])` is a two-liner: it constructs a `SpringApplication` instance and immediately calls the instance `run`.

---

### Phase 2 — Instance `run` (line 304) — the main bootstrap spine

Every step below is called in this order inside `run(String... args)`:

| # | Call | Line |
|---|------|------|
| 1 | `Startup.create()` | 305 |
| 2 | `createBootstrapContext()` | 307 |
| 3 | `configureHeadlessProperty()` | 311 |
| 4 | `getRunListeners(args)` | 312 |
| 5 | `listeners.starting(bootstrapContext, mainApplicationClass)` | 313 |
| 6 | `new DefaultApplicationArguments(args)` | 315 |
| 7 | `prepareEnvironment(listeners, bootstrapContext, applicationArguments)` | 316 |
| 8 | `printBanner(environment)` | 317 |
| 9 | `createApplicationContext()` | 318 |
| 10 | `context.setApplicationStartup(this.applicationStartup)` | 319 |
| 11 | `prepareContext(bootstrapContext, context, environment, listeners, …)` | 320 |
| 12 | `refreshContext(context)` ← **refresh happens here** | 321 |
| 13 | `afterRefresh(context, applicationArguments)` | 322 |
| 14 | `startup.started()` | 323 |
| 15 | `listeners.started(context, timeTakenToStarted)` | 327 |
| 16 | `callRunners(context, applicationArguments)` | 328 |
| 17 | `listeners.ready(context, startup.ready())` | 333 |

---

### Phase 3 — `createBootstrapContext` (line 344)

```
createBootstrapContext()
  new DefaultBootstrapContext()
  bootstrapRegistryInitializers.forEach(initializer -> initializer.initialize(bootstrapContext))
```

Runs every registered `BootstrapRegistryInitializer` before anything else touches the environment.

---

### Phase 4 — `getRunListeners` (line 453)

```
getRunListeners(args)
  getSpringFactoriesInstances(SpringApplicationRunListener.class, argumentResolver)
  applicationHook.get().getRunListener(this)   // if a hook is set
  new SpringApplicationRunListeners(logger, listeners, applicationStartup)
```

Loads `SpringApplicationRunListener` implementations from `spring.factories` (the main one is `EventPublishingRunListener`).

---

### Phase 5 — `prepareEnvironment` (line 350)

```
prepareEnvironment(listeners, bootstrapContext, applicationArguments)
  getOrCreateEnvironment()                          // creates env by web-app type
  configureEnvironment(environment, sourceArgs)
    configurePropertySources(environment, args)    // adds default + cmd-line sources
    configureProfiles(environment, args)
  ConfigurationPropertySources.attach(environment)
  listeners.environmentPrepared(bootstrapContext, environment)   // ApplicationEnvironmentPreparedEvent
  ApplicationInfoPropertySource.moveToEnd(environment)
  DefaultPropertiesPropertySource.moveToEnd(environment)
  bindToSpringApplication(environment)             // binds spring.main.* back onto this instance
  EnvironmentConverter.convertEnvironmentIfNecessary(environment, deduceEnvironmentClass())
  ConfigurationPropertySources.attach(environment) // re-attach after conversion
```

---

### Phase 6 — `createApplicationContext` (line 579)

```
createApplicationContext()
  applicationContextFactory.create(properties.getWebApplicationType())
```

`ApplicationContextFactory` selects the concrete context type: `AnnotationConfigServletWebServerApplicationContext` (servlet), `AnnotationConfigReactiveWebServerApplicationContext` (reactive), or `AnnotationConfigApplicationContext` (non-web).

---

### Phase 7 — `prepareContext` (line 380)

```
prepareContext(bootstrapContext, context, environment, listeners, applicationArguments, printedBanner)
  context.setEnvironment(environment)
  postProcessApplicationContext(context)            // sets ResourceLoader, ClassLoader, BeanNameGenerator
  addAotGeneratedInitializerIfNecessary(initializers)
  applyInitializers(context)                        // runs ApplicationContextInitializer chain
  listeners.contextPrepared(context)                // ApplicationContextInitializedEvent
  bootstrapContext.close(context)                   // fires BootstrapContextClosedEvent
  logStartupInfo(context)
  logStartupProfileInfo(context)
  beanFactory.registerSingleton("springApplicationArguments", applicationArguments)
  beanFactory.registerSingleton("springBootBanner", printedBanner)   // if banner present
  context.addBeanFactoryPostProcessor(LazyInitializationBeanFactoryPostProcessor)   // if lazy-init
  context.addApplicationListener(KeepAlive)        // if keep-alive enabled
  context.addBeanFactoryPostProcessor(PropertySourceOrderingBeanFactoryPostProcessor)
  load(context, getAllSources())                    // reads @Configuration classes / XML / packages
  listeners.contextLoaded(context)                 // ApplicationPreparedEvent
```

---

### Phase 8 — `refreshContext` → `refresh` → **`applicationContext.refresh()`** (lines 441, 755)

```
refreshContext(context)                                        :441
  shutdownHook.registerApplicationContext(context)            // registers JVM shutdown hook
  refresh(context)                                            :755
    applicationContext.refresh()                              ← Spring Framework AbstractApplicationContext.refresh()
```

`refresh()` is the single-line bridge from Boot to the Spring Framework: it delegates to `AbstractApplicationContext.refresh()`, which runs the full bean factory post-processing, singleton instantiation, and embedded server start.

---

### Summary call chain

```
SpringApplication.run(Class<?>)                       static :1353
  SpringApplication.run(Class<?>[], String[])         static :1364
    new SpringApplication(primarySources)
    .run(String... args)                              instance :304
      createBootstrapContext()                                 :344
      configureHeadlessProperty()                             :448
      getRunListeners()                                       :453
      listeners.starting()
      prepareEnvironment()                                    :350
        getOrCreateEnvironment()                              :475
        configureEnvironment()                                :498
          configurePropertySources()                         :513
          configureProfiles()                                 :543
        listeners.environmentPrepared()
        bindToSpringApplication()                            :550
      printBanner()                                          :559
      createApplicationContext()                             :579
      prepareContext()                                       :380
        postProcessApplicationContext()                      :591
        applyInitializers()                                  :616
        listeners.contextPrepared()
        load()                                               :683
        listeners.contextLoaded()
      refreshContext()                                       :441
        refresh()                                            :755
          applicationContext.refresh()  ◄── Spring Framework takes over
```

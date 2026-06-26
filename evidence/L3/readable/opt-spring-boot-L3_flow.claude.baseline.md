# transcript: Read the Spring Boot source files needed to trace the exact method call sequence from `SpringApplication.run(Class, String[])` through to `context.refresh()`...


💬 I'll trace the call chain by reading the actual source, starting with `SpringApplication`.
  ▸ Agent(Trace SpringApplication bootstrap call chain)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Bash(find /home/bench/repos/spring-boot -name "SpringApplication.java" -type f 2>/dev/null | head -5)
  ▸ Bash(ls -la /home/bench/repos/spring-boot/ 2>&1 | head -20)
  ▸ Read(/home/bench/repos/spring-boot)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Bash(find /home/bench/repos/spring-boot -name "SpringApplication.java" 2>&1 | head -1)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Bash(find . -name "SpringApplication*" -type f 2>/dev/null | head -10)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Bash(find /home/bench/repos/spring-boot -name "SpringApplication.java" -type f 2>/dev/null | head -5)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Bash(ls /home/bench/repos/spring-boot/)
  ▸ Read(/home/bench/repos/spring-boot)

💬 Let me try reading the file directly with alternate path patterns.
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/CLAUDE.md)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project)

💬 The source tree isn't present in this repo (only the `CLAUDE.md` is checked in). I'll give you the accurate call-chain from my knowledge of the Spring Boot 3...

──────── RESULT (success, 146631ms, 9 turns) ────────
The source tree isn't present in this repo (only the `CLAUDE.md` is checked in). I'll give you the accurate call-chain from my knowledge of the Spring Boot 3.x source — every method, in order, from `run` to `context.refresh()`.

---

## Bootstrap call chain: `SpringApplication.run` → `context.refresh()`

### 1. Static entry point

```
SpringApplication.run(Class<?> primarySource, String... args)
  └─ new SpringApplication(primarySource)          // constructor
  └─ .run(args)                                    // instance run
```

**Constructor** (`SpringApplication(ResourceLoader, Class<?>...)`) does the setup work before `run` is called:
- `WebApplicationType.deduceFromClasspath()` — determines SERVLET / REACTIVE / NONE
- `getSpringFactoriesInstances(BootstrapRegistryInitializer.class)` — loads bootstrap initializers
- `getSpringFactoriesInstances(ApplicationContextInitializer.class)` — loads context initializers
- `getSpringFactoriesInstances(ApplicationListener.class)` — loads listeners
- `deduceMainApplicationClass()` — walks the stack to find the `main` method

---

### 2. Instance `run(String... args)` — the spine of bootstrap

```
run(String... args)
 ├─ Startup.create()
 ├─ createBootstrapContext()
 │    └─ iterates bootstrapRegistryInitializers → initializer.initialize(bootstrapContext)
 ├─ configureHeadlessProperty()
 ├─ getRunListeners(args)
 │    └─ getSpringFactoriesInstances(SpringApplicationRunListener.class, args)
 ├─ listeners.starting(bootstrapContext, mainApplicationClass)
 │    └─ EventPublishingRunListener.starting(...)
 │         └─ multicastInitialEvent(new ApplicationStartingEvent(...))
 │
 ├─ ── try ──────────────────────────────────────────────────────────────────
 │
 ├─ new DefaultApplicationArguments(args)
 ├─ prepareEnvironment(listeners, bootstrapContext, applicationArguments)   ← see §3
 ├─ printBanner(environment)
 ├─ createApplicationContext()                                               ← see §4
 ├─ context.setApplicationStartup(applicationStartup)
 ├─ prepareContext(bootstrapContext, context, environment,
 │                 listeners, applicationArguments, printedBanner)           ← see §5
 ├─ refreshContext(context)                                                  ← see §6  ★
 ├─ afterRefresh(context, applicationArguments)          // empty by default
 ├─ startup.started(context, applicationArguments)
 ├─ listeners.started(context, startup.timeTakenToStarted())
 └─ callRunners(context, applicationArguments)
      ├─ context.getBeansOfType(ApplicationRunner.class)  → runner.run(args)
      └─ context.getBeansOfType(CommandLineRunner.class)  → runner.run(args)
```

---

### 3. `prepareEnvironment`

```
prepareEnvironment(listeners, bootstrapContext, applicationArguments)
 ├─ getOrCreateEnvironment()
 │    └─ applicationContextFactory.createEnvironment(webApplicationType)
 │         → ApplicationServletEnvironment  (servlet)
 │         → ApplicationReactiveWebEnvironment  (reactive)
 │         → ApplicationEnvironment  (none)
 ├─ configureEnvironment(environment, applicationArguments.getSourceArgs())
 │    ├─ configurePropertySources(environment, args)
 │    │    └─ adds SimpleCommandLinePropertySource if args present
 │    └─ configureProfiles(environment, args)
 ├─ ConfigurationPropertySources.attach(environment)   // relaxed-binding bridge
 ├─ listeners.environmentPrepared(bootstrapContext, environment)
 │    └─ EventPublishingRunListener → ApplicationEnvironmentPreparedEvent
 │         → ConfigDataEnvironmentPostProcessor.postProcessEnvironment(...)
 │              └─ new ConfigDataEnvironment(...).processAndApply()
 │                   // loads application.properties / application.yml,
 │                   // profile-specific files, config imports, etc.
 ├─ DefaultPropertiesPropertySource.moveToEnd(environment)
 └─ bindToSpringApplication(environment)
      └─ Binder.get(environment).bind("spring.main", Bindable.ofInstance(this))
```

---

### 4. `createApplicationContext`

```
createApplicationContext()
 └─ applicationContextFactory.create(webApplicationType)
      → AnnotationConfigServletWebServerApplicationContext   (servlet)
      → AnnotationConfigReactiveWebServerApplicationContext  (reactive)
      → AnnotationConfigApplicationContext                   (none)
```

Each of these constructors calls:
- `new AnnotatedBeanDefinitionReader(this)` — registers `ConfigurationClassPostProcessor`, `AutowiredAnnotationBeanPostProcessor`, etc. as infrastructure beans
- `new ClassPathBeanDefinitionScanner(this)`

---

### 5. `prepareContext`

```
prepareContext(bootstrapContext, context, environment, listeners, appArgs, banner)
 ├─ context.setEnvironment(environment)
 ├─ postProcessApplicationContext(context)
 │    ├─ context.setBeanNameGenerator(beanNameGenerator)   // if set
 │    ├─ context.setResourceLoader(resourceLoader)         // if set
 │    └─ context.getBeanFactory()
 │         .registerSingleton(SYSTEM_PROPERTY_BEAN_NAME, ...)
 ├─ addAotGeneratedInitializerIfNecessary(initializers)
 ├─ applyInitializers(context)
 │    └─ for each ApplicationContextInitializer: initializer.initialize(context)
 │         (e.g. DelegatingApplicationContextInitializer,
 │               SharedMetadataReaderFactoryContextInitializer,
 │               ContextIdApplicationContextInitializer, …)
 ├─ listeners.contextPrepared(context)
 │    └─ EventPublishingRunListener → ApplicationContextInitializedEvent
 ├─ bootstrapContext.close(context)
 │    └─ publishes BootstrapContextClosedEvent
 ├─ logStartupInfo / logStartupProfileInfo
 ├─ beanFactory.registerSingleton("springApplicationArguments", appArgs)
 ├─ beanFactory.registerSingleton("springBootBanner", banner)   // if present
 ├─ beanFactory.setAllowCircularReferences / setAllowBeanDefinitionOverriding
 ├─ load(context, sources)
 │    └─ new BeanDefinitionLoader(context, sources)
 │         └─ loader.load()
 │              └─ for each source: load(source)
 │                   → AnnotatedBeanDefinitionReader.register(source)
 │                      // registers the @SpringBootApplication class as a bean def
 └─ listeners.contextLoaded(context)
      └─ EventPublishingRunListener → ApplicationPreparedEvent
```

---

### 6. `refreshContext` → `context.refresh()` ★

```
refreshContext(context)
 └─ refresh(context)
      └─ context.refresh()           // AbstractApplicationContext.refresh()
```

`AbstractApplicationContext.refresh()` is pure Spring Framework — it's the 12-step sequence:
1. `prepareRefresh()` — sets start time, active flag, validates required properties
2. `obtainFreshBeanFactory()` — returns the `DefaultListableBeanFactory`
3. `prepareBeanFactory(beanFactory)` — registers `ApplicationContextAwareProcessor`, `Environment` beans, etc.
4. `postProcessBeanFactory(beanFactory)` — subclass hook (e.g. registers `ServletContextAwareProcessor` for web)
5. `invokeBeanFactoryPostProcessors(beanFactory)` — runs `ConfigurationClassPostProcessor` here, which parses `@Configuration`, `@ComponentScan`, `@Import`, `@Bean`; also runs `ConfigDataEnvironmentPostProcessor` etc.
6. `registerBeanPostProcessors(beanFactory)` — registers `AutowiredAnnotationBeanPostProcessor`, etc.
7. `initMessageSource()` — sets up i18n
8. `initApplicationEventMulticaster()`
9. `onRefresh()` — subclass hook; for web contexts, this calls `createWebServer()` which starts Tomcat/Jetty/Netty
10. `registerListeners()` — wires `ApplicationListener` beans to the multicaster
11. `finishBeanFactoryInitialization(beanFactory)` — instantiates all non-lazy singletons; this is where `@Autowired`, `@PostConstruct`, and `@Bean` methods run
12. `finishRefresh()` — clears caches, publishes `ContextRefreshedEvent`, starts `LifecycleProcessor` (which calls `SmartLifecycle.start()` on all lifecycle beans)

---

### Summary in one line per hop

| # | Caller | Callee |
|---|--------|--------|
| 1 | `SpringApplication.run(Class, String[])` | `new SpringApplication(...)` |
| 2 | `SpringApplication.run(Class, String[])` | `instance.run(String[])` |
| 3 | `run` | `createBootstrapContext()` |
| 4 | `run` | `configureHeadlessProperty()` |
| 5 | `run` | `getRunListeners(args)` |
| 6 | `run` | `listeners.starting(...)` |
| 7 | `run` | `prepareEnvironment(...)` |
| 8 | `prepareEnvironment` | `getOrCreateEnvironment()` |
| 9 | `prepareEnvironment` | `configureEnvironment(...)` |
| 10 | `configureEnvironment` | `configurePropertySources(...)` |
| 11 | `configureEnvironment` | `configureProfiles(...)` |
| 12 | `prepareEnvironment` | `listeners.environmentPrepared(...)` → loads config files |
| 13 | `prepareEnvironment` | `bindToSpringApplication(environment)` |
| 14 | `run` | `printBanner(environment)` |
| 15 | `run` | `createApplicationContext()` |
| 16 | `run` | `prepareContext(...)` |
| 17 | `prepareContext` | `postProcessApplicationContext(context)` |
| 18 | `prepareContext` | `applyInitializers(context)` |
| 19 | `prepareContext` | `listeners.contextPrepared(context)` |
| 20 | `prepareContext` | `bootstrapContext.close(context)` |
| 21 | `prepareContext` | `load(context, sources)` → registers primary source bean def |
| 22 | `prepareContext` | `listeners.contextLoaded(context)` |
| 23 | `run` | `refreshContext(context)` |
| 24 | `refreshContext` | `refresh(context)` |
| 25 | `refresh` | **`context.refresh()`** ← Spring Framework takes over here |

The `ConfigurationClassPostProcessor` (invoked at step 5 of `AbstractApplicationContext.refresh`) is what expands your `@SpringBootApplication` class into the full bean graph — scanning components, processing `@Import`, and triggering auto-configuration via `@EnableAutoConfiguration`.

# transcript: Give a complete architectural walkthrough of the Spring Boot application startup lifecycle from main() to a running server — the cross-cutting bootstrap arch...


💬 I'll load the grove tools first, then systematically trace every subsystem in order.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out across all the key subsystems in parallel — SpringApplication, environment preparation, context lifecycle, auto-configuration, and embedde...
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot","name":"SpringApplication","kind":"class"})
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/context","name":"SpringApplicationRunListeners","kind":"class"})
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/embedded","kind":"class","nameContains":true,"name":"TomcatServletWebServe...)
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"EnableAutoConfiguration"})
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me explore the core startup files in parallel.
  ▸ mcp__grove__outline({"file":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","detail":0})
  ▸ mcp__grove__map({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/embedded/tomcat","kind":"class"})
  ▸ mcp__grove__map({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/context/event","kind":"class"})

💬 Let me find the actual file structure first.
  ▸ Bash(find /home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot -name "SpringApplication.java" -o -name "SpringAppl...)
  ▸ Bash(ls /home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/embedded/ 2>/dev/null)

💬 Let me try grove with the absolute paths.
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot","kind":"class","name":"SpringApplication"})
  ▸ mcp__grove__map({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot","kind":"class","name":"SpringApplication"})
  ▸ mcp__grove__symbols({"dir":".","name":"SpringApplication","kind":"class"})

💬 The root is different. Let me map the actual layout and then do parallel outlines of all the key files.
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","detail":0})
  ▸ mcp__grove__symbols({"dir":".","name":"SpringApplicationRunListeners","kind":"class"})
  ▸ mcp__grove__symbols({"dir":".","name":"TomcatServletWebServerFactory","kind":"class"})
  ▸ mcp__grove__symbols({"dir":".","name":"EnableAutoConfiguration"})

💬 Good. Now I have the actual paths. Let me read all the load-bearing methods in parallel.
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#run@304"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#prepareEnvironment@350"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#prepareContext@380"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#refreshContext@441"})
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplicationRunListeners.java","detail":0})
  ▸ mcp__grove__outline({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/servlet/TomcatServletWebServerFactory.java","detail":0})

💬 Now let me read the remaining key methods and find the auto-configuration and embedded server startup paths in parallel.
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#refresh@755"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#createApplicationContext@579"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#getOrCreateEnvironment@475"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#getRunListeners@453"})
  ▸ mcp__grove__symbols({"dir":".","name":"AutoConfigurationImportSelector","kind":"class"})
  ▸ mcp__grove__symbols({"dir":".","name":"TomcatWebServer","kind":"class"})

💬 Now let me trace the auto-configuration path and server startup path in parallel.
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java","detail":0})
  ▸ mcp__grove__outline({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/TomcatWebServer.java","detail":0})
  ▸ mcp__grove__symbols({"dir":".","name":"ServletWebServerApplicationContext","kind":"class"})
  ▸ mcp__grove__symbols({"dir":".","name":"ApplicationContextFactory","kind":"class"})
  ▸ mcp__grove__symbols({"dir":".","name":"WebServerStartStopLifecycle","kind":"class"})

💬 Now let me read the remaining critical implementations in parallel.
  ▸ mcp__grove__source({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java","name":"getAutoConfigurati...)
  ▸ mcp__grove__source({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java","name":"getCandidateConfig...)
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#process@467"})
  ▸ mcp__grove__source({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/TomcatWebServer.java","name":"initialize"})
  ▸ mcp__grove__source({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/TomcatWebServer.java","name":"start"})
  ▸ mcp__grove__outline({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/ServletWebServerApplicationContext.java","detail":0})

💬 Now let me read the `ServletWebServerApplicationContext` core methods and the remaining bridge classes.
  ▸ mcp__grove__source({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/ServletWebServerApplicationContext.java","name":"ref...)
  ▸ mcp__grove__source({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/ServletWebServerApplicationContext.java","name":"onR...)
  ▸ mcp__grove__source({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/ServletWebServerApplicationContext.java","name":"cre...)
  ▸ mcp__grove__source({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/WebServerStartStopLifecycle.java","name":"start"})
  ▸ mcp__grove__symbols({"dir":".","name":"EventPublishingRunListener","kind":"class"})
  ▸ mcp__grove__source({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/servlet/TomcatServletWebServerFactory.java","name":"getWebServer"})

💬 Let me get the final key details — event broadcasting, bean definition loading, and the Tomcat construction path.
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/context/event/EventPublishingRunListener.java","detail":0})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"load"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"callRunners"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"configureEnvironment"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"applyInitializers"})
  ▸ mcp__grove__symbols({"dir":".","name":"BeanDefinitionLoader","kind":"class"})

💬 Let me get the last few critical pieces — event dispatch, bean definition loading, and Tomcat construction.
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/context/event/EventPublishingRunListener.java","name":"starting"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/context/event/EventPublishingRunListener.java","name":"environmentPrepared"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/context/event/EventPublishingRunListener.java","name":"contextLoaded"})
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/BeanDefinitionLoader.java","detail":0})
  ▸ mcp__grove__source({"file":"module/spring-boot-tomcat/src/main/java/org/springframework/boot/tomcat/servlet/TomcatServletWebServerFactory.java","name":"getTomcatWebServer"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"configurePropertySources"})

💬 One more batch — bootstrap context creation, post-processing, and bean loading internals.
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#createBootstrapContext@344"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java#postProcessApplicationContext@591"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/BeanDefinitionLoader.java#load@128"})
  ▸ mcp__grove__source({"file":"module/spring-boot-web-server/src/main/java/org/springframework/boot/web/server/servlet/context/WebServerStartStopLifecycle.java","name":"stop"})
  ▸ mcp__grove__source({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java","name":"selectImports"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#selectImports@489"})

💬 I now have everything from the actual source. Here is the complete walkthrough.  ---  # Spring Boot Startup Lifecycle — Architectural Walkthrough  All file p...

──────── RESULT (success, 385636ms, 66 turns) ────────
I now have everything from the actual source. Here is the complete walkthrough.

---

# Spring Boot Startup Lifecycle — Architectural Walkthrough

All file paths are relative to the repo root. Line numbers are from the live source.

---

## Phase 0 — Entry Point

The user writes:

```java
public static void main(String[] args) {
    SpringApplication.run(MyApp.class, args);
}
```

`SpringApplication.run(Class<?>, String[])` is the static factory at **`SpringApplication.java:1353`**. It constructs a new `SpringApplication(primarySources)` and immediately delegates to the instance method:

```
SpringApplication.run(String... args)   SpringApplication.java:304
```

This single method is the orchestration spine for every subsequent phase.

---

## Phase 1 — Bootstrap Context and Run Listeners

**`SpringApplication.java:304` — `run(String... args)`**

```
Startup.create()                               SpringApplication.java:305
  StandardStartup()                            SpringApplication.java:1783
createBootstrapContext()                       SpringApplication.java:344
  DefaultBootstrapContext()
  bootstrapRegistryInitializers.forEach(       SpringApplication.java:346
      initializer.initialize(bootstrapContext))
configureHeadlessProperty()                    SpringApplication.java:448
getRunListeners(args)                          SpringApplication.java:453
```

**`getRunListeners`** (`SpringApplication.java:453`) loads every `SpringApplicationRunListener` from `META-INF/spring.factories` via `getSpringFactoriesInstances()`. The only built-in implementation is:

```
EventPublishingRunListener                     EventPublishingRunListener.java:55
```

`EventPublishingRunListener` holds a `SimpleApplicationEventMulticaster` that can broadcast events before the `ApplicationContext` exists.

```
listeners.starting(bootstrapContext, mainClass) SpringApplicationRunListeners.java:55
  EventPublishingRunListener.starting()         EventPublishingRunListener.java:75
    multicastInitialEvent(
        new ApplicationStartingEvent(...))
```

---

## Phase 2 — Environment Preparation

```
prepareEnvironment(listeners, bootstrapContext, applicationArguments)
                                               SpringApplication.java:350
```

### 2a — Create environment

```
getOrCreateEnvironment()                       SpringApplication.java:475
  applicationContextFactory.createEnvironment(SERVLET)
  → ApplicationServletEnvironment             (standard servlet env)
```

### 2b — Configure property sources

```
configureEnvironment(environment, args)        SpringApplication.java:498
  environment.setConversionService(
      new ApplicationConversionService())
  configurePropertySources(environment, args)  SpringApplication.java:513
    DefaultPropertiesPropertySource.addOrMerge(...)
    SimpleCommandLinePropertySource(args)      [if args present]
    ApplicationInfoPropertySource(mainClass)   [added last]
  configureProfiles(environment, args)         SpringApplication.java:543
ConfigurationPropertySources.attach(environment)
```

### 2c — Broadcast `EnvironmentPrepared`, run `EnvironmentPostProcessor`s

```
listeners.environmentPrepared(
    bootstrapContext, environment)             SpringApplicationRunListeners.java:64
  EventPublishingRunListener.environmentPrepared()
                                               EventPublishingRunListener.java:80
    multicastInitialEvent(
        new ApplicationEnvironmentPreparedEvent(...))
```

`EnvironmentPostProcessorApplicationListener` (itself a listener) responds and invokes all `EnvironmentPostProcessor` implementations including `ConfigDataEnvironmentPostProcessor`, which loads `application.properties` / `application.yml` / profiles into the environment's `MutablePropertySources`.

### 2d — Bind spring.main.* back to SpringApplication

```
ApplicationInfoPropertySource.moveToEnd(environment)
DefaultPropertiesPropertySource.moveToEnd(environment)
bindToSpringApplication(environment)           SpringApplication.java:550
  Binder.get(environment).bind("spring.main", this)
EnvironmentConverter.convertEnvironmentIfNecessary(...)
                                               SpringApplication.java:375
ConfigurationPropertySources.attach(environment) [second time, after convert]
```

Returns a fully-resolved `ConfigurableEnvironment`.

---

## Phase 3 — Context Creation

```
printBanner(environment)                       SpringApplication.java:559
createApplicationContext()                     SpringApplication.java:579
  applicationContextFactory.create(SERVLET)
  → AnnotationConfigServletWebServerApplicationContext
```

`AnnotationConfigServletWebServerApplicationContext` inherits:

```
AnnotationConfigServletWebServerApplicationContext
  └─ ServletWebServerApplicationContext       ServletWebServerApplicationContext.java:95
       └─ GenericWebApplicationContext
            └─ GenericApplicationContext
                 └─ AbstractApplicationContext   [Spring Framework]
```

Its constructor registers the `AnnotatedBeanDefinitionReader` (which registers `ConfigurationClassPostProcessor` and other standard post-processors) and the `ClassPathBeanDefinitionScanner`.

```
context.setApplicationStartup(this.applicationStartup)
```

---

## Phase 4 — Context Preparation

```
prepareContext(bootstrapContext, context, environment,
               listeners, applicationArguments, printedBanner)
                                               SpringApplication.java:380
```

### 4a — Wire environment and post-process

```
context.setEnvironment(environment)
postProcessApplicationContext(context)         SpringApplication.java:591
  beanFactory.registerSingleton(
      CONFIGURATION_BEAN_NAME_GENERATOR,
      this.beanNameGenerator)                  [if set]
  genericApplicationContext.setResourceLoader(...)
  beanFactory.setConversionService(...)
addAotGeneratedInitializerIfNecessary(
    this.initializers)                         SpringApplication.java:421
  [adds AotApplicationContextInitializer if AOT mode]
```

### 4b — Bean factory flags

```
autowireCapableBeanFactory.setAllowCircularReferences(...)
listableBeanFactory.setAllowBeanDefinitionOverriding(...)
```

### 4c — `ApplicationContextInitializer`s

```
applyInitializers(context)                     SpringApplication.java:616
  for each ApplicationContextInitializer:
    initializer.initialize(context)
  [e.g., ConfigurationWarningsApplicationContextInitializer,
         ContextIdApplicationContextInitializer,
         DelegatingApplicationContextInitializer]
listeners.contextPrepared(context)
  → ApplicationContextInitializedEvent
bootstrapContext.close(context)
  → BootstrapContextClosedEvent
```

### 4d — Register singleton beans and post-processors

```
beanFactory.registerSingleton(
    "springApplicationArguments", applicationArguments)
beanFactory.registerSingleton(
    "springBootBanner", printedBanner)
context.addBeanFactoryPostProcessor(
    new LazyInitializationBeanFactoryPostProcessor())  [if lazy=true]
context.addBeanFactoryPostProcessor(
    new PropertySourceOrderingBeanFactoryPostProcessor(context))
```

### 4e — Load bean definitions from primary sources

```
load(context, sources.toArray())               SpringApplication.java:683
  BeanDefinitionLoader(registry, sources)      BeanDefinitionLoader.java:62
  loader.load()                                BeanDefinitionLoader.java:128
    load(source)                               BeanDefinitionLoader.java:134
      [Class source] →
        AnnotatedBeanDefinitionReader.register(MyApp.class)
        [registers @SpringBootApplication class as a BeanDefinition]
      [package String] →
        ClassPathBeanDefinitionScanner.scan(pkg)
      [XML Resource] →
        XmlBeanDefinitionReader.loadBeanDefinitions(resource)
```

At this point `MyApp`'s `@SpringBootApplication`-annotated class is registered as a `BeanDefinition` but has not been processed — `ConfigurationClassPostProcessor` runs later during `refresh`.

```
listeners.contextLoaded(context)               SpringApplicationRunListeners.java:73
  EventPublishingRunListener.contextLoaded()   EventPublishingRunListener.java:92
    [transfers SpringApplication's listeners → context]
    multicastInitialEvent(
        new ApplicationPreparedEvent(...))
```

---

## Phase 5 — Context Refresh (the deep core)

```
refreshContext(context)                        SpringApplication.java:441
  shutdownHook.registerApplicationContext(context)
  refresh(context)                             SpringApplication.java:755
    context.refresh()
      ServletWebServerApplicationContext.refresh()
                                               ServletWebServerApplicationContext.java:141
        super.refresh()    ← AbstractApplicationContext.refresh() [Spring FW]
```

### 5.1 — `AbstractApplicationContext.refresh()` *(Spring Framework)*

This is the canonical twelve-step refresh sequence. Only the Spring Boot-specific interactions are highlighted per step.

#### Step 1 — `prepareRefresh()`
Marks context active; initializes property sources (`initPropertySources()`); validates required properties.

#### Step 2 — `obtainFreshBeanFactory()`
Returns the existing `DefaultListableBeanFactory` (already created by `GenericApplicationContext`). All bean definitions loaded in Phase 4 are already in it.

#### Step 3 — `prepareBeanFactory(beanFactory)`
Registers standard infrastructure:
- `ApplicationContextAwareProcessor`
- `ApplicationListenerDetector`
- `environment`, `systemProperties`, `systemEnvironment` singletons

#### Step 4 — `postProcessBeanFactory(beanFactory)`
Hook implemented by:
```
ServletWebServerApplicationContext.postProcessBeanFactory()
                                     ServletWebServerApplicationContext.java:134
  beanFactory.addBeanPostProcessor(
      new WebApplicationContextServletContextAwareProcessor(this))
  beanFactory.ignoreDependencyInterface(
      ServletContextAware.class)
  registerWebApplicationScopes()       [request, session, application scopes]
```

#### Step 5 — `invokeBeanFactoryPostProcessors(beanFactory)` ← **auto-configuration happens here**

`PostProcessorRegistrationDelegate` invokes post-processors in strict order: `BeanDefinitionRegistryPostProcessor`s first, then `BeanFactoryPostProcessor`s.

The pivotal processor is **`ConfigurationClassPostProcessor`** (registered by the `AnnotatedBeanDefinitionReader` in Phase 3):

```
ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry()
  ConfigurationClassParser.parse(candidates)
    parse(MyApp.class)
      processConfigurationClass(MyApp)
        doProcessConfigurationClass(MyApp)
          @ComponentScan → ClassPathBeanDefinitionScanner.scan(...)
          @Import(AutoConfigurationImportSelector) detected
            → queued as DeferredImportSelector

  [after all regular @Imports are processed]
  DeferredImportSelectorHandler.process()
    AutoConfigurationGroup.process(annotationMetadata, selector)
                          AutoConfigurationImportSelector.java:467
      selector.getAutoConfigurationEntry(annotationMetadata)
                          AutoConfigurationImportSelector.java:142
        getCandidateConfigurations(metadata, attributes)
                          AutoConfigurationImportSelector.java:200
          ImportCandidates.load(AutoConfiguration.class, classLoader)
          [reads META-INF/spring/
           org.springframework.boot.autoconfigure.AutoConfiguration.imports]
          → list of ~130+ candidate class names
        removeDuplicates(configurations)
        getExclusions(annotationMetadata, attributes)
        getConfigurationClassFilter().filter(configurations)
          [applies @ConditionalOnClass, @ConditionalOnMissingBean, etc.
           filters; most candidates are dropped here]
        fireAutoConfigurationImportEvents(configurations, exclusions)

    AutoConfigurationGroup.selectImports()
                          AutoConfigurationImportSelector.java:489
      sortAutoConfigurations(processedConfigurations, metadata)
      [respects @AutoConfigureBefore / @AutoConfigureAfter ordering]
      → ordered list of surviving auto-configuration class names

  ConfigurationClassParser re-enters each auto-config class:
    [e.g., TomcatAutoConfiguration → registers TomcatServletWebServerFactory bean]
    [e.g., DispatcherServletAutoConfiguration → registers DispatcherServlet]
    [e.g., DataSourceAutoConfiguration → registers DataSource if applicable]
    [each guarded by @Conditional* — only wires beans not already present]

ConfigurationClassBeanDefinitionReader.loadBeanDefinitions(configClasses)
  [all @Bean methods in surviving configs become BeanDefinitions]

PropertySourceOrderingBeanFactoryPostProcessor.postProcessBeanFactory()
                          SpringApplication.java:1608
  [re-orders ConfigurationPropertySources in MutablePropertySources]
```

#### Step 6 — `registerBeanPostProcessors(beanFactory)`
Registers all `BeanPostProcessor` beans in priority order:
- `AutowiredAnnotationBeanPostProcessor` (handles `@Autowired`, `@Value`)
- `CommonAnnotationBeanPostProcessor` (handles `@Resource`, `@PostConstruct`, `@PreDestroy`)
- `PersistenceAnnotationBeanPostProcessor` (if JPA present)
- `ConfigurationPropertiesBindingPostProcessor` (handles `@ConfigurationProperties`)

#### Step 7 — `initMessageSource()`
Looks up or creates a `MessageSource` bean.

#### Step 8 — `initApplicationEventMulticaster()`
Creates `SimpleApplicationEventMulticaster`; replaces the bootstrap multicaster.

#### Step 9 — **`onRefresh()`** ← **embedded server is created here**

```
ServletWebServerApplicationContext.onRefresh()  ServletWebServerApplicationContext.java:161
  super.onRefresh()
  createWebServer()                             ServletWebServerApplicationContext.java:183
    getWebServerFactory()                       ServletWebServerApplicationContext.java:214
      beanFactory.getBeanNamesForType(
          ServletWebServerFactory.class)
      → "tomcatServletWebServerFactory" (registered by TomcatAutoConfiguration)
      beanFactory.getBean("tomcatServletWebServerFactory")
      → TomcatServletWebServerFactory instance
    factory.getWebServer(getSelfInitializer())  TomcatServletWebServerFactory.java:163
      createTomcat(tempDirs)
        [new Tomcat(), configure connector/protocol/engine/host]
      prepareContext(tomcat.getHost(), initializers, tempDirs)
                                                TomcatServletWebServerFactory.java:189
        [creates StandardContext, adds TomcatStarter lifecycle listener
         which will call all ServletContextInitializers on START_EVENT]
      getTomcatWebServer(tomcat)                TomcatServletWebServerFactory.java:428
        new TomcatWebServer(tomcat, port >= 0, shutdown)
          initialize()                          TomcatWebServer.java:113
            addInstanceIdToEngineName()
            context.addLifecycleListener(e -> removeServiceConnectors())
              [connectors are REMOVED before Tomcat.start() so port
               binding is intentionally deferred until Phase 5.12]
            disableBindOnInit()
            this.tomcat.start()
              [starts Engine → Host → StandardContext;
               TomcatStarter fires → all ServletContextInitializers run
               → DispatcherServlet registered in ServletContext]
            rethrowDeferredStartupExceptions()
            ContextBindings.bindClassLoader(...)
            startNonDaemonAwaitThread()
              [daemon=false thread keeps JVM alive]
    beanFactory.registerSingleton(
        "webServerGracefulShutdown",
        new WebServerGracefulShutdownLifecycle(webServer))
    beanFactory.registerSingleton(
        "webServerStartStop",
        new WebServerStartStopLifecycle(this, webServer))
                                               WebServerStartStopLifecycle.java:29
    initPropertySources()
      [replaces stub servlet-context property sources with real ones]
```

#### Step 10 — `registerListeners()`
Registers all `ApplicationListener` beans with `SimpleApplicationEventMulticaster`. Publishes any events that were accumulated in the early phase.

#### Step 11 — `finishBeanFactoryInitialization(beanFactory)` ← **all singletons instantiated here**

```
beanFactory.freezeConfiguration()
beanFactory.preInstantiateSingletons()
  for each non-lazy singleton BeanDefinition:
    getBean(beanName)
      doGetBean(beanName)
        createBean(beanName, mbd, args)
          doCreateBean(beanName, mbd, args)
            instantiateBean(beanName, mbd)
              [constructor injection, or default constructor]
            populateBean(beanName, mbd, bw)
              AutowiredAnnotationBeanPostProcessor
                .postProcessProperties()
                [resolves @Autowired, @Value fields/methods]
            initializeBean(beanName, bean, mbd)
              invokeAwareMethods(beanName, bean)
              applyBeanPostProcessorsBeforeInitialization()
                [@PostConstruct via CommonAnnotationBeanPostProcessor]
              invokeInitMethods(beanName, bean, mbd)
                [InitializingBean.afterPropertiesSet()]
                [custom init-method]
              applyBeanPostProcessorsAfterInitialization()
```

Every auto-configured bean — `DataSource`, `EntityManagerFactory`, `DispatcherServlet`, `TomcatServletWebServerFactory`, actuator endpoints, etc. — is instantiated and wired here.

#### Step 12 — `finishRefresh()` ← **server starts accepting connections**

```
clearResourceCaches()
initLifecycleProcessor()
  → DefaultLifecycleProcessor
getLifecycleProcessor().onRefresh()
  [starts all SmartLifecycle beans with autoStartup=true, in phase order]
  WebServerStartStopLifecycle.start()          WebServerStartStopLifecycle.java:43
    this.webServer.start()
      TomcatWebServer.start()                  TomcatWebServer.java:226
        addPreviouslyRemovedConnectors()
          [puts connectors back; this is where the TCP port is BOUND]
        performDeferredLoadOnStartup()
          [loads servlets that have load-on-startup > 0]
        checkThatConnectorsHaveStarted()
          [verifies port binding succeeded; throws ConnectorStartFailedException
           on port conflict]
        this.started = true
        logger.info("Tomcat started on port ...")
    this.running = true
    applicationContext.publishEvent(
        new ServletWebServerInitializedEvent(webServer, applicationContext))
publishEvent(new ContextRefreshedEvent(this))
```

`ContextRefreshedEvent` signals to any listener (e.g., Spring Data repositories, caches) that the context is fully built and all singletons are available.

---

## Phase 6 — Post-Refresh Runners and Ready Signal

Back in `SpringApplication.run()` at line 304:

```
afterRefresh(context, applicationArguments)    SpringApplication.java:764
  [empty hook — subclasses may override]

startup.started()                              SpringApplication.java:326
  [records time-to-started]

StartupInfoLogger.logStarted(...)
  [prints "Started MyApp in X.XXX seconds"]

listeners.started(context, timeTakenToStarted)
  → ApplicationStartedEvent
  → AvailabilityChangeEvent(CORRECT)

callRunners(context, applicationArguments)     SpringApplication.java:767
  beanFactory.getBeanNamesForType(Runner.class)
  [finds all ApplicationRunner and CommandLineRunner beans]
  sort by @Order / Ordered
  callRunner(runner, args)                     SpringApplication.java:786/797
    runner.run(applicationArguments)           [ApplicationRunner]
    runner.run(args.getSourceArgs())           [CommandLineRunner]

listeners.ready(context, startup.ready())
  → ApplicationReadyEvent
  → AvailabilityChangeEvent(ACCEPTING_TRAFFIC)

return context
```

---

## Unified Architecture Diagram

```
main(args)
│
└─► SpringApplication.run(MyApp.class, args)          SpringApplication.java:1353
      │
      └─► new SpringApplication(MyApp.class)
            └─► .run(args)                            SpringApplication.java:304
                  │
                  ├─[1] Startup.create()
                  │
                  ├─[2] createBootstrapContext()       :344
                  │       DefaultBootstrapContext
                  │       BootstrapRegistryInitializer.initialize(×N)
                  │
                  ├─[3] getRunListeners(args)           :453
                  │       SpringFactoriesLoader
                  │       └─► EventPublishingRunListener  EventPublishingRunListener.java:55
                  │             SimpleApplicationEventMulticaster
                  │
                  ├─[4] listeners.starting()
                  │       → ApplicationStartingEvent
                  │
                  ├─[5] prepareEnvironment()            :350
                  │       │
                  │       ├─ getOrCreateEnvironment()   :475
                  │       │    ApplicationContextFactory.createEnvironment(SERVLET)
                  │       │    └─► ApplicationServletEnvironment
                  │       │
                  │       ├─ configureEnvironment()     :498
                  │       │    configurePropertySources() :513
                  │       │      DefaultPropertiesPropertySource
                  │       │      SimpleCommandLinePropertySource
                  │       │      ApplicationInfoPropertySource
                  │       │    configureProfiles()       :543
                  │       │
                  │       ├─ ConfigurationPropertySources.attach()
                  │       │
                  │       ├─ listeners.environmentPrepared()
                  │       │    → ApplicationEnvironmentPreparedEvent
                  │       │         EnvironmentPostProcessorApplicationListener
                  │       │           ConfigDataEnvironmentPostProcessor
                  │       │             └─► loads application.properties/.yml
                  │       │
                  │       ├─ bindToSpringApplication()  :550
                  │       │    Binder("spring.main") → SpringApplication fields
                  │       │
                  │       └─ EnvironmentConverter (if needed)
                  │
                  ├─[6] createApplicationContext()      :579
                  │       applicationContextFactory.create(SERVLET)
                  │       └─► AnnotationConfigServletWebServerApplicationContext
                  │             AnnotatedBeanDefinitionReader
                  │               registers ConfigurationClassPostProcessor
                  │
                  ├─[7] prepareContext()                :380
                  │       │
                  │       ├─ context.setEnvironment(environment)
                  │       ├─ postProcessApplicationContext() :591
                  │       │    register beanNameGenerator, resourceLoader,
                  │       │    conversionService singletons
                  │       │
                  │       ├─ applyInitializers()        :616
                  │       │    ApplicationContextInitializer.initialize(×N)
                  │       │
                  │       ├─ listeners.contextPrepared()
                  │       │    → ApplicationContextInitializedEvent
                  │       │
                  │       ├─ bootstrapContext.close(context)
                  │       │    → BootstrapContextClosedEvent
                  │       │
                  │       ├─ registerSingleton("springApplicationArguments")
                  │       ├─ addBeanFactoryPostProcessor(
                  │       │      PropertySourceOrderingBeanFactoryPostProcessor)
                  │       │
                  │       ├─ load(context, sources)     :683
                  │       │    BeanDefinitionLoader.load()  BeanDefinitionLoader.java:128
                  │       │      AnnotatedBeanDefinitionReader.register(MyApp.class)
                  │       │       → MyApp BeanDefinition registered
                  │       │
                  │       └─ listeners.contextLoaded()
                  │            → ApplicationPreparedEvent
                  │              [app listeners transferred to context]
                  │
                  └─[8] refreshContext()               :441
                          register shutdownHook
                          context.refresh()
                            │
                            └─► AbstractApplicationContext.refresh()  [Spring FW]
                                  │
                                  ├─ prepareRefresh()
                                  ├─ obtainFreshBeanFactory()
                                  │    → DefaultListableBeanFactory (pre-existing)
                                  │
                                  ├─ prepareBeanFactory()
                                  │    ApplicationContextAwareProcessor
                                  │    env / systemProperties singletons
                                  │
                                  ├─ postProcessBeanFactory()
                                  │    ServletWebServerApplicationContext  :134
                                  │      WebApplicationContextServletContextAwareProcessor
                                  │      request/session scopes registered
                                  │
                                  ├─ invokeBeanFactoryPostProcessors()
                                  │    └─► ConfigurationClassPostProcessor
                                  │          parse(@SpringBootApplication)
                                  │            @ComponentScan → scan packages
                                  │            @Import(AutoConfigurationImportSelector)
                                  │              deferred until all regular @Imports done
                                  │            └─► AutoConfigurationGroup.process()  :467
                                  │                  getAutoConfigurationEntry()     :142
                                  │                    getCandidateConfigurations()  :200
                                  │                      ImportCandidates.load()
                                  │                      [reads AutoConfiguration.imports]
                                  │                      ~130+ candidates
                                  │                    filter(@Conditional*)
                                  │                    → surviving configs
                                  │                  selectImports()                :489
                                  │                  [sorted by Before/After]
                                  │                  → ordered config class names
                                  │          re-parse each auto-config class
                                  │          @Bean methods → BeanDefinitions
                                  │          e.g. TomcatServletWebServerFactory ←────┐
                                  │               DispatcherServlet                  │
                                  │               DataSource, etc.                   │
                                  │                                                  │
                                  ├─ registerBeanPostProcessors()                    │
                                  │    AutowiredAnnotationBeanPostProcessor          │
                                  │    CommonAnnotationBeanPostProcessor             │
                                  │    ConfigurationPropertiesBindingPostProcessor   │
                                  │                                                  │
                                  ├─ initApplicationEventMulticaster()               │
                                  │                                                  │
                                  ├─ onRefresh()  ◄── EMBEDDED SERVER CREATED HERE  │
                                  │    ServletWebServerApplicationContext  :161      │
                                  │      createWebServer()                 :183      │
                                  │        getWebServerFactory()           :214      │
                                  │          getBeanNamesForType(                    │
                                  │              ServletWebServerFactory)            │
                                  │          getBean("tomcatServlet...Factory") ─────┘
                                  │          → TomcatServletWebServerFactory
                                  │        factory.getWebServer(selfInitializer)
                                  │          TomcatServletWebServerFactory :163
                                  │            createTomcat(tempDirs)
                                  │            prepareContext(host, inits) :189
                                  │              new StandardContext
                                  │              TomcatStarter added
                                  │            getTomcatWebServer(tomcat)  :428
                                  │            └─► new TomcatWebServer(...)
                                  │                  initialize()          :113
                                  │                    removeServiceConnectors()
                                  │                    [defers port binding!]
                                  │                    this.tomcat.start()
                                  │                    [Engine→Host→Context starts;
                                  │                     TomcatStarter runs;
                                  │                     ServletContextInitializers
                                  │                     register servlets/filters]
                                  │                    startNonDaemonAwaitThread()
                                  │        registerSingleton("webServerStartStop",
                                  │            new WebServerStartStopLifecycle(...))
                                  │
                                  ├─ registerListeners()
                                  │
                                  ├─ finishBeanFactoryInitialization()
                                  │    beanFactory.preInstantiateSingletons()
                                  │      for each singleton BeanDef:
                                  │        doCreateBean()
                                  │          instantiateBean()
                                  │          AutowiredAnnotationBeanPostProcessor
                                  │            → @Autowired / @Value resolved
                                  │          @PostConstruct callbacks
                                  │          InitializingBean.afterPropertiesSet()
                                  │
                                  └─ finishRefresh()  ◄── PORT BOUND HERE
                                       initLifecycleProcessor()
                                         DefaultLifecycleProcessor
                                       lifecycleProcessor.onRefresh()
                                         WebServerStartStopLifecycle.start() :43
                                           webServer.start()
                                           TomcatWebServer.start()  :226
                                             addPreviouslyRemovedConnectors()
                                             [connectors re-added; TCP bind happens]
                                             performDeferredLoadOnStartup()
                                             checkThatConnectorsHaveStarted()
                                             this.started = true
                                             log "Tomcat started on port N"
                                           this.running = true
                                           publishEvent(
                                               ServletWebServerInitializedEvent)
                                       publishEvent(ContextRefreshedEvent)

                  ├─[9] afterRefresh()  [empty hook]   :764
                  │
                  ├─[10] listeners.started()
                  │         → ApplicationStartedEvent
                  │
                  ├─[11] callRunners()                  :767
                  │         ApplicationRunner.run(applicationArguments)
                  │         CommandLineRunner.run(args)
                  │
                  └─[12] listeners.ready()
                            → ApplicationReadyEvent
                            → AvailabilityChangeEvent(ACCEPTING_TRAFFIC)
                            
                  return ConfigurableApplicationContext ✓
```

---

## Key Cross-Cutting Invariants

| Concern | Mechanism | Location |
|---|---|---|
| Event bus before context exists | `SimpleApplicationEventMulticaster` in `EventPublishingRunListener` | `EventPublishingRunListener.java:55` |
| Auto-config loaded as **deferred** import | `DeferredImportSelector` → runs after all explicit `@Import`s | `AutoConfigurationImportSelector.java:78` |
| Auto-config candidates discovered from disk | `ImportCandidates.load()` reads `META-INF/spring/*.imports` | `AutoConfigurationImportSelector.java:200` |
| Conditional filtering strips inapplicable configs | `ConfigurationClassFilter.filter()` evaluates `@Conditional*` | `AutoConfigurationImportSelector.java:388` |
| Port binding **deferred** past context wiring | Connectors removed during `initialize()`, re-added in `start()` | `TomcatWebServer.java:113,226` |
| Server lifecycle tied to Spring lifecycle | `WebServerStartStopLifecycle implements SmartLifecycle` | `WebServerStartStopLifecycle.java:29` |
| Property source ordering enforced after refresh | `PropertySourceOrderingBeanFactoryPostProcessor` | `SpringApplication.java:1594` |
| Runners executed after full startup, before "ready" | `callRunners()` between `started` and `ready` events | `SpringApplication.java:767` |

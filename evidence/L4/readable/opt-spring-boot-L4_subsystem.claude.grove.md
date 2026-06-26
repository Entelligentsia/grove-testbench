# transcript: Give the complete end-to-end picture of Spring Boot's auto-configuration subsystem: from @EnableAutoConfiguration and AutoConfigurationImportSelector loading...


💬 I'll trace the entire auto-configuration pipeline using grove. Let me load the schemas and start mapping.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out parallel grove calls across the major entry points of the pipeline.
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationImportSelector","kind":"...)
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"EnableAutoConfiguration","kind":"interface"})
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition","kind":"class"})
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot/src/main/java/org/springframework/boot/context/annotation","kind":"class"})

💬 Let me search for the key files directly.
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationImportSelector"})
  ▸ mcp__grove__symbols({"dir":"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition","nameContains":true,"kind":"class"})
  ▸ Bash(find spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure -name "AutoConfigurationImportSelector.java" -o -name...)
  ▸ Bash(find spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition -name "*.java" 2>/dev/null | head -30)
  ▸ mcp__grove__symbols({"dir":".","name":"AutoConfigurationImportSelector","kind":"class"})

💬 The project root is `core/`. Now let me fan out all the key source lookups in parallel.
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java","detail":1})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition","kind":"class"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"EnableAutoConfiguration"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationMetadata"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationSorter"})

💬 Good. Now let me read all the critical method bodies in parallel.
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#getAutoConfigurationEntr...)
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#getCandidateConfiguratio...)
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#process@467"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#selectImports@489"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#filter@399"})
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java"})
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/FilteringSpringBootCondition.java"})
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java"})
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java","detail":0})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java#sortAutoConfigurations@5...)
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java#matches@44"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/FilteringSpringBootCondition.java#match@52"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java#getOutcomes@49"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java#getMatchOutcome@87"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationSorter"})

💬 Now I need the sorter, the `OnBeanCondition` match path, `ImportCandidates`, and the Spring Framework context-refresh hooks. Parallel reads:
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationSorter.java","detail":1})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java#getMatchOutcome@128"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java#getOutcomes@97"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationMetadataLoader"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"AutoConfigurationPackages"})

💬 Now I need the context-refresh path, `AutoConfigurationMetadataLoader`, and `ImportCandidates`. Let me read those and also find where `SpringApplication` hoo...
  ▸ mcp__grove__outline({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadataLoader.java"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot/src/main/java/org/springframework/boot","name":"SpringApplication","kind":"class"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"ImportCandidates"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationSorter.java#getInPriorityOrder@65"})
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","detail":0,"kind":"method"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot/src/main/java/org/springframework/boot/context","name":"ImportCandidates"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","name":"EnableAutoConfiguration"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadataLoader.java#loadMetadata@47"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"run"})
  ▸ mcp__grove__outline({"file":"core/spring-boot/src/main/java/org/springframework/boot/context/annotation/ImportCandidates.java"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"refreshContext"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"prepareContext"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot/src/main/java/org/springframework/boot/context/annotation/ImportCandidates.java#load@81"})
  ▸ mcp__grove__source({"file":"core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java","name":"refresh"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java#getOutcomes@209"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java#evaluateConditionalOnBean@157"})

💬 Let me get the `@EnableAutoConfiguration` annotation and the `OnPropertyCondition` body, then check how `ConfigurationClassPostProcessor` is wired.
  ▸ mcp__grove__symbols({"dir":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure","nameContains":true,"name":"EnableAutoConfiguration"})
  ▸ mcp__grove__source({"file":"core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnPropertyCondition.java","name":"getMatchOutcome"})
  ▸ mcp__grove__symbols({"dir":"core/spring-boot/src/main/java/org/springframework/boot","name":"AutoConfigurationExcludeFilter"})
  ▸ mcp__grove__source({"id":"java:core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java#recordEvaluation@102"})

💬 I now have all the data needed. Let me compile the complete picture.  ---  ## Spring Boot Auto-Configuration: End-to-End Pipeline  The pipeline has four dist...

──────── RESULT (success, 273734ms, 56 turns) ────────
I now have all the data needed. Let me compile the complete picture.

---

## Spring Boot Auto-Configuration: End-to-End Pipeline

The pipeline has four distinct stages: **bootstrap**, **candidate loading**, **pre-filtering**, and **full condition evaluation during context refresh**. Below is every function in order, with file and line.

---

### Stage 1 — Application Bootstrap

```
SpringApplication.run(String... args)
  core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java:304
```

Key calls inside `run()`:

| Call | Line |
|------|------|
| `createApplicationContext()` | 579 |
| `prepareContext(bootstrapContext, context, …)` | 380 |
| `refreshContext(context)` | 441 |

**`prepareContext()`** (line 380) calls `load(context, sources)` which registers the primary `@SpringBootApplication` class as a bean definition — this seeds the configuration class scanner.

**`refreshContext()`** (line 441) → **`refresh(context)`** (line 755) → **`context.refresh()`** — hands off to Spring Framework's `AbstractApplicationContext.refresh()`.

---

### Stage 2 — Context Refresh: `ConfigurationClassPostProcessor` (Spring Framework)

`AbstractApplicationContext.refresh()` calls `invokeBeanFactoryPostProcessors()`, which drives:

```
ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry()
  → processConfigBeanDefinitions()
    → ConfigurationClassParser.parse(candidates)     ← parses @SpringBootApplication
```

Inside `ConfigurationClassParser.parse()`:
- `@SpringBootApplication` → `@EnableAutoConfiguration` (via `@SpringBootConfiguration` → `@Configuration` and the `@EnableAutoConfiguration` meta-annotation)
- `@EnableAutoConfiguration` carries `@Import(AutoConfigurationImportSelector.class)`
- Because `AutoConfigurationImportSelector` implements **`DeferredImportSelector`**, it is _not_ processed inline; it is enqueued in `DeferredImportSelectorHandler`
- After all regular configuration classes are parsed, the parser calls `deferredImportSelectorHandler.process()`, which:
  1. Groups selectors by their `Group` class (returns `AutoConfigurationGroup.class` from `getImportGroup()`)
  2. Calls **`AutoConfigurationGroup.process()`** for each selector
  3. Calls **`AutoConfigurationGroup.selectImports()`** to get the final ordered list
  4. Feeds results back into `ConfigurationClassParser.processImports()` — each auto-config class name is now treated as a new `@Configuration` import

---

### Stage 3 — Candidate Loading (`AutoConfigurationGroup.process`)

```
AutoConfigurationGroup.process(AnnotationMetadata, DeferredImportSelector)
  core/…/AutoConfigurationImportSelector.java:467
```

This calls:

```
AutoConfigurationImportSelector.getAutoConfigurationEntry(AnnotationMetadata)  :142
```

**`getAutoConfigurationEntry()` call sequence, in order:**

```
1. isEnabled(annotationMetadata)                              :162
   └─ checks spring.boot.enableautoconfiguration property

2. getAttributes(annotationMetadata)                          :176
   └─ reads exclude / excludeName from @EnableAutoConfiguration

3. getCandidateConfigurations(metadata, attributes)           :200
   └─ ImportCandidates.load(EnableAutoConfiguration.class, classLoader)
        core/spring-boot/…/ImportCandidates.java:81
        ├─ decideClassloader(classLoader)                      :94
        ├─ findUrlsInClasspath(classLoader, location)          :101
        │   location = "META-INF/spring/
        │     org.springframework.boot.autoconfigure
        │     .EnableAutoConfiguration.imports"
        └─ readCandidateConfigurations(url)  [per URL]         :110
             returns List<String> of ~150 class names

4. removeDuplicates(configurations)                           :305
   └─ via LinkedHashSet

5. getExclusions(metadata, attributes)                        :247
   └─ getExcludeAutoConfigurationsProperty()                  :263

6. checkExcludedClasses(configurations, exclusions)           :212

7. configurations.removeAll(exclusions)

8. getConfigurationClassFilter().filter(configurations)       :282 / 399
   └─ see Stage 4 below

9. fireAutoConfigurationImportEvents(configurations,exclusions) :314
   └─ notifies AutoConfigurationImportListeners
      (e.g. ConditionEvaluationReportAutoConfigurationImportListener)

10. return new AutoConfigurationEntry(configurations, exclusions)  :541
```

---

### Stage 4 — Pre-filtering (`ConfigurationClassFilter.filter`)

```
ConfigurationClassFilter.filter(List<String> configurations)
  core/…/AutoConfigurationImportSelector.java:399
```

`ConfigurationClassFilter` holds a list of `AutoConfigurationImportFilter` instances loaded via `getAutoConfigurationImportFilters()` (line 278). There are three registered:

- `OnClassCondition`
- `OnWebApplicationCondition`  
- `OnBeanCondition`

All three extend `FilteringSpringBootCondition`, which implements both `Condition` and `AutoConfigurationImportFilter`. For each filter:

```
AutoConfigurationImportFilter.match(String[] candidates, AutoConfigurationMetadata metadata)
  FilteringSpringBootCondition.match()   :52
  ├─ ConditionEvaluationReport.find(beanFactory)   → gets/creates the report singleton
  ├─ getOutcomes(candidates, metadata)   [abstract, per subclass]   :72
  └─ for each null outcome or match=false:
       logOutcome(className, outcome)
       report.recordConditionEvaluation(className, this, outcome)
```

The `AutoConfigurationMetadata` consulted here is loaded from:
```
AutoConfigurationMetadataLoader.loadMetadata(classLoader)    :43
  → loadMetadata(classLoader, "META-INF/spring-autoconfigure-metadata.properties")  :47
     reads pre-computed condition metadata generated at build time by the
     spring-boot-autoconfigure-processor annotation processor
```

#### `OnClassCondition.getOutcomes()` (batch classpath scan) — `:49`

```
OnClassCondition.getOutcomes(String[] classes, AutoConfigurationMetadata metadata)  :49
├─ if (classes.length > 1 && cpuCount > 1):
│    resolveOutcomesThreaded(classes, metadata)               :64
│    ├─ splits array in half
│    ├─ ThreadedOutcomesResolver (background thread)          :145
│    │   └─ StandardOutcomesResolver.resolveOutcomes()        :166
│    └─ StandardOutcomesResolver (current thread)             :183
│        └─ resolveOutcomes()                                 :205
└─ else: StandardOutcomesResolver.resolveOutcomes()

StandardOutcomesResolver.getOutcomes(classes, start, end, metadata)  :209
  for each class:
    candidates = metadata.get(className, "ConditionalOnClass")
    getOutcome(candidates)                                     :224
    ├─ filter(candidates, ClassNameFilter.MISSING, classLoader)
    │    FilteringSpringBootCondition.filter()                 :93
    │    └─ ClassNameFilter.isPresent(className, classLoader)  :145
    │         → classLoader.loadClass(className)  [no-init]
    └─ ConditionOutcome.noMatch(…) if any class missing
```

#### `OnBeanCondition.getOutcomes()` (batch bean pre-check) — `:97`

```
OnBeanCondition.getOutcomes(String[] classes, AutoConfigurationMetadata metadata)  :97
  for each class:
    onBeanTypes = metadata.getSet(className, "ConditionalOnBean")
    getOutcome(onBeanTypes, ConditionalOnBean.class)          :115
    if null → onSingleCandidateTypes = metadata.getSet(…, "ConditionalOnSingleCandidate")
    → ConditionOutcome.noMatch() if required types provably absent
```

---

### Stage 5 — Sorting (`AutoConfigurationGroup.selectImports`)

After all `process()` invocations, Spring Framework calls:

```
AutoConfigurationGroup.selectImports()                        :489
├─ merges allExclusions and processedConfigurations across entries
├─ processedConfigurations.removeAll(allExclusions)
├─ sortAutoConfigurations(processedConfigurations, getAutoConfigurationMetadata())  :520
│    └─ getAutoConfigurationMetadata()                        :513
│         AutoConfigurationMetadataLoader.loadMetadata(classLoader)  :43
│    └─ new AutoConfigurationSorter(metadataReaderFactory, metadata, replacements::replace)
│         AutoConfigurationSorter.getInPriorityOrder(classNames)  :65
│         ├─ 1. Collections.sort(alphabetically)
│         ├─ 2. sort by @AutoConfigureOrder (reads metadata.getInteger(…, "AutoConfigureOrder"))
│         └─ 3. sortByAnnotation(classes, orderedClassNames)  :84
│                doSortByAfterAnnotation(…)                   :96
│                └─ topological sort honoring
│                   @AutoConfigureBefore / @AutoConfigureAfter
│                   (reads AutoConfigurationClass.getBefore()/:204, getAfter()/:213)
└─ returns Iterable<Entry> — each Entry = (className, annotationMetadata)
```

These entries re-enter `ConfigurationClassParser.processImports()` as if they were ordinary `@Import`ed classes.

---

### Stage 6 — Full Condition Evaluation During Bean Definition Loading

Back in `ConfigurationClassPostProcessor.processConfigBeanDefinitions()`, after `parse()` returns:

```
ConfigurationClassBeanDefinitionReader.loadBeanDefinitions(configClasses)
  → loadBeanDefinitionsForConfigurationClass(configClass, …)
    for each @Bean method on each auto-config class:
      → ConditionEvaluator.shouldSkip(metadata, REGISTER_BEAN)
```

`ConditionEvaluator.shouldSkip()` (Spring Framework) iterates `@Conditional` annotations on the method and calls:

```
SpringBootCondition.matches(ConditionContext context, AnnotatedTypeMetadata metadata)  :44
├─ getClassOrMethodName(metadata)                             :74
├─ getMatchOutcome(context, metadata)    [abstract dispatch]  :115
│    ↓  dispatches to one of:
│
│  OnClassCondition.getMatchOutcome()                         :87
│  ├─ getCandidates(metadata, ConditionalOnClass.class)       :117
│  ├─ filter(onClasses, ClassNameFilter.MISSING, classLoader)
│  │    FilteringSpringBootCondition.filter()                 :93
│  │    ClassNameFilter.isPresent() → classLoader.loadClass() :145
│  ├─ ConditionOutcome.noMatch(…) if missing
│  └─ same logic for @ConditionalOnMissingClass
│
│  OnBeanCondition.getMatchOutcome()                          :128
│  ├─ new Spec<>(context, metadata, annotations, ConditionalOnBean.class)
│  ├─ evaluateConditionalOnBean(spec, matchMessage)           :157
│  │    getMatchingBeans(spec)                                :212
│  │    └─ searches BeanFactory for matching beans by type/name/annotation
│  ├─ evaluateConditionalOnSingleCandidate(spec, …)           :168
│  └─ evaluateConditionalOnMissingBean(spec, …)               :202
│
│  OnPropertyCondition.getMatchOutcome()                      :56
│  ├─ streams all @ConditionalOnProperty annotations
│  └─ determineOutcome(annotation, environment)
│       checks property key present & value matches
│
│  OnWebApplicationCondition, OnJavaCondition, OnExpressionCondition, …
│
├─ logOutcome(classOrMethodName, outcome)                     :82
├─ recordEvaluation(context, classOrMethodName, outcome)      :102
│    ConditionEvaluationReport.get(beanFactory)
│      .recordConditionEvaluation(name, this, outcome)
└─ return outcome.isMatch()
```

Bean definitions for methods where `matches()` returns `false` are skipped. Those where it returns `true` are registered in `DefaultListableBeanFactory`.

---

### Stage 7 — Surviving Beans Instantiated

`AbstractApplicationContext.refresh()` continues to `finishBeanFactoryInitialization(beanFactory)`, which eagerly instantiates all registered non-lazy singletons — all auto-configured beans that passed conditions are now created, injected, and started.

---

## Unified Call Graph

```
SpringApplication.run()                                             SpringApplication.java:304
├── prepareContext()                                                :380
│   └── load(context, sources)   ← registers @SpringBootApplication bean def
└── refreshContext()                                               :441
    └── refresh(context)                                           :755
        └── context.refresh()   [AbstractApplicationContext — Spring Framework]
            └── invokeBeanFactoryPostProcessors()
                └── ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry()
                    └── processConfigBeanDefinitions()
                        └── ConfigurationClassParser.parse(candidates)
                            └── [DeferredImportSelectorHandler.process()]
                                └── AutoConfigurationGroup.process()            :467
                                    └── AutoConfigurationImportSelector
                                          .getAutoConfigurationEntry()           :142
                                        ├── isEnabled()                         :162
                                        ├── getAttributes()                     :176
                                        ├── getCandidateConfigurations()        :200
                                        │   └── ImportCandidates.load()         ImportCandidates.java:81
                                        │       ├── findUrlsInClasspath()       :101
                                        │       └── readCandidateConfigurations():110
                                        │           ← reads META-INF/spring/
                                        │             …EnableAutoConfiguration.imports
                                        ├── removeDuplicates()                  :305
                                        ├── getExclusions()                     :247
                                        │   └── getExcludeAutoConfigurationsProperty() :263
                                        ├── checkExcludedClasses()              :212
                                        ├── removeAll(exclusions)
                                        ├── getConfigurationClassFilter()       :282
                                        │   .filter(configurations)             :399
                                        │   └── [for each AutoConfigurationImportFilter]
                                        │       FilteringSpringBootCondition.match()   FilteringSpringBootCondition.java:52
                                        │       └── getOutcomes()  [abstract]   :72
                                        │           ├── OnClassCondition.getOutcomes()  OnClassCondition.java:49
                                        │           │   ├── resolveOutcomesThreaded()   :64
                                        │           │   │   ├── ThreadedOutcomesResolver:145
                                        │           │   │   └── StandardOutcomesResolver:183
                                        │           │   └── StandardOutcomesResolver
                                        │           │       .resolveOutcomes()          :205
                                        │           │       └── getOutcomes(start,end)  :209
                                        │           │           └── getOutcome(candidates):224
                                        │           │               └── ClassNameFilter.isPresent() :145
                                        │           │                   ← metadata from
                                        │           │                     spring-autoconfigure-metadata.properties
                                        │           ├── OnBeanCondition.getOutcomes()  OnBeanCondition.java:97
                                        │           │   └── getOutcome(types, annotation):115
                                        │           └── OnWebApplicationCondition
                                        │               .getOutcomes()
                                        └── fireAutoConfigurationImportEvents()  :314
                                            └── AutoConfigurationGroup
                                                .selectImports()                :489
                                                ├── [merge + removeAll exclusions]
                                                └── sortAutoConfigurations()    :520
                                                    └── AutoConfigurationMetadataLoader
                                                          .loadMetadata()       AutoConfigurationMetadataLoader.java:47
                                                          ← META-INF/spring-autoconfigure-metadata.properties
                                                        AutoConfigurationSorter
                                                          .getInPriorityOrder() AutoConfigurationSorter.java:65
                                                          ├── sort alphabetically
                                                          ├── sort by @AutoConfigureOrder
                                                          └── sortByAnnotation() :84
                                                              └── doSortByAfterAnnotation() :96
                                                                  ← @AutoConfigureBefore/After
                            [sorted class names re-enter ConfigurationClassParser
                             as if @Import-ed; each class is parsed for @Bean, etc.]
                        └── ConfigurationClassBeanDefinitionReader
                              .loadBeanDefinitions(configClasses)
                              └── [for each auto-config class, for each @Bean method]
                                  ConditionEvaluator.shouldSkip(metadata, REGISTER_BEAN)
                                  └── SpringBootCondition.matches()            SpringBootCondition.java:44
                                      ├── getMatchOutcome()  [dispatch]        :115
                                      │   ├── OnClassCondition.getMatchOutcome() OnClassCondition.java:87
                                      │   │   ├── getCandidates()              :117
                                      │   │   └── FilteringSpringBootCondition.filter()
                                      │   │         .ClassNameFilter.isPresent() :145
                                      │   ├── OnBeanCondition.getMatchOutcome() OnBeanCondition.java:128
                                      │   │   ├── evaluateConditionalOnBean()  :157
                                      │   │   │   └── getMatchingBeans()       :212
                                      │   │   ├── evaluateConditionalOnSingleCandidate() :168
                                      │   │   └── evaluateConditionalOnMissingBean()     :202
                                      │   ├── OnPropertyCondition.getMatchOutcome() OnPropertyCondition.java:56
                                      │   │   └── determineOutcome(annotation, env)
                                      │   └── [OnExpressionCondition, OnJavaCondition, …]
                                      ├── logOutcome()                         :82
                                      └── recordEvaluation()                   :102
                                          └── ConditionEvaluationReport
                                                .recordConditionEvaluation()
            └── finishBeanFactoryInitialization()
                └── [instantiates all surviving singleton bean definitions]
```

---

### Key Data Flows

| What | Where read | Format |
|------|-----------|--------|
| Candidate class names | `META-INF/spring/org.springframework.boot.autoconfigure.EnableAutoConfiguration.imports` | one FQCN per line |
| Pre-computed condition metadata (batch phase) | `META-INF/spring-autoconfigure-metadata.properties` | `ClassName.ConditionalOnClass=a,b,c` |
| Ordering metadata | same `.properties` file | `ClassName.AutoConfigureOrder=N`, `ClassName.AutoConfigureBefore=…` |
| Live bean registry (full phase) | `ConfigurableListableBeanFactory` | queried in `OnBeanCondition.getMatchingBeans()` |
| Condition outcomes (Actuator) | `ConditionEvaluationReport` | singleton stored in `BeanFactory` attributes |

### Design rationale for the two-phase approach

The **batch pre-filter** (Stage 4) uses `AutoConfigurationMetadata` — static properties generated at build time — to eliminate candidates before any `BeanFactory` is involved. `OnClassCondition` even splits this work across a second thread. This keeps startup fast by avoiding reflective class loading for the ~90% of auto-configs whose required classes are absent.

The **full condition evaluation** (Stage 6) runs at `REGISTER_BEAN` phase, when the `BeanFactory` is populated enough to answer `@ConditionalOnBean`/`@ConditionalOnMissingBean` questions about beans registered earlier in the same context.

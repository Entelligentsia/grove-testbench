# transcript: Trace Spring Boot's auto-configuration subsystem end-to-end. The repo is at /home/bench/repos/spring-boot. I need every function, class, and file with line n...


💬 I'll spawn an Explore agent to do a thorough structural investigation of the auto-configuration subsystem across all relevant source files.
  ▸ Agent(Deep trace of Spring Boot auto-configuration subsystem)
  ▸ Bash(find /home/bench/repos/spring-boot -type f -name "EnableAutoConfiguration.java" | head -20)
  ▸ Bash(ls -la /home/bench/repos/spring-boot/ | head -20)
  ▸ Bash(pwd)
  ▸ Read(/home/bench/repos/spring-boot)
  ▸ Bash(find /home/bench/repos/spring-boot -type f -name "*EnableAutoConfiguration*" 2>/dev/null)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project)
  ▸ Bash(find /home/bench/repos/spring-boot -type f -name "*.java" -path "*EnableAutoConfiguration*" 2>&1 | head -5)
  ▸ Bash(ls /home/bench/repos/spring-boot 2>&1 | head -5)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure)
  ▸ Read(/home/bench/repos/spring-boot/autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/build.gradle)
  ▸ Bash(find /home/bench/repos/spring-boot -name "EnableAutoConfiguration.java" -type f 2>&1 | grep -v "Permission denied")
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Bash(test -f "/home/bench/repos/spring-boot/build.gradle" && echo "Files readable" || echo "Files not readable")
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/build.gradle)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-autoconfigure/build.gradle)
  ▸ Read(/home/bench/repos/spring-boot/README.md)
  ▸ Read(/home/bench/repos/spring-boot/README.adoc)
  ▸ Read(/home/bench/repos/spring-boot/settings.gradle)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/context/annotation/ImportCandidates.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportFilter.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/FilteringSpringBootCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnWebApplicationCondition.java)
  ▸ Bash(find /home/bench/repos/spring-boot -name "ConfigurationClassPostProcessor.java" 2>&1 | grep -v Permission | head -5)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationPackage.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/ConditionEvaluationReport.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadata.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadataLoader.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationSorter.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)

💬 Let me verify the actual file paths and line numbers by reading the key source files directly.
  ▸ Bash(find /home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure -name "AutoConfiguratio...)
  ▸ Bash(find /home/bench/repos/spring-boot/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/context/annotation -name "ImportCandidates.java" 2>...)
  ▸ Bash(find /home/bench/repos/spring-boot -name "AutoConfigurationImportSelector.java" 2>/dev/null | head -5)
  ▸ Bash(find /home/bench/repos/spring-boot -name "ImportCandidates.java" 2>/dev/null | head -5)
  ▸ Bash(find /home/bench/repos/spring-boot -name "FilteringSpringBootCondition.java" -o -name "OnClassCondition.java" -o -name "SpringBootCondition.java" 2>/dev/null...)

💬 Let me read the key files directly.
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelec...)
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Agent(Find actual file paths in Spring Boot repo)
  ▸ Bash(ls -la /home/bench/repos/spring-boot)
  ▸ Bash(find /home/bench/repos/spring-boot -type d -name "spring-boot-*" 2>/dev/null | head -20)
  ▸ Bash(find /home/bench/repos/spring-boot -name "AutoConfigurationImportSelector.java" -o -name "EnableAutoConfiguration.java" -o -name "ImportCandidates.java" -o -...)
  ▸ Read(/home/bench/repos/spring-boot)
  ▸ Bash(find . -name "AutoConfigurationImportSelector.java" 2>&1 | head -5)
  ▸ Bash(pwd)

💬 Let me try reading directly with the standard paths.
  ▸ Read(/home/bench/repos/spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelec...)
  ▸ Read(/home/bench/repos/spring-boot)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java)

💬 Good, the actual path uses `core/` not `spring-boot-project/`. Let me read all the key files now.
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/context/annotation/ImportCandidates.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/FilteringSpringBootCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationSorter.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnWebApplicationCondition.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadataLoader.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)

💬 Now I have all the actual source verified. Let me compile the definitive answer.
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportFilter.java)
  ▸ Read(/home/bench/repos/spring-boot/core/spring-boot-autoconfigure/src/main/resources/META-INF/spring.factories)

💬 Now I have all the exact source verified. Here is the complete end-to-end picture.  ---  ## Spring Boot Auto-Configuration: Complete Call Graph  All paths ar...

──────── RESULT (success, 445373ms, 28 turns) ────────
Now I have all the exact source verified. Here is the complete end-to-end picture.

---

## Spring Boot Auto-Configuration: Complete Call Graph

All paths are relative to the repo root. Spring Framework classes (`ConfigurationClassParser`, `ConfigurationClassPostProcessor`, `ConditionEvaluator`) live in the Spring Framework JAR and are not in this repo; their behaviour is described structurally.

---

## 1 — The trigger annotation

**`@EnableAutoConfiguration`**  
`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/EnableAutoConfiguration.java`

```
L72  @Target(ElementType.TYPE)
L76  @AutoConfigurationPackage                      ← registers base package
L77  @Import(AutoConfigurationImportSelector.class) ← installs the selector
L78  public @interface EnableAutoConfiguration {
L84      String ENABLED_OVERRIDE_PROPERTY = "spring.boot.enableautoconfiguration";
L96      Class<?>[] exclude() default {};
L104     String[] excludeName() default {};
```

`@SpringBootApplication` is meta-annotated with `@EnableAutoConfiguration`, so every standard application implicitly carries this `@Import`.

---

## 2 — Spring Framework kicks off `@Import` processing

During `AbstractApplicationContext.refresh()` (Spring Framework), `invokeBeanFactoryPostProcessors()` drives `ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry()`. That calls `ConfigurationClassParser.parse()`, which walks every `@Configuration` class and calls `processImports()` for each `@Import`.

Because `AutoConfigurationImportSelector` implements `DeferredImportSelector` (not plain `ImportSelector`), the framework **defers** it. After all regular configuration classes are parsed, the parser calls `processDeferredImportSelectors()`. Because `getImportGroup()` returns a non-null group type, the framework instantiates the group and calls the group API:

```
ConfigurationClassParser.processDeferredImportSelectors()
  └─ DeferredImportSelectorGrouping.getImports()
       ├─ AutoConfigurationGroup.process()        ← for each @EnableAutoConfiguration site
       └─ AutoConfigurationGroup.selectImports()  ← final sorted list
```

Both are inner-class methods on `AutoConfigurationImportSelector`.

---

## 3 — `AutoConfigurationImportSelector`

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationImportSelector.java`

```java
L78   public class AutoConfigurationImportSelector
          implements DeferredImportSelector, BeanClassLoaderAware,
                     ResourceLoaderAware, BeanFactoryAware, EnvironmentAware, Ordered

L158  public Class<? extends Group> getImportGroup() {
L159      return AutoConfigurationGroup.class;   // tells Spring to use the Group API
      }
```

### 3a — `AutoConfigurationGroup.process()` (inner class, L467)

Called by Spring Framework once per `@EnableAutoConfiguration` annotation site:

```java
L467  public void process(AnnotationMetadata annotationMetadata,
                           DeferredImportSelector deferredImportSelector) {
L480      AutoConfigurationEntry autoConfigurationEntry =
              autoConfigurationImportSelector.getAutoConfigurationEntry(annotationMetadata); // ← §3b
L482      this.autoConfigurationEntries.add(autoConfigurationEntry);
L483      for (String importClassName : autoConfigurationEntry.getConfigurations()) {
L484          this.entries.putIfAbsent(importClassName, annotationMetadata);
          }
      }
```

### 3b — `getAutoConfigurationEntry()` (L142) — the orchestration method

```java
L142  protected AutoConfigurationEntry getAutoConfigurationEntry(AnnotationMetadata annotationMetadata) {
L143      if (!isEnabled(annotationMetadata)) return EMPTY_ENTRY;    // checks property
L146      AnnotationAttributes attributes = getAttributes(annotationMetadata);
L147      List<String> configurations = getCandidateConfigurations(annotationMetadata, attributes); // §4
L148      configurations = removeDuplicates(configurations);           // L305: LinkedHashSet
L149      Set<String> exclusions = getExclusions(annotationMetadata, attributes);                   // §3c
L150      checkExcludedClasses(configurations, exclusions);
L151      configurations.removeAll(exclusions);
L152      configurations = getConfigurationClassFilter().filter(configurations);                     // §5
L153      fireAutoConfigurationImportEvents(configurations, exclusions);
L154      return new AutoConfigurationEntry(configurations, exclusions);
      }
```

### 3c — `getExclusions()` (L247)

```java
L247  protected Set<String> getExclusions(...) {
L249      excluded.addAll(asList(attributes, "exclude"));      // @EnableAutoConfiguration.exclude
L251      excluded.addAll(asList(attributes, "excludeName")); // @EnableAutoConfiguration.excludeName
L253      excluded.addAll(getExcludeAutoConfigurationsProperty()); // spring.autoconfigure.exclude
L254      return getAutoConfigurationReplacements().replaceAll(excluded); // replacement mapping
      }
```

`getExcludeAutoConfigurationsProperty()` (L263) binds `spring.autoconfigure.exclude` via `Binder.get(environment)`.

### 3d — `AutoConfigurationGroup.selectImports()` (L489)

After all `process()` calls, Spring calls this once:

```java
L489  public Iterable<Entry> selectImports() {
L493      Set<String> allExclusions = ...    // union of exclusions across all entries
L497      Set<String> processedConfigurations = ...  // union of configurations
L501      processedConfigurations.removeAll(allExclusions);
L502      return sortAutoConfigurations(processedConfigurations,
                   getAutoConfigurationMetadata())   // §7
               .stream().map(this::getEntry).toList();
      }
```

The returned `Entry` objects are fed back into `ConfigurationClassParser` as if they were regular `@Import` class names.

---

## 4 — Candidate loading

### `getCandidateConfigurations()` (L200)

```java
L200  protected List<String> getCandidateConfigurations(...) {
L202      ImportCandidates importCandidates =
              ImportCandidates.load(this.autoConfigurationAnnotation, getBeanClassLoader());
L204      List<String> configurations = importCandidates.getCandidates();
          ...
      }
```

`this.autoConfigurationAnnotation` is `AutoConfiguration.class` (set in L114–115).

### `ImportCandidates.load()` (L81)

`core/spring-boot/src/main/java/org/springframework/boot/context/annotation/ImportCandidates.java`

```java
L47   private static final String LOCATION = "META-INF/spring/%s.imports";

L81   public static ImportCandidates load(Class<?> annotation, ClassLoader classLoader) {
L84       String location = String.format(LOCATION, annotation.getName());
          // → "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports"
L85       Enumeration<URL> urls = findUrlsInClasspath(classLoaderToUse, location);
L86       List<String> importCandidates = new ArrayList<>();
L87       while (urls.hasMoreElements()) {
L89           importCandidates.addAll(readCandidateConfigurations(url));  // §4a
          }
L91       return new ImportCandidates(importCandidates);
      }
```

### 4a — `readCandidateConfigurations()` (L110)

```java
L110  private static List<String> readCandidateConfigurations(URL url) {
          // Opens a BufferedReader on the URL
L115      while ((line = reader.readLine()) != null) {
L116          line = stripComment(line);   // strip everything from '#' onward
L117          line = line.trim();
L121          candidates.add(line);        // one fully-qualified class name per line
          }
      }
```

File format (`META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`):
```
# Each line is a class that carries @AutoConfiguration
org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration
org.springframework.boot.autoconfigure.cache.CacheAutoConfiguration
...
```

---

## 5 — Import-time filtering (fast pre-screen)

### `getConfigurationClassFilter()` (L282) → `ConfigurationClassFilter` inner class (L388)

```java
L282  private ConfigurationClassFilter getConfigurationClassFilter() {
L284      if (configurationClassFilter == null) {
L285          List<AutoConfigurationImportFilter> filters = getAutoConfigurationImportFilters(); // §5a
L286          for (AutoConfigurationImportFilter filter : filters) invokeAwareMethods(filter);
L289          configurationClassFilter = new ConfigurationClassFilter(this.beanClassLoader, filters);
          }
          return configurationClassFilter;
      }

L394  ConfigurationClassFilter(ClassLoader classLoader,
                                List<AutoConfigurationImportFilter> filters) {
L395      this.autoConfigurationMetadata = AutoConfigurationMetadataLoader.loadMetadata(classLoader); // §6
L396      this.filters = filters;
      }
```

### 5a — `getAutoConfigurationImportFilters()` (L278)

```java
L278  protected List<AutoConfigurationImportFilter> getAutoConfigurationImportFilters() {
L279      return SpringFactoriesLoader.loadFactories(
               AutoConfigurationImportFilter.class, this.beanClassLoader);
      }
```

Resolved from `META-INF/spring.factories` (L14-18 in that file):

```
org.springframework.boot.autoconfigure.AutoConfigurationImportFilter=\
  org.springframework.boot.autoconfigure.condition.OnBeanCondition,\
  org.springframework.boot.autoconfigure.condition.OnClassCondition,\
  org.springframework.boot.autoconfigure.condition.OnWebApplicationCondition
```

### `ConfigurationClassFilter.filter()` (L399)

```java
L399  List<String> filter(List<String> configurations) {
L401      String[] candidates = StringUtils.toStringArray(configurations);
L403      for (AutoConfigurationImportFilter filter : this.filters) {
L404          boolean[] match = filter.match(candidates, this.autoConfigurationMetadata); // §8
L405          for (int i = 0; i < match.length; i++) {
L406              if (!match[i]) candidates[i] = null;   // null out failing candidates
              }
          }
          // collect non-null candidates into result list
      }
```

---

## 6 — Pre-computed metadata

### `AutoConfigurationMetadataLoader.loadMetadata()` (L43)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationMetadataLoader.java`

```java
L38   private static final String PATH = "META-INF/spring-autoconfigure-metadata.properties";

L43   static AutoConfigurationMetadata loadMetadata(ClassLoader classLoader) {
L44       return loadMetadata(classLoader, PATH);
      }

L47   static AutoConfigurationMetadata loadMetadata(ClassLoader classLoader, String path) {
L49       Enumeration<URL> urls = classLoader.getResources(path);
L51       Properties properties = new Properties();
L52       while (urls.hasMoreElements()) {
L53           properties.putAll(PropertiesLoaderUtils.loadProperties(new UrlResource(...)));
          }
L55       return loadMetadata(properties);   // → PropertiesAutoConfigurationMetadata
      }

L110  // PropertiesAutoConfigurationMetadata.get():
L111  String value = this.properties.getProperty(className + "." + key);
      // e.g. key: "org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration.ConditionalOnClass"
      //      value: "com.rabbitmq.client.Channel,org.springframework.amqp.rabbit.core.RabbitTemplate"
```

This properties file is generated at **build time** by the `spring-boot-autoconfigure-processor` annotation processor, which reads every `@ConditionalOnClass`, `@ConditionalOnBean`, `@ConditionalOnWebApplication` on every `@AutoConfiguration` class and writes out key-value pairs. The filter phase consults this file without loading any auto-configuration bytecode.

---

## 7 — Sorting

### `AutoConfigurationSorter.getInPriorityOrder()` (L65)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/AutoConfigurationSorter.java`

```java
L65   List<String> getInPriorityOrder(Collection<String> classNames) {
L67       List<String> alphabeticallyOrderedClassNames = new ArrayList<>(classNames);
L68       Collections.sort(alphabeticallyOrderedClassNames);   // step 1: stable base order

L70       AutoConfigurationClasses classes = new AutoConfigurationClasses(
               metadataReaderFactory, autoConfigurationMetadata, alphabeticallyOrderedClassNames);

L74       orderedClassNames.sort((o1, o2) -> {               // step 2: @AutoConfigureOrder
L75           int i1 = classes.get(o1).getOrder();
L76           int i2 = classes.get(o2).getOrder();
              return Integer.compare(i1, i2);
          });

L80       orderedClassNames = sortByAnnotation(classes, orderedClassNames); // step 3: before/after
          return orderedClassNames;
      }
```

### `sortByAnnotation()` (L84) / `doSortByAfterAnnotation()` (L96)

Topological DFS using `@AutoConfigureBefore` and `@AutoConfigureAfter`. `AutoConfigurationClass.getBefore()` / `getAfter()` (L204, L213) read from the pre-built metadata if available, otherwise from the actual bytecode via `MetadataReaderFactory`.

```java
L96   private void doSortByAfterAnnotation(classes, toSort, sorted, processing, current) {
L103      Set<String> afters = classes.getClassesRequestedAfter(current);
          // = classes that declare @AutoConfigureAfter(current) or that current declares @AutoConfigureBefore(X)
L104      for (String after : afters) {
L107          doSortByAfterAnnotation(..., after);  // recurse
          }
L111      sorted.add(current);   // post-order → topological order
      }
```

---

## 8 — Filter implementations (three `AutoConfigurationImportFilter` + `Condition` hybrids)

All three extend `FilteringSpringBootCondition`, which extends `SpringBootCondition` and also implements `AutoConfigurationImportFilter`. They operate in **two completely separate contexts**:

- **Import-filter context** (`AutoConfigurationImportFilter.match()`): called from `ConfigurationClassFilter.filter()` in §5, before auto-config bytecode is loaded, consulting pre-computed metadata only.
- **`@Conditional` context** (`Condition.matches()`): called by Spring Framework's `ConditionEvaluator.shouldSkip()` during `ConfigurationClassParser` processing, once the auto-config class itself is being parsed.

### 8a — `FilteringSpringBootCondition.match()` (L52)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/FilteringSpringBootCondition.java`

```java
L42   abstract class FilteringSpringBootCondition extends SpringBootCondition
          implements AutoConfigurationImportFilter, BeanFactoryAware, BeanClassLoaderAware

L52   public boolean[] match(String[] autoConfigurationClasses,
                              AutoConfigurationMetadata autoConfigurationMetadata) {
L54       ConditionEvaluationReport report = ConditionEvaluationReport.find(this.beanFactory);
L55       ConditionOutcome[] outcomes = getOutcomes(autoConfigurationClasses, autoConfigurationMetadata); // abstract
L56       boolean[] match = new boolean[outcomes.length];
L57       for (int i = 0; i < outcomes.length; i++) {
L59           match[i] = (outcome == null || outcome.isMatch());  // null = no opinion → pass
L60           if (!match[i] && outcome != null) {
L63               logOutcome(autoConfigurationClass, outcome);
L65               report.recordConditionEvaluation(autoConfigurationClass, this, outcome);
              }
          }
          return match;
      }

L72   protected abstract ConditionOutcome[] getOutcomes(...);  // implemented by each subclass
```

### 8b — `SpringBootCondition.matches()` (L44)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/SpringBootCondition.java`

This is the `Condition.matches()` path, invoked by Spring Framework's `ConditionEvaluator.shouldSkip()`:

```java
L44   public final boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
L45       String classOrMethodName = getClassOrMethodName(metadata);
L47       ConditionOutcome outcome = getMatchOutcome(context, metadata);  // abstract, per-subclass
L48       logOutcome(classOrMethodName, outcome);
L49       recordEvaluation(context, classOrMethodName, outcome);
L50       return outcome.isMatch();
      }

L102  private void recordEvaluation(ConditionContext context, ...) {
L104      ConditionEvaluationReport.get(context.getBeanFactory())
              .recordConditionEvaluation(classOrMethodName, this, outcome);
      }
```

### 8c — `OnClassCondition` (import-filter path)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnClassCondition.java`  
`@Order(Ordered.HIGHEST_PRECEDENCE)` — runs first

```java
L49   protected ConditionOutcome[] getOutcomes(String[] autoConfigurationClasses,
                                                AutoConfigurationMetadata autoConfigurationMetadata) {
L54       if (autoConfigurationClasses.length > 1 && availableProcessors() > 1) {
L55           return resolveOutcomesThreaded(...);  // splits array in two, runs second half on a new Thread
          } else {
L58           return new StandardOutcomesResolver(...).resolveOutcomes();
          }
      }

// StandardOutcomesResolver.getOutcomes() (L209):
L215  String candidates = autoConfigurationMetadata.get(autoConfigClass, "ConditionalOnClass");
L217  outcomes[i - start] = getOutcome(candidates);

// getOutcome(String candidates) (L224):
L226  if (!candidates.contains(",")) return getOutcome(candidates, beanClassLoader);
L229  for (String candidate : commaDelimitedListToStringArray(candidates)) { ... }

// getOutcome(String className, ClassLoader) (L242):
L243  if (ClassNameFilter.MISSING.matches(className, classLoader))
          return ConditionOutcome.noMatch(...);  // class not on classpath → exclude
```

`OnClassCondition.getMatchOutcome()` (L87) — the `@Conditional` path — does the same check using `getCandidates(metadata, ConditionalOnClass.class)` to pull class names directly from the annotation instead of from the properties file.

### 8d — `OnBeanCondition` (import-filter path)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnBeanCondition.java`  
`@Order(Ordered.LOWEST_PRECEDENCE)` — runs last  
Also implements `ConfigurationCondition` with `getConfigurationPhase() = REGISTER_BEAN` — its `@Conditional` path runs only during bean registration, not parse.

```java
L97   protected ConditionOutcome[] getOutcomes(String[] autoConfigurationClasses, ...) {
L103      Set<String> onBeanTypes = autoConfigurationMetadata.getSet(autoConfigClass, "ConditionalOnBean");
L104      outcomes[i] = getOutcome(onBeanTypes, ConditionalOnBean.class);
L106      if (outcomes[i] == null) {
L107          Set<String> onSingleCandidateTypes = autoConfigurationMetadata.getSet(..., "ConditionalOnSingleCandidate");
L108          outcomes[i] = getOutcome(onSingleCandidateTypes, ConditionalOnSingleCandidate.class);
          }
      }
// This is a type-presence check (ClassNameFilter.MISSING), not a live bean lookup —
// the bean factory isn't fully populated yet at import time.
```

### 8e — `OnWebApplicationCondition` (import-filter path)

`core/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/condition/OnWebApplicationCondition.java`  
`@Order(Ordered.HIGHEST_PRECEDENCE + 20)` — runs second, just after `OnClassCondition`

```java
L55   protected ConditionOutcome[] getOutcomes(String[] autoConfigurationClasses, ...) {
L62       outcomes[i] = getOutcome(
               autoConfigurationMetadata.get(autoConfigClass, "ConditionalOnWebApplication"));
      }

L68   private ConditionOutcome getOutcome(String type) {
          // type = "SERVLET" | "REACTIVE" | null
L74       if (SERVLET.name().equals(type)) {
L75           if (MISSING.matches(SERVLET_WEB_APPLICATION_CLASS, beanClassLoader))
                  return ConditionOutcome.noMatch(...);
          }
          ...
      }
```

---

## 9 — Phase 2: condition evaluation during context refresh

After `AutoConfigurationGroup.selectImports()` returns the sorted list, Spring Framework registers each class name as an import. When `ConfigurationClassParser` subsequently parses those auto-configuration classes, it calls Spring Framework's `ConditionEvaluator.shouldSkip()` for:

1. **The class itself** (`ConfigurationPhase.PARSE_CONFIGURATION`): evaluates every `@Conditional` on the class — `@ConditionalOnClass`, `@ConditionalOnProperty`, etc. that weren't caught in the fast-filter pass (e.g. those that aren't in the metadata file, or custom conditions).
2. **Each `@Bean` method** (`ConfigurationPhase.REGISTER_BEAN`): evaluates method-level `@ConditionalOnMissingBean`, `@ConditionalOnBean`, etc. against the live `BeanFactory`.

`ConditionEvaluator.shouldSkip()` loops over the `@Conditional` annotations, instantiates each `Condition`, and calls `condition.matches(conditionContext, metadata)`. For Spring Boot conditions, that enters `SpringBootCondition.matches()` (§8b) → `getMatchOutcome()`.

`OnBeanCondition.getMatchOutcome()` at `REGISTER_BEAN` phase runs the full bean-lookup logic — inspecting `BeanFactory.getBeanNamesForType()`, checking annotations on existing bean definitions, and handling `@ConditionalOnSingleCandidate`.

---

## 10 — `SpringApplication` entry point

`core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java`

```java
L304  public ConfigurableApplicationContext run(String... args) {
L318      context = createApplicationContext();
L320      prepareContext(bootstrapContext, context, environment, listeners, ...);
L321      refreshContext(context);    // → §10a
          ...
      }

L441  private void refreshContext(ConfigurableApplicationContext context) {
L445      refresh(context);           // → context.refresh()
      }
```

`context.refresh()` is `AbstractApplicationContext.refresh()` (Spring Framework), which calls `invokeBeanFactoryPostProcessors()`, triggering `ConfigurationClassPostProcessor`, which drives everything in §§2–9.

---

## Unified Call Graph

```
SpringApplication.run()  [SpringApplication.java:304]
└─ refreshContext()  [:441]
   └─ AbstractApplicationContext.refresh()  [Spring Framework]
      └─ invokeBeanFactoryPostProcessors()
         └─ ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry()  [Spring FW]
            └─ ConfigurationClassParser.parse()
               └─ processImports()  — sees @Import(AutoConfigurationImportSelector)
                  └─ [deferred: stored in deferredImportSelectorHandler]
                  └─ processDeferredImportSelectors()  [end of parse]
                     └─ DeferredImportSelectorGrouping.getImports()
                        ├─ AutoConfigurationGroup.process()  [:467]  ← for each @EAC site
                        │   └─ AutoConfigurationImportSelector.getAutoConfigurationEntry()  [:142]
                        │       ├─ isEnabled()  [:162]  — checks spring.boot.enableautoconfiguration
                        │       ├─ getAttributes()  [:176]  — reads @EnableAutoConfiguration attrs
                        │       ├─ getCandidateConfigurations()  [:200]
                        │       │   └─ ImportCandidates.load(AutoConfiguration.class, classLoader)  [:81]
                        │       │       ├─ findUrlsInClasspath("META-INF/spring/…AutoConfiguration.imports")  [:101]
                        │       │       └─ readCandidateConfigurations(url)  [:110]  — one class/line
                        │       ├─ removeDuplicates()  [:305]  — LinkedHashSet dedup
                        │       ├─ getExclusions()  [:247]
                        │       │   ├─ @EnableAutoConfiguration.exclude / excludeName
                        │       │   ├─ getExcludeAutoConfigurationsProperty()  [:263]  — Binder
                        │       │   └─ AutoConfigurationReplacements.replaceAll()
                        │       ├─ checkExcludedClasses()  [:212]
                        │       └─ getConfigurationClassFilter().filter()  [:399]
                        │           ├─ [lazy init] getConfigurationClassFilter()  [:282]
                        │           │   ├─ getAutoConfigurationImportFilters()  [:278]
                        │           │   │   └─ SpringFactoriesLoader.loadFactories(AutoConfigurationImportFilter)
                        │           │   │       → OnBeanCondition, OnClassCondition, OnWebApplicationCondition
                        │           │   ├─ invokeAwareMethods(filter)  [:329]  — inject BeanFactory etc.
                        │           │   └─ new ConfigurationClassFilter(classLoader, filters)  [:394]
                        │           │       └─ AutoConfigurationMetadataLoader.loadMetadata(classLoader)  [:43]
                        │           │           └─ loadMetadata(classLoader, "META-INF/spring-autoconfigure-metadata.properties")  [:47]
                        │           │               → PropertiesAutoConfigurationMetadata (properties keyed className.AnnotationKey)
                        │           └─ for each filter: filter.match(candidates[], metadata)  [:404]
                        │               └─ FilteringSpringBootCondition.match()  [:52]
                        │                   ├─ ConditionEvaluationReport.find(beanFactory)  [:54]
                        │                   ├─ getOutcomes(candidates[], metadata)  [:55]  ← subclass
                        │                   │   ┌─ OnClassCondition.getOutcomes()  [:49]
                        │                   │   │   ├─ [if >1 cpu] resolveOutcomesThreaded()  [:64]
                        │                   │   │   │   ├─ ThreadedOutcomesResolver (second half in bg thread)
                        │                   │   │   │   └─ StandardOutcomesResolver (first half, caller thread)
                        │                   │   │   └─ [else] StandardOutcomesResolver.resolveOutcomes()  [:205]
                        │                   │   │       └─ getOutcomes(…)  [:209]
                        │                   │   │           ├─ metadata.get(className, "ConditionalOnClass")  [:215]
                        │                   │   │           └─ getOutcome(candidates)  [:224]
                        │                   │   │               └─ ClassNameFilter.MISSING.matches(className, classLoader)  [:243]
                        │                   │   │                   └─ Class.forName(className, false, classLoader)  [:118]
                        │                   │   ├─ OnWebApplicationCondition.getOutcomes()  [:55]
                        │                   │   │   └─ metadata.get(className, "ConditionalOnWebApplication")  [:62]
                        │                   │   │       → getOutcome(type): ClassNameFilter.MISSING checks servlet/reactive class
                        │                   │   └─ OnBeanCondition.getOutcomes()  [:97]
                        │                   │       ├─ metadata.getSet(className, "ConditionalOnBean")  [:103]
                        │                   │       └─ getOutcome(types, annotation): ClassNameFilter.MISSING on type names
                        │                   └─ report.recordConditionEvaluation()  [:65]  — for each miss
                        └─ AutoConfigurationGroup.selectImports()  [:489]
                            ├─ union exclusions across all entries
                            ├─ union configurations across all entries, minus exclusions
                            └─ sortAutoConfigurations()  [:520]
                                └─ AutoConfigurationSorter.getInPriorityOrder()  [:65]
                                    ├─ Collections.sort() — alphabetical  [:68]
                                    ├─ sort by @AutoConfigureOrder  [:74]
                                    │   └─ AutoConfigurationClass.getOrder()  [:243]
                                    │       └─ metadata.getInteger(className, "AutoConfigureOrder")
                                    └─ sortByAnnotation()  [:84]  — topological
                                        └─ doSortByAfterAnnotation()  [:96]  — recursive DFS
                                            └─ getClassesRequestedAfter()  [:159]
                                                — unions getAfter() + reverse-getBefore()

               ← ConfigurationClassParser now processes each returned auto-config class

               └─ [for each auto-config class] parse(configClass)
                  └─ ConditionEvaluator.shouldSkip(metadata, PARSE_CONFIGURATION)  [Spring FW]
                     └─ for each @Conditional annotation:
                        └─ SpringBootCondition.matches(conditionContext, metadata)  [:44]
                            └─ getMatchOutcome(context, metadata)  [abstract → subclass]
                               ├─ OnClassCondition.getMatchOutcome()  [:87]
                               │   ├─ getCandidates(metadata, ConditionalOnClass.class)  [:117]
                               │   └─ filter(onClasses, ClassNameFilter.MISSING, classLoader)
                               ├─ OnWebApplicationCondition.getMatchOutcome()  [:92]
                               │   └─ isWebApplication(context, metadata, required)
                               └─ OnBeanCondition.getMatchOutcome()  [REGISTER_BEAN phase only]
                                   └─ live BeanFactory lookups (getBeanNamesForType, etc.)

            └─ ConfigurationClassBeanDefinitionReader.loadBeanDefinitions()  [Spring FW]
               └─ [for each @Bean method in surviving auto-config class]
                  └─ ConditionEvaluator.shouldSkip(methodMetadata, REGISTER_BEAN)
                     └─ SpringBootCondition.matches() → getMatchOutcome()
                        └─ OnBeanCondition.getMatchOutcome()
                            — inspects BeanFactory for existing beans/types
                            — @ConditionalOnMissingBean: skip @Bean if user already registered one
                            — @ConditionalOnBean: only register if required bean present
```

---

## Key design points

| Concern | Mechanism |
|---|---|
| Why deferred? | `DeferredImportSelector` ensures auto-configs load **after** all user `@Configuration` classes, so `@ConditionalOnMissingBean` sees user beans first. |
| Two-phase filtering | **Import-filter phase** (§5–8): cheap, metadata-only, no bytecode loading. **`@Conditional` phase** (§9): full evaluation against the live context. |
| Pre-computed metadata | `spring-autoconfigure-metadata.properties` (generated by the annotation processor at build time) lets `OnClassCondition` filter ~150 candidates via `Properties.getProperty()` and `Class.forName()` without loading the auto-configuration class bytecode. |
| Ordering | Three-tier: alphabetical → `@AutoConfigureOrder` → `@AutoConfigureBefore`/`@AutoConfigureAfter` (topological). |
| Thread safety | `OnClassCondition` splits the candidate array and evaluates the first half on a background thread while the second half runs on the caller thread (`ThreadedOutcomesResolver`, L145). |
| Reporting | `ConditionEvaluationReport` accumulates all outcomes; it is exposed at `/actuator/conditions` and printed in the auto-configuration report on startup failure. |

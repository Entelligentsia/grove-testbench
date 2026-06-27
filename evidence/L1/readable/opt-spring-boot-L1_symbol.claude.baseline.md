# transcript: Where is the `SpringApplication` class defined? Give the exact file and line.

  ▸ Bash(grep -rn "^public class SpringApplication" /home/bench/repos/spring-boot --include="*.java" -l)
  ▸ Bash(grep -n "^public class SpringApplication " /home/bench/repos/spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java)

💬 `SpringApplication` is defined at:  `core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java:191`

──────── RESULT (success, 8846ms, 3 turns) ────────
`SpringApplication` is defined at:

`core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java:191`

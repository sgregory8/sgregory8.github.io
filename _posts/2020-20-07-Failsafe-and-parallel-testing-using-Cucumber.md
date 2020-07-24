---
layout: post
title: 19/07/20 Failsafe and parallel testing using Cucumber
---

Automated testing has always been a prominent part of our service pipelines. These tests provide the feedback and safety net vital to our continuous deployment strategy but there exists a problem... We have too many!

The problem with a continuously growing test suite (at least for us) is the time of execution. Having steadily grown from 10 to 20 to 30 minutes a recent implementation jumped our execution time to upwards of an hour; this growth in test time was beginning to undermine the whole principle of 'fast feedback'. Cue `maven-failsafe-plugin`.

## On Parallel Testing in General

The first thing to note about running any sort of tests in parallel is the thread-safety of the libraries the test code depends on. In our particular case we'd developed our own library for creating, modifying and deleting test data in an Oracle database; this library exposed some static methods to create and delete data. Unfortunately the implementation itself was NOT thread-safe and even two threads running simultaneously yielded SQL errors. This problem influenced how we'd have to configure our solution.

## Old Cucumber

Nowadays Cucumber supports parallel testing out of the box but this particular problem involved using `cucumber-jvm-parallel-plugin` to generate our own test runners. The following configuration we settled for:

```xml
                <groupId>com.github.temyers</groupId>
                <artifactId>cucumber-jvm-parallel-plugin</artifactId>
                <executions>
                    <execution>
                        <id>generateRunners</id>
                        <phase>generate-test-sources</phase>
                        <goals>
                            <goal>generateRunners</goal>
                        </goals>
                        <configuration>
                            <glue>
                                <package>whatever</package>
                            </glue>
                            <parallelScheme>FEATURE</parallelScheme>
                            <namingScheme>feature-title</namingScheme>
                        </configuration>
                    </execution>
                </executions>
```

Parallel tests per feature, but it is also possible per scenario!

## Maven Configuration

Now we have test runners generated we just need to configure our failsafe plugin to run them, this was our final setup:

```xml
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-failsafe-plugin</artifactId>
                <configuration>
                  <failIfNoTests>true</failIfNoTests>
                  <reuseForks>false</reuseForks>
                  <forkCount>2.0C</forkCount>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>integration-test</goal>
                            <goal>verify</goal>
                        </goals>
                    </execution>
                </executions>
```

I mentioned earlier the problems we encountered with running parallel threads. Instead of spawning multiple threads we chose to fork the JVM. This keeps tests running in unpolluted environments where they all have their own access to their own independent test data creation utilities. This is slightly more expensive resource wise but is certainly useful! Here 2.0C represents 2 forks per processor core. The `reuseForks` tag tells maven to terminate the process once a feature run has finished before spawning another one if needed.

We now have a test suite that executes in less than 10 minutes

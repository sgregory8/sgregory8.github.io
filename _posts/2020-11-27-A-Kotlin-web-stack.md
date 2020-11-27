---
layout: post
title: A web stack with Kotlin
---

Kotlin is the brainchild of JetBrains and having used IntelliJ IDEA exensively it felt only fitting to see what the languauge itself is capable of and how it's supported (as a relatively fresh language) amongst the web development community.

## The Idea

To host a simple 'web-stack' entirely locally using as much Kotlin as possible, by:

1. Creating a 'back-end' style web server with an in memory DB for serving requests
2. Creating a minimal 'front-end' for using the above and displaying simple information to the browser

## The back end

Seeing as Kotlin has been designed to inter-operate with the JVM there is an obvious choice here: Spring. Using the [Spring Initializr](https://start.spring.io/) it's possible to pick all the dependencies we need, the language and even the build tool. I've chose to include H2 (in memory DB), `spring-data-jpa` and `spring-starter-web`. I've also chosen to use Gradle as it seems to be the most 'common' choice amongst Kotlin projects.

### Controller

The controller will be responsible for serving some fairly basic endpoints. We'll include a 'greeting' endpoint (as it's only natural), some 'find' endpoints (for querying the DB) but most importantly a save endpoint for adding to the DB. Kotlin is very similar to Java and the Spring inegration works seamlessly out of the box. We've added `@CrossOrigin` to allow our front end to make requests from another origin.

```java
@RestController
@CrossOrigin(origins = arrayOf("http://localhost:3000"))
class Controller {

    @Autowired
    lateinit var repository: PersonRepository

    @PostMapping("/save")
    fun process(@RequestBody person: Person): String{
        repository.save(person)
        return "Done"
    }
}
```

After adding a basic `Repository` Kotlin class and wiring it into the controller this is all we need to get going! As an aside Kotlin offers some concise class definitions for 'Data' type classes. Check out this basic `Greeting` class

```Java
data class Greeting(val id: Long, val content: String)
```

Neat!

### Running the web server

```bash
./gradlew bootRun
```

## The Front end

I've elected to use [KVision](https://github.com/rjaros/kvision) to develop the front end. And to call it a 'front end' is generous at best, but it still serves as an example of what people are already doing with Kotlin!

### The code

I've implemented a simple button that uses a text search and returns the results (if found) in an Alert window.

```java
        val restClient = RestClient()
        var firstName: String
        var lastName = ""
        root("kvapp") {

            val searchValue: String
            val text = text(label = "Last name")
            div(text) {
                lastName = "$it"
            }
            button("Search", style = ButtonStyle.PRIMARY) {
                onClick {
                    val result: Promise<Response<dynamic>> = restClient.remoteRequest("http://localhost:8080/findbylastname?lastname=" + lastName)
                    result.then {
                        val json = JSON.parse<Json>(it.data.toString())
                        firstName = json["firstName"] as String
                        lastName = json["lastName"] as String
                        Alert.show(firstName + " " + lastName)
                    }
                }
            }
        }
```

It's not complex by any means but it should feel somewhat akin to developers who use Java on the daily. I've used a `RestClient` native to KVision which queries our back end api and the button does the rest of the work. The front end is accessible on [local](localhost:3000).

Hot changes are enabled and changing `App.kt` will result in live changes being propagated to the browser. The source Kotlin is of course transpiled to .js under the covers and there is support for integration with React too.

KVision is capable of much richer UI's and examples can be found [here](https://rjaros.github.io/kvision-examples/showcase/)

The whole project can be found [here](https://github.com/sgregory8/kotlin-stack)

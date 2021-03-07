---
layout: post
title: MongoDB with Flapdoodle
---

MongoDB provides a no SQL database that's easy to use and generally quite quick and easy to setup. However there are times where it might be painful to have to manage both a client application and a seperate instance of the DB (integration testing springs to mind). Enter [Flapdoodle](https://github.com/flapdoodle-oss/de.flapdoodle.embed.mongo) a Maven dependency that can manage MongoDB alongside our application.

## To Spring or not to Spring

Spring boot provides a decent level of abstraction upon MongoDB making transactions with the DB painless and simple. In this instance we'll abstain from Spring and instead include the MongoDB driver depedency and Flapdoodle dependency.

```xml
    <dependency>
      <groupId>de.flapdoodle.embed</groupId>
      <artifactId>de.flapdoodle.embed.mongo</artifactId>
      <version>3.0.0</version>
    </dependency>
    <dependency>
      <groupId>org.mongodb</groupId>
      <artifactId>mongodb-driver-sync</artifactId>
      <version>4.2.0</version>
    </dependency>
```

## The use case

The idea with this demonstration is wiring together a simple client that inserts an entity into an instance of MongoDB and retrieves the same entity back. We'll be using Flapdoodle to manage the Mongo instance.

## Starting MongoDB

We'll use this bit of code to start our MongoDB. Flapdoodle will manage MongoDB completely so if it's unable to find a local copy it will download an official binary. Many options are configurable but we'll leave it simple

```java
  private static MongodExecutable mongodExecutable;

  private static void setUp() throws IOException {
    MongodConfig mongodConfig = MongodConfig.builder()
        .version(Version.Main.PRODUCTION)
        .net(new Net(port, Network.localhostIsIPv6()))
        .build();
    mongodExecutable = starter.prepare(mongodConfig);
    mongodExecutable.start();
  }
```

Of course we'll also have to manage it's shut down at the end of our application run

```java
  private static void tearDown() {
    if (mongodExecutable != null) {
      mongodExecutable.stop();
    }
  }
```

## The client

The MongoDB Java client is fairly straight forward to configure and we only need a few details such as our `ConnectionString`, database name, collection name and port. We can also register a `CodecRegistry` to help us implement mapping from the DB to our client

```java
    CodecRegistry codecRegistry = CodecRegistries.fromRegistries(
        MongoClientSettings.getDefaultCodecRegistry(),
        CodecRegistries.fromProviders(PojoCodecProvider.builder().automatic(true).build()));
    MongoClientSettings settings = MongoClientSettings.builder()
        .applyConnectionString(new ConnectionString(connectionString))
        .codecRegistry(codecRegistry)
        .build();
```

The driver comes with it's own 'automatic' POJO mapping as long as the class we're mapping to/from conforms to the java bean specification.

## The bean

I've chosen to keep this as simple as possible

```java
public class Person {

    // Getters and setters omitted
    private String id;
    private String name;
    private int age;
}
```

## The repository

`MongoCollection` is typed (in our implementation) and as we've enabled automatic POJO mapping we can define insert/finding rather simply

```java
  private MongoCollection<Person> collection;

  public void insert(Person person) {
    collection.insertOne(person);
  }

  public Person find(String id) {
    return collection.find(eq("_id", id)).first();
  }
```

## Putting it all together

We have all the pieces of our application so we just need to put them together:

1. Call `setUp`
2. Create the client
3. Insert a `Person`
4. Retrieve the `Person`
5. Confirm they're "equivalent"
6. Shut down the Mongo process `tearDown`

Thus our `App` class becomes

```java
  public static void main(String[] args) throws IOException {
    try {
      setUp();
      // My wrapper class for my Mongo client
      Repository repository = new Repository("mongodb://localhost:" + port, COLLECTION_NAME,
          DATABASE_NAME);

      // Create a new person
      Person person = new Person();
      person.setId("1");
      person.setAge(29);
      person.setName("Sam");
      // Store the person
      repository.insert(person);
      // Retrieve the person
      Person returnedPerson = repository.find("1");
      // Call our equals method to test equivalence
      System.out.println("Returned person = original person = " + person.equals(returnedPerson));
    } finally {
      tearDown();
    }
  }
```

`true` is returned to the console!

## Closing remarks

Though the example is somewhat contrived; we'd almost never want to implement an application that works like this in the real world. The ease of Flapdoodle is obvious, in fact, implementing Fladpdoodle for 'integration' tests that require a running instance of Mongo is definitely a potential use case!

[Code here](https://github.com/sgregory8/flapdoodle-mongo)

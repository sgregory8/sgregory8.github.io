---
layout: post
title: Writing, mapping and persisting dynamic .json using Jackson, Spring and Mongo
---

JSON is a fairly standard data-interchange format and is readable by humans too. It's common with microservice architecture that individual components will communicate via JSON. Things can get slightly more complicated when less is known about the shape of incoming JSON. This post investigates writing dynamic JSON, mapping it back into POJOs and writing it to a noSQL database (MongoDB).

## The use case

For the sake of example let's assume we're wanting store some order details, however this order consists of two different products. We have an order Id and two different products that contain different `auditDetails` we wish to map and store.

```json
{
  "id": "ORDER_1",
  "messageContributions": [
    {
      "name": "VOLVO",
      "auditDetails": {
        "numberOfDoors": 4,
        "engineSize": 2000
      }
    },
    {
      "name": "GIBSON",
      "auditDetails": {
        "numberOfStrings": 6,
        "material": "Cherry",
        "colour": "Cherry Sunburst"
      }
    }
  ]
}
```

## The POJOs

Structuring the above into classes is fairly straightforward. The resulting package `json_writer` contains 5 classes:

1. `Message` the top level container.
2. `MessageContribution` the second level container within the JSON.
3. `AuditDetails` a marker interface.
4. `CarDetails` implementing `AuditDetails` and adding it's own fields.
5. `GuitarDetails` similar to the above.

## Jackson Magic (writing)

Using Jackson we can serialise the above to a JSON string with minimal effort.

```xml
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.9.8</version>
    </dependency>
```

Constructing the objects and the object mapper.

```java
// Create message parts
    MessageContribution messageContributionA = new MessageContribution("VOLVO",
        new CarDetails(4, 2000));
    MessageContribution messageContributionB = new MessageContribution("GIBSON",
        new GuitarDetails(6, "Cherry", "Cherry Sunburst"));

    // Create message
    Message message = new Message("ORDER_1",
        Arrays.asList(messageContributionA, messageContributionB));

    // Create the mapper and write to json
    ObjectMapper mapper = new ObjectMapper();
    String jsonString = mapper.writeValueAsString(message);
```

It really is that simple! Jackson simply takes the input as we've defined it and produces the JSON output seen at the top of this post.

## Jackson Magic (reading)

Suppose now that the generated JSON is sent to us and we're now responsible for mapping this back into Java and writing it to a database. Jackson is on hand again. I've created another package called `json_reader` to read the JSON back. The package consists of two classes:

1. `MappedMessage` the top level container of the message, contains an id and a list of `MappedMessageContribution`.
2. `MappedMessageContribution` the products in the message.

```java
public class MappedMessage {

  private String id;

  @JsonProperty("messageContributions")
  List<MappedMessageContribution> mappedMessageContributions;

}
```

```java
public class MappedMessageContribution {

  private String name;
  private Map<String, Object> auditDetails;

}
```

The `MappedMessage` class looks very similar to the original `Message` class seen as part of the writer. However as Jackson uses the name of the fields of the java object to match to the JSON string by default, we'll need to specify the name using an annotation: `@JsonProperty("messageContributions")`. The `MappedMessageContribution` will also need to include the audit details field as type `Map<String, Object>`. Jackson can populate this map with whatever it finds in the audit details node of the JSON string.

In one line of code we can read the JSON string back into a `MappedMessage` object, super neat!

```java
    MappedMessage mappedMessage = mapper.readValue(jsonString, MappedMessage.class);
```

## Mongo Integration

Choosing how to interface with an external database can be tricky and there are many different approaches, I've chosen to implement this little application with Spring Boot and by including `spring-boot-starter-data-mongodb` we let Spring take care of all the work.

```xml
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
```

It's as simple as defining an interface.

```java
public interface MongoDocumentRepository extends MongoRepository<MappedMessage, String> {

}
```

And Spring will configure a bean that we can `@Autowire` into our application and use at run time. It's important to note that because we're providing no configuration as to the location of our database that Spring will look for one running locally by default. I used Homebrew to install Mongo and run it from a terminal, but other choices are available i.e running a cloud MongoDB and using `application.properties` to point Spring in the right direction, running a containerised MongoDB instance ... etc.

```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

Once Mongo is running (in whatever capacity) and Spring is configured correctly we just add the repository into our application class and we're able to use all of the conveniance methods that come with it. In fact the whole application code simply becomes.

```java
    @SpringBootApplication
public class App implements CommandLineRunner {

  private final MongoDocumentRepository mongoDocumentRepository;

  @Autowired
  public App(MongoDocumentRepository mongoDocumentRepository) {
    this.mongoDocumentRepository = mongoDocumentRepository;
  }

  public static void main(final String[] args) {
    SpringApplication.run(App.class, args);
  }

  @Override
  public void run(String... args) throws IOException {

    // Create message parts
    MessageContribution messageContributionA = new MessageContribution("VOLVO",
        new CarDetails(4, 2000));
    MessageContribution messageContributionB = new MessageContribution("GIBSON",
        new GuitarDetails(6, "Cherry", "Cherry Sunburst"));

    // Create message
    Message message = new Message("ORDER_1",
        Arrays.asList(messageContributionA, messageContributionB));

    // Create the mapper and write to json
    ObjectMapper mapper = new ObjectMapper();
    String jsonString = mapper.writeValueAsString(message);

    // Map the message back
    MappedMessage mappedMessage = mapper.readValue(jsonString, MappedMessage.class);

    // Write the message to mongo
    mongoDocumentRepository.insert(mappedMessage);
  }
}
```

And using our MongoDB client we can query our Mongo instance for the persisted entity.

```bash
mongo
```

```shell
db.mappedMessage.find()
```

The resulting entity persisted to the database.

```json
{
  "_id": "ORDER_1",
  "mappedMessageContributions": [
    {
      "name": "VOLVO",
      "auditDetails": {
        "numberOfDoors": 4,
        "engineSize": 2000
      }
    },
    {
      "name": "GIBSON",
      "auditDetails": {
        "numberOfStrings": 6,
        "material": "Cherry",
        "colour": "Cherry Sunburst"
      }
    }
  ],
  "_class": "com.gregory.learning.json_reader.MappedMessage"
}
```

All code available [here](https://github.com/sgregory8/spring-mongo-jackson).



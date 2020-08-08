---
layout: post
title: Processing Custom Annotations at runtime
---

Annotations have been a key part of Java since they were introduced, and often provide convenient and fairly intuitive usage. It's little wonder that they're widespread and don't just add ornamental value to code. This post explores implementing some custom annotations and processing them at runtime!

## A Simple use case

We'll use some custom annotations to process an object marked as `@CSVWritable` to help write a list of objects to a .csv file.

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface CSVWritable {

  String delimiter() default ",";

  String textQualifier() default "\"";

}
```

First we've declared that this annotation will be retained at runtime (allowing us to process it) but other retention policies are available. It has been marked with `ElementType.TYPE` to indicate this annotation can be used to mark classes. We've also included two metadata type parameters in here called `delimiter` and `textQualifier`. These will be used to determine the csv delimiter and the way in which the csv attributes are qualified. Let's add some more custom annotations.

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
public @interface CSVMetaData {

  String headerValue() default "";

  Class<?> customMapping() default Object.class;

  @Retention(RetentionPolicy.RUNTIME)
  @Target(ElementType.FIELD)
  @interface CSVIgnore {

  }

  @Retention(RetentionPolicy.RUNTIME)
  @Target(ElementType.FIELD)
  @interface CSVId {

  }
}
```

Here we see that `ElementType.Field` has been used to state that these annotations can decorate fields. The parameters in `CSVMetaData` will allow us to pick custom headers and provide custom mapping for fields if need be. The other two annotations will help us to mark fields to ignore, and to provide a 'key' style field that will appear at the beginning of the csv file. We'll create a new class and annotate it.

```java
@CSVWritable(delimiter = "|", textQualifier = "'")
public class Person {

  @CSVMetaData(headerValue = "FULL_NAME", customMapping = NameMapper.class)
  private String firstName;

  @CSVIgnore
  private String secondName;

  private int age;

  @CSVMetaData(headerValue = "HEIGHT")
  private int height;

  @CSVId
  private String id;
}
```

This class is now ready to be processed.

```java
public class AnnotationProcessor {

  private String delimiter = ",";
  private String textQualifier = "\"";

  protected Map<String, WritableObjectDetails> processAnnotations(Object object) {

    Annotation[] annotations = object.getClass().getDeclaredAnnotations();

    boolean isWritable = false;
    for (Annotation annotation : annotations) {
      if (annotation instanceof CSVWritable) {
        isWritable = true;
        delimiter = ((CSVWritable) annotation).delimiter();
        textQualifier = ((CSVWritable) annotation).textQualifier();
        break;
      }
    }
    if (!isWritable) {
      throw new RuntimeException("Not annotated with @CSVWritable");
    }

    return processObject(object);
  }
}
```

We've provided an entry point by creating this annotation processor class and a `processAnnotations` method. All we have to do is use Java's reflection API to get the declared annotations on the class. We're inspecting the class level annotations and determining whether the object provided is annotated with `CSVWritable` if it isn't we throw an exception, otherwise we process the rest of the annotations!

And that's all there is to it, the code written can unfortunately get complicated quickly when multiple annotations are allowed to interact in various different ways. Let's examine how the custom mapping for the csv example has been implemented.

In the writer code I've provided an interface that can be implemented for the sake of custom mapping.

```java
public interface CustomCSVMapper<T> {

  String map(T object);

}
```

This is what the `NameMapper` class implements here.

```java
  @CSVMetaData(headerValue = "FULL_NAME", customMapping = NameMapper.class)
  private String firstName;
```

The annotation processing picks up on this and also uses Java's reflection API to generate an instance of the mapper and call the map method provided as follows.

```java
public class NameMapper implements CustomCSVMapper<Person> {
  @Override
  public String map(Person person) {
    return person.getFirstName() + " " + person.getSecondName();
  }
}
```

Running the code with a simple setup.

```java
  public static void main(String[] args) {
    CSVWriter csvWriter = new CSVWriter();
    Person person = new Person("Sam", "Gregory", 28, 170, "1");
    csvWriter.writeToCsv(Collections.singletonList(person), "names");
  }
```

Produces csv output that adheres to the specification layed out by our custom annotations, neat!

```csv
'id'|'FULL_NAME'|'age'|'HEIGHT'
'1'|'Sam Gregory'|'28'|'170'
```

All code available [here](https://github.com/sgregory8/custom-annotations).

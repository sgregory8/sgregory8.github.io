---
layout: post
title: 19/07/20 Writing POJO's to .csv
---

Writing java objects to 'comma seperated values' is nothing new. It turns out there are many ways to accomplish this and enough to warrant this post about a couple of approaches I took.

## Using OpenCSV

I'm sure I'm not the only one who reaches out to another library in the first instance when undertaking a task I'm not familiar with! OpenCSV promised an easy solution to the problem I faced and did in fact deliver on it's promise.

```xml
<dependency>
    <groupId>com.opencsv</groupId>
    <artifactId>opencsv</artifactId>
    <version>5.2</version>
</dependency>
```

With the dependency added we can easily get started by writing a simple POJO...

```java
public class Employee {

// getters and setters omitted for brevity
  private String name;
  private int age;

}
```

Next we can define a basic writer class which has been generified slightly to write a list of POJO's to a temporary directory...

```java
// imports omitted for brevity
public class Writer<T> {

  private static final String TEMP_DIR = System.getProperty("java.io.tmpdir");
  private static final String CSV_SUFFIX = ".csv";

  public Path writeToCsv(List<T> objects, String fileName) {

    String filePath =
        TEMP_DIR + File.separator + fileName + CSV_SUFFIX;

    try {
      FileWriter fileWriter = new FileWriter(filePath);
      StatefulBeanToCsv beanToCsv = new StatefulBeanToCsvBuilder(fileWriter)
          .build();
      beanToCsv.write(objects);
      fileWriter.close();
    } catch (IOException | CsvRequiredFieldEmptyException | CsvDataTypeMismatchException e) {
      throw new RuntimeException(e.getCause());
    }
    return Path.of(filePath);
  }
}
```

Running the code with one employee creates exactly what we'd expect...

```csv
"AGE","NAME"
"28","Sam"
```

OpenCSV has effectively worked out the relevant csv headers (field names) and written the contents of our POJO accordingly. But what if we wish to add some configuration some configuration that determines which fields of our POJO we want to write.

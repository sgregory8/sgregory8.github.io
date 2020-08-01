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

OpenCSV has effectively worked out the relevant csv headers (field names) and written the contents of our POJO accordingly. But what if we wish to add some configuration that determines which fields of our POJO we want to write, but we'll add a caveat; what if we wanted to do this programatically?

### Custom Mapping Strategy

OpenCSV provides an interface that can be implemented and provided we supply it to the instance of `StatefulBeanToCsv` we can solve our problem!

```java
public class EmpMappingStrategy implements MappingStrategy<Employee> {

  private final String[] headers;

  public EmpMappingStrategy(String[] headers) {
    this.headers = headers;
  }

  @Override
  public String[] generateHeader(Employee employee) throws CsvRequiredFieldEmptyException {
    return headers;
  }

  @Override
  public String[] transmuteBean(Employee employee)
      throws CsvDataTypeMismatchException, CsvRequiredFieldEmptyException {
    // more complicated
    return new String[0];
  }
```

We only need to provide implementation for these two methods for our case so the others have beem omitted. The `generateHeader` method is responsible for populating the header line (the first line) in our .csv output. The second method `transmuteBean` requires we provide a string array populated with the values of our POJO instance to be written to a csv line. The method provides us with the instance of the POJO.

The first method is straight forward, I've added a parameter in the classes constructor that takes a string array and sets it as an instance variable. The idea here being that the strategy is based upon headers we want to see in the output. We can pass as many or as little as we want! The second method is a little more complicated.

```java
  @Override
  public String[] transmuteBean(Employee employee)
      throws CsvDataTypeMismatchException, CsvRequiredFieldEmptyException {
    // create an array of stings (one for each field of the pojo)
    // this should be exactly the same size as the header array
    String[] csvStrings = new String[headersToMap.length];

    // create a map between header name and method to invoke
    // i've assumed the header name will have an associated getter
    Map<String, Method> headerMethodMap = new HashMap<>();
    List<Method> getterMethods = Arrays.stream(employee.getClass().getMethods())
        .filter(method -> method.getName().startsWith("get") || method.getName().startsWith("is"))
        .collect(
            Collectors.toList());
    Arrays.stream(headersToMap).forEach(header -> {
      boolean matchFound = false;
      for (Method method : getterMethods) {
        if (method.getName().contains(header)) {
          headerMethodMap.put(header, method);
          matchFound = true;
        }
      }
      if (!matchFound) throw new RuntimeException("No match found :( for header: " + header);
    });

    // invoke each method on the instance of our POJO and add to our string array
    int count = 0;
    for (String header : headersToMap) {
      try {
        csvStrings[count] = headerMethodMap.get(header).invoke(employee).toString();
        count ++;
      } catch (IllegalAccessException | InvocationTargetException e) {
        throw new RuntimeException("Could be bad :(", e);
      }
    }
    return csvStrings;
  }
```

Essentially we're matching the headers that we're provided with to getter methods on the Employee class, then invoking each of these methods on the instance of the POJO the method provides us with. Of course we can run into difficulties; if the user provides us with a header value that we can't match to our POJO, in this case I've chosen to throw a RunTime exception and break the process. Ultimately it wouldn't be too difficult to change this implemntation to add blanks into the output for a non existing header (however useful or useless that might be).

## toCSV?

If you're only after simplicty though you can strip things back and achieve something a little more elegant...

```java
public abstract class CSVWritable {

  private List<String> fields;
  private String delimeter = ",";
  private String qualifier = "\"";
  private String lineBreak = "\n";

  public CSVWritable() {
    initFields();
  }

  protected void initFields() {
    if (fields == null) fields = new ArrayList<>();
    Arrays.stream(this.getClass().getDeclaredFields()).forEach(field ->
        fields.add(field.getName().toUpperCase()));
  }

  abstract protected List<String> writeToCsvLine();

  protected String writeToCsv(List<CSVWritable> csvWritables) {
    StringBuilder sb = new StringBuilder();

    fields.forEach(field -> {

      sb.append(qualifier);
      sb.append(field);
      sb.append(qualifier);
      sb.append(delimeter);
    });

    sb.setLength(sb.length() - 1);
    sb.append(lineBreak);

    csvWritables.stream().forEach(writable -> {
      writable.writeToCsvLine().stream().forEach(line -> {

        if (fields.size() != line.length()) {
          throw new RuntimeException("Mismatch in fields provided and csv line elements");
        }

        sb.append(qualifier);
        sb.append(line);
        sb.append(qualifier);
        sb.append(delimeter);
      });
      sb.setLength(sb.length() - 1);
      sb.append(lineBreak);
    });
    return sb.toString();
  }
}
```

This abstract class essentially takes all fields from anything subclassing it and lets the subclass implement it's own way to write lines. The benefit of this is much cleaner code (though perhaps not as versatile). As an example I've made a basic pojo...

```java
public class Book extends CSVWritable {

  private String author;
  private int pages;

  public Book(String author, int pages) {
    this.author = author;
    this.pages = pages;
  }

  @Override
  protected List<String> writeToCsvLine() {
    return Arrays.asList(author, String.valueOf(pages));
  }
}
```

The `writeToCsvLine` provides all the neccessary detail, I can now use a reference to a book Object to create the content of a csv file for a list of book objects. In fact calling the method with a couple of example book objects produces this...

```csv
"AUTHOR","PAGES"
"Sam","44"
"Amber","55"
```

You don't get the advantage of specifying at run time the fields you want and if you wanted to map less fields you would have to make changes to the code itself but for the sake of example I think this solution is perhaps the nicest of all!

All code available [here](git@github.com:sgregory8/csv-concepts.git).

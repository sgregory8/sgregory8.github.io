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

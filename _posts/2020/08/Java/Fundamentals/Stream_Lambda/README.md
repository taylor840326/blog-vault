## Java Stream And Lambda

-----

### 1. 概述

Stream 是 Java8 中处理集合的关键抽象概念，它可以指定你希望对集合进行的操作。

可以执行非常复杂的查找、过滤和映射数据等操作。

Stream使用一种类似用SQL语句从数据库查询数据的直观方式来提供一种Java集合运算和表达的高阶抽象。

简而言之，Stream API 提供了一种高效且易于使用的处理数据的方式。

### 2. 特点：

1. 不是数据结构，不会保存数据。Stream只是某种数据源的一个视图，数据源可以是一个数组、Java容器或I/O Channel。 
1. 不会修改原来的数据源，它会将操作后的数据保存到另外一个对象中。（保留意见：毕竟peek方法可以修改流中元素）
1. 惰性求值，流在中间处理过程中，只是对操作进行了记录，并不会立即执行，需要等到执行终止操作的时候才会进行实际的计算。
1. 可消费性。 Stream只能被消费一次，一旦遍历过就会失效。就像容器的迭代那样，想要再次遍历必须重新生成。

### 3. 分类

1. 无状态：指元素的处理不受之前元素的影响；
1. 有状态：指该操作只有拿到所有元素之后才能继续下去。
1. 非短路操作：指必须处理所有元素才能得到最终结果；
1. 短路操作：指遇到某些符合条件的元素就可以得到最终结果，如 A || B，只要A为true，则无需判断B的结果。

### 4. Stream操作

针对Stream的操作分为三大部分：

1. Stream的创建
1. Stream的中间操作
1. Stream的最终操作

### 4.1. Stream的创建

在Java8中，可以有多种方式创建Stream

### 4.1.1. 通过已有的集合来创建Stream

在Java8中，除了增加了很多Stream相关的类以外，还对集合类自身做了增强。在其中增加了stream方法，可以将一个集合类转换成Stream。

```java
List<String> strings = Arrays.asList("Beijing","Shanghai","Guangzhou");
Stream<String> stream = strings.stream();
```

以上，通过一个已有的List创建一个流。除此以外，还有一个parallelStream方法，可以为集合创建一个并行流。

这种通过集合创建出一个Stream的方式也是比较常用的一种方式。

### 4.1.2. 通过Stream创建Stream

可以使用Stream类提供的方法，直接返回一个有指定元素组成的Stream

```java
Stream<String> stream = Stream.of("Beijing","Shanghai","Guangzhou");
```

### 4.2. Stream的中间操作

Stream有很多中间操作，多个中间操作可以连接起来形成一个流水线。

每个中间操作就像流水线上的一个工人，每个工人都可以对Stream进行加工，加工后得到的结果还是一个Stream。

常用的中间操作如下表所示：

|Stream Operations| Goal| Input|
|:---|---|---:|
|filter| Filter items according to a given predicate| Predicate|
|map/flatMap| Processes items and transforms | Function|
| limit| Limit the results| int|
| sorted| Sort items inside stream| Comparator|
|distinct| Remove duplicate itesm according to equals method of the given type||

### 4.2.1. filter

filter方法用于通过设置的条件过滤出元素，以下代码片段使用filter方法过滤掉空字符串

```java
List<String> strings = Arrays.asList("Beijing","","Shanghai");
Stream<String> stream = strings.stream().filter(item -> !item.isEmpty()).forEach(System.out::println);
//Beijing,,Shanghai
```

### 4.2.1. map/flatMap

map/flatMap方法映射每个元素到对应的结果

```java
List<Integer> numbers = Arrays.asList(3,2,2,3,7,3,5);
numbers.stream().map(i -> i*i).foreach(System.out::println);
numbers.stream().flatMap(i -> Stream.of(i*i)).forEach(System.out::println);
//9,4,4,9,49,9,25
```

### 4.2.1. limit/skip

limit返回Stream的前n个元素；skip则是扔掉前n个元素。

```java
List<Integer> numbers = Arrays.asList(3,2,2,3,7,3,5);
numbers.stream().limit(4).forEach(System.out::println);
//3,2,2,3
numbers.stream().skip(4).forEach(System.out::println);
//7,3,5
```

### 4.2.1. sorted

sorted 方法用于对Stream进行排序。

```java
List<Integer> numbers = Arrays.asList(3,2,2,3,7,3,5);
numbers.stream().sroted().foreach(System.out::println);
//2,2,3,3,3,5,7
```

### 4.2.1. distinct

distinct主要用来去重

```java
List<Integer> numbers = Arrays.asList(3,2,2,3,7,3,5);
numbers.stream().distinct().forEach(System.out::println);
//3,2,7,5
```

### 4.3. Stream的最终操作

Stream的中间操作得到的结果还是一个Stream，那么如何把一个Stream转换成需要的类型？

最终操作会消费流，产生一个最终的结果。也就是说，在最终操作之后不能再次使用流，也不能再使用任何中间操作，否则将抛出异常。

```java
java.lang.IllegalStateException: stream has already been operated upon or closed
```

常见的最终操作如下所示：

|Stream Operation| Goal| Input|
|:---|---|---:|
|forEach| For every item,outputs something| Consumer|
|count| Counts current items||
|collect| Reduces the stream into a desired collection||

### 4.3.1. forEach

Stream提供了forEach方法来迭代流中的每个数据

```java
Random random = new Random();
random.ints().limit(10).forEach(System.out::println);
```

### 4.3.2. count

count用来统计Stream中的元素个数

```java
List<String> strings = Arrays.asList("Beijing","Shanghai","Guangzhou");
System.out.println(strings.stream().count());
//3
```

### 4.3.3. collect

collect就是一个归约操作，可以接受各种做法作为参数，将Stream中的元素累积成一个汇总结果。

```java
List<String> strings = Arrays.asList("Beijing","Shanghai","Guangzhou");
strings.stream().filter(str -> str.startsWith("Bei")).collect(Collectors.toList());
//Beijing

```


### 5. Stream实战

通常Stream就是为了处理数据，而处理数据就不可避免要和数据库的SQL联系在一起。

本部分主要从SQL的使用场景出发，看看Stream能否有对应的实现方法。

### 5.1. 集合操作

### 5.1.1. 交集

### 5.1.2. 并集

### 5.1.3. 并集去重

### 5.1.4. 差集


### 5.2. 集合类型转换

### 5.2.1. 


### 5.3. 聚合统计

### 5.3.1. 分组聚合

### 5.3.2. 分区聚合

### 5.4. 使用Stream模拟SQL

[]

### 参考资料

```html
Java工程师成神之路
https://hollischuang.github.io/toBeTopJavaer/#/basics/java-basic/stream
```

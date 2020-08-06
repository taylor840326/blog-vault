## 集合类型转换

-----

### 1. 集合类型转换

### 1.1. Stream转List

```java
List<Integer> integers = Arrays.asList(3, 2, 2, 3, 7, 4, 5);
List<Integer> toList = integers.stream().collect(Collectors.toList());
```

### 1.2. Stream转LinkedList

```java
List<Integer> integers = Arrays.asList(3, 2, 2, 3, 7, 4, 5);
LinkedList<Integer> toLinkedList = integers.stream().collect(Collectors.toCollection(LinkedList::new));
```

### 1.3. Stream转Set

```java
List<Integer> integers = Arrays.asList(3, 2, 2, 3, 7, 4, 5);
Set<Integer> toSet = integers.stream().collect(Collectors.toSet());
```

### 1.4. 转成CopyOnWriteArrayList

```java
List<Integer> integers = Arrays.asList(3, 2, 2, 3, 7, 4, 5);
CopyOnWriteArrayList<Integer> toCopyOnWriteList = integers.stream().collect(Collectors.toCollection(CopyOnWriteArrayList::new));
```

### 1.5. 收集后转换为不可变List

```java
List<Integer> integers = Arrays.asList(3, 2, 2, 3, 7, 4, 5);
ImmutableList<Integer> immutableList = integers.stream().collect(Collectors.collectingAndThen(Collectors.toList(), ImmutableList::copyOf));
```

### 1.6. List转Map

```java
/*Lombok*/
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
class Student {
    private Long id;
   private String name;
}
ArrayList<Student> students = new ArrayList<>();
for (int i = 1; i <= 10; i++) {
    Student student = new Student();
    student.setId((long)i);
    student.setName("s" + i);
    students.add(student);
}

Map<Long, String> listToMap = students.stream().collect(Collectors.toMap(Student::getId, Student::getName));
for (Long aLong : listToMap.keySet()) {
    System.out.println(listToMap.get(aLong));
}
```

**需要注意的是** toMap 如果集合对象有重复的key，会报错Duplicate key...

可以用Collectors.toMap的第三个参数 (k1,k2)->k1 来设置，如果有重复的key,则保留key1,舍弃key2 

```java
/*Lombok*/
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
class Student {
    private Long id;
   private String name;
}
ArrayList<Student> students = new ArrayList<>();
for (int i = 1; i <= 10; i++) {
    Student student = new Student();
    student.setId((long)i%5);
    student.setName("s" + i);
    students.add(student);
}

Map<Long, String> listToMap = students.stream().collect(Collectors.toMap(Student::getId, Student::getName,(k1,k2)->k1));
for (Long aLong : listToMap.keySet()) {
    System.out.println(listToMap.get(aLong));
}
```

### 1.7. List 转 List<Map<String,Object>> 

有时候需要将List转换成List<Map<String,Object>>的形式，一般是把Map当成一个Tuple2类型来用了。

```java
/*Lombok*/
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
class Student {
    private Long id;
   private String name;
}
ArrayList<Student> students = new ArrayList<>();
for (int i = 1; i <= 10; i++) {
    Student student = new Student();
    student.setId((long)i%5);
    student.setName("s" + i);
    students.add(student);
}

Map<Long, String> listToMap = students.stream().collect(Collectors.toMap(Student::getId, Student::getName,(k1,k2)->k1));
for (Long aLong : listToMap.keySet()) {
    System.out.println(listToMap.get(aLong));
}
```
List<Map<String,Object>> personToMap = peopleList.stream().map((p) -> { Map<String, Object> map = new HashMap<>(); map.put("name", p.name); map.put("age", p.age); return map; }).collect(Collectors.toList()); //或者 List<Map<String,Object>> personToMap = peopleList.stream().collect(ArrayList::new, (list, p) -> { Map<String, Object> map = new HashMap<>(); map.put("name", p.name); map.put("age", p.age); list.add(map); }, List::addAll);

字典查询和数据转换 toMap时，如果value为null,会报空指针异常 解决办法一：

Map<String, List> resultMaps = Arrays.stream(dictTypes) .collect(Collectors.toMap(i -> i, i -> Optional.ofNullable(dictMap.get(i)).orElse(new ArrayList<>()), (k1, k2) -> k2));

解决办法二：

Map<String, List> resultMaps = Arrays.stream(dictTypes) .filter(i -> dictMap.get(i) != null).collect(Collectors.toMap(i -> i, dictMap::get, (k1, k2) -> k2));

解决办法三：

Map<String, String> memberMap = list.stream().collect(HashMap::new, (m,v)-> m.put(v.getId(), v.getImgPath()),HashMap::putAll); System.out.println(memberMap);

解决办法四：

Map<String, String> memberMap = new HashMap<>(); list.forEach((answer) -> memberMap.put(answer.getId(), answer.getImgPath())); System.out.println(memberMap);

Map<String, String> memberMap = new HashMap<>(); for (Member member : list) { memberMap.put(member.getId(), member.getImgPath()); }

假设有一个User实体类，有方法getId(),getName(),getAge()等方法，现在想要将User类型的流收集到一个Map中，示例如下：

Stream userStream = Stream.of(new User(0, "张三", 18), new User(1, "张四", 19), new User(2, "张五", 19), new User(3, "老张", 50));

Map<Integer, User> userMap = userSteam.collect(Collectors.toMap(User::getId, item -> item));

假设要得到按年龄分组的Map<Integer,List>,可以按这样写：

Map<Integer, List> ageMap = userStream.collect(Collectors.toMap(User::getAge, Collections::singletonList, (a, b) -> { List resultList = new ArrayList<>(a); resultList.addAll(b); return resultList; }));

Map<Integer, String> map = persons .stream() .collect(Collectors.toMap( p -> p.age, p -> p.name, (name1, name2) -> name1 + ";" + name2));

System.out.println(map); // {18=Max, 23=Peter;Pamela, 12=David}
```


### 1.7. Map转List

```java
List list = map.entrySet().stream().sorted(Comparator.comparing(e -> e.getKey())) .map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List list = map.entrySet().stream().sorted(Comparator.comparing(Map.Entry::getValue)).map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List list = map.entrySet().stream().sorted(Map.Entry.comparingByKey()).map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());
```

### 1.8. Map转Map

```java
//示例1 Map<String, List> 转 Map<String,User> Map<String,List> map = new HashMap<>(); map.put("java", Arrays.asList("1.7", "1.8")); map.entrySet().stream();

@Getter @Setter @AllArgsConstructor public static class User{ private List versions; }

Map<String, User> collect = map.entrySet().stream() .collect(Collectors.toMap( item -> item.getKey(), item -> new User(item.getValue())));

//示例2 Map<String,Integer> 转 Map<String,Double> Map<String, Integer> pointsByName = new HashMap<>(); Map<String, Integer> maxPointsByName = new HashMap<>();

Map<String, Double> gradesByName = pointsByName.entrySet().stream() .map(entry -> new AbstractMap.SimpleImmutableEntry<>( entry.getKey(), ((double) entry.getValue() / maxPointsByName.get(entry.getKey())) * 100d)) .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
```



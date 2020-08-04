java8 Lambda Stream collect Collectors 常用详细实例代码汇总


交集 (list1 + list2)

List<T> intersect = list1.stream()
                         .filter(list2::contains)
                         .collect(Collectors.toList());

差集

//(list1 - list2)
List<String> reduce1 = list1.stream().filter(item -> !list2.contains(item)).collect(toList());

//(list2 - list1)
List<String> reduce2 = list2.stream().filter(item -> !list1.contains(item)).collect(toList());

并集

//使用并行流 
List<String> listAll = list1.parallelStream().collect(toList());
List<String> listAll2 = list2.parallelStream().collect(toList());
listAll.addAll(listAll2);


去重并集

List<String> listAllDistinct = listAll.stream()
.distinct().collect(toList());


Map集合转 List

List<Person> list = map.entrySet().stream().sorted(Comparator.comparing(e -> e.getKey()))
		.map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());
		
List<Person> list = map.entrySet().stream().sorted(Comparator.comparing(Map.Entry::getValue)).map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List<Person> list = map.entrySet().stream().sorted(Map.Entry.comparingByKey()).map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List集合转 Map

/*使用Collectors.toMap形式*/
Map result = peopleList.stream().collect(Collectors.toMap(p -> p.name, p -> p.age, (k1, k2) -> k1));
//其中Collectors.toMap方法的第三个参数为键值重复处理策略，如果不传入第三个参数，当有相同的键时，会抛出一个IlleageStateException。
//或者
Map<Integer, String> result1 = list.stream().collect(Collectors.toMap(Hosting::getId, Hosting::getName));
//List<People> -> Map<String,Object>
List<People> peopleList = new ArrayList<>();
peopleList.add(new People("test1", "111"));
peopleList.add(new People("test2", "222"));
Map result = peopleList.stream().collect(HashMap::new,(map,p)->map.put(p.name,p.age),Map::putAll);


List 转 Map<Integer,Apple>
/**
 * List<Apple> -> Map<Integer,Apple>
 * 需要注意的是：
 * toMap 如果集合对象有重复的key，会报错Duplicate key ....
 *  apple1,apple12的id都为1。
 *  可以用 (k1,k2)->k1 来设置，如果有重复的key,则保留key1,舍弃key2
 */
Map<Integer, Apple> appleMap = appleList.stream().collect(Collectors.toMap(Apple::getId, a -> a,(k1, k2) -> k1));


List 转 List<Map<String,Object>>
List<Map<String,Object>> personToMap = peopleList.stream().map((p) -> {
    Map<String, Object> map = new HashMap<>();
    map.put("name", p.name);
    map.put("age", p.age);
    return map;
}).collect(Collectors.toList());
//或者
List<Map<String,Object>> personToMap = peopleList.stream().collect(ArrayList::new, (list, p) -> {
   Map<String, Object> map = new HashMap<>();
    map.put("name", p.name);
    map.put("age", p.age);
    list.add(map);
}, List::addAll);


字典查询和数据转换 toMap时，如果value为null,会报空指针异常
解决办法一：

Map<String, List<Dict>> resultMaps = Arrays.stream(dictTypes)
.collect(Collectors.toMap(i -> i, i -> Optional.ofNullable(dictMap.get(i)).orElse(new ArrayList<>()), (k1, k2) -> k2));

解决办法二：

Map<String, List<Dict>> resultMaps = Arrays.stream(dictTypes)
.filter(i -> dictMap.get(i) != null).collect(Collectors.toMap(i -> i, dictMap::get, (k1, k2) -> k2));

解决办法三：

Map<String, String> memberMap = list.stream().collect(HashMap::new, (m,v)->
    m.put(v.getId(), v.getImgPath()),HashMap::putAll);
System.out.println(memberMap);

解决办法四：

Map<String, String> memberMap = new HashMap<>();
list.forEach((answer) -> memberMap.put(answer.getId(), answer.getImgPath()));
System.out.println(memberMap);

Map<String, String> memberMap = new HashMap<>();
for (Member member : list) {
    memberMap.put(member.getId(), member.getImgPath());
}


假设有一个User实体类，有方法getId(),getName(),getAge()等方法，现在想要将User类型的流收集到一个Map中，示例如下：

Stream<User> userStream = Stream.of(new User(0, "张三", 18), new User(1, "张四", 19), new User(2, "张五", 19), new User(3, "老张", 50));

Map<Integer, User> userMap = userSteam.collect(Collectors.toMap(User::getId, item -> item));


假设要得到按年龄分组的Map<Integer,List>,可以按这样写：

Map<Integer, List<User>> ageMap = userStream.collect(Collectors.toMap(User::getAge, Collections::singletonList, (a, b) -> {
            List<User> resultList = new ArrayList<>(a);
            resultList.addAll(b);
            return resultList;
        }));

Map<Integer, String> map = persons
    .stream()
    .collect(Collectors.toMap(
        p -> p.age,
        p -> p.name,
        (name1, name2) -> name1 + ";" + name2));

System.out.println(map);
// {18=Max, 23=Peter;Pamela, 12=David}


Map 转 另一个Map

//示例1 Map<String, List<String>> 转 Map<String,User>
Map<String,List<String>> map = new HashMap<>();
map.put("java", Arrays.asList("1.7", "1.8"));
map.entrySet().stream();

@Getter
@Setter
@AllArgsConstructor
public static class User{
    private List<String> versions;
}

Map<String, User> collect = map.entrySet().stream()
                .collect(Collectors.toMap(
                        item -> item.getKey(),
                        item -> new User(item.getValue())));

//示例2 Map<String,Integer>  转 Map<String,Double>
Map<String, Integer> pointsByName = new HashMap<>();
Map<String, Integer> maxPointsByName = new HashMap<>();

Map<String, Double> gradesByName = pointsByName.entrySet().stream()
        .map(entry -> new AbstractMap.SimpleImmutableEntry<>(
                entry.getKey(), ((double) entry.getValue() /
                        maxPointsByName.get(entry.getKey())) * 100d))
        .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));

排序

//按照自然顺序进行排序 如果要自定义排序sorted 传入自定义的 Comparator
list.stream()
    .sorted()
    .filter((s) -> s.startsWith("a"))
    .forEach(System.out::println);

//对象排序比较 请重写对象的equals()和hashCode()方法
list.sorted((a, b) -> b.compareTo(a))

Collections.sort(names, (a, b) -> b.compareTo(a));


比较

Comparator<Person> comparator = (p1, p2) -> p1.firstName.compareTo(p2.firstName);

Person p1 = new Person("John", "Doe");
Person p2 = new Person("Alice", "Wonderland");

comparator.compare(p1, p2);             // > 0
comparator.reversed().compare(p1, p2);  // < 0

Map.merge() 类似于分组之后sum

 Map<String, Integer> studentScoreMap2 = new HashMap<>();
        studentScoreList.forEach(studentScore -> studentScoreMap2.merge(
          studentScore.getStuName(),
          studentScore.getScore(),
          Integer::sum));


自定义 Collector

Collector<Person, StringJoiner, String> personNameCollector =
    Collector.of(
        () -> new StringJoiner(" | "),          // supplier
        (j, p) -> j.add(p.name.toUpperCase()),  // accumulator
        (j1, j2) -> j1.merge(j2),               // combiner
        StringJoiner::toString);                // finisher

String names = persons
    .stream()
    .collect(personNameCollector);

System.out.println(names);  // MAX | PETER | PAMELA | DAVID


参考资料

```html
https://blog.csdn.net/fzy629442466/article/details/84629422
```
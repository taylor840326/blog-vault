## Gson
-----


Gson用户指南
概述
Gson是这样一个Java类库，它可以将Java对象转换为相应的JSON形式，也可以将JSON字符串转换为对应的Java对象。Gson是一个开源库，其地址为：http://code.google.com/p/google-gson。
Gson可以使用任意Java对象，包括哪些预先存在的、不在你的源代码中的对象（因此，你并不知道对象的属性）。

Gson的目标
提供一种机制，使得将Java对象转换为JSON或相反如使用toString()以及构造器（工厂方法）一样简单。
允许预先存在的不可变的对象转换为JSON或与之相反。
允许自定义对象的表现形式
支持任意复杂的对象
输出轻量易读的JSON
Gson的性能和可扩展性
下面给出一些我们在同时运行很多其他任务的桌面环境（双处理器，8GB内存，64位Ubuntu操作系统）下的测试指标。你可以使用PerformanceTest类重复运行这些测试。

Strings:反序列化超过25MB的字符串没有出现任何问题（查看PerformanceTest类中的disabled_testStringDeserializationPerformance 方法）
大型集合：
1.序列化一个包含超过140亿个对象的集合（查看PerformanceTest类中的disabled_testLargeCollectionSerialization 方法）
2.反序列化一个拥有87000个对象的集合（查看PerformanceTest类中的disabled_testLargeCollectionDeserialization方法）
Gson 1.4版本将字节数组和集合的反序列化限制从80KB提升到了11MB。
注：测试的时候删除disabled_前缀。这个前缀是我们用来进行Junit测试时组织运行这些测试的。
Gson的用户群
Gson最一开始是谷歌内部使用的，现在已经应用在了许多项目中了。如今，它已经被许多公共项目和公司所使用。详情请见这里这里。

使用Gson
使用Gson的首要类是Gson类，你可以仅仅通过new Gson()的方式创建它。你也可以通过GsonBuilder类去创建Gson实例，这个类允许你进行一系列配置，例如版本控制等等。

Gson实例不会保存任何进行Json操作时的状态。因此，你可以自由的服用相同的Gson对象进行诸多的Json序列化和反序列化操作。

原始类型的例子
序列化
Gson gson = new Gson();
gson.toJson(1);            ==> prints 1
gson.toJson("abcd");       ==> prints "abcd"
gson.toJson(new Long(10)); ==> prints 10
int[] values = { 1 };
gson.toJson(values);       ==> prints [1]
反序列化
int one = gson.fromJson("1", int.class);
Integer one = gson.fromJson("1", Integer.class);
Long one = gson.fromJson("1", Long.class);
Boolean false = gson.fromJson("false", Boolean.class);
String str = gson.fromJson("\"abc\"", String.class);
String anotherStr = gson.fromJson("[\"abc\"]", String.class);
对象的例子
class BagOfPrimitives {
  private int value1 = 1;
  private String value2 = "abc";
  private transient int value3 = 3;
  BagOfPrimitives() {
    // no-args constructor
  }
}
序列化
BagOfPrimitives obj = new BagOfPrimitives();
Gson gson = new Gson();
String json = gson.toJson(obj);  
==> json is {"value1":1,"value2":"abc"}
注意你不能序列化一个具有循环引用从而导致无限递归的对象。

反序列化
BagOfPrimitives obj2 = gson.fromJson(json, BagOfPrimitives.class);   
==> obj2 is just like obj
更好的序列化需要对象具备的要点
最好使用private成员变量
没有必要使用注解指示一个成员变量是否需要序列化或反序列化。所有当前类中的成员变量（包括继承自所有父类的成员变量）都默认支持序列化和反序列化。
以下实现得以正确的操作空对象
1、序列化时，一个空的成员变量将会在输出中被省去。
2、反序列化时，在JSON字符串中缺失的字段将会在相应的成员变量中变为空。
如果一个成员变量由synthetic关键字标记，在JSON序列化或者反序列化的过程中将会被忽略。
如果成员变量对应的是外部类中的内部类，匿名类，本地类则会被忽略，从而不被序列化或反序列化。
嵌套类（包括内部类）的例子
Gson可以轻易的序列化静态的嵌套类。

Gson同样可以反序列化静态嵌套类。然而，Gson不能自动的反序列化一个纯内部类，这是因为在创建这样的对象时它的无参构造器需要一个指向包裹对象（外部类）的引用，而这在反序列化的时候是不可能的。你可以将这个内部类指定为静态的或者提供一个自定义的实例构造者以解决这个问题。以下是一个例子：

public class A { 
  public String a; 

  class B { 

    public String b; 

    public B() {
      // No args constructor for B
    }
  } 
}
注：上面的B类默认情况下是不能使用Gson进行序列化的。

Gson不能反序列化{“b”：“abc”}为一个B的实例，因为B类是一个内部类。如果它被定义为static class B，那么Gson就可以对其执行反序列化。另外一个解决办法是为B提供一个自定义的实例构造者。

public class InstanceCreatorForB implements InstanceCreator<A.B> {
  private final A a;
  public InstanceCreatorForB(A a)  {
    this.a = a;
  }
  public A.B createInstance(Type type) {
    return a.new B();
  }
}
以上的办法是可能的，但不推荐。

数组的例子
Gson gson = new Gson();
int[] ints = {1, 2, 3, 4, 5};
String[] strings = {"abc", "def", "ghi"};
序列化
gson.toJson(ints);     ==> prints [1,2,3,4,5]
gson.toJson(strings);  ==> prints ["abc", "def", "ghi"]
反序列化
int[] ints2 = gson.fromJson("[1,2,3,4,5]", int[].class); 
==> ints2 will be same as ints
我们同样支持多为数组，以及任意复杂的元素类型。

集合的例子
Gson gson = new Gson();
Collection<Integer> ints = Lists.immutableList(1,2,3,4,5);
序列化
String json = gson.toJson(ints); ==> json is [1,2,3,4,5]
反序列化
Type collectionType = new TypeToken<Collection<Integer>>(){}.getType();
Collection<Integer> ints2 = gson.fromJson(json, collectionType);
ints2 is same as ints
相当丑陋：注意我们如何定义集合的类型。
不幸的是，我们没有办法用Java避免这种尴尬。

集合的限制
可以序列化任意对象的集合但不能反序列化之
1、这是因为没有途径使得用户可以去提示该对象的类型。
反序列化过程中，集合必须制定特定的泛型
所有这些是有意义的，它使得你在遵循好的Java编码实践的过程中很少发生错误。

序列化和反序列化泛型
当你调用toJson(obj)，Gson会调用obj.getClass()去获取该类里面的相关字段进行序列化。同样的，你往往可以传递MyClass.class对象到fromJson(json, MyClass.class)方法中。如果对象是非泛型的，这将会工作良好。
然而，如果对象是泛型的，Java类型擦除机制将会导致泛型类型的丢失。以下通过一个例子进行阐释：

class Foo<T> {
  T value;
}
Gson gson = new Gson();
Foo<Bar> foo = new Foo<Bar>();
gson.toJson(foo); // May not serialize foo.value correctly

gson.fromJson(json, foo.getClass()); // Fails to deserialize foo.value as Bar
上面的代码之所以不能讲相应的值转换成对应的条目类型，这是因为Gson调用list.getClass()去获取它的类型信息时，返回的是Foo.class的原始类型。这意味着Gson没有办法知道这个对象的类型是Foo<Bar>，而不仅仅只是解释为Foo。

你可以通过为你的泛型指定正确的参数化类型来解决这个问题。这里你需要用到TypeToken类。

Type fooType = new TypeToken<Foo<Bar>>() {}.getType();
gson.toJson(foo, fooType);

gson.fromJson(json, fooType);
这个获取 footType 的习惯性语法，事实上是因为在定义了一个包含getType()方法的匿名本地内部类，该方法返回完整的参数化类型。

序列化和反序列化任意类型的对象的集合
有时候，你所处理的JSON数组包含混合的类型。例如：

['hello',5,{name:'GREETINGS',source:'guest'}]
相应的集合为：

Collection collection = new ArrayList();
collection.add("hello");
collection.add(5);
collection.add(new Event("GREETINGS", "guest"));
Event类的定义为：

class Event {
  private String name;
  private String source;
  private Event(String name, String source) {
    this.name = name;
    this.source = source;
  }
}
你可以序列化该集合而不需要任何额外的操作：toJson(collection)可以将结果写入到指定的输出。然而，不能通过fromJson(json, Collection.class)进行反序列化操作，这是因为Gson无法知道如何映射到指定的输入类型。Gson要求你在使用fromJson的时候提供集合的泛型版本。因此，你有三个选择：

Option 1: 你可以通过使用Gson的解析器API（较底层的流解析器或者Dom解析器JsonParser）来解析该数组的元素，然后对数组的每个元素分别调用Gson.fromJson()方法。这是首选的途径。这个例子 阐述了该怎么做。

Option 2: 为Collection.class注册一个类型适配器以检查数组的每个成员并将之映射到相应的对象。这种方式的缺陷是将会导致反序列化其他集合类型时是无效的（也就是不够通用）。

Option 3: 为MyCollectionMemberType注册类型适配器并在fromJson中使用Collection<MyCollectionMemberType>。只有当你的数组是顶层元素或者你可以改变Collection<MyCollectionMemberType>集合类型中的成员字段时，这种方式才是有效的。

内置的序列化器和反序列化器
Gson为常用类型定义了一些内置的序列化器和反序列化器，但这些类有时候工作可能并不良好。这里给出一些具体的类：

1、匹配java.net.URL的字符串如“http://code.google.com/p/google-gson/”。
2、匹配java.net.URL的字符串如“/p/google-gson/”

你可以通过查看远吗找到这些常用类，比如Joda。

自定义序列化和反序列化机制
有时候，默认的实现并不是你想要的。这在处理类库时常常发生（例如DateTime）。Gson允许你注册自己自定义的序列化器和反序列化器。该过程分为两部分：

Json序列化器：需要为一个对象自定义序列化机制。

Json反序列化器：需要为一个类型自定义反序列化机制。

实例构造者：并不需要，如果无参构造器是可用的或者注册了一个反序列化器。

  GsonBuilder gson = new GsonBuilder();
  gson.registerTypeAdapter(MyType2.class, new MyTypeAdapter());
  gson.registerTypeAdapter(MyType.class, new MySerializer());
  gson.registerTypeAdapter(MyType.class, new MyDeserializer());
  gson.registerTypeAdapter(MyType.class, new MyInstanceCreator());
registerTypeAdapter会检查类型适配器是否实现了上面三个接口中的一个以上并且它们都注册了类型适配器。

写一个序列化器
这里通过一个例子说明如何为JodaTime DateTime类自定义序列化器。

private class DateTimeSerializer implements JsonSerializer<DateTime> {
  public JsonElement serialize(DateTime src, Type typeOfSrc, JsonSerializationContext context) {
    return new JsonPrimitive(src.toString());
  }
}
当序列化到DateTime对象时，Gson会调用toJson()。

写一个反序列化器
这里通过一个例子说明如何为JodaTime DateTime类自定义反序列化器。

private class DateTimeDeserializer implements JsonDeserializer<DateTime> {
  public DateTime deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context)
      throws JsonParseException {
    return new DateTime(json.getAsJsonPrimitive().getAsString());
  }
}
当需要反序列化一个JSON字符串片段到DateTime对象时，Gson会调用fromJson()。

序列化器和反序列化器的几个要点
通常，你想要为所有泛型类型注册仅一个序列化器和反序列化器以处理其相应的唯一的原始类型。

例如，假设你有一个叫做“Id”的类需要用Id表述或转换（i.e. an internal vs. external representation）。
Id<T>类型将会为所有的泛型使用同一个序列化器
1、基本上输出id值
反序列化机制是类似的但并不完全相同
1、需要调用"new Id(Class<T>, String)"以返回Id<T>的实例。
Gson支持为此注册一个单一处理器。你也可以为某个特定泛型注册一个特定的处理器（如Id(RequiresSpecialHanding)就需要特定的处理器）。
toJson和fromJson方法中的类型参数所包含的泛型参数信息帮助你为所有的泛型类型定义一个处理器以匹配相同的原始类型。

写一个实例构造者
反序列化一个对象时，Gson需要为该类型创建一个默认实例。
可以良好的进行序列化和反序列化的类应该拥有一个无参构造器 —— 无论其是由public还是由private修饰的。
通常来说，实例构造者的使用时机是在你需要处理没有定义无参构造器的库类时。

实例构造者的例子
private class MoneyInstanceCreator implements InstanceCreator<Money> {
  public Money createInstance(Type type) {
    return new Money("1000000", CurrencyCode.USD);
  }
}
类型可以是一个相应的泛型

对于启动一个需要特定泛型类型信息的构造器非常有用
例如，Id类存储了创建Id的类。
使用InstanceCreator处理参数化类型
有时候，你试图去实例化的类型是一个参数化类型。通常，这不会有什么问题，因为这是一个原始类型的实例。例子如下：

class MyList<T> extends ArrayList<T> {
}

class MyListInstanceCreator implements InstanceCreator<MyList<?>> {
    @SuppressWarnings("unchecked")
  public MyList<?> createInstance(Type type) {
    // No need to use a parameterized list since the actual instance will have the raw type anyway.
    return new MyList();
  }
}
然而，有时候你需要创建的实例是基于实际的参数化类型。在这种情况下，你可以使用传入createInstance方法中的类型参数。例子如下：

public class Id<T> {
  private final Class<T> classOfId;
  private final long value;
  public Id(Class<T> classOfId, long value) {
    this.classOfId = classOfId;
    this.value = value;
  }
}

class IdInstanceCreator implements InstanceCreator<Id<?>> {
  public Id<?> createInstance(Type type) {
    Type[] typeParameters = ((ParameterizedType)type).getActualTypeArguments();
    Type idType = typeParameters[0]; // Id has only one parameterized type T
    return Id.get((Class)idType, 0L);
  }
}
在上面的例子中，如果没有传入参数化类型的实际类型，那么Id类是无法创建的。我们通过使用传入的type来解决这个问题。这种情况下，该type是表示Id<Foo>的Java参数化类型的对象，该对象的实际类型绑定到了Id<Foo>。Id类仅仅只有一个参数化类型参数T，因此我们可以使用getActualTypeArgument()返回的第0个参数，这种情况下该参数将会拥有Foo.class。

紧凑和漂亮的JSON格式输出对比
Gson默认提供的默认JSON输出是一个紧凑的JSON格式。这意味着输出的JSON格式中将不会有空格字符。因此，在JSON输出中无论是字段名和他们的值之间，对象域以及数组所包含的对象之间都不会有空格。同样，"null"字段将会在JSON输出中被忽略（注：null值在集合或数组中不会被忽略）。查看Null对象支持部分的相关信息并进行相关配置以使Gson的输出支持null值。

如果你想要输出为漂亮的结构，你需要使用GsonBuilder来配置你的Gson实例。JsonFormatter类在我们的公开API中并没有暴露，因此，客户端不能为JSON输出配置默认的打印设置或间隔。现在，我们仅仅提供了一个默认的JsonPrintFormatter类，该类默认：行宽为80个字符，2个字符的首行间距以及4个字符的右间距。

下面的例子展示如何使用默认的JsonPrintFormatter代替JsonCompatFormatter配置一个Gson实例：

Gson gson = new GsonBuilder().setPrettyPrinting().create();
String jsonOutput = gson.toJson(someObject);
Null对象支持
Gson中的默认实现是，所有空对象将会被忽略。这样允许更加紧凑的输出格式；然而，当由JSON格式重新转换为其Java对象时，客户必须为这些成员定义一个默认值。

下例展示了如何配置Gson实例以达到输出null的目的：

Gson gson = new GsonBuilder().serializeNulls().create();
注意：当用Gson序列化空值时，将会在JsonElement结构中添加一个JsonNull元素。因此，该对象可以用于自定义的序列化器或反序列化器。

例子如下：

public class Foo {
  private final String s;
  private final int i;

  public Foo() {
    this(null, 5);
  }

  public Foo(String s, int i) {
    this.s = s;
    this.i = i;
  }
}

Gson gson = new GsonBuilder().serializeNulls().create();
Foo foo = new Foo();
String json = gson.toJson(foo);
System.out.println(json);

json = gson.toJson(null);
System.out.println(json);

======== OUTPUT ========
{"s":null,"i":5}
null
版本支持
同一个对象的不同版本中可以通过使用@Since注解得到保留。该注解可以应用于类、成员变量，在未来甚至可以应用在方法上。为了应用这个特性，你必须配置你的Gson实例以使它忽略所有搞过某些版本的成员变量或对象。如果没有为Gson实例设置版本，那么它将会忽略版本而序列化和反序列化所有域和类。

public class VersionedClass {
  @Since(1.1) private final String newerField;
  @Since(1.0) private final String newField;
  private final String field;

  public VersionedClass() {
    this.newerField = "newer";
    this.newField = "new";
    this.field = "old";
  }
}

VersionedClass versionedObject = new VersionedClass();
Gson gson = new GsonBuilder().setVersion(1.0).create();
String jsonOutput = gson.toJson(someObject);
System.out.println(jsonOutput);
System.out.println();

gson = new Gson();
jsonOutput = gson.toJson(someObject);
System.out.println(jsonOutput);

======== OUTPUT ========
{"newField":"new","field":"old"}

{"newerField":"newer","newField":"new","field":"old"}
序列化过程中排除某些域
Gson支持大量的机制以排除高层类，成员变量以及成员变量类型。下面的可插拔式机制允许成员变量和类的排除。如果以下的机制不能满足你的需求，你通常可以使用自定义序列化器和反序列化器。

Java修饰的排除机制
默认情况下，如果你使用transient标记某个成员变量，它将会被排除。同样，如果一个成员变量被声明为“static”那么默认情况下它也将被排除。如果你想要包含某些transient修饰的成员变量，你可以按如下做法：

import java.lang.reflect.Modifier;

Gson gson = new GsonBuilder()
    .excludeFieldsWithModifiers(Modifier.STATIC)
    .create();
注：你可以为“excludeFieldsWithModifiers”方法提供任意数量的Modifier常量。例如：

Gson gson = new GsonBuilder()
    .excludeFieldsWithModifiers(Modifier.STATIC, Modifier.TRANSIENT, Modifier.VOLATILE)
    .create();
Gson的@Expose注解
该特性提供了一种你可以明确指定那些你不想要执行JSON的序列化和反序列化的成员变量。使用该注解，你必须使用new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create()来创建Gson实例。该Gson实例将会排除该类中所有没有使用@Expose注解标记的成员变量。

用户定义的排除策略
如果以上的机制还不能满足你的需求，那么通常你可以定义你自己的排除策略然后将之插入Gson中。查看ExclusionStrategyJava文档查看更多信息。

以下例子展示了如何排除一个使用特定注解“@Foo”标记的成员变量，该注解还可以排除高层类型（或者公开的成员变量的类型）的类字符串。

@Retention(RetentionPolicy.RUNTIME)
  @Target({ElementType.FIELD})
  public @interface Foo {
    // Field tag only annotation
  }

  public class SampleObjectForTest {
    @Foo private final int annotatedField;
    private final String stringField;
    private final long longField;
    private final Class<?> clazzField;

    public SampleObjectForTest() {
      annotatedField = 5;
      stringField = "someDefaultValue";
      longField = 1234;
    }
  }

  public class MyExclusionStrategy implements ExclusionStrategy {
    private final Class<?> typeToSkip;

    private MyExclusionStrategy(Class<?> typeToSkip) {
      this.typeToSkip = typeToSkip;
    }

    public boolean shouldSkipClass(Class<?> clazz) {
      return (clazz == typeToSkip);
    }

    public boolean shouldSkipField(FieldAttributes f) {
      return f.getAnnotation(Foo.class) != null;
    }
  }

  public static void main(String[] args) {
    Gson gson = new GsonBuilder()
        .setExclusionStrategies(new MyExclusionStrategy(String.class))
        .serializeNulls()
        .create();
    SampleObjectForTest src = new SampleObjectForTest();
    String json = gson.toJson(src);
    System.out.println(json);
  }

======== OUTPUT ========
{"longField":1234}
JSON域命名支持
Gson支持某些预先定义的成员变量命名策略以将基本的Java成员变量名称（如以小写字母开头的驼峰命名规则---“simpleFieldNameInJava”）转换为Json域名（如sample_field_name_in_java o 或者SampleFieldNameInJava）。查看FieldNamingPolicy类以获取关于预先定义命名策略的信息。

同样Gson有基于注解的策略以允许客户程序员为每一个域名自定义名称。注意，基于注解的策略拥有域名名称的有效性检查机制，当它检查到某个提供了该注解的域名为非法时，会抛出“Runtime”异常。

下面的例子展示了如何使用Gson命名机制的特性：

private class SomeObject {
  @SerializedName("custom_naming") private final String someField;
  private final String someOtherField;

  public SomeObject(String a, String b) {
    this.someField = a;
    this.someOtherField = b;
  }
}

SomeObject someObject = new SomeObject("first", "second");
Gson gson = new GsonBuilder().setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE).create();
String jsonRepresentation = gson.toJson(someObject);
System.out.println(jsonRepresentation);

======== OUTPUT ========
{"custom_naming":"first","SomeOtherField":"second"}
如果你需要使用自定义命名机制（查看该论坛）,你可以使用@SerializedName注解。

在自定义的序列化器和反序列化器之间分享状态
有时候你需要在自定义的序列化器或反序列化器之间分享状态（查看该论坛）。你可以通过下面三个途径实现：

1、在静态成员变量中保存分享的状态。
2、定义序列化器或反序列化器为父类型的内部类，然后使用副类型中的成员变量实例保存分享的状态。
3、使用Java ThreadLocal

1和2是非线程安全的，3是线程安全的。

流
根据Gson的对象模型和数据绑定方式，你可以使用Gson读写流。你同样可以结合流和对象模型的访问方式以这两者之间最好的实践方法。

设计中的问题
查看Gson设计文档的相关论坛。它同样包含了可以将用于Json转换的其他颇具竞争力的Java类库。

未来改进
在最后的改进列表中，或者如果你想要建议新的功能，查看项目网站中的Issues模块。

作者：WeberLisper
链接：https://www.jianshu.com/p/1e20b28c39d1
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
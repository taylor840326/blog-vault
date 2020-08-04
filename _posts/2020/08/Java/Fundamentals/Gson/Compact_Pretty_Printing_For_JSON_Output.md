## Compact Vs. Pretty Printing for JSON Output Format

-----

一般情况下Gson类提供的 API已经能满足大部分的使用场景。

但有时需要更多特殊、强大的功能时，这时候就引入一个新的类 GsonBuilder。

GsonBuilder从名上也能知道是用于构建Gson实例的一个类，要想改变Gson默认的设置必须使用该类配置Gson

GsonBuilder用法：　

//各种配置  
//生成配置好的Gson

```java
Gson gson = new GsonBuilder().create();
```

### 1. GsonBuilder的使用场景
　　
### 1.1. 处理null值

Gson在默认情况下是不自动导出值为null的键

如：
```java
public class User {
     public String name;
     public int age;
　　　//省略
     public String email;
}
Gson gson = new Gson();
User user = new User(张三",24);
System.out.println(gson.toJson(user));  //{"name":"张三","age":24}
```
email字段是没有在json中出现的，当在调试时需要导出完整的json串时或API接中要求没有值必须用Null时，就会比较有用。

```java
Gson gson = new GsonBuilder().serializeNulls() .create();
User user = new User("张三", 24);
System.out.println(gson.toJson(user)); //{"name":"张三","age":24,"email":null}
```


### 1.2. 格式化输出、日期时间及其它：

```java
Gson gson = new GsonBuilder()
    //序列化null
    .serializeNulls()
    // 设置日期时间格式，另有2个重载方法
    // 在序列化和反序化时均生效
    .setDateFormat("yyyy-MM-dd")
    // 禁此序列化内部类
     .disableInnerClassSerialization()
    //生成不可执行的Json（多了 )]}' 这4个字符）
    .generateNonExecutableJson()
     //禁止转义html标签
    .disableHtmlEscaping()
    //格式化输出
    .setPrettyPrinting()
    .create();
```

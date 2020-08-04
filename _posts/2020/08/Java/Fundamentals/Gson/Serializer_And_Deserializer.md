## 序列化和反序列化 (Serializers and Deserializers)
-----

### 6. 流式序列化和反序列化

### 6.1. 流式反序列化

（1）自动方式

　　　　Gson提供了fromJson()和toJson() 两个直接用于解析和生成的方法，前者实现反序列化，后者实现了序列化。同时每个方法都提供了重载方法　　

Gson.toJson(Object);
Gson.fromJson(Reader,Class);
Gson.fromJson(String,Class);
Gson.fromJson(Reader,Type);
Gson.fromJson(String,Type);
　　(2)手动方式：手动的方式就是使用stream包下的JsonReader类来手动实现反序列化，和Android中使用pull解析XML是比较类似的

复制代码
String json = "{\"name\":\"张三\",\"age\":\"24\"}";
User user = new User();
JsonReader reader = new JsonReader(new StringReader(json));
reader.beginObject();
while (reader.hasNext()) {
    String s = reader.nextName();
    switch (s) {
        case "name":
        user.name = reader.nextString();
        break;
        case "age":
        user.age = reader.nextInt(); //自动转换
        break;
        case "email":
        user.email = reader.nextString();
        break;
    }
}
reader.endObject(); // throws IOException
System.out.println(user.name);  //张三
System.out.println(user.age);   // 24
System.out.println(user.email); //zhangsan@ceshi.com                

自动方式最终都是通过JsonReader来实现的，如果第一个参数是String类型，那么Gson会创建一个StringReader转换成流操作

### 6.2. 流式序列化

Gson.toJson方法列表

　　//PrintStream(System.out) 、StringBuilder、StringBuffer和*Writer都实现了Appendable接口。　　

Gson gson = new Gson();
User user = new User("张三",24,"zhangsan@ceshi.com");
gson.toJson(user,System.out);
　　(2)手动方式

复制代码
JsonWriter writer = new JsonWriter(new OutputStreamWriter(System.out));
writer.beginObject() // throws IOException
    .name("name").value("张三")
     .name("age").value(24)
     .name("email").nullValue() //演示null
    .endObject(); // throws IOException
    writer.flush(); // throws IOException
//{"name":"张三","age":24,"email":null}
//除了beginObject、endObject还有beginArray和endArray，两者可以相互嵌套，注意配对即可。beginArray后不可以调用name方法，同样beginObject后在调用value之前必须要调用name方法。




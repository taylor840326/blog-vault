## SpringBoot 常用知识总结
-----

### 1.@SpringBootApplication注解

### 2.Spring Bean相关

### 2.1.@Autowird

@Autowird注解自动导入对象到类中，被注入进的类同样要被Spring容器管理。

比如Service类注入到Controller类中。

```java
@Service
public class UserService{
...
}

@RestController
@RequestMapping("/users")
public class UserController {
    @Autowird
    UserService userService;
    ...

}
```

### 2.2.@Component/@Repository/@Service/@Controller

我们一般使用 @Autowired 注解让 Spring 容器帮我们自动装配 bean。要想把类标识成可用于 @Autowired 注解自动装配的 bean 的类,可以采用以下注解实现：

1. @Component ：通用的注解，可标注任意类为 Spring 组件。如果一个 Bean 不知道属于哪个层，可以使用@Component 注解标注。
1. @Repository : 对应持久层即 Dao 层，主要用于数据库相关操作。
1. @Service : 对应服务层，主要涉及一些复杂的逻辑，需要用到 Dao 层。
1. @Controller : 对应 Spring MVC 控制层，主要用户接受用户请求并调用 Service 层返回数据给前端页面。

### 2.3.@RestController

@RestController注解是@Controller和@ResponseBody的合集,表示这是个控制器 bean,并且是将函数的返回值直 接填入 HTTP 响应体中,是 REST 风格的控制器。

注：现在都是前后端分离，说实话我已经很久没有用过@Controller。如果你的项目太老了的话，就当我没说。

单独使用 @Controller 不加 @ResponseBody的话一般使用在要返回一个视图的情况，这种情况属于比较传统的 Spring MVC 的应用，对应于前后端不分离的情况。@Controller +@ResponseBody 返回 JSON 或 XML 形式数据

### 2.4.@Scope

声明 Spring Bean 的作用域，使用方法：

```java
@Bean 
@Scope("singleton")
public Person personSingleton() {
    return new Person();
}
```

四种常见的 Spring Bean 的作用域：

1. singleton : 唯一 bean 实例，Spring 中的 bean 默认都是单例的。
1. prototype : 每次请求都会创建一个新的 bean 实例。
1. request : 每一次 HTTP 请求都会产生一个新的 bean，该 bean 仅在当前 HTTP request 内有效。
1. session : 每一次 HTTP 请求都会产生一个新的 bean，该 bean 仅在当前 HTTP session 内有效。

### 2.5.@Configuration

一般用来声明配置类，可以使用 @Component注解替代，不过使用Configuration注解声明配置类更加语义化。

```java
@Configuration
public class AppConfig{
    
    @Bean
    public TransferService transferService(){
        return new TransferServiceImpl();
    }
}
```

### 3.处理常见的HTTP请求类型

5种常见的请求类型有

1. GET ：请求从服务器获取特定资源。举个例子：GET /users（获取所有学生）
1. POST ：在服务器上创建一个新的资源。举个例子：POST /users（创建学生）
1. PUT ：更新服务器上的资源（客户端提供更新后的整个资源）。举个例子：PUT /users/12（更新编号为 12 的学生）
1. DELETE ：从服务器删除特定的资源。举个例子：DELETE /users/12（删除编号为 12 的学生）
1. PATCH ：更新服务器上的资源（客户端提供更改的属性，可以看做作是部分更新），使用的比较少，这里就不举例子了。

### 3.1.GET

@GetMapping("users)注解等价于@RequestMapping(value="/users",method = ReuestMehtod.GET)

```java
@GetMapping("/users")
public ResponseEntity<List<Users>> getALLUsers(){
    return userRepostiroy.findAll();
}
```

### 3.1.POST

@PostMapping("users)等价于@RequestMapping(value="/users",method = RequestMethod.POST)

```java
@PostMapping("/users")
public ResponseEntity<User> createUser(@Valid @RequestBody UserCreateReuqest userCreateRequest){
    return userRepository.save(user);
}
```

### 3.1.PUT

@PutMapping("/users/{userId})等价于@RequestMapping(value = "/users/{userId}",method = RequestMethod.PUT)

```java
@PutMapping("/users/{userId}")
public ResponseEntity<User> updateUser(@PathVariable(value = "userId") Long userId,@Valid @RequestBody UserUpdateRequest userUpdateRequest){
    ...
}
```

### 3.1.DELETE

@Deletemapping("/usrs/{userId})等价于@RequestMapping(value = "/users/{userId}",method = RequestMethod.DELETE)

```java
@DeleteMapping("/users/{userId}")
public ResponseEntity<User> deleteUser(@PathVariable(value = "userId") Long userId){
    ....
}
```

### 3.1.PATCH

一般实际项目中，都是PUT方法不够用了采用PATCH请求去更新数据

```java
@PatchMapping("/profile")
public ResponseEntity<User> updateStudent(@RequestBody StudentUpdateRquest studentUpdateRequest){
    studentRepository.updateDetail(studentUpdateRquest);
    return ResponseEntity.ok().build();
}
```

### 4.前后端传值

### 4.1.@PathVariable和@RequestParam

@PathVariable用于获取路径参数

@RequestParam用于获取参训参数

```java
@GetMapping("/klasses/{klassId}/teachers")
public List<Teacher> getKlassRelatedTeacher(@PathVariable("klassId") Long klassId,@RequestParam(value = "type",required = false) String type){
    ...
}
```

如果我们请求的url是/klass/{123456}/teachers?type=web

则服务获取到的数据就是：klassId = 123456,type = web

### 4.2.@RequestBody

@RequestBody注解用于读取Request请求(GET/POST/PUT/DELETE)的body部分，并且Content-Type为application/json格式的数据。

接受到的数据会自动兵丁到Java 对象上。

系统会使用HttpMessageConverter或者自定义的HttpMessageConverter将请求的body中的json字符串转换为Java对象。

```java
@PostMapping("/sign-up")
public ResponseEntity signUp(@RequestBody @Valid UserRegisterRequest userRegisterReuqest){
    userService.save(userRegisterReuqest);
    return ResponseEntity.ok().build();
}
```

UserRegisterRequest对象定义如下

```java
@Data 
@AllArgsConstructor
@NoArgsConstructor
public class UserRegisterRequest {
    
    @NotBlank
    private String userName;
    
    @NotBlank
    private String password;
    
    @FullName
    @NotBlank
    private String fullName;
}
```

如果对接口发送一个POST请求，并且body的JSON数据为

```html
curl -XPOST http://localhost:8080/api/users/sign-up -d 

{
  "userName": "coder",
  "fullName": "beijing",
  "password": "123456"
}
```

这样json里面的数据就会被绑定在UserRegisterRequest类上。

需要注意：
1. 一个请求方法只可以有一个@RequestBody，但是可以有多个@RequestParam或者@PathVariable
1. 如果你的方法必须要有两个@RequestBody来接受数据的话，大概率是你的数据库设计或者系统设计出问题了。


### 5.读取配置信息

通常一些外部服务的配置信息需要存放在application.properties文件中。

SpringBoot为我们提供了多种配置文件的读取方式

假设有一个配置文件内容如下：

```yaml
wuhan2020: 2020年初武汉爆发了新型冠状病毒，疫情严重，但是，我相信一切都会过去！武汉加油！中国加油！

my-profile:
  name: Guide哥
  email: koushuangbwcx@163.com

library:
  location: 湖北武汉加油中国加油
  books:
    - name: 天才基本法
      description: 二十二岁的林朝夕在父亲确诊阿尔茨海默病这天，得知自己暗恋多年的校园男神裴之即将出国深造的消息——对方考取的学校，恰是父亲当年为她放弃的那所。
    - name: 时间的秩序
      description: 为什么我们记得过去，而非未来？时间“流逝”意味着什么？是我们存在于时间之内，还是时间存在于我们之中？卡洛·罗韦利用诗意的文字，邀请我们思考这一亘古难题——时间的本质。
    - name: 了不起的我
      description: 如何养成一个新习惯？如何让心智变得更成熟？如何拥有高质量的关系？ 如何走出人生的艰难时刻？
```

### 5.1.@Value（常用）

@Value("${property}") 读取比较简单的配置信息

```java
@Value("${wuhan2020}")
private String name;
```

### 5.2.@ConfigurationProperties(常用)

@ConfigurationProperties注解可以读取配置信息并于Bean绑定

```java
@Component
@ConfigurationProperties(prefix="library")
public class LibraryProperties {
    @NotEmpty
    private String location;
    private List<Book> books;
    
    @Setter
    @Getter
    @ToString
    static class Book {
        String name;
        String description;
    }
    ....
}
```

这样就可以像使用普通Spring Bean一样，将其注入到其他类中使用。

### 5.3.@PropertySource(不常用)

@PropertySource指定读取的properties文件

```java
@Component
@PropertySource("classpath:website.properties")
public class WebSite{
    @Value("${url}")
    private String url;
    ...
}
```

### 6.参数校验

JSR(Java Specification Requests)是一套JavaBean参数校验标准，它定义了很多常用的校验注解。

我们可以直接将这些注解加载我们JavaBean的属性上面，这样就可以在需要校验的时候进行参数检验。

校验的时候我们实际用的是Hibernate Validator框架。

1. Hibernate Validator 4.x是Bean Validation 1.0(JSR 303)的参考实现
1. Hibernate Validator 5.x是Bean Validation 1.1(JSR 349)的参考实现
1. Hibernate Validator 6.0是Bean Validation 2.0(JSR 380)的参考实现

SpringBoot项目的spring-boot-starter-web依赖中已经有hibernate-validator包，不需要引用相关依赖。

需要注意的是：所有的注解，推荐使用JSR注解，即javax.validation.constraints，而不是org.hibernate.validator.constraints

### 6.1.一些常用字段验证的注解

1. @NotEmpty 被注释的字符串的不能为 null 也不能为空
1. @NotBlank 被注释的字符串非 null，并且必须包含一个非空白字符
1. @Null 被注释的元素必须为 null
1. @NotNull 被注释的元素必须不为 null
1. @AssertTrue 被注释的元素必须为 true
1. @AssertFalse 被注释的元素必须为 false
1. @Pattern(regex=,flag=)被注释的元素必须符合指定的正则表达式
1. @Email 被注释的元素必须是 Email 格式。
1. @Min(value)被注释的元素必须是一个数字，其值必须大于等于指定的最小值
1. @Max(value)被注释的元素必须是一个数字，其值必须小于等于指定的最大值
1. @DecimalMin(value)被注释的元素必须是一个数字，其值必须大于等于指定的最小值
1. @DecimalMax(value) 被注释的元素必须是一个数字，其值必须小于等于指定的最大值
1. @Size(max=, min=)被注释的元素的大小必须在指定的范围内
1. @Digits (integer, fraction)被注释的元素必须是一个数字，其值必须在可接受的范围内
1. @Past被注释的元素必须是一个过去的日期
1. @Future 被注释的元素必须是一个将来的日期

### 6.2.验证请求体RequestBody

```java
@Data 
@AllArgsConstructor
@NoArgsConstructor
public class Person {
    @NotNull(message = "classId 不能为空")
    private String classId;
    
    @Size(max = 33)
    @NotNull(message = "name 不能为空")
    private String name;

    @Pattern(regexp = "((^Man$|^Woman$|^UGM$))",message = "sex 值不在可选范围")
    @NotNull(message = "sex 不能为空")
    private String sex;

    @Email(message = "email 格式不正确")
    @NotNull(message = "email 不能为空")
    private String email;
}
```

我们在需要验证的参数上加上了@Valid注解，如果验证失败则会抛出MethodArgumentNotValidException

```java
@RestController
@RequestMapping("/api")
public class PersonController {

    @PostMapping("/person")
    public ResponseEntity<Person> getPerson(@RequestBody @Valid Person person){
        return ResponseEntity.ok().body(person);
    }
}


```

### 6.3.验证请求参数Path Variables 和Request Parameters

一定不要忘记在类上加上@Validated注解，这个参数可以告诉Spring去校验方法参数

```java
@RestController
@RequestMapping("/api")
@Validated
public class PersonController {
    @GetMapping("/person/{id}")
    public ResponseEntity<Integer> getPersonByID(@Valid @PathVariable("id") @Max(value = 5,message = "超过 id 的范围了") Integer id) {
        return ResponseEntity.ok().body(id);
    }
}
```
### 7.全局处理Controller层异常

@ControllerAdvice注解定义全局异常处理类

@ExceptionHandler注解声明异常处理方法

```java
@ControllerAdvice
@ResponseBody
public class GlobalExceptionHandler {
    /*请求参数异常处理*/
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleMethodArgumentNotValidException(MethodArgumentNotValidException ex,HttpServletRequest request){
        ...
    }
    ...
}
```

### 8.JPA相关

### 8.1.创建表

@Entity注解声明一个类对应一个数据库实体

@Table注解作用在类上，设置表名

```java
@Entity
@Table(name = "t_role")
public class Role {
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String description;
}
```

### 8.2.创建主键

@Id注解用于声明一个字段为主键

使用@Id声明之后，我们还需要定义主键的生成策略。可以使用@GeneratedValue指定主键生成策略。

对于主键生成的方法在JPA中有两种,分别是

1. 通过@GeneratedValue直接使用JPA内置提供的四种主键生成策略
1. 通过@GenericGenerator声明一个主键策略，然后@GeneratedValue使用这个策略

#### 8.2.1.使用JPA内置的四种策略
JPA使用枚举定义了4种常用的主键生成策略

```java
public enum GenerationType {
    /*
    使用一个特定的数据表格来保存主键
    持久化引擎通过关系数据库的一张特定的表格来生成主键
    */
    TABLE,
    /*
    在某些数据库中不支持主键自增长，他们提供了另外一种叫SEQUENCE的主键生成机制。比如Oracle，PostgreSQL。
    */
    SEQUENCE,
    /*
    主键自增长
    */
    IDENTITY,
    /*
    把主键生成策略交给持久化引擎Persistence Engine
    持久化引擎会根据数据库在以上三种主键生成策略中选择其中一种
    */
    AUTO
}
```

@GeneratedValue注解默认使用的策略时GenerationType.AUTO。

如果后端数据库使用的时MySQL，则GenerationType.IDENTITY策略比较普通一点。

如果是分布式系统的话需要另外考虑使用分布式ID

#### 8.2.2.使用自定义策略

除了上面使用JPA默认的4中策略以外，还可以使用@GenericGenerator注解声明一种主键策略，然后使用@GeneratedValue注解应用这个策略

```java
...
@Id 
@GenericGenerator(name = "identityIdGenerator",strategy = "identity")
@GeneratedValue(generator = "identityIdGenerator")
private Long id;
...
```

以上定义主键策略等同于使用默认的主键策略IDENTITY

```java
...
@Id 
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;
...
```

JPA额外提供的主键生成策略有如下几种：
```java
    //详见DefaultIdentifierGeneratorFactory类
    public DefaultIdentifierGeneratorFactory() {
        this.register("uuid2", UUIDGenerator.class);
        this.register("guid", GUIDGenerator.class);
        this.register("uuid", UUIDHexGenerator.class);
        this.register("uuid.hex", UUIDHexGenerator.class);
        this.register("assigned", Assigned.class);
        this.register("identity", IdentityGenerator.class);
        this.register("select", SelectGenerator.class);
        this.register("sequence", SequenceStyleGenerator.class);
        this.register("seqhilo", SequenceHiLoGenerator.class);
        this.register("increment", IncrementGenerator.class);
        this.register("foreign", ForeignGenerator.class);
        this.register("sequence-identity", SequenceIdentityGenerator.class);
        this.register("enhanced-sequence", SequenceStyleGenerator.class);
        this.register("enhanced-table", TableGenerator.class);
    }
```

### 8.3.设置字段类型

@Column注解用于声明字段

```java
@Column(name= "user_name",nullable=false,length=32)
private String userName;
```

设置字段并且加默认值（比较常用）

```java
Column(columnDefinition = "tinyint(1) default 1")
private Boolean enabled;
```

### 8.4.指定不持久化特定字段

@Transient注解用于声明不需要与数据库映射的字段，在保存的时候不需要保存进数据库。

```java
@Entity(name="USER")
public class User {
    ...
    @Transient
    private String secrect;
}
```

除了使用@Transient声明以外，还可以采用下面几种方法

```java
static String secrect;  //static修饰的变量不会持久化
final String secrect = "111111";    //final修饰的变量不会持久化
transient String secrect;   //transient修饰的变量不会持久化
```

### 8.5.声明大字段

@Lob注解用于声明某个字段为大字段


简化声明

```java
@Lob
private String content;
```

更详细的声明

```java
@Lob        
/*
指定Lob类型数据库的获取策略
FetchType.EAGER表示非延迟获取
FetchType.LAZY表示延迟获取
*/
@Basic(fetch = FetchType.EAGER)
/*
定义字段的类型
*/
@Column(name = "content",columnDefinition = "LONGTEXT NOT NULL")
private String content;
```

### 8.6.创建枚举类型的字段

```java
public enum Gender {
    MALE("男性")，
    FEMALE("女性");
    
    private String value;
    Gender(String str){
        value = str;    
    }
}

@Entity
@Table(name = "role")
public class Role{
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String description;

    @Enumerated(EnumType.STRING)
    private Gender gender; 
    ...
}
```
数据库里面对应存储的是MALE/FEMALE

### 8.7.增加审计功能

只要继承了AbstractAuditBase的类都会默认加上下面四个字段

```java
@Data 
@AllArgsConstructor
@NoArgsConstructor
@MappedSuperclas
@EntityListeners(value = AuditingEntityListener.class)
public abstract class AbstractAuditBase{

    @CreatedDate
    @Column(updateable = false)
    @JsonIgnore
    private Instant createdAt;

    @LastModifiedDate
    @JsonIgnore
    private Instant updatedAt;

    @CreatedBy
    @Column(updateable=false)
    @JsonIgnore
    private String createdBy;
    
    @LastModifiedBy
    @JsonIgnore
    private String updatedBy;
}
```

对应的审计功能对应的配置类可能是下面的

```java
@Configuration
@EnableJpaAuditing
public class AuditSecurityConfiguration{
    @Bean
    AuditorAware<String> auditorAware() {
        return () -> Optional.ofNullable(SecurityContextHolder.getContext())
                            .map(SecurityContext::getAuthentication)
                            .filter(Authentication::isAuthenticated)
                            .map(Authentication::getName);
    }   
}
```

@CreatedDate注解表示改字段为创建时间字段。在这个实体被insert的时候，会设置此字段的值。

@CreatedBy注解表示该字段为创建人，在执行insert操作的时候会创建字段。

@LastModifiedDate注解表示该字段为修改时间字段。

@LastModifiedBy注解表示该字段更新人。

@EnableJpaAuditing注解表是开启JPA的审计功能。

### 8.8.删除/修改数据

@Modifying注解提示JPA该操作是修改操作，修改操作还要配合@Transactional注解使用

```java
@Repository
public interface UserRepository extends JpaRepository<User,Long> {
    @Modifying
    @Transactional(rollbackFor = Exception.class)
    void deleteByUserName(String userName);
}
```

### 8.9.关联关系

@OneToOne注解表示一对一关系

@OneToMany注解表示一对多关系

@ManyToOne注解表示多对一关系

@ManyToMany注解表示多对多关系

### 9.事务Transactional

@Transactional注解一般可以作用在类或者方法上

1. 作用于类上：当把@Transactional注解放在类上时，表示该类的所有public方法都配置相同的事务属性信息。
1. 作用于方法上：当类配置了@Transactional注解，方法也配置了@Transactional注解，方法的事务会覆盖类的事务配置信息.

在要开启事务的方法上使用@Transactional注解即可开启事务

```java
@Transactional(rollbackFor = Exception.class)
public void save(){
    ...
}
```

我们知道Exception分为运行时异常RuntimeException和非运行时异常。

在@Transactional注解中如果不配置rollbackFor属性，那么事务只会在遇到RuntimeException的时候才会回滚；加上rollbackFor=Exception.class可以让事务在遇到非运行时异常时也可以回滚。

### 10.JSON数据处理

### 10.1.过滤json数据

@JsonIgnoreProperties注解作用再类上用于过滤掉特定字段不返回或者不解析

```java
//生成json时将userRoles属性过滤
@JsonIgnoreProperties({userRoles})
public class User {
    private String userName;
    private String fullName;
    private String password;
    @JsonIgnore     //JsonIgnore一般用在类的属性上，作用和JsonIgnoreProperties一样
    private List<UserRole> userRoles = new ArrayList<>();
}
```

### 10.2.格式化json数据

@JsonFormat注解一般用来格式化JSON数据。

```java
@JsonFormat(shape = JsonFormat.Shape.STRING,pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",timezone = 'GMT')
private Date date;
```

### 10.3.扁平化对象

@JsonUnWrapped注解用来扁平化json数据

```java
@Getter
@Setter
@ToString
public class Account {
    @JsonUnwrapped
    private Location location;
    
    @JsonUnwrapped
    private PersonInfo personInfo;

    @Getter
    @Setter
    @ToString
    public static class Location{
        private String provinceName;
        private String countyName;
    }

    @Getter
    @Setter
    @ToString
    public static class PersonInfo {
        private String userName;
        private String fullName;
    }
}
```

未扁平化之前

```json
{
  "location": {
    "provinceName": "湖北",
    "countyName": "武汉"
  },
  "personInfo": {
    "userName": "coder1234",
    "fullName": "beijing"
  } 
}
```

使用@JsonUnwrapped扁平化对象之后

```json
{
  "provinceName": "湖北"，
  "countyName": "武汉",
  "userName": "coder1234",
  "fullName": "beijing"
}
```

### 11.测试相关

@ActiveProfiles一般作用于测试类上，用于声明生效的Spring配置文件

```java
@SpringBootTest(webEnvironment = RANDOM_PORT)
@ActiveProfiles("test")
@Slf4j
public abstract class TestBeans(){
    ...
}
```

@Test注解声明一个方法为测试方法

@Transactional被声明的测试方法的数据会回滚，避免污染测试数据

@WithMockUser Spring Security提供的用来模拟一个真是用户，并且可以赋予权限
```java
@Test
@Transactional
@WithMockUser(username = "user01",authorities = "ROLE_TEACHER")
public void testFunc() throws Exception {
    ...
}
```



参考资料
```html
https://www.toutiao.com/i6818828234700882436/?tt_from=android_share&utm_campaign=client_share&timestamp=1596116322&app=news_article&utm_medium=toutiao_android&use_new_style=1&req_id=202007302138410101310751300A506A7F&group_id=6818828234700882436
```
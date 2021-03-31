## 使用HttpClient和RestTemplate访问Http资源
-----

## 1. 使用HttpClient

```java
		CloseableHttpClient client = HttpClientBuilder.create().build();
		ArrayList<NameValuePair> params = new ArrayList<>();
		params.add(new BasicNameValuePair("regionId","gz"));
		params.add(new BasicNameValuePair("limit","10"));

		URI uri = new URIBuilder().setScheme("https").setHost("open.didiyunapi.com")
				.setPath("/dicloud/i/compute/dc2/list")
				.setParameters(params)
				.build();

		HttpPost httpPost = new HttpPost(uri);
		httpPost.setHeader("Authorization","Bearer xxxxxx");

		CloseableHttpResponse resp = client.execute(httpPost);
		System.out.println(EntityUtils.toString(resp.getEntity()));
```

## 1. HttpMessageConverter

在使用RestTemplate作为客户端接收服务端的请求时，会经常遇到如下异常：

```bash
Could not extract response: no suitable HttpMessageConverter found for response type
```

如下示例：

```java
try {
 ResponseEntity responseEntity = restTemplate.getForEntity(url, Employee[].class);
 for (Employee employee : responseEntity.getBody()) {
  System.out.println(employee);
 }
} catch (Exception e) {
 e.printStackTrace();
 System.out.println("Error:-" + e.getMessage());
}
```

异常栈如下所示:

```java
org.springframework.web.client.RestClientException: Could not extract response: no suitable HttpMessageConverter found for response type [class [Lcom.technicalkeeda.bean.Employee;] and content type [application/octet-stream]
 at org.springframework.web.client.HttpMessageConverterExtractor.extractData(HttpMessageConverterExtractor.java:109)
 at org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor.extractData(RestTemplate.java:812)
 at org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor.extractData(RestTemplate.java:796)
 at org.springframework.web.client.RestTemplate.doExecute(RestTemplate.java:576)
 at org.springframework.web.client.RestTemplate.execute(RestTemplate.java:529)
 at org.springframework.web.client.RestTemplate.getForEntity(RestTemplate.java:261)
 at com.technicalkeeda.test.App.getEmployees(App.java:79)
 at com.technicalkeeda.test.App.main(App.java:32)
```

## 2. 可以找到的解决方案有两种

## 方案1

通过ClientHttpRequestFactory去创建restTemplate的http连接，这个类继承自Apache HttpComponents HttpClient。

如下代码所示：

```java
ClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory(HttpClients.createDefault());
RestTemplate restTemplate = new RestTemplate(requestFactory);
```

同理，可以使用Apache HttpComponents HttpClient代替RestTemplate。

## 方案2

通过上面的报错可以得知没有http内容类型application/octe-stream对应的Http消息转换器，所以可以指定一个。

```java
RestTemplate restTemplate = new RestTemplate();
MappingJackson2HttpMessageConverter mappingJackson2HttpMessageConverter = new MappingJackson2HttpMessageConverter();
mappingJackson2HttpMessageConverter.setSupportedMediaTypes(Arrays.asList(MediaType.APPLICATION_JSON, MediaType.APPLICATION_OCTET_STREAM));
restTemplate.getMessageConverters().add(mappingJackson2HttpMessageConverter);
```
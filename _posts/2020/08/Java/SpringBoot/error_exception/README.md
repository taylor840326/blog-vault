## 异常及错误处理
-----

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
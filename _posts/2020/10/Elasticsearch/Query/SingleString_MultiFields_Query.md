## 单字符串多字段

-----

```html
PUT /blogs/_doc/1
{
  "title":"Quick brown rabbits",
  "body":"Brown rabbits are commonly seen."
}

PUT /blogs/_doc/2
{
  "title":"Keeping pets healthy",
  "body":"My quick brown fox eats rabbits on a regular basis."
}

#从相关性来说，文档2的评分应该更高。但结果确实文档1更高
POST /blogs/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "title": "Brown fox"
          }
        },
        {
          "match": {
            "body": "Brown fox"
          }
        }
      ]
    }
  }
}
```

上例中，title和body相互竞争。但是不应该将分数简单叠加，二十应该找到单个最佳匹配的字段的评分。

Disjunction Max Query 查询

将任何与任一查询匹配的文档作为结果返回。采用字段上最匹配的评分最终评分返回。

```html

GET /blogs/_search
{
  "query": {
    "dis_max": {
      "tie_breaker": 0.7,
      "boost": 1.2,
      "queries": [
        {"match": {
          "title": "Quick fox"
        }},
        {
          "match": {
            "body": "Quick fox"
          }
        }
      ]
    }
  }
}
```

通过Tie Broker参数调整

1. 获得最佳匹配语句的评分 _score
1. 将其他匹配语句的评分与tie_breaker相乘
1. 对以上评分求和并规范化

Tie Breaker是一个介于0-1之间的浮点数。0代表使用最佳匹配；1代表所有语句同等重要。



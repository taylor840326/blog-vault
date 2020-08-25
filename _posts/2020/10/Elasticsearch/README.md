## Elastcisearch

-----
### 1. 概要

### 1. 概要

Elasticsearch是一个开源的分布式搜索引擎，提供了近实时搜索和聚合两大功能

Elastic Stack包括Elasticsearch、Kibana、Logstash、Beats等一系列产品。

1. Elasticsearch是核心引擎，提供了海量数据存储、搜索和聚合的能力。
1. Beats是轻量的数据采集器
1. Logstash用来做数据转换;
1. Kibana则提供了丰富的可视化展现与分析的功能。

Elastic Stack主要被广泛使用于：搜索、日志管理、安全分析、指标分析、业务分析、应用性能监控等多个领域。

Elastic Stack开元了X-Pack在内的相关代码。作为商业解决方案，X-Pack的部分功能需要收费。Elastic公司从6.8和7.1开始，Security功能也可以 免费使用

相比关系型数据库，Elasticsearch提供了如模糊查询、搜索条件的算分等关系型数据库所不善长的功能。但是在事务性等方面，也不如关系型数据库来的强大。

### 2. 搜索和聚合Aggregation

Precosion指除了相关的结果，还返回了多少不相关的结果

Recall衡量有多少相关的结果，实际上并没有返回

精确值包括：数字、日期和某夕具体的字符串

全文本： 是需要被检索的非结构文本。
 
Analysis是将文本转换成倒排索引中的Terms的过程

Elasticsearch的Analyzer是Char Filter => Tokenizer => Token Filter的过程

要善于利用_analyze API去测试Analyzer

Elasticsearch搜索支持URI Search 和REST Body两种

Elasticsearch提供了Bucket/Metric/Pipeline/Matrix四种方式的聚合

### 3. 文档CRUD和Index Mapping

除了CRUD操作外，Elasticsearch还提供了bulk、mget和msearch等操作。从提升性能的角度上说，建议使用。但是，单次操作的数据量不要过大，以免引发性能问题。

每个索引都有一个Mapping定义，包含文档的字段和类型、字段的Analyzer的相关配置。

Mapping可以被动态的创建，为了避免一些错误的类型推算或者满足特定的需求，可以显示的定义Mapping。

Mapping可以动态创建，也可以显示定义。你可以在Mapping中定制Analyzer。

你可以为字段指定定制化的analyzer，也可以为查询字符串指定search_analyzer

Index Template可以定义Mapping和Settings，并自动的应用到新创建的索引之上，建议要合理的使用Index Template

Dynamic Template支持在具体的索引上指定规则，为新增的字段指定相应的Mappings。

[Mapping](Mapping/Mapping.md)

[倒排索引](Inverted_index.md)

[Elasticsearch查询](Query/Query.md)

[分词器](Analyzer/Analyzer.md)

[应用示例](Elasticsearch_SpringBoot.md)


### 自我测试

#### 判断题： ES支持使用HTTP PUT 写入新文档，并通过ES生成文档id

错！需要用POST方法写入新文档。

#### 判断题： update一个文档，需要使用HTTP PUT

错！update一个文档，必须使用POST方法，PUT方法只能用来做Index胡子哦喝Create

#### 判断题： Index一个已经存在的文档，旧的文档会先被删除，新的文档再被写入。同时版本号加1

对

#### 尝试描述创建一个新的文档到一个不存在的索引中，背后会发生一些什么操作？

默认情况下，会创建相应的索引。并且自己设置Mapping。当然，实际情况还是要看是否有合适的Index Template。

#### ES7中的合法的type是什么？

ES7中一个索引只能有一个type，合法名字是_doc

#### 精确值和全文的本质区别是什么？

精确值不会被Analyzer分词，全文本会。

#### Analyzer由那几个部分组成？

Char Filter -> Tokenizer -> Token Filter

#### 尝试描述match和match_phrase的区别

match中的terms之间是OR的关系，match_phrase中的terms之间是AND的关系。并且term之间位置关系也影响搜索的结果。

#### 如果你希望match_phrase匹配到更多结果，你应该配置查询中什么参数？

slop。

#### 如果Mapping的Dynamic设置成strict，索引一个包含新增字段的恩当时会发生什么？

直接报错。

#### 如果Mapping的Dynamic设置成false，索引一个包含新增字段的文档时会发生什么？

文档被索引，新的字段在_source中可见。但是该字段无法搜索。

#### 判断： 可以把一个字段的类型从integer改成long，因为这两个类型是兼容的

错！字段类型修改，必须要重新reindex操作

#### 判断： 你可以在Mapping文件中为indexing和searching指定不同的analyzer

对。可以在mapping中为index和search指定不同的analyizer

#### 判断： 字段类型为text的字段，一定可以被全文检索

错！如果这个字段的index=false就无法被搜索。


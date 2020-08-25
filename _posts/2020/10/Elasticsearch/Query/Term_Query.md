## 基于term的查询
-----

term的重要性：

term是表达语义的最小单位。搜索和利用统计语言模型进行自然语言处理都需要处理term


特点：

1. Term level Query: Term Query / Range Query / Exists Query / Prefix Query / Wildcard Query
1. 在ES中，Term查询**对输入不做分词**。会将输入作为一个整体，在倒排索引中查找准确的词项，并且使用相关度算分公式为每个包含该词项的文档进行**相关度**算分- 例如 “Apple Store”
1. 可以通过Constant Score将查询转换成一个Filtering避免算分，并利用缓存提高性能



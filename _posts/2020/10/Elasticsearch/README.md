## Elastcisearch

-----

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

:star: **注意** :star:


### 运维相关

[搭建高可用集群]()

详细讲述如何搭建一套高可用的ES集群，集群的硬件如何规划。

[索引生命周期管理]()

包括如下几点：
1. 如何创建索引模板
1. 索引上线、下线维护
1. 索引的备份和恢复

[ES版本升级方案]()

ES的软件大版本和小版本的滚动升级。

[集群的维护]()


### 开发相关

[Mapping](Dev/Mapping/Mapping.md)

[倒排索引](Dev/Inverted_index/Inverted_index.md)

[Elasticsearch查询](Dev/Search/Query.md)

[分词器](Dev/Analyzer/Analyzer.md)

[应用示例](Dev/Practice/Elasticsearch_SpringBoot.md)

[备份和恢复](Ops/Backup_Restore/README.md)

### ML && NLP




## 使用ProxySQL进行数据脱敏
-----

## 1.简介

数据脱敏是指对某些敏感信息通过脱敏规则进行数据的变形，实现敏感隐私数据的可靠保护。

在涉及客户安全数据或者一些商业性敏感数据的情况下，在不违反系统规则条件下，对真实数据进行改造并提供测试使用。

被脱敏的数据不限于以下几种：
1. 身份证号
1. 手机号
1. 卡号 
1. 客户号
1. 客户名称
1. 客户邮箱
1. 客户地址
1. **

数据脱敏数据安全技术之一，其他与数据安全的技术还包括：
1. 数据库漏扫
1. 数据库加密
1. 数据库防火墙
1. 数据脱敏
1. 数据库安全审计系统

通过多维度的数据安全策略，可以尽量避免 拖库、刷库、撞库等情况的发生。

本文主要讲述如何使用MySQL数据库代理软件ProxySQL的查询复写和查询规则功能实现数据脱敏。


## 2.ProxySQL查询复写和查询规则

ProxySQL是一款非常强大的数据库代理软件，他对DBA、开发和测试都非常友好。我对这款软件的评价就是：“早用早享受，谁用谁知道：）”

抛开其强大的在线不停机维护功能不谈，最让我喜欢的还有它提供了查询复写和在线配置查询规则的能力。在日常数据库维护的时候查询复写和在线配置查询规则能帮助我们在不修改任何代码的前提下快速优化线上SQL，快速调整后端数据库架构。当然还包括这篇文档中要着重说明的它可以按照我们配置的查询规则和复写规则实现数据脱敏。

### 2.1.公司线上数据脱敏的要求

我所在的公司对线上数据安全性有一些要求，以下罗列出一些：

1. 对用户基本信息进行脱敏。用户基本信息包括：用户真实姓名、邮箱、手机号、家庭住址等。
1. 对用户的消费信息进行脱敏。包括：充值、消费等金额要脱敏
1. 对公司服务的组织名称要脱敏

## 3.实现方案

PrxoySQL是一款MySQL数据库代理软件，所有对后端数据库的请求都要通过它才能转发给后端数据库。而ProxySQL又支持进行查询复写和查询规则配置。

在用户发起查询请求的时候，我们就可以通过ProxySQL提供的机制对SQL语句进行改写，在制定的列上加上不同的函数，进而实现数据脱敏的要求。

为了实现上面的设想，我们来深入的研究以下ProxySQL的查询规则配置。

本文档使用的ProxySQL版本为 2.0.10


### 3.1.ProxySQL查询规则

官方文档地址
```html
https://github.com/sysown/proxysql/wiki/Main-(runtime)#mysql_query_rules
```

当登录到ProxySQL的终端管理界面后，就可以执行如下命令查看到查询规则的配置表结构。

```sql
Admin> SHOW CREATE TABLE mysql_query_rules\G
*************************** 1. row ***************************
       table: mysql_query_rules
Create Table: CREATE TABLE mysql_query_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    查询规则id
    active INT CHECK (active IN (0,1)) NOT NULL DEFAULT 0,
    规则是否处于激活状态。只有actvie=1的时候这条规则才被加载到runtime模式，并且被查询规则处理器处理。
    username VARCHAR,
    发起查询的用户名
    schemaname VARCHAR,
    查询目标数据库名称
    flagIN INT CHECK (flagIN >= 0) NOT NULL DEFAULT 0,
    链式查询规则入口。当这个查询规则处于激活状态(active=1)，flagIN=0的时候就会从这条规则开始匹配语句。
    client_addr VARCHAR,
    发起查询规则的客户端地址
    proxy_addr VARCHAR,
    proxy_port INT CHECK (proxy_port >= 0 AND proxy_port <= 65535), 
    发起查询规则的代理的地址和端口。
    digest VARCHAR,
    查询的digest唯一编码，这个唯一编码可以通过以下语句获取。select * from stats.stats_mysql_query_digest，通过找到执行的语句就能找到对应的digest值。
    match_digest VARCHAR,
    同上。用在匹配digest的时候。一般用不到。
    match_pattern VARCHAR,
    这个就是进行数据脱敏非常重要的参数之一。这里需要配置一些正则表达式，通过正则表达式就能匹配到某个SQL语句。进而可以对匹配到的SQL语句进行查询复写。
    negate_match_pattern INT CHECK (negate_match_pattern IN (0,1)) NOT NULL DEFAULT 0,
    表示这条语句是否进行取反匹配。比如match_pattern匹配到一个SQL，而此时negate_match_pattern的值设为1，则表示匹配这个SQL以外的所有SQL。
    re_modifiers VARCHAR DEFAULT 'CASELESS',
    正则匹配算法。默认即可。
    flagOUT INT CHECK (flagOUT >= 0), replace_pattern VARCHAR CHECK(CASE WHEN replace_pattern IS NULL THEN 1 WHEN replace_pattern IS NOT NULL AND match_pattern IS NOT NULL THEN 1 ELSE 0 END),
    这个又是链式匹配最终要的参数之一，flagOUT的值如果和它下面的某个规则flagIN的值一样，就会把处理的SQL再转发给这个规则处理。直到发送给某个apply的值为1的规则为止。
    destination_hostgroup INT DEFAULT NULL,
    目标后端mysql的编号，这个在mysql_servers表中配置
    cache_ttl INT CHECK(cache_ttl > 0),
    cache_empty_result INT CHECK (cache_empty_result IN (0,1)) DEFAULT NULL,
    cache_timeout INT CHECK(cache_timeout >= 0),
    与查询缓冲相关的配置，本文档用不到。
    reconnect INT CHECK (reconnect IN (0,1)) DEFAULT NULL,
    是否重连
    timeout INT UNSIGNED CHECK (timeout >= 0),
    查询超时时间
    retries INT CHECK (retries>=0 AND retries <=1000),】
    重试次数
    delay INT UNSIGNED CHECK (delay >=0),
    延时时间。本文档用不到
    next_query_flagIN INT UNSIGNED,
    mirror_flagOUT INT UNSIGNED,
    mirror_hostgroup INT UNSIGNED,
    对查询进行mirror操作的配置。本文档用不到。
    error_msg VARCHAR,
    对查询返回一个错误消息。在数据脱敏的时候可以有友好提示。
    OK_msg VARCHAR,
    对查询返回一个OK消息。本文档用不到。
    sticky_conn INT CHECK (sticky_conn IN (0,1)),
    是否更愿意连到某个后端
    multiplex INT CHECK (multiplex IN (0,1,2)),
    复杂查询配置。本文用不到
    gtid_from_hostgroup INT UNSIGNED,
    gtid配置。本文用不到
    log INT CHECK (log IN (0,1)),
    是否记录日志。如果log=1，还必须在variables中配置日志格式和路径。
    apply INT CHECK(apply IN (0,1)) NOT NULL DEFAULT 0,
    只有apply=1的时候，查询规则才被执行。通常普通的单条查询规则要把active、apply都设置为1；而链式查询规则入口规则的active都要为1，apply要为0，最后出口的规则active和apply必须都要为1。
    comment VARCHAR)
    规则注释
1 row in set (0.00 sec)
```

The fields have the following semantics:

    rule_id - the unique id of the rule. Rules are processed in rule_id order
    active - only rules with active=1 will be considered by the query processing module and only active rules are loaded into runtime.
    username - filtering criteria matching username. If is non-NULL, a query will match only if the connection is made with the correct username
    schemaname - filtering criteria matching schemaname. If is non-NULL, a query will match only if the connection uses schemaname as default schema (in mariadb/mysql schemaname is equivalent to databasename)
    flagIN, flagOUT, apply - these allow us to create "chains of rules" that get applied one after the other. An input flag value is set to 0, and only rules with flagIN=0 are considered at the beginning. When a matching rule is found for a specific query, flagOUT is evaluated and if NOT NULL the query will be flagged with the specified flag in flagOUT. If flagOUT differs from flagIN , the query will exit the current chain and enters a new chain of rules having flagIN as the new input flag. If flagOUT matches flagIN, the query will be re-evaluate again against the first rule with said flagIN. This happens until there are no more matching rules, or apply is set to 1 (which means this is the last rule to be applied)
    client_addr - match traffic from a specific source
    proxy_addr - match incoming traffic on a specific local IP
    proxy_port - match incoming traffic on a specific local port
    digest - match queries with a specific digest, as returned by stats_mysql_query_digest.digest
    match_digest - regular expression that matches the query digest. See also mysql-query_processor_regex
    match_pattern - regular expression that matches the query text. See also mysql-query_processor_regex
    negate_match_pattern - if this is set to 1, only queries not matching the query text will be considered as a match. This acts as a NOT operator in front of the regular expression matching against match_pattern or match_digest
    re_modifiers - comma separated list of options to modify the behavior of the RE engine. With CASELESS the match is case insensitive. With GLOBAL the replace is global (replaces all matches and not just the first). For backward compatibility, only CASELESS is the enabled by default. See also mysql-query_processor_regex for more details.
    replace_pattern - this is the pattern with which to replace the matched pattern. It's done using RE2::Replace, so it's worth taking a look at the online documentation for that: https://github.com/google/re2/blob/master/re2/re2.h#L378. Note that this is optional, and when this is missing, the query processor will only cache, route, or set other parameters without rewriting.
    destination_hostgroup - route matched queries to this hostgroup. This happens unless there is a started transaction and the logged in user has the transaction_persistent flag set to 1 (see mysql_users table).
    cache_ttl - the number of milliseconds for which to cache the result of the query. Note: in ProxySQL 1.1 cache_ttl was in seconds
    cache_empty_result - controls if resultset without rows will be cached or not
    reconnect - feature not used
    timeout - the maximum timeout in milliseconds with which the matched or rewritten query should be executed. If a query run for longer than the specific threshold, the query is automatically killed. If timeout is not specified, global variable mysql-default_query_timeout applies
    retries - the maximum number of times a query needs to be re-executed in case of detected failure during the execution of the query. If retries is not specified, global variable mysql-query_retries_on_failure applies
    delay - number of milliseconds to delay the execution of the query. This is essentially a throttling mechanism and QoS, allowing to give priority to some queries instead of others. This value is added to the mysql-default_query_delay global variable that applies to all queries. Future version of ProxySQL will provide a more advanced throttling mechanism.
    mirror_flagOUT and mirror_hostgroup - setting related to mirroring .
    error_msg - query will be blocked, and the specified error_msg will be returned to the client
    OK_msg - the specified message will be returned for a query that uses the defined rule
    sticky_conn - not implemented yet
    multiplex - If 0, multiplex will be disabled. If 1, multiplex could be re-enabled if there are is not any other conditions preventing this (like user variables or transactions). If 2, multiplexing is not disabled for just the current query. See wiki Default is NULL, thus not modifying multiplexing policies
    gtid_from_hostgroup - defines which hostgroup should be used as the leader for GTID consistent reads (typically the defined WRITER hostgroup in a replication hostgroup pair)
    log - this column can have three values: 1 - matched query will be recorded into the events log; 0 - matched query will not be recorded into the events log; NULL - matched query log attribute will remain value from the previous match(es). Executed query will be recorded to the events log if its log attribute is set to 1 when rule is applied (apply=1) or after processing all query rules and its log attribute is set to 1
    apply - when set to 1 no further queries will be evaluated after this rule is matched and processed (note: mysql_query_rules_fast_routing rules will not be evaluated afterwards)
    comment - free form text field, usable for a descriptive comment of the query rule


## 参考资料

参考链接：
```html
https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E8%84%B1%E6%95%8F/7914656?fr=aladdin
```

## 分片与集群的故障转移
-----

### Primary Shard主分片  -  提升系统存储容量

分片是Elasticsearch分布式存储的基石。分为主分片 和 副本分片

通过主分片，将数据分布在所有节点上

主分片Primary Shard，可以将一份索引的数据，分散在多个Data Node上，实现存储的水平扩展。

主分片数在索引创建的时候指定，后续默认不能修改，如果修改，需要重新创建索引


### Replica Shard副本分片 - 提高数据的可用性

**数据可用性**

通过引入副本分片(Replica Shard)提高数据的可用性。一旦主分片丢失，副本分片可以Promote成主分片。

副本分片数可以动态调整。

每个节点上都由完备的数据。如果不设置副本分片，一旦出现节点硬件故障，就由可能造成数据丢失

**提升系统的读取性能**

副本分片由主分片同步。通过支持增加Replica个数，一定成都上可以提高读取的吞吐量


### 分片数设定

如何规划一个索引的主分片和副本分片数

主分片数过小：例如创建了1个主分片的索引。如果该索引增长很快，集群无法通过增加节点实现对这个索引的数据扩展。

主分片设置过大： 导致单个分片容量很小。引发一个节点上由过多分片，影响性能。

副本分片树设置过多，会降低集群整体的写入性能。

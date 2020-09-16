## Elasticsearc的备份和恢复
-----

### 1. 概要

常见的数据库都会提供备份的机制，以解决在数据库无法使用的情况下可以开启新的实例，然后通过备份来恢复数据减少损失。

虽然 Elasticsearch 有良好的容灾性，但由于以下原因，其依然需要备份机制:

1. 数据灾备。在整个集群无法正常工作时，可以及时从备份中恢复数据。
1. 归档数据。随着数据的积累，比如日志类的数据，集群的存储压力会越来越大，不管是内存还是磁盘都要承担数据增多带来的压力，此时我们往往会选择只保留最近一段时间的数据，比如1个月，而将1个月之前的数据删除。如果你不想删除这些数据，以备后续有查看的需求，那么你就可以将这些数据以备份的形式归档。
1. 迁移数据。当你需要将数据从一个集群迁移到另一个集群时，也可以用备份的方式来实现。

Elasticsearch 做备份有两种方式:

1. 将数据导出成文本文件，比如通过 elasticdump、esm 等工具将存储在 Elasticsearch 中的数据导出到文件中。
1. 以备份 elasticsearch data 目录中文件的形式来做快照，也就是 Elasticsearch 中 snapshot 接口实现的功能。

第一种方式相对简单，在数据量小的时候比较实用，当应对大数据量场景效率就大打折扣。我们今天就着重讲解下第二种备份的方式，即 snapshot api 的使用。

备份要解决备份到哪里、如何备份、何时备份和如何恢复的问题，那么我们接下来一个个解决。

### 2. 备份到哪里

在 Elasticsearch 中通过 repository 定义备份存储类型和位置，存储类型有共享文件系统、AWS 的 S3存储、HDFS、微软 Azure的存储、Google Cloud 的存储等，当然你也可以自己写代码实现国内阿里云的存储。我们这里以最简单的共享文件系统为例，你也可以在本地做实验。

首先，你要在 elasticsearch.yml 的配置文件中注明可以用作备份路径 path.repo ，如下所示：

path.repo: ["/mount/backups", "/mount/longterm_backups"]
配置好后，就可以使用 snapshot api 来创建一个 repository 了，如下我们创建一个名为 my_backup 的 repository。

PUT /_snapshot/my_backup
{
  "type": "fs",
  "settings": {
    "location": "/mount/backups/my_backup"
  }
}
之后我们就可以在这个 repository 中来备份数据了。

### 3. 如何备份

有了 repostiroy 后，我们就可以做备份了，也叫快照，也就是记录当下数据的状态。如下所示我们创建一个名为 snapshot_1 的快照。

PUT /_snapshot/my_backup/snapshot_1?wait_for_completion=true
wait_for_completion 为 true 是指该 api 在备份执行完毕后再返回结果，否则默认是异步执行的，我们这里为了立刻看到效果，所以设置了该参数，线上执行时不用设置该参数，让其在后台异步执行即可。

执行成功后会返回如下结果，用于说明备份的情况：

{
  "snapshots": [
    {
      "snapshot": "snapshot_1",
      "uuid": "52Lr4aFuQYGjMEv5ZFeFEg",
      "version_id": 6030099,
      "version": "6.3.0",
      "indices": [
        ".monitoring-kibana-6-2018.05.30",
        ".monitoring-es-6-2018.05.28",
        ".watcher-history-7-2018.05.30",
        ".monitoring-beats-6-2018.05.29",
        "metricbeat-6.2.4-2018.05.28",
        ".monitoring-alerts-6",
        "metricbeat-6.2.4-2018.05.30"
      ],
      "include_global_state": true,
      "state": "SUCCESS",
      "start_time": "2018-05-31T12:45:57.492Z",
      "start_time_in_millis": 1527770757492,
      "end_time": "2018-05-31T12:46:15.214Z",
      "end_time_in_millis": 1527770775214,
      "duration_in_millis": 17722,
      "failures": [],
      "shards": {
        "total": 28,
        "failed": 0,
        "successful": 28
      }
    }
  ]
}
返回结果的参数意义都是比较直观的，比如 indices 指明此次备份涉及到的索引名称，由于我们没有指定需要备份的索引，这里备份了所有索引；state 指明状态；duration_in_millis 指明备份任务执行时长等。

我们可以通过 GET _snapshot/my_backup/snapshot_1获取 snapshot_1 的执行状态。

此时如果去 /mount/backups/my_backup 查看，会发现里面多了很多文件，这些文件其实都是基于 elasticsearch data 目录中的文件生成的压缩存储的备份文件。大家可以通过 du -sh . 命令看一下该目录的大小，方便后续做对比。

### 4. 何时备份

通过上面的步骤我们成功创建了一个备份，但随着数据的新增，我们需要对新增的数据也做备份，那么我们如何做呢？方法很简单，只要再创建一个快照 snapshot_2 就可以了。

PUT /_snapshot/my_backup/snapshot_2?wait_for_completion=true
当执行完毕后，你会发现 /mount/backups/my_backup 体积变大了。这说明新数据备份进来了。要说明的一点是，当你在同一个 repository 中做多次 snapshot 时，elasticsearch 会检查要备份的数据 segment 文件是否有变化，如果没有变化则不处理，否则只会把发生变化的 segment file 备份下来。这其实就实现了增量备份。

elasticsearch 的资深用户应该了解 force merge 功能，即可以强行将一个索引的 segment file 合并成指定数目，这里要注意的是如果你主动调用 force merge api，那么 snapshot 功能的增量备份功能就失效了，因为 api 调用完毕后，数据目录中的所有 segment file 都发生变化了。

另一个就是备份时机的问题，虽然 snapshot 不会占用太多的 cpu、磁盘和网络资源，但还是建议大家尽量在闲时做备份。

### 5. 如何恢复

所谓“养兵千日，用兵一时”，我们该演练下备份的成果，将其恢复出来。通过调用如下 api 即可快速实现恢复功能。

POST /_snapshot/my_backup/snapshot_1/_restore?wait_for_completion=true
{
  "indices": "index_1",
  "rename_replacement": "restored_index_1"
}
通过上面的 api，我们可以将 index_1 索引恢复到 restored_index_1 中。这个恢复过程完全是基于文件的，因此效率会比较高。

虽然我们这里演示的是在同一个集群做备份与恢复，你也可以在另一个集群上连接该 repository 做恢复。我们这里就不做说明了。

### 6. 备份的兼容性 

由于 Elasticsearch 版本更新比较快，因此大家在做备份与恢复的时候，要注意版本问题，同一个大版本之间的备份与恢复是没有问题的，比如都是 5.1 和 5.6 之间可以互相备份恢复。但你不能把一个高版本的备份在低版本恢复，比如将 6.x 的备份在 5.x 中恢复。而低版本备份在高版本恢复有一定要求：

1) 5.x 可以在 6.x 恢复

2) 2.x 可以在 5.x 恢复

3) 1.x 可以在 2.x 恢复

其他跨大版本的升级都是不可用的，比如1.x 的无法在 5.x 恢复。这里主要原因还是 Lucene 版本问题导致的，每一次 ES 的大版本升级都会伴随 Lucene 的大版本，而 Lucene 的版本是尽量保证向前兼容，即新版可以读旧版的文件，但版本跨越太多，无法实现兼容的情况也在所难免了。

```html
https://elasticsearch.cn/article/648
```
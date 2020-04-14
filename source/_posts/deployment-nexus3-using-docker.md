---
layout: docker
title: deployment-nexus3-using-docker
date: 2020-04-14 12:23:35
tags:
---

## 使用Docker启动Nexus3

------

## 1.简介

通常情况下，使用Maven管理Java项目的时候需要配置一个公司内的Maven镜像仓库。

因为，很多Jar包只能保存在公司内的服务器，不能传送到互联网上。

本文档主要说明如何创建一个公司内可用的Maven镜像仓库。

本文档只用Nexus3服务搭建Maven镜像仓库。


## 2.启动服务

本文档主要说明使用Docker启动Nexus3服务。

Docker的启动命令为：

```bash
#!/bin/bash

case "$1" in
        "start")
                docker run \
                       --name nexus3 \
                       -p 8081:8081 \
                       --name nexus \
                       -v /var/lib/maven:/nexus-data \
                       -d sonatype/nexus3
                ;;
        "stop")
                docker stop nexus3
                ;;
        "destroy")
                docker rm -f nexus3
                ;;
        *)
                echo "Usage: $@ [start|stop|destroy]"
esac


```


## 3.仓库配置


### 3.1.登录nexus3服务web页面


通过Docker启动Nexus3服务后可以使用Linux系统的命令查看8081端口是否启动成功。

```bash
$ ss -tnpl |grep 8081
```
如果可以看到8081端口就可以访问nexus3服务了。

### 3.2.修改管理员密码

nexus3默认用户名和密码是admin/admin123。登录后重新修改管理员密码。

### 3.3.仓库类型

nexus3服务可以设置的仓库类型有三种，依次是：

1. proxy：是远程仓库的代理。比如说在nexus中配置了一个central repository的proxy，当用户向这个proxy请求一个artifact，这个proxy就会先在本地查找，如果找不到的话，就会从远程仓库下载，然后返回给用户，相当于起到一个中转的作用。　　　　
1. Hosted：是宿主仓库，用户可以把自己的一些构件，deploy到hosted中，也可以手工上传构件到hosted里。比如说oracle的驱动程序，ojdbc6.jar，在central repository是获取不到的，就需要手工上传到hosted里，一般用来存放公司自己的jar包；
1. Group：是仓库组，在maven里没有这个概念，是nexus特有的。目的是将上述多个仓库聚合，对用户暴露统一的地址，这样用户就不需要在pom中配置多个地址，只要统一配置group的地址就可以了右边那个Repository Path可以点击进去，看到仓库中artifact列表。不过要注意浏览器缓存，当你的项目希望在多个。


通常我们使用maven的时候可以不用设置多个仓库地址，可以使用Group仓库类型管理多个仓库。

而通用的仓库主要有如下三个：

1. maven-public：maven-central、maven-release和maven-snapshot三个库的合集。
1. maven-release：用来存放release版本的jar包。
1. maven-snapshot：用来存放snapshot版本的jar包。


### 3.4.添加阿里云镜像仓库

nexus3服务启动后，默认会去国外的网站访问maven官方仓库。这样会导致我们初次下载某些软件依赖包的时候速度非常缓慢，好在有友好的阿里云帮助我们已经做好的常用仓库的镜像，我们需要把nexus3服务的仓库设置成阿里云提供的仓库。

### 3.4.1. 阿里云maven镜像仓库简介

可以通过如下地址访问阿里云的Maven镜像服务

```html
https://maven.aliyun.com/mvn/view
```

通过查看这个页面的最后一列，我们可以找到对应仓库在阿里云的访问地址。例如：

![avater](/2020/04/14/deployment-nexus3-using-docker/aliyun_maven_path.png)


### 3.4.2. 把阿里云地址加入到私有仓库中

首先创建一个新的仓库，仓库类型为Proxy，填入地址，其他默认即可

![avater](/2020/04/14/deployment-nexus3-using-docker/create_repository_on_nexus3.png)

![avater](/2020/04/14/deployment-nexus3-using-docker/select_maven2_proxy_type.png)

![avater](/2020/04/14/deployment-nexus3-using-docker/create_aliyun_central_proxy_repository.png)

最后选择“Create repository”按钮即可创建好一个类型为proxy的代理仓库。当用户访问这个代理仓库的时候如果本地有缓存就直接返回给客户，如果没有就需要再从阿里云拉去数据后再返回。


### 3.4.3. 修改maven-public仓库

因为这个仓库是一个group类型的仓库，以后客户端就可以通过访问这个仓库直接访问到后端的多个仓库管理的软件包。

![avater](/2020/04/14/deployment-nexus3-using-docker/modify_maven_public_group_repository.png)

把自己创建的阿里云代理仓库以导maven-public仓库中

![avater](/2020/04/14/deployment-nexus3-using-docker/enable_aliyun_proxy_repository.png)

![avater](/2020/04/14/deployment-nexus3-using-docker/enable_aliyun_proxy_repository2.png)

![avater](/2020/04/14/deployment-nexus3-using-docker/save_change.png)


到此为止，就可以访问我们的镜像仓库了。

## 4.修改settings.xml配置文件

通常修改好的settings.xml内容如下所示：

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<!--
 | This is the configuration file for Maven. It can be specified at two levels:
 |
 |  1. User Level. This settings.xml file provides configuration for a single user,
 |                 and is normally provided in ${user.home}/.m2/settings.xml.
 |
 |                 NOTE: This location can be overridden with the CLI option:
 |
 |                 -s /path/to/user/settings.xml
 |
 |  2. Global Level. This settings.xml file provides configuration for all Maven
 |                 users on a machine (assuming they're all using the same Maven
 |                 installation). It's normally provided in
 |                 ${maven.conf}/settings.xml.
 |
 |                 NOTE: This location can be overridden with the CLI option:
 |
 |                 -gs /path/to/global/settings.xml
 |
 | The sections in this sample file are intended to give you a running start at
 | getting the most out of your Maven installation. Where appropriate, the default
 | values (values used when the setting is not specified) are provided.
 |
 |-->
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/path/to/local/repo</localRepository>
  -->
  <localRepository>C:\Users\iXing\.m2\repository</localRepository>
  <!-- interactiveMode
   | This will determine whether maven prompts you when it needs input. If set to false,
   | maven will use a sensible default value, perhaps based on some other setting, for
   | the parameter in question.
   |
   | Default: true
  <interactiveMode>true</interactiveMode>
  -->

  <!-- offline
   | Determines whether maven should attempt to connect to the network when executing a build.
   | This will have an effect on artifact downloads, artifact deployment, and others.
   |
   | Default: false
  <offline>false</offline>
  -->

  <!-- pluginGroups
   | This is a list of additional group identifiers that will be searched when resolving plugins by their prefix, i.e.
   | when invoking a command line like "mvn prefix:goal". Maven will automatically add the group identifiers
   | "org.apache.maven.plugins" and "org.codehaus.mojo" if these are not already contained in the list.
   |-->
  <pluginGroups>
    <!-- pluginGroup
     | Specifies a further group identifier to use for plugin lookup.
    <pluginGroup>com.your.plugins</pluginGroup>
    -->
  </pluginGroups>

  <!-- proxies
   | This is a list of proxies which can be used on this machine to connect to the network.
   | Unless otherwise specified (by system property or command-line switch), the first proxy
   | specification in this list marked as active will be used.
   |-->
  <proxies>
    <!-- proxy
     | Specification for one proxy, to be used in connecting to the network.
     |
    <proxy>
      <id>optional</id>
      <active>true</active>
      <protocol>http</protocol>
      <username>proxyuser</username>
      <password>proxypass</password>
      <host>proxy.host.net</host>
      <port>80</port>
      <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
    </proxy>
    -->
  </proxies>

  <!-- servers
   | This is a list of authentication profiles, keyed by the server-id used within the system.
   | Authentication profiles can be used whenever maven must make a connection to a remote server.
   |-->
  <servers>
    <!-- server
     | Specifies the authentication information to use when connecting to a particular server, identified by
     | a unique name within the system (referred to by the 'id' attribute below).
     |
     | NOTE: You should either specify username/password OR privateKey/passphrase, since these pairings are
     |       used together.
     |
    <server>
      <id>deploymentRepo</id>
      <username>repouser</username>
      <password>repopwd</password>
    </server>
    -->

    <!-- Another sample, using keys to authenticate.
    <server>
      <id>siteServer</id>
      <privateKey>/path/to/private/key</privateKey>
      <passphrase>optional; leave empty if not used.</passphrase>
    </server>
    -->
<server>
	<id>nexus-releases</id>
	<username>admin</username>
	<password>admin</password>
</server>
<server>
	<id>nexus-snapshots</id>
	<username>admin</username>
	<password>admin</password>
</server>
<server>
	<id>3rdParty</id>
	<username>admin</username>
	<password>admin</password>
</server>
  </servers>

  <!-- mirrors
   | This is a list of mirrors to be used in downloading artifacts from remote repositories.
   |
   | It works like this: a POM may declare a repository to use in resolving certain artifacts.
   | However, this repository may have problems with heavy traffic at times, so people have mirrored
   | it to several places.
   |
   | That repository definition will have a unique id, so we can create a mirror reference for that
   | repository, to be used as an alternate download site. The mirror site will be the preferred
   | server for that repository.
   |-->
  <mirrors>
    <!-- mirror
     | Specifies a repository mirror site to use instead of a given repository. The repository that
     | this mirror serves has an ID that matches the mirrorOf element of this mirror. IDs are used
     | for inheritance and direct lookup purposes, and must be unique across the set of mirrors.
     |
    <mirror>
      <id>mirrorId</id>
      <mirrorOf>repositoryId</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://my.repository.com/repo/path</url>
    </mirror>
     -->

<!-- mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
</mirror -->

<mirror>
    <id>nexus</id>
    <name>nexus Mirror chenshu repository</name>
    <url>http://127.0.0.1:8081/repository/maven-public/</url>
    <mirrorOf>*</mirrorOf>
  </mirror>
<mirror>
    <id>nexus</id>
    <name>nexus Mirror central repository</name>
    <url>http://127.0.0.1:8081/repository/aliyun-central/</url>
    <mirrorOf>*</mirrorOf>
  </mirror>

<mirror>
    <id>3rdParty</id>
    <name>3rd party repository</name>
    <url>http://127.0.0.1:8081/repository/3rdParty/</url>
    <mirrorOf>3rdParty</mirrorOf>
</mirror>
  </mirrors>

  <!-- profiles
   | This is a list of profiles which can be activated in a variety of ways, and which can modify
   | the build process. Profiles provided in the settings.xml are intended to provide local machine-
   | specific paths and repository locations which allow the build to work in the local environment.
   |
   | For example, if you have an integration testing plugin - like cactus - that needs to know where
   | your Tomcat instance is installed, you can provide a variable here such that the variable is
   | dereferenced during the build process to configure the cactus plugin.
   |
   | As noted above, profiles can be activated in a variety of ways. One way - the activeProfiles
   | section of this document (settings.xml) - will be discussed later. Another way essentially
   | relies on the detection of a system property, either matching a particular value for the property,
   | or merely testing its existence. Profiles can also be activated by JDK version prefix, where a
   | value of '1.4' might activate a profile when the build is executed on a JDK version of '1.4.2_07'.
   | Finally, the list of active profiles can be specified directly from the command line.
   |
   | NOTE: For profiles defined in the settings.xml, you are restricted to specifying only artifact
   |       repositories, plugin repositories, and free-form properties to be used as configuration
   |       variables for plugins in the POM.
   |
   |-->
  <profiles>
    <!-- profile
     | Specifies a set of introductions to the build process, to be activated using one or more of the
     | mechanisms described above. For inheritance purposes, and to activate profiles via <activatedProfiles/>
     | or the command line, profiles have to have an ID that is unique.
     |
     | An encouraged best practice for profile identification is to use a consistent naming convention
     | for profiles, such as 'env-dev', 'env-test', 'env-production', 'user-jdcasey', 'user-brett', etc.
     | This will make it more intuitive to understand what the set of introduced profiles is attempting
     | to accomplish, particularly when you only have a list of profile id's for debug.
     |
     | This profile example uses the JDK version to trigger activation, and provides a JDK-specific repo.
    -->
    <profile>
      <id>jdk-1.8</id>

      <activation>
        <jdk>1.8</jdk>
      </activation>

	<properties>
		<maven.compiler.source>1.8</maven.compiler.source>
		<maven.compiler.target>1.8</maven.compiler.target>
		<maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
	</properties>
	<repositories>
		<repository>
			<id>maven-public</id>
			<url>http://127.0.0.1:8081/repository/maven-public/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
		</repository>
		<repository>
			<id>aliyun-central</id>
			<url>http://127.0.0.1:8081/repository/aliyun-central/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
		</repository>

		<repository>
			<id>3rdParty</id>
			<url>http://127.0.0.1:8081/repository/3rdParty/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
		</repository>
	</repositories>

    </profile>

    <!--
     | Here is another profile, activated by the system property 'target-env' with a value of 'dev',
     | which provides a specific path to the Tomcat instance. To use this, your plugin configuration
     | might hypothetically look like:
     |
     | ...
     | <plugin>
     |   <groupId>org.myco.myplugins</groupId>
     |   <artifactId>myplugin</artifactId>
     |
     |   <configuration>
     |     <tomcatLocation>${tomcatPath}</tomcatLocation>
     |   </configuration>
     | </plugin>
     | ...
     |
     | NOTE: If you just wanted to inject this configuration whenever someone set 'target-env' to
     |       anything, you could just leave off the <value/> inside the activation-property.
     |
    <profile>
      <id>env-dev</id>

      <activation>
        <property>
          <name>target-env</name>
          <value>dev</value>
        </property>
      </activation>

      <properties>
        <tomcatPath>/path/to/tomcat/instance</tomcatPath>
      </properties>
    </profile>
    -->
<profile>
	<id>jdk1.8</id>
	<activation>
	<activeByDefault>true</activeByDefault>
	<jdk>1.8</jdk>
	</activation>
	<properties>
		<maven.compiler.source>1.8</maven.compiler.source>
		<maven.compiler.target>1.8</maven.compiler.target>
		<maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
	</properties>
	<repositories>
		<repository>
			<id>maven-public</id>
			<url>http://127.0.0.1:8081/repository/maven-public/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
		</repository>
		<repository>
			<id>aliyun-central</id>
			<url>http://127.0.0.1:8081/repository/aliyun-central/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
		</repository>

		<repository>
			<id>3rdParty</id>
			<url>http://127.0.0.1:8081/repository/3rdParty/</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
				<updatePolicy>always</updatePolicy>
			</snapshots>
			</repository>
		</repositories>
</profile>
  </profiles>

  <!-- activeProfiles
   | List of profiles that are active for all builds.
   |
  <activeProfiles>
    <activeProfile>alwaysActiveProfile</activeProfile>
    <activeProfile>anotherAlwaysActiveProfile</activeProfile>
  </activeProfiles>
  -->
</settings>


```


## 5.上传私有包到镜像仓库





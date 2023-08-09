Ory Hydra 应用示例
-----

# 简介

最近从其他同事得知项目用到了OAuth2认证方式，使用的认证服务就是Hydra。出于对技术的提前积累特对该服务进行了简单的调研。

本文作为调研笔记用于自己学习只用。

Ory Hydra是经过强化的、经过OpenID认证的OAuth2服务软件。其针对低延迟、高吞吐量和低资源消耗进行了优化。其不是身份提供者(也就是不提供用户注册、用户登录和密码重置等功能)，而是通过登录和同意应用程序连接到现有身份提供者。

# 服务启动

为了方便的搭建起Hydra开发环境，可以使用docker-compose工具启动Hydra。

以下为docker-compose.yml文件的内容

```yml
version: "3.7"
services:
  hydra:
    image: oryd/hydra:v2.0.2
    ports:
      - "4444:4444" # Public port
      - "4445:4445" # Admin port
      - "5555:5555" # Port for hydra token user
    command: serve -c /etc/config/hydra/hydra.yml all --dev
    volumes:
      - type: bind
        source: ./config
        target: /etc/config/hydra
    environment:
      - DSN=postgres://hydra:secret@postgresd:5432/hydra?sslmode=disable&max_conns=20&max_idle_conns=4
    restart: unless-stopped
    depends_on:
      - hydra-migrate
    networks:
      - intranet
  hydra-migrate:
    image: oryd/hydra:v2.0.2
    environment:
      - DSN=postgres://hydra:secret@postgresd:5432/hydra?sslmode=disable&max_conns=20&max_idle_conns=4
    command: migrate -c /etc/config/hydra/hydra.yml sql -e --yes
    volumes:
      - type: bind
        source: ./config
        target: /etc/config/hydra
    restart: on-failure
    networks:
      - intranet
  consent:
    environment:
      - HYDRA_ADMIN_URL=http://hydra:4445
    image: oryd/hydra-login-consent-node:v2.0.2
    ports:
      - "3001:3000"
    restart: unless-stopped
    networks:
      - intranet
  postgresd:
    image: postgres:11.8
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=hydra
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=hydra
    networks:
      - intranet
networks:
  intranet:
```

还需要为Hydra服务创建一个配置文件hydra.yml，该文件放在docker-compose.yml文件同级的config目录下。

```yml
serve:
  cookies:
    same_site_mode: Lax

urls:
  self:
    issuer: http://172.18.3.200:4444
  consent: http://172.18.3.200:3001/consent
  login: http://172.18.3.200:3001/login
  logout: http://172.18.3.200:3001/logout

secrets:
  system:
    - youReallyNeedToChangeThis

oidc:
  subject_identifiers:
    supported_types:
      - pairwise
      - public
    pairwise:
      salt: youReallyNeedToChangeThis
```

# 令牌(token)颁发过程

# 参考资料

【官网】
```html
https://www.ory.sh/docs/identities/native-browser
```

【阮一峰 OAuth 2.0 的四种方式】

```html
https://www.ruanyifeng.com/blog/2019/04/oauth-grant-types.html
```

【其他网络资源】

```html
https://blog.csdn.net/u010381752/article/details/119328575

http://www.junyao.tech/posts/f8dc0074.html
```
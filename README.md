# 小镇之恋

> 高学历优质青年严肃婚恋交友平台

## 技术栈

| 层级 | 技术 |
|------|------|
| 小程序 | Flutter (Dart) |
| 后端 | Java Spring Boot 3.4 |
| 数据库 | MySQL 8.0 |
| 缓存 | Redis 7 |
| 搜索引擎 | Elasticsearch 8 |
| 构建 | Gradle (Kotlin DSL) |

## 项目结构

```
qingteng-love/
├── app/                    # Flutter 小程序
│   └── lib/main.dart
├── server/                 # Spring Boot 后端
│   ├── app/
│   │   ├── src/main/java/com/qingteng/
│   │   │   ├── QingtengApplication.java
│   │   │   ├── user/       # 用户模块
│   │   │   ├── karma/      # 缘分模块
│   │   │   ├── bazi/       # 八字模块
│   │   │   ├── geo/        # 地理模块
│   │   │   ├── chat/       # 聊天模块
│   │   │   ├── village/    # 村口社区
│   │   │   └── common/     # 公共模块
│   │   └── src/main/resources/
│   │       └── application.yml
│   └── build.gradle.kts
├── docker-compose.yml      # MySQL + Redis + ES
├── docs/
│   ├── prd/                # 产品文档
│   ├── design/             # 设计方案归档
│   └── plans/              # 实施规划
└── README.md
```

## 快速启动

### 1. 启动基础设施

```bash
docker compose up -d
```

### 2. 启动后端

```bash
cd server
gradle bootRun
```

### 3. 启动小程序

```bash
cd app
flutter run
```

## 开发进度

- [x] 项目脚手架搭建
- [x] 用户认证体系
- [x] 个人主页（基础版）
- [x] 匹配推荐 —「寻觅」
- [x] 双向匹配机制
- [x] 即时通讯 —「聊天」
- [x] 八字合缘 🔮
- [x] 个人中心 🏠
- [x] 缘分盲盒 🎲
- [x] 同乡近邻 📍

详细规划见：[docs/plans/第一期实施规划.md](docs/plans/第一期实施规划.md)
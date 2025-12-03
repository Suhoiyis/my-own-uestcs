# PostgreSQL 存储数据组织与元数据管理报告

PostgreSQL的数据存储可以从两个层面来理解：

- **逻辑存储结构**：是指用户在使用数据库时接触到的各种对象，例如数据库、模式（Schema）、表、视图、索引、函数等。
- **物理存储结构**：是指PostgreSQL实际上将这些对象以文件的形式存储在磁盘上的方式，主要包括数据文件、事务日志等。

## 逻辑结构

在 PostgreSQL 中，逻辑存储结构组织如下：

1. **数据库集群（Cluster）**：指的是一个PostgreSQL实例，包含多个数据库。
2. **数据库（Database）**：每个数据库都是一个独立的逻辑单元，拥有独立的权限、对象。
3. **模式（Schema）**：数据库中的命名空间，用于逻辑组织表、视图、函数等对象。默认有`public`模式。
4. **表（Table）**：存储用户数据，是数据库的核心对象。
5. **索引（Index）**：加快数据查询速度的辅助结构。
6. **视图、函数、存储过程、操作等**：支持复杂的数据处理与自动化。

这些对象通过 PostgreSQL 内部的系统目录（System Catalog）进行统一管理。

## 物理结构

通过浏览安装目录`C:\Program Files\PostgreSQL\17\data`可以观察到 PostgreSQL 的物理文件组织结构，主要包括以下部分：

### 1. 关键目录说明

| 目录              | 作用                                                         |
| ----------------- | ------------------------------------------------------------ |
| **base/**         | 存储所有数据库的数据文件。每个数据库对应一个子目录。         |
| **global/**       | 存储与整个集群有关的全局系统表（如数据库列表、用户信息等）。 |
| **pg_wal/**       | Write-Ahead Logging，预写日志，用于保证事务的持久性。        |
| **pg_xact/**      | 存储事务提交状态（如提交/中止标志）。                        |
| **pg_multixact/** | 支持多事务共享行锁的元信息。                                 |
| **pg_stat_tmp/**  | 存储临时统计信息，重启后会清除。                             |
| **pg_log/**       | 存储日志信息（错误日志、连接日志等）。                       |

### 2. 数据文件组织

- 数据文件以**表的OID命名**，而不是表名。
- 每个表在物理上被串联多个1GB的段（segment），以表OID、表OID.1、表OID.2等方式命名。
- 同一张表的主表、TOAST（大字段存储）、索引等也分别是存储。

## PostgreSQL 元数据管理机制

在 PostgreSQL 中，**元数据（Metadata）**是指关于数据库中对象（如数据库、表、列、索引、函数等）的数据。PostgreSQL 使用一套称为 **系统目录（System Catalogs）** 的系统表集合来存储和管理所有的元数据信息。这些系统目录本身也是表结构，用户可以像操作普通表一样进行查询。

### 1.系统目录的作用

系统目录在 PostgreSQL 中主要负责以下任务：

- 描述数据库中所有对象的结构、属性和定义
- 支持 SQL 解析、权限校验、执行计划生成等操作
- 支撑 `pgAdmin`、`psql` 等工具提供图形化/命令行管理功能
- 提供系统信息查询入口，可供开发者与运维使用

这些系统表大多数位于 `pg_catalog` 模式下。

------

### 2. 核心系统目录表详解

| 系统表名               | 描述                                         | 示例用途                         |
| ---------------------- | -------------------------------------------- | -------------------------------- |
| `pg_database`          | 记录数据库列表及属性                         | 获取所有数据库的 OID 和名称      |
| `pg_namespace`         | 存储所有模式（Schema）的信息                 | 查询有哪些命名空间               |
| `pg_class`             | 存储所有“关系型对象”的信息：表、索引、视图等 | 查表或索引是否存在，表文件 OID   |
| `pg_attribute`         | 存储表或视图的字段（列）定义                 | 获取某张表的字段名、类型、顺序等 |
| `pg_type`              | 存储所有数据类型的定义                       | 包括内建类型、用户自定义类型     |
| `pg_index`             | 存储索引的结构和属性                         | 哪些字段上建了索引，索引类型等   |
| `pg_constraint`        | 存储约束信息（主键、外键、唯一等）           | 查找表的主键约束                 |
| `pg_proc`              | 存储所有函数与存储过程的信息                 | 查找函数名、返回类型、语言等     |
| `pg_roles` / `pg_user` | 存储角色和用户账户信息                       | 查看用户权限、角色分配           |
| `pg_depend`            | 存储对象之间的依赖关系                       | 如视图依赖表、函数依赖类型等     |

------

### 3. 示例：查询表结构元数据

以下是一些常见查询，用于获取数据库对象的元数据：

#### a. 查询当前数据库中所有用户表：

```
sql复制编辑SELECT relname AS table_name
FROM pg_class
WHERE relkind = 'r' AND relnamespace = (
  SELECT oid FROM pg_namespace WHERE nspname = 'public'
);
```

#### b. 查询某张表的字段信息：

```
sql复制编辑SELECT attname AS column_name, format_type(atttypid, atttypmod) AS data_type
FROM pg_attribute
WHERE attrelid = 'student'::regclass AND attnum > 0 AND NOT attisdropped;
```

#### c. 查询某张表的主键信息：

```
sql复制编辑SELECT conname AS constraint_name, a.attname AS column_name
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
WHERE t.relname = 'student' AND c.contype = 'p';
```

------

### 4. 元数据更新与维护机制

PostgreSQL 在以下操作中自动维护元数据：

- **创建/修改/删除数据库对象时**：系统目录会自动插入/更新/删除对应记录。
- **执行 DDL 语句时**（如 `CREATE TABLE`、`ALTER TABLE`）：自动反映到 `pg_class`、`pg_attribute` 等表中。
- **依赖管理**：如删除一个被视图引用的表时，系统会检查 `pg_depend`，防止错误。
- **权限控制**：元数据中记录了用户与角色对各类对象的访问权限，如在 `pg_roles` 和 `pg_auth_members` 中。

查看：

通过以下方式可以更方便地查看元数据：

- **pgAdmin**：图形界面展示系统目录内容（如点击表可以查看字段、约束、索引等）。
- **`\d` 命令（psql）**：
  - `\d student`：查看表结构（字段、类型、约束）
  - `\d+ student`：包括存储信息（如是否压缩、是否 TOAST）
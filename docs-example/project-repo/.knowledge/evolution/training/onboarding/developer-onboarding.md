# 开发者入职指南 (Developer Onboarding Guide)

**版本**: 1.0
**最后更新**: 2025-11-30

---

## 欢迎加入！

欢迎加入ECP电商平台开发团队！本指南将帮助你快速熟悉项目和团队。

---

## 第一周：环境搭建与了解项目

### Day 1: 环境准备

**任务清单**:
- [ ] 申请代码仓库访问权限
- [ ] 申请各环境访问权限（dev, staging）
- [ ] 安装开发工具（IDE, Docker, kubectl）
- [ ] 克隆代码仓库

**开发环境要求**:
```yaml
必备软件:
  - JDK: 17
  - Node.js: 20+
  - Docker: 24+
  - IDE: IntelliJ IDEA / VS Code
  - Git: 2.40+

推荐工具:
  - Postman / Insomnia
  - DBeaver
  - k9s (Kubernetes管理)
```

### Day 2: 项目概览

**阅读文档** (按顺序):
1. [项目章程](../../project-charter.md) - 了解项目背景和目标
2. [系统架构](../../architecture/system-architecture.md) - 了解整体架构
3. [技术栈规范](../../technology/tech-stack.md) - 了解技术选型
4. [代码分层](../../architecture/layer-summary.md) - 了解代码结构

### Day 3-5: 本地运行

**步骤**:
```bash
# 1. 克隆代码
git clone git@github.com:company/ecp-user-service.git
cd ecp-user-service

# 2. 启动依赖服务
docker-compose up -d

# 3. 运行应用
./gradlew bootRun

# 4. 验证
curl http://localhost:8001/actuator/health
```

**常见问题**:
- Q: 数据库连接失败？
- A: 检查Docker是否启动，端口是否被占用

---

## 第二周：编码规范与流程

### 编码规范学习

**必读文档**:
1. [编码约定](../../implementation/coding/coding-conventions.md)
2. [Git工作流](../../implementation/coding/git-workflow.md)
3. [测试策略](../../implementation/testing/test-strategy.md)

### 第一个任务

建议从以下类型任务开始：
- Bug修复（了解代码流程）
- 文档更新（了解项目结构）
- 小功能开发（实践编码规范）

### 代码提交流程

```
1. 创建分支: git checkout -b feature/ECP-xxx-description
2. 编写代码
3. 本地测试: ./gradlew test
4. 提交代码: git commit -m "feat(module): description"
5. 推送分支: git push -u origin feature/ECP-xxx-description
6. 创建PR，请求Review
7. Review通过后合并
```

---

## 第三周：深入理解

### 领域知识学习

**阅读文档**:
1. [用户域模型](../../../../../domain-knowledge/bounded-contexts/user-domain/domain-model.md)
2. [订单域模型](../../../../../domain-knowledge/bounded-contexts/order-domain/domain-model.md)
3. [企业术语词典](../../../../../domain-knowledge/glossary/enterprise-glossary.md)

### AI协作学习

**阅读文档**:
1. [AI协作原则](../../ai-collaboration/ai-principles.md)
2. [SDD模板](../../ai-collaboration/sdd-template.md)
3. [Prompt模板库](../../ai-collaboration/prompt-library/code-generation.md)

---

## 第四周：独立开发

### 目标
- 独立完成一个完整功能
- 熟练使用Git工作流
- 能够进行Code Review

### 自检清单

**技术方面**:
- [ ] 理解项目架构
- [ ] 掌握编码规范
- [ ] 能够编写单元测试
- [ ] 熟悉部署流程

**流程方面**:
- [ ] 熟悉Git工作流
- [ ] 了解Code Review流程
- [ ] 知道如何提问和求助

---

## 资源汇总

### 重要链接

| 资源 | 链接 |
|------|------|
| 代码仓库 | github.com/company/ecp-* |
| API文档 | api-docs.example.com |
| 监控面板 | grafana.example.com |
| 日志查询 | kibana.example.com |

### 联系人

| 角色 | 联系人 | 职责 |
|------|--------|------|
| 入职导师 | @mentor | 解答疑问、指导学习 |
| 技术负责人 | @tech-lead | 技术决策、架构问题 |
| 团队负责人 | @team-lead | 任务分配、团队事务 |

### 学习资源

- 内部Wiki: wiki.example.com
- 技术博客: blog.example.com/tech
- 培训录屏: training.example.com

---

## FAQ

**Q: 遇到问题应该怎么办？**
A: 先查文档 → 搜索内部Wiki → 问导师 → 团队讨论

**Q: 代码Review通常需要多久？**
A: 目标24小时内，紧急情况可以找Reviewer沟通

**Q: 如何参与技术讨论？**
A: 参加每周技术分享会，订阅tech-discussion邮件组

---

## 入职反馈

完成入职后，请填写反馈表帮助我们改进：
[入职反馈表](https://forms.example.com/onboarding-feedback)

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @HR |

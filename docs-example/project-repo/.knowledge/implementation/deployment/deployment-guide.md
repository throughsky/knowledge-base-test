# 部署指南 (Deployment Guide)

**版本**: 1.0
**最后更新**: 2025-11-30
**负责人**: @运维团队

---

## 1. 部署架构

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ user-svc    │  │ order-svc   │  │ product-svc │     │
│  │ (3 replicas)│  │ (5 replicas)│  │ (3 replicas)│     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                    Istio Service Mesh                    │
└─────────────────────────────────────────────────────────┘
```

---

## 2. 环境配置

| 环境 | 命名空间 | 用途 | 访问地址 |
|------|----------|------|----------|
| **dev** | ecp-dev | 开发测试 | api-dev.example.com |
| **staging** | ecp-staging | 集成测试 | api-staging.example.com |
| **production** | ecp-prod | 生产环境 | api.example.com |

---

## 3. 部署流程

### 3.1 先决条件

- [ ] Kubernetes 集群 v1.28+
- [ ] Helm v3.12+
- [ ] kubectl 已配置
- [ ] 数据库迁移已执行
- [ ] 配置已更新

### 3.2 Helm 部署

```bash
# 1. 添加 Helm 仓库
helm repo add ecp https://charts.example.com/ecp
helm repo update

# 2. 查看配置
helm show values ecp/user-service > values.yaml

# 3. 部署服务
helm upgrade --install user-service ecp/user-service \
  --namespace ecp-prod \
  --set image.tag=1.2.3 \
  --set replicas=3 \
  -f values-prod.yaml

# 4. 验证部署
kubectl get pods -n ecp-prod -l app=user-service
kubectl rollout status deployment/user-service -n ecp-prod
```

### 3.3 values.yaml 示例

```yaml
image:
  repository: registry.example.com/ecp/user-service
  tag: "1.2.3"
  pullPolicy: IfNotPresent

replicas: 3

resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"

env:
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: url

livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5

ingress:
  enabled: true
  hosts:
    - host: api.example.com
      paths:
        - path: /api/v1/users
          pathType: Prefix
```

---

## 4. 回滚步骤

### 4.1 查看历史版本

```bash
helm history user-service -n ecp-prod
```

### 4.2 执行回滚

```bash
# 回滚到上一版本
helm rollback user-service -n ecp-prod

# 回滚到指定版本
helm rollback user-service 5 -n ecp-prod
```

### 4.3 验证回滚

```bash
kubectl get pods -n ecp-prod -l app=user-service
kubectl logs -f deployment/user-service -n ecp-prod
```

---

## 5. 健康检查

### 5.1 检查端点

| 端点 | 用途 |
|------|------|
| `/actuator/health` | 整体健康状态 |
| `/actuator/health/liveness` | 存活探针 |
| `/actuator/health/readiness` | 就绪探针 |
| `/actuator/info` | 应用信息 |

### 5.2 验证命令

```bash
# 检查Pod状态
kubectl get pods -n ecp-prod

# 检查健康状态
curl https://api.example.com/actuator/health

# 查看日志
kubectl logs -f deployment/user-service -n ecp-prod
```

---

## 6. 监控告警

### 6.1 关键指标

| 指标 | 告警阈值 | 说明 |
|------|----------|------|
| CPU使用率 | > 80% | 考虑扩容 |
| 内存使用率 | > 85% | 检查内存泄漏 |
| P99响应时间 | > 500ms | 检查性能问题 |
| 错误率 | > 1% | 排查错误原因 |
| Pod重启次数 | > 3次/小时 | 检查应用稳定性 |

### 6.2 监控链接

- Grafana Dashboard: https://grafana.example.com/d/ecp-prod
- Jaeger Tracing: https://jaeger.example.com
- Kibana Logs: https://kibana.example.com

---

## 7. 紧急联系

| 角色 | 联系人 | 电话 |
|------|--------|------|
| 运维值班 | @oncall | 123-456-7890 |
| 技术负责人 | @tech-lead | 123-456-7891 |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @运维团队 |

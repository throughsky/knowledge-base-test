# 部署运维规范 - AI编码约束

> 适用于：环境管理、容器化部署、CI/CD、监控告警场景

## 一、环境隔离规范 [MUST]

### 1.1 四级环境

| 环境 | 用途 | 资源配置 | 权限管控 |
|------|------|----------|----------|
| dev | 日常调试 | 单机/轻量集群 | 开发人员可读写 |
| test | 功能测试 | 小型集群(2-3节点) | 测试可读写，开发只读 |
| staging | 回归/性能测试 | 与生产一致 | 仅CI/CD可部署 |
| prod | 生产 | 高可用集群(≥3节点) | 仅CI/CD可部署，禁止手动 |

### 1.2 环境一致性

```yaml
rules:
  - Docker镜像统一基础镜像
  - Terraform管理基础设施
  - Flyway管理数据库脚本
  - 配置中心管理环境配置
```

### 1.3 生产环境红线

```yaml
prohibited:
  - 手动登录服务器操作
  - 手动执行SQL脚本
  - 使用latest镜像标签
  - 明文存储敏感配置
```

## 二、容器化规范 [MUST]

### 2.1 Dockerfile规范

```dockerfile
# ✅ 正确：多阶段构建
# 阶段1：构建
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# 阶段2：运行
FROM eclipse-temurin:17-jre-alpine

# 安全：非root用户
RUN addgroup -S app && adduser -S app -G app
USER app

# 复制构建产物
COPY --from=builder /build/target/*.jar /app/app.jar

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### 2.2 镜像标签规范

```yaml
format: 版本号-CommitID
example: v1.0.0-7a3f2d9
prohibited:
  - latest
  - dev
  - test
```

### 2.3 镜像安全扫描

```yaml
# CI流水线中扫描
scan:
  tool: Trivy
  severity: HIGH,CRITICAL
  fail_on_vulnerability: true
```

## 三、K8s部署规范 [MUST]

### 3.1 资源限制

```yaml
# deployment.yaml
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "2"
    memory: "2Gi"
```

### 3.2 健康检查

```yaml
# 存活探针
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  failureThreshold: 3

# 就绪探针
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5
  failureThreshold: 3
```

### 3.3 滚动更新

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0    # 零停机
    maxSurge: 1          # 最多多启动1个Pod
```

### 3.4 反亲和性

```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: mall-order
          topologyKey: kubernetes.io/hostname
```

### 3.5 安全上下文

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

## 四、CI/CD流水线规范 [MUST]

### 4.1 流水线阶段

```yaml
stages:
  - code-check      # 代码检查（SonarQube）
  - test            # 单元测试+集成测试
  - build           # 构建Docker镜像
  - scan            # 镜像安全扫描
  - deploy          # K8s部署
  - verify          # 部署验证
```

### 4.2 GitHub Actions配置

```yaml
# .github/workflows/deploy.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  IMAGE_REGISTRY: ghcr.io/${{ github.repository_owner }}
  APP_NAME: mall-order

jobs:
  code-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # SonarQube需要完整历史

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        with:
          args: >
            -Dsonar.projectKey=${{ env.APP_NAME }}
            -Dsonar.sources=src

  test:
    runs-on: ubuntu-latest
    needs: code-check
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run Tests with Coverage
        run: mvn clean test jacoco:report

      - name: Upload Coverage Report
        uses: actions/upload-artifact@v4
        with:
          name: jacoco-report
          path: target/site/jacoco/

  build:
    runs-on: ubuntu-latest
    needs: test
    outputs:
      image_tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_REGISTRY }}/${{ env.APP_NAME }}
          tags: |
            type=sha,prefix=v1.0.0-

      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  scan:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image_tag }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  deploy:
    runs-on: ubuntu-latest
    needs: [build, scan]
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Set up Kubectl
        uses: azure/setup-kubectl@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4
        with:
          version: 'v3.12.0'

      - name: Configure Kubeconfig
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config

      - name: Deploy to Kubernetes
        run: |
          helm upgrade --install ${{ env.APP_NAME }} ./charts/${{ env.APP_NAME }} \
            --namespace prod \
            --set image.repository=${{ env.IMAGE_REGISTRY }}/${{ env.APP_NAME }} \
            --set image.tag=v1.0.0-${{ github.sha }} \
            --set replicas=3 \
            --wait --timeout=5m

  verify:
    runs-on: ubuntu-latest
    needs: deploy
    steps:
      - uses: actions/checkout@v4

      - name: Run API Tests
        id: api-test
        continue-on-error: true
        run: |
          npm install -g newman
          newman run test/api-test.json -e test/prod-environment.json

      - name: Rollback on Failure
        if: steps.api-test.outcome == 'failure'
        run: |
          helm rollback ${{ env.APP_NAME }} 0 --namespace prod
          curl -X POST -H "Content-Type: application/json" \
            -d '{"msg":"部署失败，已自动回滚"}' \
            ${{ secrets.WEBHOOK_URL }}
          exit 1

      - name: Notify Success
        if: steps.api-test.outcome == 'success'
        run: |
          curl -X POST -H "Content-Type: application/json" \
            -d '{"msg":"部署成功: ${{ env.APP_NAME }}@v1.0.0-${{ github.sha }}"}' \
            ${{ secrets.WEBHOOK_URL }}
```

### 4.3 质量门禁

```yaml
quality_gates:
  - sonarqube_no_critical_issues
  - unit_test_coverage >= 80%
  - security_scan_passed
  - all_tests_passed
```

## 五、监控告警规范 [MUST]

### 5.1 可观测性工具链

| 类型 | 工具 | 用途 |
|------|------|------|
| 指标监控 | Prometheus+Grafana | QPS、RT、错误率、JVM |
| 日志监控 | ELK | 集中日志、关键词检索 |
| 链路追踪 | SkyWalking | 跨服务调用链路 |
| 告警管理 | AlertManager | 分级告警、升级 |

### 5.2 核心监控指标

```yaml
application:
  - http_requests_total          # 请求总数
  - http_request_duration_seconds  # 请求耗时
  - http_requests_errors_total   # 错误数

jvm:
  - jvm_memory_used_bytes        # 内存使用
  - jvm_gc_pause_seconds         # GC暂停时间
  - jvm_threads_current          # 线程数

business:
  - order_create_total           # 订单创建数
  - payment_success_total        # 支付成功数
```

### 5.3 告警规则

```yaml
# prometheus-rules.yaml
groups:
  - name: app-alerts
    rules:
      - alert: 接口错误率过高
        expr: rate(http_requests_errors_total[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "接口错误率超过5%"

      - alert: P99响应时间过高
        expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "P99响应时间超过1秒"

      - alert: JVM内存使用率过高
        expr: jvm_memory_used_bytes / jvm_memory_max_bytes > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "JVM内存使用率超过85%"
```

### 5.4 告警分级

| 级别 | 触发场景 | 通知方式 | 响应时效 |
|------|----------|----------|----------|
| Critical | 服务宕机、错误率>5% | 钉钉@所有人+电话 | 5分钟 |
| Warning | 内存>85%、慢查询增多 | 钉钉群通知 | 30分钟 |
| Info | 配置更新、服务重启 | 邮件通知 | 无需即时 |

## 六、灾备与恢复规范 [MUST]

### 6.1 备份策略

| 数据类型 | 备份频率 | 备份方式 | 保留时长 |
|----------|----------|----------|----------|
| 订单/支付（核心） | 全量每日+增量每小时 | MySQL主从+定时备份 | 90天 |
| 用户数据（重要） | 全量每日+增量每2小时 | 全量备份+Binlog | 180天 |
| 日志/统计（非核心） | 全量每日 | 压缩存储 | 30天 |

### 6.2 备份验证

```bash
# 每周自动执行恢复测试
#!/bin/bash
# 1. 下载最新备份
wget http://backup.mall.com/mysql/full-$(date +%Y%m%d).sql.gz

# 2. 恢复到测试库
gunzip full-$(date +%Y%m%d).sql.gz
mysql -h test-db -u test -p$TEST_PWD < full-$(date +%Y%m%d).sql

# 3. 校验数据完整性
prod_count=$(mysql -h prod-db -e "select count(*) from order_info" -N)
test_count=$(mysql -h test-db -e "select count(*) from order_info" -N)
if [ $prod_count -eq $test_count ]; then
    echo "备份恢复成功"
else
    curl -X POST -d '{"msg":"备份恢复失败"}' $DINGTALK_WEBHOOK
fi
```

### 6.3 异地备份

```yaml
rules:
  - 核心数据异地存储
  - 跨区域复制（如OSS跨区域复制）
  - 定期校验异地备份可用性
```

## 七、混沌工程规范 [SHOULD]

### 7.1 故障注入类型

| 故障类型 | 测试场景 | 预期结果 |
|----------|----------|----------|
| 服务宕机 | 单服务Pod重启 | 流量自动切换，无感知 |
| 网络延迟 | 服务间调用延迟500ms | 触发熔断，降级处理 |
| 资源耗尽 | CPU/内存打满 | 触发HPA扩容 |
| 数据库故障 | 主库宕机 | 自动切换从库 |

### 7.2 演练流程

```yaml
workflow:
  1. 制定演练方案（故障类型、影响范围、回滚方案）
  2. 低峰期执行演练
  3. 监控服务指标
  4. 验证容错能力
  5. 输出演练报告
  6. 修复发现的问题
```

## 八、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 镜像标签用latest | 检查Deployment配置 |
| 2 | 容器无资源限制 | 检查resources配置 |
| 3 | 无滚动更新配置 | 检查strategy配置 |
| 4 | 备份未验证 | 检查恢复测试记录 |
| 5 | 监控仅覆盖指标 | 检查日志+链路配置 |
| 6 | 敏感配置明文存储 | 检查ConfigMap/Secret |
| 7 | 生产环境手动部署 | 检查部署记录 |
| 8 | 无健康检查探针 | 检查liveness/readiness |
| 9 | 容器root用户运行 | 检查securityContext |
| 10 | CI/CD无质量门禁 | 检查流水线配置 |

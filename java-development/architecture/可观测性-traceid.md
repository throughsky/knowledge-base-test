## SpringBoot集成TraceId（追踪ID）

## 一、TraceId 是什么？

## 场景一：无SkyWalking的最优实现

### 核心方案

`MDC（日志上下文） + Filter（入口生成/读取TraceId） + TaskDecorator（异步线程传递） + Feign/RestTemplate拦截器（微服务跨服务传递）`

### 适用场景

### 1\. 依赖配置（拆分SpringBoot/SpringCloud）

#### 1.1 SpringBoot单体项目依赖

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <parent> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-parent</artifactId> <version>2.7.15</version> <!-- 3.x可替换为3.2.0 --> <relativePath/> </parent> <groupId>com.example</groupId> <artifactId>boot-traceid-no-skywalking</artifactId> <version>0.0.1-SNAPSHOT</version> <dependencies> <!-- SpringBoot Web核心 --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-web</artifactId> </dependency> <!-- 工具类：判空/字符串处理 --> <dependency> <groupId>org.apache.commons</groupId> <artifactId>commons-lang3</artifactId> <version>3.14.0</version> </dependency> <!-- 可选：Hutool（雪花ID生成） --> <dependency> <groupId>cn.hutool</groupId> <artifactId>hutool-all</artifactId> <version>5.8.22</version> </dependency> <!-- 测试依赖（非核心） --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-test</artifactId> <scope>test</scope> </dependency> </dependencies> <build> <plugins> <plugin> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-maven-plugin</artifactId> <version>2.7.15</version> </plugin> </plugins> </build>
</project>
```

#### 1.2 SpringCloud微服务项目依赖

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <parent> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-parent</artifactId> <version>2.7.15</version> <!-- 对应Cloud 2021.0.x --> <relativePath/> </parent> <groupId>com.example</groupId> <artifactId>cloud-traceid-no-skywalking</artifactId> <version>0.0.1-SNAPSHOT</version> <dependencies> <!-- 基础依赖（同SpringBoot） --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-web</artifactId> </dependency> <dependency> <groupId>org.apache.commons</groupId> <artifactId>commons-lang3</artifactId> <version>3.14.0</version> </dependency> <dependency> <groupId>cn.hutool</groupId> <artifactId>hutool-all</artifactId> <version>5.8.22</version> </dependency> <!-- 微服务核心：OpenFeign --> <dependency> <groupId>org.springframework.cloud</groupId> <artifactId>spring-cloud-starter-openfeign</artifactId> </dependency> <!-- 测试依赖 --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-test</artifactId> <scope>test</scope> </dependency> </dependencies> <!-- Cloud版本管理 --> <dependencyManagement> <dependencies> <dependency> <groupId>org.springframework.cloud</groupId> <artifactId>spring-cloud-dependencies</artifactId> <version>2021.0.5</version> <type>pom</type> <scope>import</scope> </dependency> </dependencies> </dependencyManagement> <build> <plugins> <plugin> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-maven-plugin</artifactId> <version>2.7.15</version> </plugin> </plugins> </build>
</project>
```

### 2\. 核心代码实现（无SkyWalking专属）

#### 2.1 TraceId工具类（自定义生成/传递）

```java
package com.example.traceid.util;

import cn.hutool.core.lang.Snowflake;
import cn.hutool.core.net.NetUtil;
import cn.hutool.core.util.IdUtil;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.MDC;

import java.util.UUID;

/**
 * 无SkyWalking时：自定义TraceId生成/管理工具类
 */
public class TraceIdUtils { // MDC中TraceId的Key（日志配置用%X{traceId}读取） public static final String TRACE_ID_MDC_KEY = "traceId"; // HTTP头传递TraceId的Key public static final String TRACE_ID_HEADER_KEY = "X-Trace-Id"; // 雪花ID生成器（高并发用，单机/低并发可只用UUID） private static final Snowflake SNOWFLAKE = IdUtil.createSnowflake( NetUtil.ipv4ToLong(NetUtil.getLocalhostStr()) % 32, 1L ); /** * 生成TraceId：低并发用UUID，高并发用雪花ID */ public static String generateTraceId() { // 方案1：UUID（默认，无需额外依赖） return UUID.randomUUID().toString().replace("-", ""); // 方案2：雪花ID（高并发切换） // return SNOWFLAKE.nextIdStr(); } /** * 从MDC获取TraceId，兜底返回UNKNOWN */ public static String getTraceId() { String traceId = MDC.get(TRACE_ID_MDC_KEY); return StringUtils.isBlank(traceId) ? "UNKNOWN" : traceId; } /** * 手动设置TraceId到MDC */ public static void setTraceIdToMdc(String traceId) { if (StringUtils.isNotBlank(traceId)) { MDC.put(TRACE_ID_MDC_KEY, traceId); } } /** * 清除MDC中的TraceId */ public static void clearTraceIdFromMdc() { MDC.remove(TRACE_ID_MDC_KEY); }
}
```

#### 2.2 TraceId过滤器（请求入口生成/读取TraceId）

```java
package com.example.traceid.filter;

import com.example.traceid.util.TraceIdUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * 无SkyWalking时：请求入口生成/读取TraceId，放入MDC
 * 优先级最高，保证所有逻辑执行前已有TraceId
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceIdMdcFilter implements Filter { @Override public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException { try { HttpServletRequest httpRequest = (HttpServletRequest) request; // 1. 优先读取上游传递的TraceId（网关/其他服务） String traceId = httpRequest.getHeader(TraceIdUtils.TRACE_ID_HEADER_KEY); // 2. 上游无则生成新的 if (StringUtils.isBlank(traceId)) { traceId = TraceIdUtils.generateTraceId(); } // 3. 放入MDC，供日志读取 MDC.put(TraceIdUtils.TRACE_ID_MDC_KEY, traceId); // 4. 执行后续逻辑 chain.doFilter(request, response); } finally { // 核心：请求结束清除MDC，避免线程池复用导致TraceId错乱 MDC.clear(); } }
}
```

#### 2.3 异步线程池配置（解决异步TraceId丢失）

```java
package com.example.traceid.config;

import org.slf4j.MDC;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskDecorator;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * 无SkyWalking时：异步线程池配置，传递MDC上下文
 */
@Configuration
@EnableAsync
public class AsyncTraceConfig { // 自定义TaskDecorator：复制父线程MDC到子线程 private static class MdcTraceDecorator implements TaskDecorator { @Override public Runnable decorate(Runnable runnable) { Map<String, String> parentMdc = MDC.getCopyOfContextMap(); return () -> { try { if (parentMdc != null) { MDC.setContextMap(parentMdc); } runnable.run(); } finally { MDC.clear(); // 子线程执行完清除MDC } }; } } // 全局异步线程池 @Bean("asyncTraceExecutor") public Executor asyncTraceExecutor() { ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor(); int core = Runtime.getRuntime().availableProcessors() * 2; executor.setCorePoolSize(core); executor.setMaxPoolSize(core * 2); executor.setQueueCapacity(200); executor.setThreadNamePrefix("async-trace-"); executor.setTaskDecorator(new MdcTraceDecorator()); // 绑定装饰器 executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy()); executor.setWaitForTasksToCompleteOnShutdown(true); executor.setAwaitTerminationSeconds(30); executor.initialize(); return executor; }
}
```

#### 2.4 微服务跨服务传递（Feign/RestTemplate拦截器）

##### 2.4.1 Feign拦截器（微服务专属）

```java
package com.example.traceid.interceptor;

import com.example.traceid.util.TraceIdUtils;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.stereotype.Component;

/**
 * 无SkyWalking时：Feign调用传递TraceId
 */
@Component
public class FeignTraceInterceptor implements RequestInterceptor { @Override public void apply(RequestTemplate template) { String traceId = TraceIdUtils.getTraceId(); if (!"UNKNOWN".equals(traceId)) { template.header(TraceIdUtils.TRACE_ID_HEADER_KEY, traceId); } }
}
```

##### 2.4.2 RestTemplate拦截器（微服务专属）

```java
package com.example.traceid.config;

import com.example.traceid.util.TraceIdUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;

/**
 * 无SkyWalking时：RestTemplate传递TraceId
 */
@Configuration
public class RestTemplateTraceConfig { @Bean public RestTemplate restTemplate() { RestTemplate restTemplate = new RestTemplate(); restTemplate.setInterceptors(Collections.singletonList((request, body, execution) -> { String traceId = TraceIdUtils.getTraceId(); if (!"UNKNOWN".equals(traceId)) { request.getHeaders().add(TraceIdUtils.TRACE_ID_HEADER_KEY, traceId); } return execution.execute(request, body); })); return restTemplate; }
}
```

#### 2.5 日志配置（logback-spring.xml）

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="30 seconds"> <contextName>traceid-no-skywalking</contextName> <!-- 控制台输出 --> <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender"> <encoder> <charset>UTF-8</charset> <!-- 核心：%X{traceId}读取MDC中的TraceId --> <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{traceId}] %-5level %logger{50} - %msg%n</pattern> </encoder> </appender> <!-- 文件输出 --> <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender"> <file>logs/app.log</file> <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy"> <fileNamePattern>logs/app.%d{yyyy-MM-dd}.log</fileNamePattern> <maxHistory>7</maxHistory> <maxFileSize>100MB</maxFileSize> </rollingPolicy> <encoder> <charset>UTF-8</charset> <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{traceId}] %-5level %logger{50} - %msg%n</pattern> </encoder> </appender> <root level="INFO"> <appender-ref ref="CONSOLE"/> <appender-ref ref="FILE"/> </root>
</configuration>
```

### 3\. 无SkyWalking的核心验证

## 场景二：有SkyWalking的最优实现

### 核心方案

`复用SkyWalking TraceId + MDC绑定 + 上下文传递（异步/跨服务）`

### 核心差异

### 1\. 依赖配置（拆分SpringBoot/SpringCloud）

#### 1.1 SpringBoot单体项目（新增SkyWalking依赖）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <parent> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-parent</artifactId> <version>2.7.15</version> <relativePath/> </parent> <groupId>com.example</groupId> <artifactId>boot-traceid-with-skywalking</artifactId> <version>0.0.1-SNAPSHOT</version> <dependencies> <!-- 基础依赖（同无SkyWalking） --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-web</artifactId> </dependency> <dependency> <groupId>org.apache.commons</groupId> <artifactId>commons-lang3</artifactId> <version>3.14.0</version> </dependency> <!-- SkyWalking核心依赖 --> <dependency> <groupId>org.apache.skywalking</groupId> <artifactId>apm-toolkit-spring-boot-starter</artifactId> <version>8.16.0</version> <!-- 与SkyWalking OAP版本一致 --> </dependency> <!-- SkyWalking日志增强：自动绑定TraceId到MDC --> <dependency> <groupId>org.apache.skywalking</groupId> <artifactId>apm-toolkit-logback-1.x</artifactId> <version>8.16.0</version> </dependency> </dependencies> <build> <plugins> <plugin> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-maven-plugin</artifactId> <version>2.7.15</version> </plugin> </plugins> </build>
</project>
```

#### 1.2 SpringCloud微服务项目（新增SkyWalking依赖）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <parent> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-parent</artifactId> <version>2.7.15</version> <relativePath/> </parent> <groupId>com.example</groupId> <artifactId>cloud-traceid-with-skywalking</artifactId> <version>0.0.1-SNAPSHOT</version> <dependencies> <!-- 基础依赖（同无SkyWalking） --> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-web</artifactId> </dependency> <dependency> <groupId>org.apache.commons</groupId> <artifactId>commons-lang3</artifactId> <version>3.14.0</version> </dependency> <dependency> <groupId>org.springframework.cloud</groupId> <artifactId>spring-cloud-starter-openfeign</artifactId> </dependency> <!-- SkyWalking核心依赖 --> <dependency> <groupId>org.apache.skywalking</groupId> <artifactId>apm-toolkit-spring-boot-starter</artifactId> <version>8.16.0</version> </dependency> <!-- SkyWalking Feign增强：跨服务链路追踪 --> <dependency> <groupId>org.apache.skywalking</groupId> <artifactId>apm-toolkit-feign</artifactId> <version>8.16.0</version> </dependency> <!-- SkyWalking日志增强 --> <dependency> <groupId>org.apache.skywalking</groupId> <artifactId>apm-toolkit-logback-1.x</artifactId> <version>8.16.0</version> </dependency> </dependencies> <dependencyManagement> <dependencies> <dependency> <groupId>org.springframework.cloud</groupId> <artifactId>spring-cloud-dependencies</artifactId> <version>2021.0.5</version> <type>pom</type> <scope>import</scope> </dependency> </dependencies> </dependencyManagement> <build> <plugins> <plugin> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-maven-plugin</artifactId> <version>2.7.15</version> </plugin> </plugins> </build>
</project>
```

### 2\. SkyWalking极简部署（Docker，中小型项目首选）

```
# 1. 拉取OAP和UI镜像（版本与项目依赖一致）
docker pull apache/skywalking-oap-server:8.16.0
docker pull apache/skywalking-ui:8.16.0

# 2. 启动OAP（单节点，H2存储，无需额外数据库）
docker run -d \ --name skywalking-oap \ -p 11800:11800 \ # Agent上报端口 -p 12800:12800 \ # UI访问OAP端口 -e SW_STORAGE=h2 \ apache/skywalking-oap-server:8.16.0

# 3. 启动UI（可视化界面，访问http://localhost:8080）
docker run -d \ --name skywalking-ui \ -p 8080:8080 \ --link skywalking-oap:oap \ -e SW_OAP_ADDRESS=http://oap:12800 \ apache/skywalking-ui:8.16.0
```

### 3\. 核心代码实现（有SkyWalking专属）

#### 3.1 TraceId工具类（复用SkyWalking TraceId）

```
package com.example.traceid.util;

import org.apache.commons.lang3.StringUtils;
import org.apache.skywalking.apm.toolkit.trace.TraceContext;
import org.slf4j.MDC;

/**
 * 有SkyWalking时：复用其TraceId，无需自定义生成
 */
public class TraceIdUtils { // 复用SkyWalking的MDC Key（SW_TRACE_ID），也可自定义 public static final String TRACE_ID_MDC_KEY = "SW_TRACE_ID"; public static final String TRACE_ID_HEADER_KEY = "X-Trace-Id"; /** * 获取TraceId：优先SkyWalking，兜底UNKNOWN */ public static String getTraceId() { // SkyWalking原生TraceId String skyWalkingTraceId = TraceContext.traceId(); if (StringUtils.isNotBlank(skyWalkingTraceId) && !"N/A".equals(skyWalkingTraceId)) { return skyWalkingTraceId; } // 兜底读取MDC String mdcTraceId = MDC.get(TRACE_ID_MDC_KEY); return StringUtils.isBlank(mdcTraceId) ? "UNKNOWN" : mdcTraceId; } /** * 绑定SkyWalking TraceId到MDC（仅特殊场景用） */ public static void bindSkyWalkingTraceIdToMdc() { String traceId = TraceContext.traceId(); if (StringUtils.isNotBlank(traceId) && !"N/A".equals(traceId)) { MDC.put(TRACE_ID_MDC_KEY, traceId); } }
}
```

#### 3.2 TraceId过滤器（简化：仅绑定SkyWalking TraceId到MDC）

```
package com.example.traceid.filter;

import com.example.traceid.util.TraceIdUtils;
import org.apache.skywalking.apm.toolkit.trace.TraceContext;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import java.io.IOException;

/**
 * 有SkyWalking时：过滤器仅绑定其TraceId到MDC，无需生成
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceIdMdcFilter implements Filter { @Override public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException { try { // 绑定SkyWalking TraceId到MDC，供日志读取 TraceIdUtils.bindSkyWalkingTraceIdToMdc(); chain.doFilter(request, response); } finally { MDC.clear(); // 释放SkyWalking上下文（避免内存泄漏） TraceContext.release(); } }
}
```

#### 3.3 异步线程池配置（传递SkyWalking上下文）

```
package com.example.traceid.config;

import org.apache.skywalking.apm.toolkit.trace.TraceContext;
import org.slf4j.MDC;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskDecorator;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * 有SkyWalking时：异步线程池传递MDC+SkyWalking上下文
 */
@Configuration
@EnableAsync
public class AsyncTraceConfig { private static class MdcTraceDecorator implements TaskDecorator { @Override public Runnable decorate(Runnable runnable) { // 复制父线程MDC和SkyWalking TraceId Map<String, String> parentMdc = MDC.getCopyOfContextMap(); String parentSkyWalkingTraceId = TraceContext.traceId(); return () -> { try { // 子线程绑定MDC if (parentMdc != null) { MDC.setContextMap(parentMdc); } // 子线程绑定SkyWalking TraceId（核心：保证链路不中断） if (StringUtils.isNotBlank(parentSkyWalkingTraceId) && !"N/A".equals(parentSkyWalkingTraceId)) { TraceContext.continueTrace(parentSkyWalkingTraceId); } runnable.run(); } finally { MDC.clear(); TraceContext.release(); // 释放SkyWalking上下文 } }; } } @Bean("asyncTraceExecutor") public Executor asyncTraceExecutor() { ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor(); int core = Runtime.getRuntime().availableProcessors() * 2; executor.setCorePoolSize(core); executor.setMaxPoolSize(core * 2); executor.setQueueCapacity(200); executor.setThreadNamePrefix("async-trace-"); executor.setTaskDecorator(new MdcTraceDecorator()); executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy()); executor.initialize(); return executor; }
}
```

#### 3.4 日志配置（绑定SkyWalking TraceId）

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="30 seconds"> <!-- 引入SkyWalking默认配置 --> <include resource="org/apache/skywalking/apm/toolkit/log/logback/default.xml"/> <contextName>traceid-with-skywalking</contextName> <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender"> <encoder> <charset>UTF-8</charset> <!-- %X{SW_TRACE_ID}：SkyWalking原生TraceId --> <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{SW_TRACE_ID}] %-5level %logger{50} - %msg%n</pattern> </encoder> </appender> <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender"> <file>logs/app.log</file> <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy"> <fileNamePattern>logs/app.%d{yyyy-MM-dd}.log</fileNamePattern> <maxHistory>7</maxHistory> <maxFileSize>100MB</maxFileSize> </rollingPolicy> <encoder> <charset>UTF-8</charset> <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{SW_TRACE_ID}] %-5level %logger{50} - %msg%n</pattern> </encoder> </appender> <root level="INFO"> <appender-ref ref="CONSOLE"/> <appender-ref ref="FILE"/> </root>
</configuration>
```

#### 3.5 项目挂载SkyWalking Agent（核心步骤）

启动项目时添加JVM参数（本地/生产通用）：

```
# 本地IDEA VM Options
-javaagent:/path/to/skywalking-agent/skywalking-agent.jar
-DSW_AGENT_NAME=boot-traceid-demo # 服务名（UI中显示）
-DSW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800 # OAP地址

# 生产Jar启动
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar \ -DSW_AGENT_NAME=cloud-traceid-demo \ -DSW_AGENT_COLLECTOR_BACKEND_SERVICES=192.168.1.100:11800 \ -jar app.jar
```

### 4\. 有SkyWalking的核心验证

---

## 核心差异总结

维度

无SkyWalking（纯自研）

有SkyWalking（复用TraceId）

TraceId生成

自定义（UUID/雪花ID）

复用SkyWalking全局TraceId（无需自定义）

核心目标

日志携带TraceId，定位问题

日志+可视化链路统一，支持跨服务/异步链路分析

运维成本

0（仅代码）

低（单节点Docker部署OAP+UI）

异步/跨服务处理

仅传递MDC上下文

传递MDC+SkyWalking上下文（保证链路不中断）

日志配置

读取自定义MDC Key（traceId）

读取SkyWalking MDC Key（SW\_TRACE\_ID）

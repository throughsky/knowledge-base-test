# 接口设计规范 - AI编码约束

> 适用于：RESTful API设计、Controller编写、接口文档场景

## 一、RESTful语义规范 [MUST]

### 1.1 HTTP方法映射

| 操作 | HTTP方法 | 幂等性 | URL示例 |
|------|----------|--------|---------|
| 查询单个 | GET | 是 | `GET /api/v1/orders/{orderId}` |
| 查询列表 | GET | 是 | `GET /api/v1/orders?status=1&pageNum=1` |
| 创建 | POST | 否 | `POST /api/v1/orders` |
| 全量更新 | PUT | 是 | `PUT /api/v1/orders/{orderId}` |
| 部分更新 | PATCH | 是 | `PATCH /api/v1/orders/{orderId}` |
| 删除 | DELETE | 是 | `DELETE /api/v1/orders/{orderId}` |

### 1.2 URL设计规范

```yaml
rules:
  - 使用名词复数，禁止动词
  - 全小写，连字符分隔
  - 层级清晰，不超过3级
  - 版本号放在路径中
```

```java
// ✅ 正确URL
GET    /api/v1/users                    // 用户列表
GET    /api/v1/users/{userId}           // 用户详情
POST   /api/v1/users                    // 创建用户
PUT    /api/v1/users/{userId}           // 更新用户
DELETE /api/v1/users/{userId}           // 删除用户
GET    /api/v1/users/{userId}/orders    // 用户的订单列表

// ❌ 错误URL
GET    /api/v1/getUser                  // 动词
GET    /api/v1/user                     // 单数
GET    /api/v1/User                     // 大写
POST   /api/v1/createOrder              // 动词
GET    /api/v1/user_list                // 下划线
```

### 1.3 查询参数规范

```yaml
query_params:
  - pageNum: 页码（从1开始）
  - pageSize: 每页条数
  - sortBy: 排序字段
  - sortOrder: 排序方向（asc/desc）
  - 业务过滤字段使用小驼峰
```

```java
// ✅ 正确
GET /api/v1/orders?userId=1001&status=1&pageNum=1&pageSize=10&sortBy=createTime&sortOrder=desc

// ❌ 错误
GET /api/v1/orders?user_id=1001&page=1   // 命名不一致
```

## 二、请求规范 [MUST]

### 2.1 请求DTO设计

```java
@Data
@Schema(description = "订单创建请求")
public class OrderCreateRequest {

    @NotNull(message = "用户ID不能为空")
    @Schema(description = "用户ID", example = "1001", required = true)
    private Long userId;

    @NotEmpty(message = "商品列表不能为空")
    @Size(min = 1, max = 100, message = "商品数量1-100件")
    @Schema(description = "商品列表", required = true)
    private List<OrderItemDTO> items;

    @NotNull(message = "订单金额不能为空")
    @DecimalMin(value = "0.01", message = "订单金额必须大于0")
    @Schema(description = "订单金额", example = "299.00", required = true)
    private BigDecimal amount;

    @Schema(description = "收货地址ID")
    private Long addressId;

    @Size(max = 200, message = "备注不超过200字")
    @Schema(description = "订单备注")
    private String remark;
}
```

### 2.2 Controller参数校验

```java
@RestController
@RequestMapping("/api/v1/orders")
@Validated
public class OrderController {

    // 请求体校验
    @PostMapping
    public Result<Long> createOrder(@Valid @RequestBody OrderCreateRequest request) {
        return Result.success(orderService.createOrder(request));
    }

    // 路径参数校验
    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrder(
            @PathVariable @Min(value = 1, message = "订单ID必须大于0") Long orderId) {
        return Result.success(orderService.getOrderById(orderId));
    }

    // 查询参数校验
    @GetMapping
    public Result<PageInfo<OrderVO>> listOrders(
            @RequestParam @NotNull(message = "用户ID不能为空") Long userId,
            @RequestParam(defaultValue = "1") @Min(1) Integer pageNum,
            @RequestParam(defaultValue = "10") @Max(100) Integer pageSize) {
        return Result.success(orderService.listOrders(userId, pageNum, pageSize));
    }
}
```

### 2.3 请求体规范

```yaml
rules:
  - 使用JSON格式
  - Content-Type: application/json
  - 嵌套层级不超过3层
  - 禁止过大请求体（建议≤1MB）
```

## 三、响应规范 [MUST]

### 3.1 统一响应结构

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {

    @Schema(description = "业务状态码", example = "200")
    private int code;

    @Schema(description = "提示消息", example = "成功")
    private String msg;

    @Schema(description = "响应数据")
    private T data;

    @Schema(description = "响应时间戳", example = "1704067200000")
    private long timestamp;

    // 成功响应
    public static <T> Result<T> success(T data) {
        return new Result<>(200, "成功", data, System.currentTimeMillis());
    }

    public static Result<Void> success() {
        return new Result<>(200, "成功", null, System.currentTimeMillis());
    }

    // 失败响应
    public static Result<Void> fail(int code, String msg) {
        return new Result<>(code, msg, null, System.currentTimeMillis());
    }
}
```

### 3.2 业务状态码规范

| 码段 | 含义 | 示例 |
|------|------|------|
| 200 | 成功 | 200 = 操作成功 |
| 400-499 | 客户端错误 | 400=参数错，401=未登录，403=无权限，404=资源不存在 |
| 500-599 | 服务端错误 | 500=系统错误，503=服务不可用 |
| 5001-5999 | 用户模块业务错误 | 5001=用户不存在，5002=密码错误 |
| 6001-6999 | 订单模块业务错误 | 6001=订单不存在，6002=订单已支付 |
| 7001-7999 | 支付模块业务错误 | 7001=余额不足，7002=支付超时 |

```java
// 业务异常码枚举
public enum BizErrorCode {
    // 用户模块 5001-5999
    USER_NOT_FOUND(5001, "用户不存在"),
    PASSWORD_ERROR(5002, "密码错误"),
    USER_DISABLED(5003, "用户已禁用"),

    // 订单模块 6001-6999
    ORDER_NOT_FOUND(6001, "订单不存在"),
    ORDER_ALREADY_PAID(6002, "订单已支付"),
    ORDER_EXPIRED(6003, "订单已过期"),
    STOCK_NOT_ENOUGH(6004, "库存不足"),

    // 支付模块 7001-7999
    BALANCE_NOT_ENOUGH(7001, "余额不足"),
    PAYMENT_TIMEOUT(7002, "支付超时");

    private final int code;
    private final String msg;
}
```

### 3.3 分页响应结构

```java
@Data
@Schema(description = "分页响应")
public class PageInfo<T> {

    @Schema(description = "当前页", example = "1")
    private Integer pageNum;

    @Schema(description = "每页条数", example = "10")
    private Integer pageSize;

    @Schema(description = "总条数", example = "100")
    private Long total;

    @Schema(description = "总页数", example = "10")
    private Integer pages;

    @Schema(description = "数据列表")
    private List<T> list;

    @Schema(description = "是否有下一页", example = "true")
    private Boolean hasNextPage;
}
```

### 3.4 响应示例

```json
// 成功响应（单条数据）
{
    "code": 200,
    "msg": "成功",
    "data": {
        "orderId": 1001,
        "orderNo": "202401010001",
        "amount": 299.00,
        "status": 1,
        "createTime": "2024-01-01 12:00:00"
    },
    "timestamp": 1704067200000
}

// 成功响应（分页数据）
{
    "code": 200,
    "msg": "成功",
    "data": {
        "pageNum": 1,
        "pageSize": 10,
        "total": 100,
        "pages": 10,
        "list": [...],
        "hasNextPage": true
    },
    "timestamp": 1704067200000
}

// 失败响应
{
    "code": 6001,
    "msg": "订单不存在",
    "data": null,
    "timestamp": 1704067200000
}
```

## 四、全局异常处理 [MUST]

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    // 参数校验异常（@Valid）
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleValidException(MethodArgumentNotValidException e) {
        String errorMsg = e.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.joining(", "));
        return Result.fail(400, "参数校验失败: " + errorMsg);
    }

    // 参数校验异常（@Validated）
    @ExceptionHandler(ConstraintViolationException.class)
    public Result<Void> handleConstraintException(ConstraintViolationException e) {
        String errorMsg = e.getConstraintViolations().stream()
                .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                .collect(Collectors.joining(", "));
        return Result.fail(400, "参数校验失败: " + errorMsg);
    }

    // 业务异常
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusinessException(BusinessException e) {
        return Result.fail(e.getCode(), e.getMessage());
    }

    // 未知异常
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.fail(500, "系统繁忙，请稍后重试");
    }
}
```

## 五、接口文档规范 [MUST]

### 5.1 SpringDoc配置

```yaml
# application.yml
springdoc:
  api-docs:
    enabled: true
    path: /v3/api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
  packages-to-scan: com.example.controller
```

### 5.2 Controller文档注解

```java
@RestController
@RequestMapping("/api/v1/orders")
@Tag(name = "订单接口", description = "订单CRUD操作")
public class OrderController {

    @Operation(
        summary = "创建订单",
        description = "用户下单接口，需传入用户ID、商品列表、金额"
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "创建成功"),
        @ApiResponse(responseCode = "400", description = "参数错误"),
        @ApiResponse(responseCode = "6004", description = "库存不足")
    })
    @PostMapping
    public Result<Long> createOrder(
            @RequestBody @Valid OrderCreateRequest request) {
        return Result.success(orderService.createOrder(request));
    }

    @Operation(summary = "查询订单详情")
    @Parameter(name = "orderId", description = "订单ID", required = true, example = "1001")
    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrder(@PathVariable Long orderId) {
        return Result.success(orderService.getOrderById(orderId));
    }
}
```

## 六、版本控制规范 [MUST]

### 6.1 版本策略

```yaml
format: /api/v{major}/resource
rules:
  - 主版本号递增表示不兼容变更
  - 新增字段必须设默认值
  - 禁止删除旧字段（标记废弃）
  - 禁止修改字段类型
```

### 6.2 接口废弃流程

```java
// 1. 标记废弃
@Deprecated
@Operation(summary = "【已废弃】查询订单", description = "请使用 /api/v2/orders 替代")
@GetMapping("/api/v1/orders/{orderId}")
public Result<OrderVO> getOrderV1(@PathVariable Long orderId) {
    // ...
}

// 2. 新版本接口
@Operation(summary = "查询订单详情")
@GetMapping("/api/v2/orders/{orderId}")
public Result<OrderDetailVO> getOrderV2(@PathVariable Long orderId) {
    // ...
}
```

## 七、安全规范 [MUST]

### 7.1 接口限流

```java
// Sentinel限流注解
@SentinelResource(
    value = "createOrder",
    blockHandler = "createOrderBlockHandler"
)
@PostMapping
public Result<Long> createOrder(@RequestBody @Valid OrderCreateRequest request) {
    return Result.success(orderService.createOrder(request));
}

// 限流降级处理
public Result<Long> createOrderBlockHandler(OrderCreateRequest request, BlockException e) {
    return Result.fail(429, "请求过于频繁，请稍后重试");
}
```

### 7.2 幂等性设计

```java
// 使用RequestId实现幂等
@PostMapping
public Result<Long> createOrder(
        @RequestHeader("X-Request-Id") String requestId,
        @RequestBody @Valid OrderCreateRequest request) {

    // 幂等检查
    String key = "idempotent:order:" + requestId;
    Boolean isNew = redisTemplate.opsForValue().setIfAbsent(key, "1", 30, TimeUnit.MINUTES);
    if (Boolean.FALSE.equals(isNew)) {
        throw new BusinessException("请勿重复提交");
    }

    return Result.success(orderService.createOrder(request));
}
```

### 7.3 敏感数据脱敏

```java
@Data
public class UserVO {
    private Long userId;
    private String userName;

    @JsonSerialize(using = PhoneDesensitizer.class)
    private String phone;  // 138****8000

    @JsonSerialize(using = IdCardDesensitizer.class)
    private String idCard;  // 310***********1234
}
```

## 八、统一请求/响应结构模板 [MUST]

> 所有项目必须使用以下标准化的请求/响应结构，确保接口风格一致。

### 8.1 通用请求基类 CommonRequest

```java
package com.example.vo.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用请求基类
 * 所有请求对象必须继承此类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@Schema(description = "通用请求基类")
public class CommonRequest {

    @Schema(description = "请求追踪ID（可选）",
            example = "createUser_20250127150000_123456")
    private String traceId;
}
```

### 8.2 通用分页请求基类 CommonPageRequest

```java
package com.example.vo.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用分页请求基类
 * 所有分页查询请求必须继承此类
 */
@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
@Schema(description = "通用分页请求基类")
public abstract class CommonPageRequest extends CommonRequest {

    @Schema(description = "页码", example = "1", minimum = "1")
    @NotNull(message = "页码不能为空")
    @Min(value = 1, message = "页码最小为1")
    private Integer pageNumber = 1;

    @Schema(description = "每页数量", example = "10", minimum = "1", maximum = "100")
    @NotNull(message = "每页数量不能为空")
    @Min(value = 1, message = "每页数量最小为1")
    @Max(value = 100, message = "每页数量不能超过100")
    private Integer pageSize = 10;

    @Schema(description = "排序字段", example = "createTime")
    private String sortBy;

    @Schema(description = "排序方向", example = "desc", allowableValues = {"asc", "desc"})
    private String sortDirection = "desc";
}
```

### 8.3 通用响应基类 CommonResponse

```java
package com.example.vo.response;

import com.example.enums.ErrorCodeEnum;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用响应基类
 * 所有API必须返回此类型
 */
@Data
@NoArgsConstructor
@Accessors(chain = true)
@Schema(description = "通用响应基类")
public class CommonResponse<T> {

    @Schema(description = "响应状态码", example = "0")
    private String code;

    @Schema(description = "响应消息", example = "success")
    private String message;

    @Schema(description = "响应数据")
    private T data;

    public boolean isSuccess() {
        return "0".equals(code);
    }

    public static <T> CommonResponse<T> success() {
        return new CommonResponse<T>().setCode("0").setMessage("success");
    }

    public static <T> CommonResponse<T> success(T data) {
        return new CommonResponse<T>().setCode("0").setMessage("success").setData(data);
    }

    public static <T> CommonResponse<T> error(ErrorCodeEnum errorCode) {
        return new CommonResponse<T>().setCode(errorCode.getCode()).setMessage(errorCode.getMessage());
    }

    public static <T> CommonResponse<T> error(String code, String message) {
        return new CommonResponse<T>().setCode(code).setMessage(message);
    }
}
```

### 8.4 分页数据封装类 PageData

```java
package com.example.vo.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 分页数据封装类
 * 作为 CommonResponse<PageData<T>> 的 data 字段类型
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "分页数据封装类")
public class PageData<T> {

    @Schema(description = "总条数", example = "100")
    private Long total;

    @Schema(description = "当前页码", example = "1")
    private Integer pageNumber;

    @Schema(description = "每页数量", example = "10")
    private Integer pageSize;

    @Schema(description = "数据列表")
    private List<T> list;

    /**
     * 计算总页数
     */
    public Integer getTotalPages() {
        if (total == null || pageSize == null || pageSize == 0) {
            return 0;
        }
        return (int) Math.ceil((double) total / pageSize);
    }
}
```

### 8.5 使用示例

```java
// 普通请求
@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "创建用户请求")
public class CreateUserRequest extends CommonRequest {

    @NotBlank(message = "用户名不能为空")
    @Schema(description = "用户名", example = "john_doe")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Schema(description = "密码")
    private String password;
}

// 分页查询请求
@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "搜索用户请求")
public class SearchUserRequest extends CommonPageRequest {

    @Schema(description = "关键词", example = "john")
    private String keyword;

    @Schema(description = "角色", example = "admin")
    private String role;
}

// Controller使用
@PostMapping("/search")
public CommonResponse<PageData<UserResponse>> searchUsers(
        @Valid @RequestBody SearchUserRequest request) {
    return userService.searchUsers(request);
}
```

## 九、错误码格式规范 [MUST]

> 统一错误码格式，便于问题定位和系统间通信。

### 9.1 错误码格式定义

| 位置 | 长度 | 含义          | 示例     |
| ---- | ---- | ------------- | -------- |
| 1-4  | 4位  | 系统/模块代码 | 1001     |
| 5    | 1位  | 错误类型      | B/C/T    |
| 6-13 | 8位  | 错误序号      | 00000001 |

**错误类型说明**:
- **B** (Business): 业务错误，如用户名已存在、余额不足
- **C** (Client): 客户端错误，如参数校验失败、未认证
- **T** (Technical): 技术错误，如数据库异常、服务超时

**特殊码值**:
- `"0"`: 成功码，固定为字符串 "0"

### 9.2 错误码枚举模板

```java
package com.example.enums;

import lombok.Getter;

/**
 * 错误码枚举
 *
 * 格式：[系统代码4位][类型1位][序号8位]
 * - B: 业务错误 (Business)
 * - C: 客户端错误 (Client)
 * - T: 技术错误 (Technical)
 */
@Getter
public enum ErrorCodeEnum {

    // ==================== 成功码 ====================
    SUCCESS("0", "success"),

    // ==================== 业务错误码 (1001B00000001-1001B00000999) ====================
    USERNAME_EXISTS("1001B00000001", "用户名已存在"),
    USER_NOT_FOUND("1001B00000002", "用户不存在"),
    PASSWORD_INCORRECT("1001B00000003", "密码错误"),
    ACCOUNT_DISABLED("1001B00000004", "账户已禁用"),
    INSUFFICIENT_BALANCE("1001B00000005", "余额不足"),

    // ==================== 客户端错误码 (1001C00000001-1001C00000999) ====================
    VALIDATION_ERROR("1001C00000001", "参数校验失败"),
    UNAUTHORIZED("1001C00000002", "未认证"),
    FORBIDDEN("1001C00000003", "权限不足"),
    RESOURCE_NOT_FOUND("1001C00000004", "资源不存在"),
    METHOD_NOT_ALLOWED("1001C00000005", "请求方法不允许"),

    // ==================== 技术错误码 (1001T00000001-1001T00000999) ====================
    INTERNAL_ERROR("1001T00000001", "系统内部错误"),
    DATABASE_ERROR("1001T00000002", "数据库操作失败"),
    CACHE_ERROR("1001T00000003", "缓存操作失败"),
    REMOTE_SERVICE_ERROR("1001T00000004", "远程服务调用失败"),
    TIMEOUT_ERROR("1001T00000005", "请求超时");

    private final String code;
    private final String message;

    ErrorCodeEnum(String code, String message) {
        this.code = code;
        this.message = message;
    }

    /**
     * 根据错误码查找枚举值
     */
    public static ErrorCodeEnum fromCode(String code) {
        for (ErrorCodeEnum errorCode : values()) {
            if (errorCode.code.equals(code)) {
                return errorCode;
            }
        }
        throw new IllegalArgumentException("Invalid error code: " + code);
    }
}
```

### 9.3 多系统错误码分配

| 系统代码 | 系统名称 | 错误码范围                  |
| -------- | -------- | --------------------------- |
| 1001     | 用户中心 | 1001B/C/T 00000001-00000999 |
| 1002     | 订单系统 | 1002B/C/T 00000001-00000999 |
| 1003     | 支付系统 | 1003B/C/T 00000001-00000999 |
| 1004     | 商品系统 | 1004B/C/T 00000001-00000999 |

### 9.4 业务异常类模板

```java
package com.example.exception;

import com.example.enums.ErrorCodeEnum;
import lombok.Getter;

/**
 * 业务异常类
 */
@Getter
public class BusinessException extends RuntimeException {

    private final String code;
    private final String msg;

    public BusinessException(ErrorCodeEnum errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.msg = errorCode.getMessage();
    }

    public BusinessException(String code, String msg) {
        super(msg);
        this.code = code;
        this.msg = msg;
    }

    public BusinessException(ErrorCodeEnum errorCode, Throwable cause) {
        super(errorCode.getMessage(), cause);
        this.code = errorCode.getCode();
        this.msg = errorCode.getMessage();
    }
}
```

## 十、HTTP方法简化策略 [SHOULD]

> 在特定场景下，可采用简化的HTTP方法策略（仅GET/POST），便于防火墙配置和统一处理。

### 10.1 简化HTTP方法映射

| 操作类型              | 推荐方法 | URL示例                      |
| --------------------- | -------- | ---------------------------- |
| 查询单条数据          | GET      | `/api/v1/users/{id}`         |
| 查询列表（简单）      | GET      | `/api/v1/users?role=admin`   |
| 查询列表（复杂/分页） | POST     | `/api/v1/users/search`       |
| 创建资源              | POST     | `/api/v1/users/create`       |
| 更新资源              | POST     | `/api/v1/users/update`       |
| 删除资源              | POST     | `/api/v1/users/delete/{id}`  |
| 批量操作              | POST     | `/api/v1/users/batch-delete` |

### 10.2 适用场景

| 场景 | 建议 |
|------|------|
| 对外公开API | 使用标准RESTful（GET/POST/PUT/DELETE） |
| 企业内部系统 | 可使用简化策略（GET/POST） |
| 防火墙限制环境 | 推荐简化策略 |
| 微服务间调用 | 使用标准RESTful |

### 10.3 简化策略的利弊

**采纳理由**:
- 简化防火墙配置（部分企业防火墙默认阻止PUT/DELETE）
- 统一请求体格式（POST 统一使用 JSON Body）
- 便于日志记录（POST 请求参数在 Body 中，更安全）
- 降低 CSRF 风险

**不采纳理由**:
- 违反 RESTful 规范
- POST 请求默认不可缓存
- 幂等性语义丢失（PUT 天然幂等）
- 部分 API 测试工具依赖 HTTP 动词语义

### 10.4 简化策略下的Controller示例

```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "用户管理", description = "用户管理相关接口")
public class UserController {

    @Autowired
    private UserService userService;

    // GET - 查询单条
    @GetMapping("/{id}")
    @Operation(summary = "获取用户详情")
    public CommonResponse<UserResponse> getUserById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    // POST - 复杂查询/分页
    @PostMapping("/search")
    @Operation(summary = "分页搜索用户")
    public CommonResponse<PageData<UserResponse>> searchUsers(
            @Valid @RequestBody SearchUserRequest request) {
        return userService.searchUsers(request);
    }

    // POST - 创建
    @PostMapping("/create")
    @Operation(summary = "创建用户")
    public CommonResponse<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        return userService.createUser(request);
    }

    // POST - 更新
    @PostMapping("/update")
    @Operation(summary = "更新用户")
    public CommonResponse<UserResponse> updateUser(
            @Valid @RequestBody UpdateUserRequest request) {
        return userService.updateUser(request);
    }

    // POST - 删除
    @PostMapping("/delete/{id}")
    @Operation(summary = "删除用户")
    public CommonResponse<Void> deleteUser(@PathVariable Long id) {
        return userService.deleteUserById(id);
    }

    // POST - 批量删除
    @PostMapping("/batch-delete")
    @Operation(summary = "批量删除用户")
    public CommonResponse<Void> batchDeleteUsers(
            @RequestBody List<Long> ids) {
        return userService.batchDeleteUsers(ids);
    }
}
```

## 十一、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | URL包含动词 | 检查RequestMapping路径 |
| 2 | GET请求带RequestBody | 检查GET方法参数 |
| 3 | 无统一响应格式 | 检查返回类型是否为CommonResponse |
| 4 | 无参数校验注解 | 检查@Valid/@Validated |
| 5 | 无全局异常处理 | 检查@RestControllerAdvice |
| 6 | 无接口文档注解 | 检查@Operation/@Tag |
| 7 | 无版本号 | 检查URL是否包含/v1/ |
| 8 | 响应包含敏感数据 | 检查password/secret等字段 |
| 9 | POST接口无幂等设计 | 检查创建类接口 |
| 10 | 无分页参数 | 检查列表查询接口 |
| 11 | 请求类未继承基类 | 检查是否继承CommonRequest |
| 12 | 错误码格式不规范 | 检查是否符合13位格式 |

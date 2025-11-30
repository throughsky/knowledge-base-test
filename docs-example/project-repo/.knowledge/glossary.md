# 项目术语词典 (Project Glossary)

**最后更新**: 2025-11-30

---

## 概述

本词典定义了项目中使用的业务和技术术语，建立团队的"通用语言"。

<!-- AI-CONTEXT
项目术语词典补充企业术语词典，定义项目特有术语。
AI在理解需求或生成文档时应使用这些标准术语。
-->

---

## 业务术语

| 术语 | 英文 | 定义 | 关联代码 |
|------|------|------|----------|
| **购物车** | Cart | 用户待结算商品集合 | `Cart.java` |
| **结算** | Checkout | 从购物车生成订单的过程 | `CheckoutService` |
| **优惠券** | Coupon | 可用于订单减免的凭证 | `Coupon.java` |
| **秒杀** | Flash Sale | 限时限量抢购活动 | `FlashSaleService` |
| **预售** | Pre-sale | 商品正式发售前的预定 | `PreSaleOrder` |

---

## 技术术语

| 术语 | 定义 | 使用场景 |
|------|------|----------|
| **DTO** | Data Transfer Object，数据传输对象 | 层间数据传递 |
| **VO** | Value Object，值对象 | API请求/响应 |
| **PO** | Persistent Object，持久化对象 | 数据库实体 |
| **BO** | Business Object，业务对象 | Service层 |

---

## 状态枚举

### 订单状态 (OrderStatus)

| 状态 | 代码 | 说明 |
|------|------|------|
| 草稿 | `DRAFT` | 订单创建中 |
| 待支付 | `PENDING_PAYMENT` | 等待支付 |
| 已支付 | `PAID` | 支付完成 |
| 处理中 | `PROCESSING` | 仓库处理中 |
| 已发货 | `SHIPPED` | 已交付物流 |
| 已完成 | `COMPLETED` | 订单完结 |
| 已取消 | `CANCELLED` | 订单取消 |

---

## 缩写对照

| 缩写 | 全称 |
|------|------|
| ECP | Example Commerce Platform |
| US | User Service |
| OS | Order Service |
| PS | Product Service |

---

## 变更历史

| 日期 | 变更 | 作者 |
|------|------|------|
| 2025-11-30 | 初始版本 | @技术负责人 |

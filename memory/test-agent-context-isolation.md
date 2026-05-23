# 子 Agent 上下文隔离测试方案

## 测试目标

验证：父 session 分发任务给子 agent 后，父 session 上下文增长是否显著低于不分发的情况。

## 测试原理

- 子 agent 通过 `sessions_spawn` 创建，上下文从 0 开始
- 父 session 只接收结果摘要（少量 token）
- 对比两组实验中父 session 的 token 增长量

## 测试方案

### 实验 A：父 session 自己执行（对照组）

**任务**：读取 5 个文件 → 分析内容 → 写回摘要

**步骤**：
1. 记录当前父 session 的 `totalTokens` 和 `contextTokens`
2. 父 session 自己执行：读取文件、分析、写摘要
3. 记录新的 token 数据
4. **增长量 = 后 - 前**

**预期**：token 增长 ≈ 文件内容 + 分析输出（预计 3000-8000 token）

### 实验 B：分发给子 agent 执行（实验组）

**任务**：同上（完全相同的 5 个文件）

**步骤**：
1. 记录当前父 session 的 `totalTokens` 和 `contextTokens`（确保与 A 实验前接近的基数）
2. 父 session 只写任务描述（≈50 token）
3. `sessions_spawn` 子 agent 执行
4. 子 agent 完成后，父 session 读取结果摘要
5. 记录新的 token 数据
6. **增长量 = 后 - 前**

**预期**：token 增长 ≈ 任务描述 + 结果摘要（预计 200-800 token）

### 对比指标

| 指标 | 实验 A（不拆分） | 实验 B（拆分） |
|--|--|--|
| 父 session token 增长量 | 预计 3000-8000 | 预计 200-800 |
| 父 session 推理时间 | 较长（含大上下文） | 较短 |
| 总 token 消耗 | A + 子任务 | 父 + 子（分散） |

## 测试材料

- 读取 `memory/` 目录下的 5 个日志文件（已有内容，非空）
- 分析每个文件的主题/关键事件
- 生成 1-2 句摘要

## 执行计划

1. ✅ 写测试方案（本文件）
2. 执行实验 A（不拆分）
3. 执行实验 B（拆分）
4. 对比数据，得出结论
5. 更新 MEMORY.md（如有效，纳入长期策略）

## 注意事项

- 两组实验之间间隔 ≥5 分钟，避免缓存干扰
- 实验 B 的子 agent 用 `context="isolated"`（默认，独立上下文）
- 所有数据写入本文件，不依赖父 session 记忆

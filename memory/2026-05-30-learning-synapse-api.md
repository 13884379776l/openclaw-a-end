# Synapse Client API 学习（通过 8008 端口）

**学习时间：2026-05-30 23:28 GMT+8**

---

## 1. 端口发现

| 端口 | 服务 | 可达性 |
|------|------|--------|
| 8088 | Element Web | ✅ 可达 |
| 8008 | Synapse Client API | ✅ 可达 |
| 9090 | Synapse Admin API | ❌ 不可达（需开启） |

**关键发现：Client API 走 8008 端口，不需要 admin_api_enabled。**

## 2. 已学习的 API

### 登录
```
POST http://192.168.31.18:8008/_matrix/client/v3/login
{
  "type": "m.login.password",
  "identifier": {"type": "m.id.user", "user": "commander"},
  "password": "Cmd@123456!"
}
→ 返回 access_token
```

### 获取已加入房间
```
GET http://192.168.31.18:8008/_matrix/client/v3/joined_rooms
Authorization: Bearer {token}
```

### 获取房间信息
```
GET http://192.168.31.18:8008/_matrix/client/v3/rooms/{room_id}/state/m.room.name
GET http://192.168.31.18:8008/_matrix/client/v3/rooms/{room_id}/state/m.room.topic
```

### 发送消息
```
PUT http://192.168.31.18:8008/_matrix/client/v3/rooms/{room_id}/send/m.room.message/{txn_id}
Authorization: Bearer {token}
{ "msgtype": "m.text", "body": "测试消息" }
```

## 3. 已发现的房间

| 房间 ID | 名称 | 主题 |
|--  --|--  --|--  --|
| !AbEUPUjdGiEsOKSpLl | 测试公开房间 | 指挥官测试用 |
| !TVNnBUliIZIteQRHAI | 123 | 321 |
| !WXyqvGnGVJGsgSODSR | 三端实时通讯 | 指挥官 + A端 + B端 |

## 4. 待实践

- [ ] 验证通过 Client API 发送消息
- [ ] 获取房间成员列表（当前 token 过期）
- [ ] 定期同步通过 NAS 通道

---

**士兵长 (A端)**
2026-05-30 23:28 GMT+8

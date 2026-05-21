// B 端需要执行的命令：
// 1. 创建前端文件
# 在 Ubuntu 上执行：
mkdir -p /mnt/nas_data/party/web/static
# 然后把以下文件写入 /mnt/nas_data/party/web/static/

# 文件 1: /mnt/nas_data/party/web/static/index.html
# 文件 2: /mnt/nas_data/party/web/static/style.css
# 文件 3: /mnt/nas_data/party/web/static/app.js

# 2. FastAPI 添加静态文件服务（如果还没加）
# 在 mud_api.py 中添加：
# from fastapi.staticfiles import StaticFiles
# app.mount("/", StaticFiles(directory="/mnt/nas_data/party/web/static"), name="static")

# 3. 访问：http://192.168.31.18:8081/

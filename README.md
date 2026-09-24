# laya-service

Docker 镜像封装 [laya](https://github.com/NandhaKishorM/laya) 的 `laya-serve` HTTP 服务
（`POST /v1/systemone`,Jev 兼容协议）。

## 本地构建运行

```bash
docker build -t laya-service .
docker run --rm -p 8000:8000 \
  -v laya-model-cache:/home/laya/.cache/huggingface \
  laya-service
```

首次启动会从 Hugging Face 下载 checkpoint（公开模型，无需账号）。镜像默认在
**构建时**预下载权重（GitHub Actions 网络可访问 HF)，运行时以
`HF_HUB_OFFLINE=1` 离线启动，无需外网。如希望运行时下载，构建时加
`--build-arg PRELOAD_MODELS=0` 并设置 `-e HF_HUB_OFFLINE=0`；国内环境可搭配
`-e HF_ENDPOINT=https://hf-mirror.com`。

调用示例：

```bash
curl -X POST http://localhost:8000/v1/systemone \
  -H 'Content-Type: application/json' \
  -d '{"state": {"text": "..."}, "questions": [{"type": "choice", "question": "...", "options": ["a", "b"]}]}'
```

## 环境变量

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| `LAYA_HOST` / `LAYA_PORT` | `0.0.0.0` / `8000` | 监听地址 |
| `LAYA_DEVICE` | `cpu` | `cpu` / `cuda` |
| `LAYA_MODELS` | 上游默认 | 路由模型，如 `auto`、`english` |
| `LAYA_PRELOAD` | `1` | 启动时预加载 checkpoint |
| `LAYA_API_KEY` | 未设置 | 设置后启用 Bearer 鉴权 |
| `HF_HUB_OFFLINE` | `1` | `0` 时允许运行时下载 checkpoint |
| `HF_ENDPOINT` | 未设置 | HF 被墙时设为 `https://hf-mirror.com` |
| `HF_TOKEN` | 未设置 | 拉取 gated checkpoint 时使用 |
| `OMP_NUM_THREADS` | `4` | CPU 线程数 |

## 发布镜像

打 tag 推送即可触发 GitHub Actions 构建并推送到阿里云 ACR:

```bash
git tag v0.1.0
git push origin v0.1.0
```

推送前需要在仓库 Settings → Secrets 中配置：

- `ALIYUN_REGISTRY_USERNAME`
- `ALIYUN_REGISTRY_PASSWORD`

产物：`crpi-gz6f3ok0ezphywc8.cn-shanghai.personal.cr.aliyuncs.com/42tr/laya-service:{latest,<version>}`

# MPV 极速定制优化配置（Windows / Intel 核显优先）

一套面向 Windows 的 `mpv` 便携配置，主要目标是：

- **强制核显渲染/硬解**：锁定 `D3D11 + Intel`，尽量让独显保持休眠（更安静、低发热）
- **多窗口/切后台更稳**：偏稳定性的 D3D11 开关与解码路径设置，降低“切后台黑屏/唤醒失败”概率
- **网络流更稳**：更强缓存、FFmpeg 级别重连、HLS 码率与请求头伪装

---

## 快速开始（便携模式）

1. 准备较新的 Windows `mpv.exe`（建议官方构建或可信发行版）。
2. 将本仓库的 `portable_config/` 放到 `mpv.exe` 同级目录（便携模式会自动生效）。
3. （可选）把 `yt-dlp.exe` 放到 `mpv.exe` 同级目录，用于解析 YouTube/B站等网站视频。

---

## 配置文件说明

### `portable_config/mpv.conf`

当前配置为“全局一套参数”（不依赖 profile）。核心内容如下：

- **渲染/硬解（强制核显）**
  - `vo=gpu-next`
  - `gpu-api=d3d11`
  - `d3d11-adapter=Intel`
  - `hwdec=d3d11va`
  - `d3d11-output-format=auto`
- **切换稳定性优先**
  - `d3d11-flip=no`
  - `d3d11-exclusive-fs=no`
  - `vd-lavc-dr=no`
- **低负载画质**
  - `scale=bicubic`、`cscale=bicubic`、`dscale=mitchell`
  - `deband=no`
  - `dither-depth=auto`
- **网络流/直播增强**
  - 缓存：`cache=yes`、`demuxer-max-bytes=400MiB`、`demuxer-max-back-bytes=100MiB`、`demuxer-readahead-secs=45`
  - 暂停等缓冲：`cache-pause=yes`、`cache-pause-wait=2`
  - 重连：`demuxer-reconnect-timeout=60`、`demuxer-lavf-o=reconnect=1,reconnect_streamed=1,reconnect_delay_max=5`
  - 超时：`network-timeout=100`
  - HLS：`hls-bitrate=max`
  - 伪装：`user-agent=...`、`http-header-fields='Referer: https://www.google.com/'`
  - 拖拽：`force-seekable=yes`（仅在你确实需要“在缓存范围内拖拽”时才建议保留）
- **yt-dlp 格式策略**
  - `ytdl-format="bestvideo[height<=1080][vcodec!^=av01]+bestaudio/bestvideo[height<=1080]+bestaudio/best"`
- **窗口与交互**
  - 最小化启动：`window-minimized=yes`
  - 初始窗口：`geometry=1280x720+50%+50%`、`autofit-larger=90%x90%`
  - 简洁 UI：`border=no`、`osc=no`、`osd-bar=no`
- **进度记忆**
  - `save-position-on-quit=yes`
  - `watch-later-directory="~~/watch_later"`
- **音频**
  - `ao=wasapi`
  - `volume=30`、`volume-max=100`
  - `audio-pitch-correction=yes`
  - `video-sync=display-resample`

---

## 使用方式

- **本地文件**：直接拖拽到 `mpv.exe` 或双击打开即可
- **网络流/HLS**：

```bash
mpv "<url>"
```

---

## 安全提示（重要）

当前 `mpv.conf` **全局设置了** `tls-verify=no`，这意味着 **HTTPS 证书不再校验**，存在被劫持/中间人攻击风险。  
如果你不需要此能力，建议改回 `tls-verify=yes`（或删除该行使用默认行为）。

# MPV 极速定制优化配置（Windows / Intel 核显优先）

一套面向 Windows 的 `mpv` 便携配置，主要目标是：

- **强制核显渲染/硬解**：锁定 `D3D11 + Intel`，尽量让独显保持休眠（更安静、低发热）
- **多窗口/切后台更稳**：偏稳定性的 D3D11 开关与解码路径设置，降低“切后台黑屏/唤醒失败”概率
- **网络流更稳**：更强缓存、FFmpeg 级别 HTTP 重连、HLS 码率与请求头伪装

---

## 快速开始（便携模式）

1. 准备较新的 Windows `mpv.exe`（建议官方构建或可信发行版）。
2. 将本仓库的 `portable_config/` 放到 `mpv.exe` 同级目录（便携模式会自动生效）。
3. （可选）把 `yt-dlp.exe` 放到 `mpv.exe` 同级目录，用于解析 YouTube/B站等网站视频。

---

## 配置文件说明

### `portable_config/mpv.conf`

当前配置为“全局一套参数”（不依赖 profile）。文件内按 **10 个区块** 排版，下面按区块概括（具体以仓库内文件为准）。

1. **解码与输出（强制核显）**  
   - `vo=gpu-next`、`gpu-api=d3d11`、`d3d11-adapter=Intel`  
   - `hwdec=d3d11va`、`d3d11-output-format=auto`

2. **全屏与窗口切换（稳定性优先）**  
   - `d3d11-flip=no`、`d3d11-exclusive-fs=no`、`vd-lavc-dr=no`

3. **缩放与画质**  
   - `scale=bicubic`、`cscale=bicubic`、`dscale=mitchell`（另保留注释行 `#dscale=bicubic` 便于切换）  
   - `dither-depth=auto`、`deband=yes`（高负载若卡顿可改为 `no`）

4. **缓存与解复用**  
   - `cache=yes`、`demuxer-max-bytes=400MiB`、`demuxer-max-back-bytes=100MiB`  
   - `demuxer-readahead-secs=45`、`demuxer-thread=yes`  
   - `demuxer-reconnect-timeout=70`（与下方 lavf/HTTP 重试总时长配套）  
   - `cache-pause=yes`、`cache-pause-wait=2`、`force-seekable=yes`

5. **网络与直播（HLS / HTTP）**  
   - `user-agent`：模拟常见桌面 Chrome，降低被源站刁难概率  
   - `demuxer-lavf-o=reconnect=1,reconnect_streamed=1,reconnect_on_network_error=1,reconnect_max_retries=6,reconnect_delay_max=120,reconnect_delay_total_max=70`  
     - HTTP 重连为 **指数退避**（约 0→1→3→7→15→31 秒量级），**不是**固定间隔；`reconnect_max_retries=6` 与 `reconnect_delay_total_max` 用于限制轮次与累计等待  
   - `network-timeout=100`、`hls-bitrate=max`  
   - `http-header-fields='Referer: https://www.google.com/'`  
   - `tls-verify=no`（见下文安全提示）

6. **yt-dlp**  
   - `ytdl-format="bestvideo[height<=1080][vcodec!^=av01]+bestaudio/bestvideo[height<=1080]+bestaudio/best"`  
   - 可选：在配置中取消注释 `script-opts=ytdl_hook-ytdl_path=...` 指定 `yt-dlp.exe` 路径

7. **窗口与 OSD**  
   - `window-minimized=no`  
   - `geometry=1280x720+50%+50%`、`autofit-larger=90%x90%`  
   - `border=no`、`osc=no`、`osd-bar=no`

8. **播放进度（watch later）**  
   - `save-position-on-quit=yes`  
   - `write-filename-in-watch-later-config=yes`（在进度文件中保存文件名以便排查）
   - `watch-later-options-remove=sub-pos`、`watch-later-options-remove=osd-margin-y`（不记录字幕位置等临时状态）

9. **输入与掉帧**  
   - `framedrop=vo`  
   - `input-cursor-passthrough=no`

10. **音频与同步**  
    - `ao=wasapi`、`volume-max=100`、`volume=30`  
    - `audio-pitch-correction=yes`、`audio-file-auto=fuzzy`  
    - `video-sync=display-resample`

---

## 快捷键说明 (`portable_config/input.conf`)

本配置添加了几个常用的快捷键：

- **`ENTER`**：切换全屏
- **`UP` / `DOWN` 方向键**：调节音量
- **`LEFT` / `RIGHT` 方向键**：后退 / 前进 10 秒
- **`ESC` (智能按键)**： 
  - 第一下：如果处于全屏或最大化，则**退出全屏/恢复窗口**。
  - 第二下（或已经是窗口状态）：**最小化并自动暂停播放**。

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
若你不需要此能力，建议改为 `tls-verify=yes`（或删除该行使用默认行为）。

# tools/

小红书内容生产辅助工具集。单文件 HTML，无前端框架依赖。

## 快速开始

```bash
# 在仓库根目录执行：
bash tools/dev.sh
```

自动完成：检查 Python 3 → 扫描工具清单 → 启动本地服务（端口 8765）→ 打开浏览器工具首页。

**为什么需要本地服务器？**
直接双击 HTML 文件（`file://`）也能使用基本功能，但调用 Gemini 等外部 API 时浏览器会因 CORS 限制拒绝请求。通过 `dev.sh` 以 `http://localhost` 形式打开则不受此限制。

---

## 工具列表

### cover-overlay.html — 封面生成工具

**版本：** v1.1

**用途：** AI 生图 + 中文文字叠加 + 原尺寸导出，一站制作小红书封面。

| 功能 | 说明 |
|------|------|
| AI 生图 | 输入提示词，调用 Gemini Imagen 3 或通义万象生成背景 |
| 上传图片 | 拖拽或点击上传本地图片作为背景 |
| 多图层文字 | 独立控制字号、字重、颜色、对齐、行间距、不透明度、阴影 |
| 拖拽定位 | 鼠标拖动文字到任意位置，实时预览 |
| 导出 PNG | 按背景图原始尺寸（如 1080×1440）无损导出 |

**使用步骤：**
1. 点右上角 ⚙ 配置 API Key（推荐 Gemini，Key 可选存本地）
2. 切「AI 生图」tab，输入英文提示词 → 生成背景
3. 添加文字图层，拖拽调整位置、样式
4. 导出 PNG

**注意：**
- 千问（DashScope）不支持浏览器直接跨域调用，建议用 Gemini
- Gemini API Key 申请：[Google AI Studio](https://aistudio.google.com)

---

## 添加新工具

1. 在 `tools/` 下新建 `工具名.html`
2. 在 `<head>` 内加入元数据注释：

```html
<!-- @tool
name: 工具名（英文，用于显示和 URL）
version: 1.0
description: 一句话说明工具用途
-->
```

3. 重启 `dev.sh`，工具自动出现在首页和终端 dashboard

---

## 版本记录

| 工具 | 版本 | 日期 | 变更 |
|------|------|------|------|
| cover-overlay | v1.0 | 2026-05-30 | 初版：上传图片 + 多图层文字叠加 + 拖拽 + 导出 |
| cover-overlay | v1.1 | 2026-05-30 | 集成 AI 生图（Gemini Imagen 3 / 通义万象）+ API Key 管理弹窗 |
| cover-overlay | v1.2 | 2026-05-30 | 主标题/副标题预设按钮，默认色改为深蓝灰 #1d2b3a |
| cover-overlay | v1.3 | 2026-05-30 | 自动缓存：图层存 localStorage，背景图存 IndexedDB，刷新后恢复；清空工作区按钮 |
| cover-overlay | v1.4 | 2026-05-30 | 字体选择（Noto Sans SC / Noto Serif SC / 系统），编辑器分组重组（字体/颜色/阴影） |
| dev.sh | v1.0 | 2026-05-30 | 初版：本地服务器 + 工具清单生成 + 终端 dashboard |
| index.html | v1.0 | 2026-05-30 | 初版：浏览器工具首页，自动读取清单渲染工具卡片 |
| post-tracker | v1.0 | 2026-05-30 | 初版：笔记数据录入（IndexedDB）+ 记录表格 + 分析图表 |

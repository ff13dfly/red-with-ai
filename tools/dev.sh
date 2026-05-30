#!/usr/bin/env bash
# tools/dev.sh — 启动 red 工具集本地服务（静态文件服务器 + 终端 dashboard）
# 用法：bash tools/dev.sh
set -e

PORT=8765
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 颜色 ─────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RED='\033[0;31m'; NC='\033[0m'

info() { echo -e "${GREEN}[tools]${NC} $*"; }
warn() { echo -e "${YELLOW}[tools]${NC} $*"; }
err()  { echo -e "${RED}[tools]${NC} $*" >&2; exit 1; }

# ── 前置检查 ──────────────────────────────────────────
command -v python3 >/dev/null 2>&1 || err "需要 Python 3，请先安装：https://python.org"

PY_MINOR=$(python3 -c "import sys; print(sys.version_info.minor + sys.version_info.major * 10)")
[ "$PY_MINOR" -ge 36 ] || warn "建议 Python 3.6+（当前版本较旧）"

# ── 生成工具清单（tools-manifest.json）────────────────
# 扫描 *.html 中的 @tool 注释块，输出 JSON
python3 - "$TOOLS_DIR" <<'PYEOF'
import os, re, json, sys

tools_dir = sys.argv[1]
tools = []

for fname in sorted(os.listdir(tools_dir)):
    if not fname.endswith('.html') or fname in ('index.html',):
        continue
    path = os.path.join(tools_dir, fname)
    try:
        content = open(path, encoding='utf-8').read()
    except Exception:
        continue
    m = re.search(r'<!--\s*@tool(.*?)-->', content, re.DOTALL)
    if not m:
        continue
    meta = {'url': fname}
    for line in m.group(1).strip().splitlines():
        if ':' in line:
            k, _, v = line.partition(':')
            meta[k.strip()] = v.strip()
    tools.append(meta)

out = os.path.join(tools_dir, 'tools-manifest.json')
with open(out, 'w', encoding='utf-8') as f:
    json.dump({'tools': tools}, f, ensure_ascii=False, indent=2)

print(f"[tools] 清单已生成：{len(tools)} 个工具")
PYEOF

# ── 停掉旧进程 ────────────────────────────────────────
lsof -ti:"$PORT" | xargs kill -9 2>/dev/null || true
sleep 0.2

# ── 启动静态服务器 ────────────────────────────────────
cd "$TOOLS_DIR"
python3 -m http.server "$PORT" --bind 127.0.0.1 > /tmp/red-tools.log 2>&1 &
SERVER_PID=$!
sleep 0.4

kill -0 "$SERVER_PID" 2>/dev/null || err "服务器启动失败，请查看 /tmp/red-tools.log"
info "服务已启动  →  http://localhost:$PORT/"

# ── 打开浏览器 ────────────────────────────────────────
open "http://localhost:$PORT/" 2>/dev/null || \
  xdg-open "http://localhost:$PORT/" 2>/dev/null || \
  warn "请手动打开浏览器访问 http://localhost:$PORT/"

# ── 退出清理 ──────────────────────────────────────────
cleanup() {
  kill "$SERVER_PID" 2>/dev/null || true
  tput cnorm 2>/dev/null || true
  printf "\n${YELLOW}[tools] 已停止${NC}\n"
  exit 0
}
trap cleanup INT TERM EXIT

# ── 终端 Dashboard ────────────────────────────────────
START=$(date +%s)
tput civis 2>/dev/null || true

while true; do
  clear
  UPTIME=$(( $(date +%s) - START ))

  printf "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}\n"
  printf "${BLUE}${BOLD}║  Red Tools · 本地工具集                  ║${NC}\n"
  printf "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}\n"
  printf "${CYAN}  http://localhost:${PORT}   运行 ${UPTIME}s   Ctrl+C 停止${NC}\n\n"

  # 读取 manifest 展示工具列表
  printf "${BOLD}  工具列表${NC}\n"
  printf "  ${DIM}%-8s  %-22s  %s${NC}\n" "版本" "名称" "地址"
  printf "  ${DIM}%s${NC}\n" "──────────────────────────────────────────────────"

  python3 - "$TOOLS_DIR" "$PORT" <<'PYEOF'
import json, os, sys

tools_dir, port = sys.argv[1], sys.argv[2]
manifest_path = os.path.join(tools_dir, 'tools-manifest.json')

GREEN = '\033[0;32m'; CYAN = '\033[0;36m'; NC = '\033[0m'

try:
    data = json.load(open(manifest_path, encoding='utf-8'))
    for t in data.get('tools', []):
        ver  = t.get('version', '—')
        name = t.get('name', t.get('url', ''))
        url  = f"http://localhost:{port}/{t.get('url','')}"
        print(f"  {GREEN}v{ver:<7}{NC}  {name:<22}  {CYAN}{url}{NC}")
except Exception as e:
    print(f"  (清单读取失败: {e})")
PYEOF

  echo
  printf "  ${DIM}首页：http://localhost:${PORT}/  （浏览器工具卡片）${NC}\n"
  echo

  sleep 3
done

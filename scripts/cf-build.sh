#!/usr/bin/env bash
# Cloudflare Workers Builds 构建脚本。
# 负责：拉 submodule、装固定版本的 Hugo extended 与 Dart Sass、生成 public/。
set -euo pipefail

HUGO_VERSION="0.170.1"
SASS_VERSION="1.108.2"

# 1. 主题是 git submodule，构建环境不一定自动拉取
if [ ! -d themes/PaperMod/layouts ]; then
  echo "==> 拉取主题 submodule"
  git submodule update --init --recursive
fi

# 2. Hugo：构建镜像默认是 extended_0.147.7，解析不了 PaperMod 的新布局，这里固定 0.170.1
if ! hugo version 2>/dev/null | grep -q "v${HUGO_VERSION}"; then
  case "$(uname -m)" in
    x86_64|amd64) HUGO_ARCH="amd64" ;;
    arm64|aarch64) HUGO_ARCH="arm64" ;;
    *) echo "!! 未知架构 $(uname -m)"; exit 1 ;;
  esac
  echo "==> 安装 Hugo ${HUGO_VERSION} linux-${HUGO_ARCH}"
  curl -sSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz" -o /tmp/hugo.tar.gz
  mkdir -p /tmp/hugo-bin
  tar -xzf /tmp/hugo.tar.gz -C /tmp/hugo-bin hugo
  export PATH="/tmp/hugo-bin:$PATH"
fi

# 3. Dart Sass：Hugo 0.170 编译 SCSS 必须有它。装到临时目录，避免全局安装的权限问题。
if ! command -v sass >/dev/null 2>&1; then
  echo "==> 安装 Dart Sass ${SASS_VERSION}"
  npm install --no-save --prefix /tmp/sass-tool "sass@${SASS_VERSION}" >/dev/null
  export PATH="/tmp/sass-tool/node_modules/.bin:$PATH"
fi

# 4. 构建。SITE_BASE_URL 由 Workers 的“构建变量”注入（例如 https://blogs.xxx.workers.dev/）
# 必须是绝对地址：baseURL 写成 "/" 会让 PaperMod 的面包屑 JSON-LD 拼坏（它用 replace 把所有斜杠都削掉），
# Hugo 的压缩器会因此报 "expected comma character or an array or object ending"。
BASE_URL="${SITE_BASE_URL:-}"
echo "==> hugo version: $(hugo version)"
if [ -z "$BASE_URL" ]; then
  echo "!! 没有设置 SITE_BASE_URL，回退到 hugo.toml 里的 baseURL。"
  echo "!! 在 workers.dev 上会生成指向 GitHub Pages 的绝对链接，请到 Settings > Build > Build variables 设置 SITE_BASE_URL。"
  hugo --gc --minify
else
  echo "==> baseURL: $BASE_URL"
  hugo --gc --minify --baseURL "$BASE_URL"
fi

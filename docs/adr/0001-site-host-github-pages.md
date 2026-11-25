# 0001 主站放 GitHub Pages，Cloudflare Worker 只作预览

- 状态：已采纳（2026-11-25）
- 相关：`scripts/cf-build.sh`、`layouts/_partials/extend_head.html`、`wrangler.jsonc`

## 背景

同一份 Hugo 源码先后接了三家托管：GitHub Pages（`.github/workflows/hugo.yaml`）、Netlify（`netlify.toml`）、Cloudflare Workers（`wrangler.jsonc` + 构建脚本）。域名 cszywu.com 尚未购买，需要一个稳定的公开地址；同时希望有第二个环境验证构建产物。

## 决策

主站固定为 GitHub Pages（`https://joeyredfield.github.io/blogs/`）。Cloudflare Worker（`blogs.<子域>.workers.dev`）降级为预览站：构建脚本 `export HUGO_SITE_PREVIEW=1`，模板据此注入 `<meta name="robots" content="noindex, nofollow">`，避免同一内容被搜索引擎收录两次。

## 后果

- 两站共用同一份源码与同一条评论讨论（见 ADR-0002），在预览站回复等于在主站回复。
- 想让 Worker 转正，删掉 `scripts/cf-build.sh` 里的 `HUGO_SITE_PREVIEW=1` 即可，其余不变。
- Worker 的构建镜像 Hugo 版本低且有其他缺失，所以用仓库内脚本自取 Hugo 0.170.1 extended 与 Dart Sass，不依赖镜像预装。

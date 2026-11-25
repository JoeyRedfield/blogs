## 项目速查

- 站点：Hugo 0.170.1 + PaperMod（主题是 submodule）。主站是 GitHub Pages，Cloudflare Worker 只作预览（`HUGO_SITE_PREVIEW=1` → 注入 noindex）。
- 构建：`hugo --gc --minify --baseURL <绝对地址>`；SCSS 需要 Dart Sass，普通版 Hugo 不带。
- 红线：front matter 的 `date` 不要写成未来时间（`buildFuture` 关闭，页面会静默消失）；`static/` 不要放 CNAME（域名尚未购买，Pages 会 301 到不存在的域名）。
- 评论键：Giscus `mapping=specific`，term = 源文件路径（`content/posts/x.md` → `posts-x`）。已发评论的文章不要改名，改名需用 front matter `giscusTerm` 钉住旧 term。
- 模板里只能读到 `^HUGO_` 或 `^CI$` 的环境变量（Hugo `security.funcs.getenv` 默认白名单），其他名字静默变空串。
- 细节见 `README.md`，决策见 `docs/adr/`。

## Agent skills

### Issue tracker

Issues live in GitHub Issues at `JoeyRedfield/blogs`, managed with the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

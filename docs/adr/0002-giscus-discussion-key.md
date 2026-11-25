# 0002 Giscus 讨论键与 URL 解耦

- 状态：已采纳（2026-11-25）
- 相关：`hugo.toml` 的 `[params.giscus]`、`layouts/_partials/comments.html`

## 背景

最初用 `mapping = "pathname"`，Giscus 以浏览器地址（`/blogs/posts/hello-hugo/`）作为讨论的 key。站点存在两个部署路径（GitHub Pages 带 `/blogs` 前缀，Cloudflare Worker 不带），同一篇文章会分裂成两条互不相干的讨论；以后绑自定义域名还会再裂一次。

## 决策

改用 `mapping = "specific"` + `strict = "1"`，term 由模板按**源文件路径**生成（`content/posts/hello-hugo.md` → `posts-hello-hugo`），front matter 可用 `giscusTerm` 覆盖。Giscus 在 strict 模式下按讨论正文里的 `<!-- sha1: <term> -->` 注释精确查找。

## 后果

- 评论数据始终在 GitHub Discussions，换域名/换托管不会丢；变的是页面能否找回它。
- `strict = "1"` 不读讨论标题，迁移已有讨论必须改正文里的 sha1，改标题无效。
- 文章有评论后改名 = 换 term = 评论失联；恢复方法是在 front matter 写 `giscusTerm: <旧 term>`。
- 已知撞键组合：`content/posts-foo.md` 与 `content/posts/foo.md` 都映射到 `posts-foo`。
- 换仓库等于换讨论空间（Giscus 绑 repoId），不同仓库键相同也不会串。

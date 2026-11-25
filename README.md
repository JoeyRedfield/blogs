# cszywu 的博客

个人博客，使用 [Hugo](https://gohugo.io/)（0.170.1）与 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题构建。线上地址：<https://joeyredfield.github.io/blogs/>（仓库 [JoeyRedfield/blogs](https://github.com/JoeyRedfield/blogs)）。

## 本地开发

```bash
# 主题以 git submodule 引入，首次克隆需要
git clone --recurse-submodules <repo-url>
# 或已克隆后
git submodule update --init --recursive

# 本地预览（含草稿）
hugo server --buildDrafts

# 构建静态文件到 public/
hugo --gc --minify
```

依赖：Hugo 0.158+、Dart Sass（`brew install hugo dart-sass`）。

## 写文章

```bash
hugo new content posts/my-post.md
```

文章放在 `content/posts/`，front matter 中 `draft: true` 的文章不会进入生产构建；`date` 不要写未来时间，Hugo 默认不构建未来文章。

## 部署

推送到 `main` 后由 GitHub Actions 构建并发布到 GitHub Pages（见 `.github/workflows/hugo.yaml`），线上地址 `https://joeyredfield.github.io/blogs/`。仓库 Settings → Pages 的 Source 需为 **GitHub Actions**；`--baseURL` 由 Pages 的输出动态决定，不要写死。

## 以后绑定自定义域名（可选）

现在没有域名，`static/` 里**不要**放 `CNAME`：Pages 一旦认了自定义域名，`github.io/blogs/` 会 301 过去，域名解析不了就全站打不开。买了域名后做四步：

1. `echo 你的域名 > static/CNAME` 并 push（Hugo 会把它复制到站点根目录）
2. DNS 加记录：`www CNAME joeyredfield.github.io`；根域用 A 记录指向 `185.199.108.153`、`185.199.109.153`、`185.199.110.153`、`185.199.111.153`
3. Pages 设置填 custom domain，勾选 Enforce HTTPS
4. 把 `hugo.toml` 的 `baseURL` 改成 `https://你的域名/`

## 评论与阅读统计

两者都是纯前端方案，不需要服务器，也没有数据库。

**评论（Giscus）**：基于 GitHub Discussions。配置在 `hugo.toml` 的 `[params.giscus]`，模板在 `layouts/_partials/comments.html`。

- 仓库的 Discussions 已开启，评论会落到 `Announcements` 分类
- **还需要一步**：去 <https://github.com/apps/giscus> 给 `JoeyRedfield/blogs` 装上 Giscus App（只需一次）。没装之前评论区会显示错误
- 单独关闭某页评论：在该页 front matter 写 `comments: false`（例如 `content/about.md`）

**阅读量（不蒜子）**：`layouts/_partials/extend_post_content.html` 在每篇文章末尾输出 `本文阅读 N 次`，`layouts/_partials/extend_head.html` 引入脚本。开关是 `hugo.toml` 的 `[params.busuanzi]`（`enable` / `pagePV`）。它统计的是页面浏览量 PV，数据在 busuanzi 自己的服务上，不落库。

**可选：Umami 访问分析**：`[params.umami]` 默认关闭，`enable = true` 并填 `websiteID` 即可（Umami Cloud 免费额度够个人博客用）。

> 模板注意：PaperMod 用 `partialCached` 缓存 footer，且缓存键只含 Layout/Kind，所以**不要**把与单页相关的逻辑（比如 Giscus 主题同步）放进 `extend_footer.html`，会被别的页面缓存串用。主题同步脚本现在写在 `comments.html` 里。

## 部署到别的平台

`hugo --gc --minify` 产出的 `public/` 是纯静态文件，以下平台都能直接托管同一份源码，**内容不用改**：

| 平台 | 免费地址 | 配置文件 | 说明 |
|---|---|---|---|
| GitHub Pages | `joeyredfield.github.io/blogs/` | `.github/workflows/hugo.yaml` | 项目站，路径 = 仓库名；功能最基础 |
| Cloudflare Pages | `<项目名>.pages.dev` | 面板里填构建命令 | 支持 `_redirects`、`_headers`、边缘函数、PR 预览 |
| Netlify | `<站点名>.netlify.app` | `netlify.toml`（已备好） | 同上，另有表单/身份认证 |

三家共同需要的构建设定：

- 构建命令：`hugo --gc --minify`
- 输出目录：`public`
- 环境变量：`HUGO_VERSION=0.170.1`、`HUGO_ENV=production`；**主题是 submodule，必须递归拉取**（CI 里 `submodules: recursive`，Netlify/CF 需在面板里也开着）
- Dart Sass：Hugo 编译 SCSS 需要它，`netlify.toml` 和 Actions 里都装了。Hugo **extended** 版自带，普通版没有

绑定自定义域名是在各家面板里加域名 + 配 DNS，和用哪家托管无关；换平台时记得同步改 `hugo.toml` 的 `baseURL`（GitHub Pages 的 workflow 会自动注入，别的平台要自己设）。

## 目录

- `content/` — 文章与独立页面
- `layouts/` — 覆盖主题的模板（评论、阅读量、head 扩展）
- `assets/css/extended/` — 追加样式（自动合并进主题样式表）
- `netlify.toml` — Netlify 部署配置（GitHub Pages 用不到）
- `static/` — 原样拷贝到根目录的静态资源
- `themes/PaperMod/` — 主题（submodule）
- `docs/agents/` — 工程技能约定（issue tracker / triage labels / domain docs）

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

**讨论的键（重要）**：Giscus 把「页面」映射到「Discussion」靠一个 `term`，我们用的是 `mapping = "specific"` + `strict = "1"`，`term` 由 `comments.html` 按**源文件路径**生成 —— `content/posts/hello-hugo.md` → `posts-hello-hugo`。Discussion 的标题就是这个 term。

这样做的原因是 URL 会变、term 不会：

- GitHub Pages 的路径是 `/blogs/posts/hello-hugo/`，Cloudflare Workers 的是 `/posts/hello-hugo/`，用 `mapping = "pathname"` 会分裂成两条互不相干的评论；用 term 则两个站看到的是同一条讨论。
- 以后把站点迁到 `cszywu.com`（路径从 `/blogs/posts/hello-hugo/` 变成 `/posts/hello-hugo/`），已有评论不会丢。

代价是两条约定：**有评论之后不要改文章的文件名**（改名 = 换 term = 评论失联）；文件名可能撞车或想换 key 时，在 front matter 写 `giscusTerm: 任意稳定字符串` 覆盖它。

**阅读量（不蒜子）**：`layouts/_partials/extend_post_content.html` 在每篇文章末尾输出 `本文阅读 N 次`，`layouts/_partials/extend_head.html` 引入脚本。开关是 `hugo.toml` 的 `[params.busuanzi]`（`enable` / `pagePV`）。它统计的是页面浏览量 PV，数据在 busuanzi 自己的服务上，不落库。

**可选：Umami 访问分析**：`[params.umami]` 默认关闭，`enable = true` 并填 `websiteID` 即可（Umami Cloud 免费额度够个人博客用）。

> 模板注意：PaperMod 用 `partialCached` 缓存 footer，且缓存键只含 Layout/Kind，所以**不要**把与单页相关的逻辑（比如 Giscus 主题同步）放进 `extend_footer.html`，会被别的页面缓存串用。主题同步脚本现在写在 `comments.html` 里。

## 部署到别的平台

`hugo --gc --minify` 产出的 `public/` 是纯静态文件，以下平台都能直接托管同一份源码，**内容不用改**：

| 平台 | 免费地址 | 配置文件 | 说明 |
|---|---|---|---|
| GitHub Pages | `joeyredfield.github.io/blogs/` | `.github/workflows/hugo.yaml` | 项目站，路径 = 仓库名；功能最基础 |
| Cloudflare Workers | `blogs.<子域>.workers.dev` | `wrangler.jsonc` + `scripts/cf-build.sh`（已备好，见下） | 静态资源托管，走 Workers Builds 自动部署 |
| Cloudflare Pages | `<项目名>.pages.dev` | 面板里填构建命令 | 支持 `_redirects`、`_headers`、边缘函数、PR 预览 |
| Netlify | `<站点名>.netlify.app` | `netlify.toml`（已备好） | 同上，另有表单/身份认证 |

三家共同需要的构建设定：

- 构建命令：`hugo --gc --minify`
- 输出目录：`public`
- 环境变量：`HUGO_VERSION=0.170.1`、`HUGO_ENV=production`；**主题是 submodule，必须递归拉取**（CI 里 `submodules: recursive`，Netlify/CF 需在面板里也开着）
- Dart Sass：Hugo 编译 SCSS 需要它，`netlify.toml` 和 Actions 里都装了。Hugo **extended** 版自带，普通版没有

绑定自定义域名是在各家面板里加域名 + 配 DNS，和用哪家托管无关。

`baseURL` 是唯一容易踩的坑：它决定 CSS/图片/链接的绝对地址。三家都有「本次构建的地址」环境变量，构建时传进去就不会错：

- GitHub Pages：workflow 里用 `--baseURL` 取自 `steps.pages.outputs.base_url`（已配好）
- Netlify：`netlify.toml` 里用 `--baseURL "$DEPLOY_PRIME_URL"`（已配好，PR 预览也正确）
- Cloudflare Pages：构建命令加 `--baseURL "$CF_PAGES_URL"`

所以同一份源码可以在三家同时部署、互不干扰，只是绑定的域名不同。

### Cloudflare Workers（Workers Builds）

第一次构建失败的根因：Cloudflare 自动检测把「构建命令」填成了 `npx hugo`，而 `hugo` 不是 npm 包，npx 找不到可执行文件 → `npm error could not determine executable to run`。另外即使命令改对，构建镜像自带的 Hugo 是 `extended_0.147.7`（低于 PaperMod 要求的 0.158），也没有 Dart Sass，且不一定拉 submodule。

仓库里已经放好两个文件：

- `wrangler.jsonc` — 声明这是静态资源 Worker：`assets.directory = "./public"`、`not_found_handling = "404-page"`（用 Hugo 生成的 404.html）
- `scripts/cf-build.sh` — 构建脚本：缺 submodule 就拉、Hugo 版本不对就下 0.170.1 extended（按 `uname -m` 选 amd64/arm64）、缺 Dart Sass 就装到临时目录、最后带 `--baseURL` 构建

面板里改三处（Worker → Settings → Build）：

| 项 | 值 |
|---|---|
| Build command | `bash scripts/cf-build.sh` |
| Deploy command | `npx wrangler deploy`（默认值，不用改） |
| Build variables | `SITE_BASE_URL = https://blogs.<你的子域>.workers.dev/` |

**`SITE_BASE_URL` 要设成绝对地址**（`https://blogs.<你的子域>.workers.dev/`），不能图省事写 `/`：PaperMod 的面包屑 JSON-LD 里用 `replace .Parent.Permalink site.Home.Permalink ""` 削前缀，baseURL 是 `/` 时它会把所有斜杠都删掉，于是 JSON-LD 少一个逗号，Hugo 压缩器直接报 `expected comma character or an array or object ending`，构建失败。不设这个变量时脚本会回退到 `hugo.toml` 里的 baseURL（能构建，但站内绝对链接会指向 GitHub Pages），所以请把它当必填。以后绑了自定义域名再改成 `https://cszywu.com/`。

部署前想在本地校验配置：`npx wrangler deploy --dry-run`（只读配置和 public/，不真的上传）。

**预览与主站的分工。** 主站是 GitHub Pages（`https://joeyredfield.github.io/blogs/`），Worker 那份只当预览。所以 `scripts/cf-build.sh` 里有一行 `export HUGO_SITE_PREVIEW=1`，它带来一个差异（外加评论共用）：

- `layouts/_partials/extend_head.html` 注入 `<meta name="robots" content="noindex, nofollow">`，预览站不进搜索结果，避免同一份内容被收录两次；
- 评论不区分环境：`term` 是源文件路径，与域名无关，所以两处看到的是同一条 Discussion（在预览站回复等于在主站回复）。

想让 Worker 反过来当主站时，把那一行删掉（并同步注释里的说明）即可。

变量名带 `HUGO_` 前缀不是随便取的：Hugo 的 `security.funcs.getenv` 默认只放行 `^HUGO_` 和 `^CI$`，普通变量在模板里 `getenv` 拿到的是空串，会静默失效。

## 目录

- `content/` — 文章与独立页面
- `layouts/` — 覆盖主题的模板（评论、阅读量、head 扩展）
- `assets/css/extended/` — 追加样式（自动合并进主题样式表）
- `netlify.toml` — Netlify 部署配置（GitHub Pages 用不到）
- `wrangler.jsonc` — Cloudflare Workers 静态资源配置
- `scripts/cf-build.sh` — Cloudflare Workers 的构建脚本
- `static/` — 原样拷贝到根目录的静态资源
- `themes/PaperMod/` — 主题（submodule）
- `docs/agents/` — 工程技能约定（issue tracker / triage labels / domain docs）

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

## 换托管商

`hugo --gc --minify` 产出的 `public/` 是纯静态文件，可直接部署到 Cloudflare Pages、Netlify、Vercel 或任意对象存储：删掉或替换 `.github/workflows/hugo.yaml` 即可。用 Cloudflare Pages 的话会得到 `<项目名>.pages.dev` 免费子域名，构建命令 `hugo --gc --minify`、输出目录 `public`、环境变量 `HUGO_VERSION=0.170.1`。

## 目录

- `content/` — 文章与独立页面
- `layouts/` — 覆盖主题的模板（可选）
- `static/` — 原样拷贝到根目录的静态资源
- `themes/PaperMod/` — 主题（submodule）
- `docs/agents/` — 工程技能约定（issue tracker / triage labels / domain docs）

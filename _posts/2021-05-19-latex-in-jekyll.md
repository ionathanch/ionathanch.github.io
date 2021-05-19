---
layout: post
title: "Adding $\\LaTeX$ to your Jekyll Site"
tab_title: "Adding LaTeX to your Jekyll Site"
katex: true
tags:
  - jekyll
  - blog
  - LaTeX
---

As it turns out, adding support to render LaTeX in a Jekyll blog isn't all that hard, because other people have done most of the heavy lifting.
There are two main ways to do this:
* Client-side rendering: After the page loads, a JS script is run to transform LaTeXy parts of the page to lovely, styled HTML.
* Build-time rendering: After Markdown files are compiled to HTML, a Jekyll plugin further transforms those LaTeXy parts to HTML as well.
Here's how you do either using $\KaTeX$.

<!--more-->

# Client-Side $\KaTeX$

Inside of your HTML `<head>` tag, usually in `_layouts/default.html` for Jekyll blogs, add the following to conditionally load stylesheets and scripts.

```html
{% raw %}{% if page.katex %}

<!-- CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css"/>

<!-- JavaScript -->
<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body,{
    delimiters: [
      { left: '$$',  right: '$$',  display: true  },
      { left: '$',   right: '$',   display: false },
      { left: '\\[', right: '\\]', display: true  },
      { left: '\\(', right: '\\)', display: false }
  ]});">
</script>

{% endif %}{% endraw %}
```

This uses jsDelivr as the CDN to deliver the styles and scripts, and it uses KaTeX's [auto-render extension](https://katex.org/docs/autorender.html) to render everything within the specified delimiters. `display: true` is equivalent to a `displaymath` environment, while `display: false` is equivalent to an inline `math` environment. Their documentation has a few more options you can set, like which tags and classes to ignore during processing.

To use LaTeX in a post, add `katex: true` to the front matter, and write your LaTeX within the specified delimiters. For instance, the body of the following:

```markdown
---
layout: post
title: "Your Post Title"
katex: true
---

This is an example of inline \\(\LaTeX\\). The following is Stokes' theorem in a
`displaymath` environment: \$$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega\$$
```

is displayed as below:

> This is an example of inline \\(\LaTeX\\). The following is Stokes' theorem in a `displaymath` environment: \$$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega\$$

Note the extra backslashes to escape `\` and `$` from being processed by kramdown. Sometimes you will need to escape underscores as well to prevent kramdown from rendering text as italics instead of subscripts: the double subscript $\_{i\_{j}}$ is written as `$\_{i\_{j}}$`.

# Build-Time $\KaTeX$

Your LaTeX can be rendered during Jekyll's build instead of on the client side by using the [jekyll-katex](https://github.com/linjer/jekyll-katex/) plugin. Note that this will _not_ work with GitHub Pages because they only allow [supported plugins](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#plugins). The plugin repository has a detailed README, but to setup in short:

1. Add to `_config.yml`.
```yaml
plugins:
- jekyll-katex
```
2. Add to `Gemfile`.
```ruby
group :jekyll_plugins do
     gem 'jekyll-katex'
end
```
3. Again, add stylesheet to `<head>` (conditionally, if you like).
```html
{% raw %}{% if page.katex %}
< link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css" />
{% endif %}{% endraw %}
```

The plugin will only render LaTeX within specific Liquid tags. The example above can be written as (removing the spaces between braces and `%`):

```markdown
{% raw %}This is an example of inline {% katex %} \LaTeX {% endkatex %}.
The following is Stokes' theorem in a `displaymath` environment:
{% katex display %} \int_{\partial \Omega} \omega = \int_{\Omega} d\omega {% endkatex %}{% endraw %}
```

Or using the mixed math environment:

```markdown
{% raw %}{% katexmm %}
This is an example of inline $\LaTeX$. The following is Stokes' theorem in a
`displaymath` environment: $$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega$$
{% endkatexmm %}{% endraw %}
```

There is no need to escape any special characters. However, there doesn't seem to be a way to customize the delimiters used in `katexmm`. The `katex` and `katexmm` Liquid tags can be ignored as usual, by wrapping content in `{​% raw %}{​% endraw %}` tags.

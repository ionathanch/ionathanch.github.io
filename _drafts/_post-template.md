---
layout: post
title: "Post Template"
tags:
  - post
categories:
  - templates
---

Front matter:

```yaml
---
layout: post
title: "Post Template"
long_title: "This shows up only in the full post"
tab_title: "This shows up in the browser table title"
excerpt_separator: "<!--more-->"
katex: true
comments: false
tags:
  - post
categories:
  - templates
---
```

This part will be displayed on the blog page.

```html
<!--more-->
```

This part will be shown in the full post.

Including an image:

```html
{% raw %}
{% include image.html
           img="assets/images/image.png"
           title="title"
           caption="caption"
           url="https://ionathan.ch" %}
{% endraw %}
```

Linking to another post:

```markdown
[part 2]({{ site.baseurl }}{ % post_url yyyy-mm-dd-part-1 % })
```

Using LaTeX with `jekyll-katex`:

```latex
{% raw %}
{% katex %}
% This is inline
\int_{\partial \Omega} \omega = \int_{\Omega} d\omega
{% endkatex %}

{% katex display %}
% This is on its own line
\int_{\partial \Omega} \omega = \int_{\Omega} d\omega
{% endkatex %}

{% katexmm %}
This is a mixed environment with inline $\LaTeX$ and `displaymath`:
$$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega$$
{% endkatexmm %}
{% endraw %}
```

Using LaTeX with server-side auto-rendering (`katex: true`):

```latex
This is inline $\LaTeX$, and this is also inline \\(\LaTeX\\). These are `displaymath` environments:
\$$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega\$$
\\[\int_{\partial \Omega} \omega = \int_{\Omega} d\omega\\]
```

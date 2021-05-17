---
layout: post
title: "Post Template"
tags:
  - post
categories:
  - templates
---

For the Liquid templates below, remove the spaces between `%` and `{`, `}`.

Front matter:

```yaml
---
layout: post
title: "Post Template"
excerpt_separator: "<!--more-->"
comments: false
tags:
  - post
categories:
  - templates
---
```

This part will be displayed on the home page.

```html
<!--more-->
```

This part will be shown in the full post.

Including an image:

```html
{ % include image.html
            img="assets/images/image.png"
            title="title"
            caption="caption"
            url="https://ionathan.ch" % }
```

Linking to another post:

```markdown
[part 2]({{ site.baseurl }}{ % post_url yyyy-mm-dd-post-file-name % })
```

Using LaTeX:

```latex
{ % katex % }
% This is inline
\int_{\partial \Omega} \omega = \int_{\Omega} d\omega
{ % endkatex % }

{ % katex display % }
% This is on its own line
\int_{\partial \Omega} \omega = \int_{\Omega} d\omega
{ % endkatex % }

{ % katexmm % }
This is a mixed environment with $\textit{inline}$ math and on its own line:
$$\int_{\partial \Omega} \omega = \int_{\Omega} d\omega$$
{ % endkatexmm % }
```

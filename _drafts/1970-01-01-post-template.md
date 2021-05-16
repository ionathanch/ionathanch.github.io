---
layout: post
title: "Post Template"
use_math: true
excerpt_separator: "<!--more-->"
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
excerpt_separator: "<!--more-->"
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

```markdown
{% include image.html
           img="assets/images/image.png"
           title="title"
           caption="caption"
           url="https://ert.space" %}
```

Linking to another post:

```markdown
[part 2]({{ site.baseurl }}{% post_url yyyy-mm-dd-post-file-name %})
```

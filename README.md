### ⚠️ This repository has moved to [ionathanch.gitlab.io](https://gitlab.com/ionathanch/ionathanch.gitlab.io/). ⚠️

<hr/>

## Building
1. Install the [correct version](https://pages.github.com/versions/) of Ruby.
2. `make install`
3. `make`

## Theme changes to Hydeout
Most of these changes are marked with a comment indicating where the original was modified.
* Added profile picture to `_includes/sidebar.html`
* Removed category links with blank `_includes/category-links.html`
* Removed related posts with blank `_includes/related_posts.html`
* `_includes/custon-icon-links.html` contains an icon
* `_includes/custom-head.html` adds LaTeX support via KaTeX using `katex: true`
* `_includes/font-includes.html` removes loaded font from Hydeout theme
* NEW: `_includes/image.html` provides an `include` that adds image captions below images
* NEW: `blog/index.html` is a page containing blog posts, with a list of categories copied from `_layouts/category.html`
* NEW: `category/index.html` is a hidden placeholder page with a list of categories copied from above
* NEW: `assets/css/fonts.scss` loads fonts if not present locally
* Moved pagination buttons to below page content in `_layouts/index.html`
* Added option to display longer page title than in the sidebar to `_layouts/page.html` using `long_title`
* Added option to display alternate tab title `tab_title` and Open Graph meta tags to `_includes/head.html`
* Added image caption styling, custom fonts, and widened column in `assets/css/main.scss`

### Special assets
* Sidebar profile picture: Add the relative path of the image to `_config.yml` under `profile`
* KaTeX script: Add the relative path of `katex.min.js` to `_config.yml` under `katex.js_path`

### Images with captions
To add an image with a caption, use the following code, replacing the content within the [brackets]:

```liquid
{% include image.html
           img="[relative path to image]"
           caption="[caption]"
           title="[hovertext]"
           url="[URL]" %}
```

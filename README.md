# Building
1. Install the [correct version](https://pages.github.com/versions/) of Ruby.
2. `make install`
3. `make`

# Theme changes to Hydeout
Most of these changes are marked with a comment indicating where the original was modified.
* Added profile picture to `_includes/sidebar.html`
* Removed category links from `_includes/sidebar-nav-links.html`
* Removed comments and related posts from `_includes/post.html`
* `_includes/custon-icon-links.html` contains an icon
* NEW: `_includes/image.html` provides an `include` that adds image captions below images
* NEW: `_includes/custom-head.html` adds LaTeX support via KaTeX using `katex: true`
* Added image caption styling and made title font smaller in `assets/css/main.scss`
* NEW: `blog/index.html` is a page containing blog posts, with a list of categories copied from `_layouts/category.html`
* Added option to display longer page title than in the sidebar to `_layouts/page.html`
* Moved pagination buttons to below page content in `_layouts/index.html`

## Sidebar profile picture
Add the relative path of the image to `_config.yml` under `profile`.

## Images with captions
To add an image with a caption, use the following code, replacing the content within the [brackets]:

```liquid
{% include image.html
           img="[relative path to image]"
           caption="[caption]" %}
```
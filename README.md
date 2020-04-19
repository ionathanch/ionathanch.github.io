# Building
Assuming `jekyll` and `bundler` have been installed in a Ruby environment, run `bundle install` to install Gems, then run `bundle exec jekyll serve` to build and host the site.

# Theme changes to Hydeout
Most of these changes are marked with a comment indicating where the original was modified.
* Added profile picture to `_includes/sidebar.html`
* Removed category links from `_includes/sidebar-nav-links.html`
* `_includes/custon-icon-links.html` contains social media links
* NEW: `_includes/image.html` provides an `include` that adds image captions below images
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
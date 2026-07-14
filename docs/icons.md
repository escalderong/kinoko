# Icons

Kinoko renders all icons through [FontAwesome Free](https://fontawesome.com/search?ic=free), served as a static asset by Propshaft. There are no SVG files in the repo — every icon is a one-liner helper call.

## Usage

```slim
= icon("trash")
```

renders:

```html
<i class="fa-solid fa-trash" aria-hidden="true"></i>
```

### Signature

```ruby
icon(name, style: :solid, **html_attrs)
```

| Argument | Default | Description |
|---|---|---|
| `name` | — | FontAwesome icon slug, without the `fa-` prefix (e.g. `"trash"`, `"circle-check"`) |
| `style:` | `:solid` | `:solid`, `:regular`, or `:brands` |
| `**html_attrs` | — | Any HTML attribute, passed straight to the tag (`class:`, `data:`, `id:`, `"aria-hidden":`, etc.) |

Defined in `app/helpers/icons_helper.rb`. Since it's a plain Rails helper, it's available in every view without an explicit include.

### Examples

```slim
= icon("plus")
= icon("github", style: :brands)
= icon("circle-check", class: "text-success text-lg")
= icon("gear", data: { controller: "dropdown" })
```

## Finding icon names

Browse [fontawesome.com/search](https://fontawesome.com/search), filter to **Free**, and use the slug shown there (drop the `fa-` prefix — the helper adds it). Only Free icons are installed; Pro-only icons will render as a blank/missing glyph (tofu box) since their font files aren't shipped.

Styles map to real FontAwesome prefixes:

| `style:` | Renders as |
|---|---|
| `:solid` (default) | `fa-solid` |
| `:regular` | `fa-regular` |
| `:brands` | `fa-brands` |

Passing anything else raises `ArgumentError`.

## Sizing

Icons are webfont glyphs (`<i>` tags), not SVGs — they size via `font-size`, not `height`/`width`. Tailwind's `h-4 w-4` etc. have **no effect** on them.

Use instead:

- Tailwind `text-*` utilities (`text-sm`, `text-lg`, `text-xl`, ...) — preferred, keeps sizing consistent with surrounding text
- FontAwesome's own size classes (`fa-xs`, `fa-sm`, `fa-lg`, `fa-xl`, `fa-2xl`, or `fa-1x` through `fa-10x`) if you need finer control

```slim
= icon("trash", class: "text-sm")
= icon("expand", class: "fa-lg")
```

## Color

Icons inherit color via `currentColor` automatically — no extra class needed. Use daisyUI/Tailwind semantic color utilities as you would for text:

```slim
= icon("trash", class: "text-error")
= icon("circle-check", class: "text-success")
```

This keeps icons correctly themed across every daisyUI theme the app supports (per-Commerce theming), since none of these are hardcoded colors.

## Accessibility

Icons default to `aria-hidden="true"` since they're almost always decorative, paired with adjacent visible text or a labeled control (button, link). If an icon is ever the **only** content of an interactive element (no visible text, no `aria-label` on the parent), override the default:

```slim
= icon("trash", "aria-hidden": false)
```

...but prefer adding an `aria-label` to the parent button/link instead of un-hiding the icon itself — the icon is still purely decorative even when it's the visual content.

## How it's wired up (asset pipeline)

FontAwesome Free ships as the npm package `@fortawesome/fontawesome-free` (see `package.json`). It is **not** run through the Tailwind CSS build — it's registered as a plain Propshaft asset path and linked directly:

- `config/initializers/assets.rb` registers the **package root** (not its `css/`/`webfonts/` subfolders individually) as a Propshaft asset path:

  ```ruby
  Rails.application.config.assets.paths << Rails.root.join("node_modules/@fortawesome/fontawesome-free")
  ```

  Registering the root — rather than `css/` and `webfonts/` separately — matters: FontAwesome's CSS references its webfonts with relative paths (`url(../webfonts/fa-solid-900.woff2)`), and Propshaft only resolves those correctly when the two directories stay siblings under one registered root.

- `app/views/layouts/_head.html.slim` links the compiled FontAwesome stylesheet directly:

  ```slim
  = stylesheet_link_tag "css/all.min", "data-turbo-track": "reload"
  ```

- **Why not `@import` it into `app/assets/tailwind/application.css`** (the same way `@plugin "daisyui"` is loaded)? Tailwind's CLI inlines `@import`ed CSS text into the compiled `tailwind.css`, but it doesn't rewrite or copy through relative `url()` references the way a full JS bundler would. Inlining FontAwesome's CSS that way would leave `url(../webfonts/...)` pointing at the wrong location once compiled, breaking every glyph. Keeping it as a separate Propshaft-served stylesheet avoids that entirely, at the cost of one extra `<link>` tag.

### Production / deploy note

Propshaft silently skips any `config.assets.paths` entry that doesn't exist on disk at `assets:precompile` time — it won't raise an error. Whatever deploy pipeline eventually gets set up for this app **must run `npm install` (or `npm ci`) before `bin/rails assets:precompile`**, or icons will 404 in production with no obvious error pointing at the cause.

## Testing

`spec/helpers/icons_helper_spec.rb` covers the helper: default style, style override, class/attribute pass-through, and the `aria-hidden` default. If you touch `IconsHelper#icon`, keep those passing.

## Migration history

Prior to FontAwesome, Kinoko used two separate hand-rolled inline-SVG icon mechanisms — an `IconsHelper` that rendered SVG partials per icon, and a second system where raw SVG path-data strings lived as Ruby constants (navbar and flash icons). Both were replaced in favor of a single FontAwesome-backed helper so that no SVG files need to live in the repo and any icon is a one-liner call.

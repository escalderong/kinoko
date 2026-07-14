# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# FontAwesome Free ships css/ and webfonts/ as siblings, with relative
# `url(../webfonts/...)` references between them. Registering the package ROOT
# (not its subfolders) preserves that structure so Propshaft's CssAssetUrls
# compiler can resolve and fingerprint the font url()s correctly.
#
# NOTE: if this path doesn't exist at `assets:precompile` time (e.g. `npm install`
# didn't run before precompile in a deploy pipeline), Propshaft silently skips it
# and icons will 404. Ensure npm install/ci runs before assets:precompile.
Rails.application.config.assets.paths << Rails.root.join("node_modules/@fortawesome/fontawesome-free")

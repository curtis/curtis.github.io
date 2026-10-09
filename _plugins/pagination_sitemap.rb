# Keep the paginated home pages (/page2/ onward) out of sitemap.xml.
# They are marked noindex in _includes/head.html.
Jekyll::Hooks.register :site, :pre_render do |site|
  site.pages.each do |page|
    page.data["sitemap"] = false if page.pager && page.pager.page > 1
  end
end

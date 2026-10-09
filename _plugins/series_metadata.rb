# Give series index pages a title and description from _data/series.yml,
# so jekyll-seo-tag does not fall back to the site-wide defaults.
# The payload already holds a copy of the page data by the time this hook
# runs, so both have to be updated.
Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  next unless page.data["layout"] == "series"

  series_info = page.site.data.dig("series", page.data["series"])
  next unless series_info

  %w[title description].each do |key|
    page.data[key] ||= series_info[key]
    payload["page"][key] ||= series_info[key]
  end
end

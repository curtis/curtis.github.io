# Map subtitle to description for jekyll-seo-tag.
# Subtitle is used as a short, hand-crafted meta description.
Jekyll::Hooks.register :documents, :pre_render do |doc|
  if doc.data["subtitle"] && !doc.data["description"]
    doc.data["description"] = doc.data["subtitle"]
  end
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  if page.data["subtitle"] && !page.data["description"]
    page.data["description"] = page.data["subtitle"]
  end
end

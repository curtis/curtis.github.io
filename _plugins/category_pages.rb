# Auto-generates a page for every category used in posts.
# Pulls name/description from _data/categories.yml when available.
module CategoryPages
  class CategoryPage < Jekyll::Page
    def initialize(site, slug, cat_info)
      @site = site
      @base = site.source
      @dir = slug
      @name = "index.html"

      process(@name)
      read_yaml(File.join(site.source, "_layouts"), "category.html")

      data["title"] = cat_info["name"] || slug.capitalize
      data["category"] = slug
      data["category_name"] = cat_info["name"] || slug.capitalize
      data["description"] = cat_info["description"] || ""
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      categories_data = site.data["categories"] || {}
      existing = site.pages.select { |p| p.data["layout"] == "category" }.map { |p| p.data["category"] }

      site.categories.each_key do |slug|
        next if existing.include?(slug)

        cat_info = categories_data[slug] || {}
        site.pages << CategoryPage.new(site, slug, cat_info)
      end
    end
  end
end

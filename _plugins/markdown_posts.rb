# Writes a Markdown copy of every post next to its HTML page, so AI agents
# can read the content without the nav, CTA, and footer around it.
# /posts/my-post/ gets a sibling at /posts/my-post.md, which the post links
# to with <link rel="alternate" type="text/markdown"> and llms.txt indexes.
require "nokogiri"
require "reverse_markdown"

module MarkdownPosts
  DROPPED = "script, style, noscript, td.gutter, td.rouge-gutter".freeze

  module_function

  def path_for(post)
    "#{post.url.chomp('/')}.md"
  end

  def render(post, html)
    site = post.site
    data = post.data

    lines = ["# #{data['title']}", ""]
    lines.push("> #{data['subtitle']}", "") if data["subtitle"]
    lines << "- Author: #{site.config['author']}"
    lines << "- Published: #{post.date.strftime('%Y-%m-%d')}"
    lines << "- Updated: #{Time.parse(data['last_modified_at'].to_s).strftime('%Y-%m-%d')}" if data["last_modified_at"]
    lines << "- Categories: #{data['categories'].join(', ')}" unless data["categories"].to_a.empty?
    lines << "- Canonical URL: #{site.config['url']}#{post.url}"
    lines.push("", body(html, site.config["url"]), "")
    lines.join("\n")
  end

  def body(html, site_url)
    doc = Nokogiri::HTML5.fragment(html)

    # Gist embeds are script tags with no content at build time, so leave a link
    doc.css("script[src*='gist.github.com']").each do |script|
      url = script["src"].sub(/\.js(\?.*)?\z/, "")
      script.replace(%(<p><a href="#{url}">Code sample on GitHub Gist</a></p>))
    end
    doc.css("iframe[src]").each do |frame|
      frame.replace(%(<p><a href="#{frame['src'].sub(%r{\A//}, 'https://')}">Embedded content</a></p>))
    end
    doc.css(DROPPED).each(&:remove)

    # Dead links keep their original URL in the title attribute
    doc.css(".dead-link[title]").each do |link|
      link.replace("#{link.text} (dead link: #{link['title']})")
    end

    %w[href src].each do |attr|
      doc.css("[#{attr}^='/']").each do |node|
        node[attr] = "#{site_url}#{node[attr]}" unless node[attr].start_with?("//")
      end
    end

    # Rebuild code blocks so the language survives and Rouge's spans do not.
    # reverse_markdown reads the language from a highlight-* class on the
    # element wrapping the pre.
    doc.css("pre").each do |pre|
      holder = pre.at_css("code[class*='language-']") || pre.ancestors("[class*='language-']").first
      language = holder && holder["class"][/language-(\w+)/, 1]
      wrapper = Nokogiri::XML::Node.new("div", doc)
      wrapper["class"] = "highlight-#{language}" if language
      fenced = Nokogiri::XML::Node.new("pre", doc)
      code = Nokogiri::XML::Node.new("code", doc)
      code.content = pre.text
      fenced.add_child(code)
      wrapper.add_child(fenced)
      pre.replace(wrapper)
    end

    ReverseMarkdown.convert(doc.to_html, github_flavored: true, unknown_tags: :bypass).strip
  end
end

markdown_posts = {}

Jekyll::Hooks.register :site, :after_reset do |_site|
  markdown_posts.clear
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  post.data["markdown_url"] = MarkdownPosts.path_for(post)
end

# post_convert sees the post's own HTML before any layout wraps it
Jekyll::Hooks.register :posts, :post_convert do |post|
  markdown_posts[MarkdownPosts.path_for(post)] = MarkdownPosts.render(post, post.content)
end

Jekyll::Hooks.register :site, :post_write do |site|
  markdown_posts.each do |path, markdown|
    dest = File.join(site.dest, path)
    FileUtils.mkdir_p(File.dirname(dest))
    File.write(dest, markdown)
  end
  Jekyll.logger.info "Markdown:", "Wrote #{markdown_posts.size} post copies"
end

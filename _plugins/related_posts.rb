# Picks up to three related posts for each post, exposed as page.related.
# Posts that share the most categories come first, and ties go to the post
# published closest in time. Posts in the same series are skipped because
# the series nav already links them.
class RelatedPosts < Jekyll::Generator
  safe true
  LIMIT = 3

  def generate(site)
    posts = site.posts.docs

    posts.each do |post|
      categories = post.data["categories"] || []
      series = post.data["series"]

      scored = posts.filter_map do |other|
        next if other.equal?(post)
        next if series && other.data["series"] == series

        shared = (categories & (other.data["categories"] || [])).size
        next if shared.zero?

        [other, shared]
      end

      post.data["related"] = scored
        .sort_by { |other, shared| [-shared, (other.date - post.date).abs] }
        .first(LIMIT)
        .map(&:first)
    end
  end
end

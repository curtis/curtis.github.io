# Reading time filter that accounts for code blocks and gist embeds.
# Prose: 200 wpm, code: 100 wpm, gists: +1 min each.
module ReadingTime
  def reading_time(content)
    # Count gist embeds (loaded via JS, no content at build time)
    gists = content.scan(/gist\.github\.com/).length

    # Separate code blocks from prose
    code_content = content.scan(/<pre[\s>].*?<\/pre>/m).join(" ")
    prose = content.gsub(/<pre[\s>].*?<\/pre>/m, "")

    # Strip HTML tags and count words
    prose_words = remove_tags(prose).split.length
    code_words = remove_tags(code_content).split.length

    seconds = (prose_words.to_f / 200 * 60) +
              (code_words.to_f / 100 * 60) +
              (gists * 60)

    [1, (seconds / 60.0).ceil].max
  end

  private

  def remove_tags(text)
    text.gsub(/<[^>]*>/, " ")
  end
end

Liquid::Template.register_filter(ReadingTime)

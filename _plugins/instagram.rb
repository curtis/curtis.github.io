require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

Jekyll::Hooks.register :site, :after_init do |site|
  token_file = File.join(site.source, '.instagram_token')
  token = if File.exist?(token_file)
            File.read(token_file).strip
          else
            ENV['INSTAGRAM_TOKEN']
          end
  next unless token && !token.empty?

  data_file = File.join(site.source, '_data', 'instagram.json')
  photo_dir = File.join(site.source, 'img', 'instagram')

  # Skip if the data file was updated in the last hour
  if File.exist?(data_file)
    age = Time.now - File.mtime(data_file)
    if age < 3600
      Jekyll.logger.info "Instagram:", "Using cached feed (#{(age / 60).to_i}m old)"
      next
    end
  end

  Jekyll.logger.info "Instagram:", "Fetching photos..."

  begin
    uri = URI("https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count&limit=24&access_token=#{token}")
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      Jekyll.logger.warn "Instagram:", "API returned #{response.code} -- skipping"
      next
    end

    data = JSON.parse(response.body)

    if data['error']
      Jekyll.logger.warn "Instagram:", "API error: #{data['error']['message']}"
      next
    end

    photos = (data['data'] || []).select { |p| %w[IMAGE CAROUSEL_ALBUM].include?(p['media_type']) }
    FileUtils.mkdir_p(photo_dir)

    result = photos.map do |p|
      # Download the image if we don't have it yet
      filename = "#{p['id']}.jpg"
      local_path = File.join(photo_dir, filename)

      unless File.exist?(local_path)
        Jekyll.logger.info "Instagram:", "Downloading #{filename}..."
        img_uri = URI(p['media_url'])
        img_response = Net::HTTP.get_response(img_uri)
        if img_response.is_a?(Net::HTTPSuccess)
          File.binwrite(local_path, img_response.body)
        else
          Jekyll.logger.warn "Instagram:", "Failed to download #{filename}"
        end
      end

      {
        'id' => p['id'],
        'caption' => p['caption'] || '',
        'url' => "/img/instagram/#{filename}",
        'permalink' => p['permalink'],
        'timestamp' => p['timestamp'],
        'likes' => p['like_count'] || 0,
        'comments' => p['comments_count'] || 0
      }
    end

    FileUtils.mkdir_p(File.dirname(data_file))
    File.write(data_file, JSON.pretty_generate(result))
    Jekyll.logger.info "Instagram:", "Saved #{result.length} photos"

    # Also try to refresh the token
    refresh_uri = URI("https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=#{token}")
    refresh_response = Net::HTTP.get_response(refresh_uri)
    if refresh_response.is_a?(Net::HTTPSuccess)
      refresh_data = JSON.parse(refresh_response.body)
      if refresh_data['access_token']
        Jekyll.logger.info "Instagram:", "Token refreshed (expires in #{refresh_data['expires_in'] / 86400} days)"
      end
    end
  rescue StandardError => e
    Jekyll.logger.warn "Instagram:", "Failed to fetch: #{e.message}"
  end
end

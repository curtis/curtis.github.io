require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

def api_error(response)
  JSON.parse(response.body).dig('error', 'message') || response.body.to_s[0, 200]
rescue StandardError
  response.body.to_s[0, 200]
end

def oauth_error?(response)
  JSON.parse(response.body).dig('error', 'type') == 'OAuthException'
rescue StandardError
  false
end

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
      Jekyll.logger.warn "Instagram:", "API returned #{response.code}: #{api_error(response)}"
      Jekyll.logger.warn "Instagram:", "The token is dead and cannot be refreshed. Generate a new one and put it in .instagram_token" if oauth_error?(response)
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

    # Extend the token. A long lived token lasts 60 days and can only be
    # refreshed while it is still valid, so this has to run on every build and
    # the new value has to be written back. Logging success without saving it is
    # how the last one quietly expired.
    refresh_uri = URI("https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=#{token}")
    refresh_response = Net::HTTP.get_response(refresh_uri)
    if refresh_response.is_a?(Net::HTTPSuccess)
      refresh_data = JSON.parse(refresh_response.body)
      if refresh_data['access_token']
        days = refresh_data['expires_in'].to_i / 86400
        if File.exist?(token_file)
          File.write(token_file, refresh_data['access_token'])
          Jekyll.logger.info "Instagram:", "Token refreshed and saved (expires in #{days} days)"
        else
          Jekyll.logger.warn "Instagram:", "Token refreshed (expires in #{days} days) but INSTAGRAM_TOKEN is an env var, so it cannot be saved. Update it manually."
        end
      end
    else
      Jekyll.logger.warn "Instagram:", "Token refresh failed: #{api_error(refresh_response)}"
    end
  rescue StandardError => e
    Jekyll.logger.warn "Instagram:", "Failed to fetch: #{e.message}"
  end
end

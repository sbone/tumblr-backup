require 'dotenv'
require 'tumblr_client'
require 'json'
require 'pry'
require 'open-uri'
require 'ruby-progressbar'
require 'whirly'
require 'date'

Dotenv.load

Tumblr.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

@downloads_enabled = ENV['DOWNLOADS_ENABLED']

# the hash to be saved into JSON file
@postsHash = {}

# offset count for pagination
@posts_offset = 0

def request_posts(offset)
  client = Tumblr::Client.new
  client.posts(ENV['TUMBLR_URL'], offset: offset)
end

# initial request
@posts_whole = request_posts(@posts_offset)

# save total post count
@total_posts_count = @posts_whole['total_posts']

# setup progressbar!
@progressbar = ProgressBar.create(
  title: 'Posts Backed Up',
  total: @total_posts_count,
  format: '  %p%% (%c/%C) %t'
)

# track progress
@saved_posts_count = 0

# tumblr limits responses to 20 posts
@tumblr_response_limit = 20

# set posts to process
@posts = @posts_whole['posts']

# timeout (in seconds) for photo downloads
@request_timeout = 60

def get_file_extension(filename)
  filename.split(//).last(3).join('').to_s
end

def write_file(full_path)
  File.open(full_path, 'wb') do |f|
    f.write open(url, read_timeout: @request_timeout).read
  end
end

def download_photo(url, filename)
  request_url_filename = url.split('/')[4].split('\.', -1)[0]
  file_extension = get_file_extension(request_url_filename)
  write_file("data/images/#{filename}.#{file_extension}")
end

def download_video(url, filename)
  request_url_filename = url.split('/')[3].split('\.', -1)[0]
  file_extension = get_file_extension(request_url_filename)
  write_file("data/videos/#{filename}.#{file_extension}")
end

def extract_filename(photo_url)
  filename_regex = %r{/[^/]*$/}
  filename_regex.match(photo_url)
end

def process_photos(post)
  photos = post['photos']
  photos_array = []
  photos.each do |photo|
    if @downloads_enabled
      pretty_timestamp = Time.at(post['timestamp']).strftime('%Y-%m-%e | %k%M%p')
      download_photo(photo['original_size']['url'], pretty_timestamp)
    end
    photo['original_size']['url'] = extract_filename(photo['original_size']['url'])
    photos_array.push(photo['original_size'])
  end

  photos_array
end

def process_video(post)
  video_url = ''
  if post['video_url'].nil?
    puts "TODO: download this externally hosted video #{post['permalink_url']}"
  else
    video_url = post['video_url']
    if @downloads_enabled
      pretty_timestamp = Time.at(post['timestamp']).strftime('%Y-%m-%e | %k%M%p')
      download_video(video_url, pretty_timestamp)
    end
  end

  video_url
end

def process_posts(posts)
  posts.each do |post|
    timestamp = post['timestamp']
    caption = post['caption']
    post_type = post['type']

    @postsHash[post['id']] = {
      'timestamp': timestamp,
      'type': post_type,
      'caption': caption
    }

    if post_type == 'photo'
      @postsHash[post['id']]['photos'] = process_photos(post)
    elsif post_type == 'video'
      # save video type - 'embed' or 'file'?
      @postsHash[post['id']]['video'] = process_video(post)
    elsif post_type == 'chat'
      @postsHash[post['id']]['dialogue'] = post['dialogue']
    end

    @saved_posts_count += 1

    @progressbar.increment

    if @saved_posts_count == @posts_offset + @tumblr_response_limit
      @posts_offset += @tumblr_response_limit
      request_next_page(@posts_offset)
    elsif @saved_posts_count == @total_posts_count
      Whirly.stop
      posts_to_json(@postsHash)
      return
    end
  end

end

def request_next_page(offset)
  @next_page = request_posts(offset)
  process_posts(@next_page['posts'])
end

def posts_to_json(hash)
  File.open('data/posts.json', 'w') do |f|
    f.write(JSON.pretty_generate(hash))
  end
end

# Let's begin!
# Whirly.start(spinner: 'pencil')
process_posts(@posts)


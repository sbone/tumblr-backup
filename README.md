# Tumblr Backup

Ruby script to backup a photo-and-video-centric Tumblog locally.

Post contents are saved in `/data/:media_type:/`
Key post data is written to `/data/posts.json`

## Usage

Within locally cloned repo:

1. `cp .env.example .env`
1. `bundle install`
1. `ruby tumblr.rb`

## Next Steps

- [x] download images locally
- [x] format posts photo urls to match local photo filenames
- [ ] prevent posts from being re-read each usage
- [ ] handle video/non-photo posts
- [ ] make filenames useful

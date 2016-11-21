# Tumblr Backup

My wife and I share a blog on Tumblr to share photos of our son with friends and family. It's been an amazing platform, but I've felt remiss not having a local backup.

As a V1, key post data is being written to `data/posts.json`.

## Usage

Within locally cloned repo:

1. `bundle install`
2. `ruby tumblr.rb`

## Next Steps

- [x] download images locally
- [ ] format posts photo urls to match local photo filenames
- [ ] prevent posts from being re-read each usage
- [ ] handle video/non-photo posts

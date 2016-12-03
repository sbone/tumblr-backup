# Tumblr Backup

My wife and I share a blog on Tumblr to share photos of our son with friends and family. It's been an amazing platform, but I've felt remiss not having a local backup.

As a V1, key post data is being written to `data/posts.json`.

## Usage

Within locally cloned repo:

1. `touch .env`
1. populate `.env`: 
 
	```
	CONSUMER_KEY='{your-consumer-key}'
	CONSUMER_SECRET='{your-consumer-secret}'
	OAUTH_TOKEN='{your-oauth-token}'
	OAUTH_TOKEN_SECRET='{your-token-secret}'
	TUMBLR_URL='{your-tumblr-url}'
	```

1. `bundle install`
1. `ruby tumblr.rb`

## Next Steps

- [x] download images locally
- [x] format posts photo urls to match local photo filenames
- [ ] prevent posts from being re-read each usage
- [ ] handle video/non-photo posts

request = require 'request'
rockets = require 'rockets'

module.exports = class Client

  constructor: (config) ->
    @client = new rockets()
    @config = config


  # Plaintext fallback for IRC clients and mobile notifications.
  fallback: (type) ->
    return "A relevant #{type} was just created on reddit.com"


  # Builds a Reddit URL.
  url: (parts...) ->
    return 'https://reddit.com/' + parts.join('/').replace(/\/$/, '')


  # Determines which search terms matched given content.
  matched: (content, search) ->
    matches = []

    for term in [].concat(search)
      match = (new RegExp(term, 'i')).exec(content)
      if match?[0] then matches.push(match[0])

    return matches.join(', ')


  # Formats a comment payload
  formatComment: (comment) ->
    if not comment then return false

    post = comment.link_id[3...]
    link = @url('r', comment.subreddit, 'comments', post, '_', comment.id)

    fields = [
      {
          title: 'Subreddit'
          value: "<#{@url('r', comment.subreddit)}|#{comment.subreddit}>"
          short: true
        },
        {
          title: 'User'
          value: "<#{@url('u', comment.author)}|#{comment.author}>"
          short: true
        },
        {
          title: 'Link'
          value: link
          short: true
        },
    ]

    # These are the search terms in the "contains" rule.
    search = @config.channels.comments.include?.contains

    # Only show matched search terms if there were search terms.
    if search?.length
      fields.push {
        title: 'Matched'
        value: @matched(comment.body, search)
        short: true
      }

    return {
      color       : @config.channels.comments.color or '#336699'
      fallback    : @fallback 'comment'
      title       : 'Comment'
      title_link  : link
      text        : comment.body
      fields      : fields
    }


  # Builds a post payload
  formatPost: (post) ->
    if not post then return false

    fields = [
      {
        title: 'Content'
        value: if post.is_self then post.selftext else post.url
        short: false
      },
      {
        title: 'Subreddit'
        value: "<#{@url('r', post.subreddit)}|#{post.subreddit}>"
        short: true
      },
      {
        title: 'User'
        value: "<#{@url('u', post.author)}|#{post.author}>"
        short: true
      },
      {
        title: 'Link'
        value: @url(post.permalink)
        short: true
      }
    ]

    # These are the search terms in the "contains" rule.
    search = @config.channels.posts.include?.contains

    # Only show matched search terms if there were search terms.
    if search?.length
      fields.push {
        title: 'Matched'
        value: @matched("#{post.selftext} #{post.title}", search)
        short: true
      }

    return {
      color       : @config.channels.posts.color or '#ff4500'
      fallback    : @fallback 'post'
      title       : post.title
      title_link  : @url(post.permalink)
      fields      : fields
    }


  # Sends attachment data to Slack
  sendToSlack: (data) ->
    for hook in [].concat(@config.webhook)
      request
        method: 'POST'
        url: hook
        json:
          attachments: [
            data
          ]


  # Subscribes to channels and starts listening for events.
  run: () ->
    # When a relevant comment is received
    @client.on 'comment', (model) =>
      @sendToSlack @formatComment(model?.data)

    # When a relevant post is received
    @client.on 'post', (model) =>
      @sendToSlack @formatPost(model?.data)

    # When the socket connection is established
    @client.on 'connect', () =>

      # Subscribe to receive comments
      if @config.channels?.comments
        include = @config.channels.comments.include
        exclude = @config.channels.comments.exclude

        @client.subscribe 'comments', include, exclude

      # Subscribe to receive posts
      if @config.channels?.posts
        include = @config.channels.posts.include
        exclude = @config.channels.posts.exclude

        @client.subscribe 'posts', include, exclude

    # Attempt to connect to the server
    @client.connect()

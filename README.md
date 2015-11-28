![Rockets](header.gif) [![Author](http://img.shields.io/badge/author-@rudi_theunissen-336699.svg?style=flat-square)](https://twitter.com/rudi_theunissen) [![Version](https://img.shields.io/npm/v/rockets.svg?style=flat-square)](https://www.npmjs.com/package/rockets-slack) [![Dependencies](https://img.shields.io/david/rockets/slack.svg?style=flat-square)](https://david-dm.org/rockets/slack)

---

This is a Slack integration client for [rockets/rockets](https://github.com/rockets/rockets).

## Installation

```bash
npm install rockets-slack
```

## Usage

```js
var RocketsSlack = require('rockets-slack');

var config = {

    // Slack webhook URL
    webhook: "https://hooks.slack.com/services/*/*/*",

    // Channel subscriptions
    channels: {
        
        // Configuration for post events
        posts: {

            // Highlight color in Slack for posts
            color: "#ff4500"

            // Filtering rules for posts
            include: {},
            exclude: {}
        },

        // Configuration for comment events
        comments: {

            // Highlight color in Slack for comments
            color: "#336699"

            // Filtering rules for comments
            include: {},
            exclude: {}
        }
    }
};

var client = new RocketsSlack(config);

// Establish a connection and start listening for events.
client.run();
```

## Filters

See [rockets/rockets](https://github.com/rockets/rockets) for a complete list of filtering rules.

## Credits

Illustrations by Ken Samonte.

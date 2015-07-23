# Description
#   teaches the character to the hubot.
#
# Configuration:
#   REDIS_URL
#
# Commands:
#   hubot learn <keyword> <info> - hobot will remember the infomation. 
#   hubot say <keyword> - hubot will tell what you saved information in hubot learn
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   jun85664396@gmail.com

Redis = require "redis"
Url   = require "url"

module.exports = (robot) ->
  url = if process.env.REDIS_URL?
          process.env.REDIS_URL
        else
          "redis://localhost:6379"
  urlInfo = Url.parse url, true
  redisClient = if urlInfo.auth then Redis.createClient(urlInfo.port, urlInfo.hostname, {no_ready_check: true}) else Redis.createClient(urlInfo.port, urlInfo.hostname)

  learn = (key, data)->
    redisClient.set "#{key}:memory", data
    if !(key?)
      return "I need a keyword"
    else if !(data?)
      return "I need a infomation, Learn rule keyword 'infomation' "
    else
      return "I learn #{key}"

  say = (key, callback)->
    redisClient.get "#{key}:memory", (err, reply) ->
      if reply?
        callback reply.toString()
      else
        callback "I don't know keyword"

  robot.respond /learn (.*)$/i, (msg) ->
    data = msg.match[1].split(" ")
    msg.send learn data[0], data.slice(1, data.length).join(" ")

  robot.respond /say (.*)$/i, (msg) ->
    say msg.match[1], (data)->
      msg.send data

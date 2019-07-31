require 'fastlane/action'
require_relative '../helper/wechat_helper'

module Fastlane
  module Actions
    class WechatAction < Action
      require 'net/https'
      require 'json'

      def self.run(params)
        access_token = params[:access_token]
        access_token_url = params[:access_token_url]
        agentid = params[:agentid]
        secret = params[:secret]
        recievers = params[:recievers]
        send_message_url = params[:send_message_url]
        msgtype = params[:msgtype]
        text = params[:text]
        articles = params[:articles]

        unless access_token
          access_token = request_access_token(access_token_url, agentid, secret)
          UI.important "[WechatAction] request access_token: #{access_token}"
        end

        msg_uri = URI(send_message_url)
        headers = {
          'token' => access_token,
          'agentid' => agentid,
          'Content-Type' => 'application/json'
        }
        body = {}
        body['touser'] = recievers.join('|')
        body['msgtype'] = msgtype

        # 1、文本类型
        # {
        #   "msgtype": "text",
        #   "text": {
        #       "content": "广州今日天气：29度，大部分多云，降雨概率：60%",
        #       "mentioned_list":["wangqing","@all"],
        #       "mentioned_mobile_list":["13800001111","@all"]
        #   }
        # }
        if msgtype == 'text'
          body['text'] = {
            'content' => text
          }
        end

        # 2、markdown类型
        # {
        #   "msgtype": "markdown",
        #   "markdown": {
        #     "content": "实时新增用户反馈<font color=\"warning\">132例</font>，请相关同事注意。\n
        #       >类型:<font color=\"comment\">用户反馈</font> \n
        #       >普通用户反馈:<font color=\"comment\">117例</font> \n
        #       >VIP用户反馈:<font color=\"comment\">15例</font>"
        #   }
        # }
        if msgtype == 'markdown'
          body['markdown'] = {
            "content" => text
          }
        end


        # 3、图片类型
        # {
        #   "msgtype": "image",
        #   "image": {
        #     "base64": "DATA",
        #     "md5": "MD5"
        #   }
        # }
        if msgtype == 'image'
          body['image'] = {
            'content' => text
          }
        end

        # 4、图文类型
        # {
        #   "msgtype": "news",
        #   "news": {
        #     "articles" : [
        #       {
        #       "title" : "中秋节礼品领取",
        #       "description" : "今年中秋节公司有豪礼相送",
        #       "url" : "URL",
        #       "picurl" : "http://res.mail.qq.com/node/ww/wwopenmng/images/independent/doc/test_pic_msg1.png"
        #       }
        #     ]
        #   }
        # }
        if msgtype == 'news'
          body['news'] = {
            'articles' => articles
          }
        end

        # UI.success(body)
        req = Net::HTTP::Post.new(msg_uri, headers)
        req.body = body.to_json
        Net::HTTP.new(msg_uri.host, msg_uri.port).start do |http|
          http.request(req)
        end
      end

      def self.request_access_token(url, agentid, secret)
        token_uri = URI(url)
        req = Net::HTTP::Get.new(token_uri)
        req['agentid'] = agentid.to_s
        req['secret'] = secret.to_s
        res = Net::HTTP.start(token_uri.hostname, token_uri.port) do |http|
          http.request(req)
        end
        JSON.parse(res.body)["access_token"]
      end

      def self.description
        "this is a wechat api wrapper"
      end

      def self.details
        "send message via enterprice wechat server api"
      end

      def self.authors
        ["xiongzenghui"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :access_token,
            description: "wechat access token",
            type: String,
            optional: true,
            conflicting_options: [:access_token_url, :secret]
          ),
          FastlaneCore::ConfigItem.new(
            key: :access_token_url,
            description: "request wechat access token url",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :agentid,
            description: "agentid param for request wechat access token",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :secret,
            description: "secret param for request wechat access token",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :recievers,
            description: "how many man to receive this message",
            type: Array,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :text,
            description: "wechat message text",
            type: String,
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :msgtype,
            description: "wechat message type, eg: markdown、text、image、news",
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :send_message_url,
            description: "send message to wechat server api url",
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :articles,
            description: "news articles",
            type: Array,
            optional: true,
            conflicting_options: [:text]
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
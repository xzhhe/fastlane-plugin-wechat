require 'fastlane/action'
require_relative '../helper/wechat_helper'

module Fastlane
  module Actions
    class WechatAction < Action
      require 'net/http'
      require 'net/https'
      require 'json'

      def self.run(params)
        if params[:webhook]
          retry_times(3) { send_with_webhook(params) }
        else
          retry_times(3) { send_with_token(params) }
        end
      end

      def self.send_with_webhook(params = {})
        msgtype = params[:msgtype]
        text = params[:text]

        url = URI(params[:webhook])
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == 'https'

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = 'application/json'
        request.body = http_body(params)

        puts http.request(request).body
      end

      def self.send_with_token(params = {})
        access_token_url = params[:access_token_url]
        agentid = params[:agentid]
        secret = params[:secret]
        send_message_url = params[:send_message_url]

        access_token = request_access_token(access_token_url, agentid, secret)
        UI.important "[WechatAction] request access_token: #{access_token}"

        msg_uri = URI(send_message_url)
        http = Net::HTTP.new(msg_uri.host, msg_uri.port)
        http.use_ssl = true if msg_uri.scheme == 'https'

        headers = {
          'token' => access_token,
          'agentid' => agentid,
          'Content-Type' => 'application/json'
        }

        request = Net::HTTP::Post.new(msg_uri, headers)
        request.body = http_body(params)
        puts http.request(request).body
      end

      def self.request_access_token(url, agentid, secret)
        token_uri = URI(url)

        http = Net::HTTP.new(token_uri.host, token_uri.port)
        http.use_ssl = true if token_uri.scheme == 'https'

        request = Net::HTTP::Get.new(token_uri)
        request['agentid'] = agentid.to_s
        request['secret'] = secret.to_s

        # resp = Net::HTTP.start(token_uri.hostname, token_uri.port) do |http|
        #   http.request(request)
        # end
        # JSON.parse(resp.body)["access_token"]

        resp = http.request(request)
        JSON.parse(resp.body)["access_token"]
      end

      def self.http_body(params = {})
        recievers = params[:recievers]
        mentioned_list = params[:mentioned_list]
        msgtype = params[:msgtype]
        text = params[:text]
        articles = params[:articles]

        body = {}
        body['msgtype'] = msgtype

        unless params[:webhook]
          body['touser'] = recievers.join('|')
        end

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
            'content' => text,
            'mentioned_list' => mentioned_list
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
            "content" => text,
            'mentioned_list' => mentioned_list
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
            'content' => text,
            'mentioned_list' => mentioned_list
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
            'articles' => articles,
            'mentioned_list' => mentioned_list
          }
        end

        body.to_json
      end

      def self.retry_times(times, &block)
        tries = 1
        begin
          block.call
        rescue Exception => e
          tries += 1
          retry if tries <= times

          puts "❌ Over #{times} times failed"
          puts "❗️ Exception messgae:"
          puts e.class
          puts e.message
          puts "❗️ Exception backtrace:"
          puts e.backtrace.inspect
        end
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
            key: :webhook,
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
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :mentioned_list,
            description: "mentioned_list",
            type: Array,
            optional: true
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

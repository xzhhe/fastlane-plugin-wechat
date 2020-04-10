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

      def self.send_with_webhook(params)
        webhook = params[:webhook]
        agentid = params[:agentid]

        url = URI(webhook)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == 'https'

        headers = { 'Content-Type' => 'application/json' }
        headers['agentid'] = agentid if agentid
        request = Net::HTTP::Post.new(url, headers)

        request.body = http_body(params)
        puts http.request(request).body
      end

      def self.send_with_token(params)
        access_token_url = params[:access_token_url]
        secret = params[:secret]
        agentid = params[:agentid]
        send_message_url = params[:send_message_url]

        access_token = request_access_token(access_token_url, agentid, secret)
        UI.important "[WechatAction] access_token: #{access_token}"

        msg_uri = URI(send_message_url)
        http = Net::HTTP.new(msg_uri.host, msg_uri.port)
        http.use_ssl = true if msg_uri.scheme == 'https'

        headers = {
          'Content-Type' => 'application/json',
          'token' => access_token,
          'agentid' => agentid
        }

        request = Net::HTTP::Post.new(msg_uri, headers)
        request.body = http_body(params)
        puts http.request(request).body
      end

      def self.http_body(params)
        msgtype = params[:msgtype]
        msgcontent = params[:msgcontent]
        touser = params[:touser]
        mentioned_list = params[:mentioned_list]

        body = {}
        body['msgtype'] = msgtype
        body['touser'] = touser.join('|') if touser

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
          text = { 'content' => msgcontent }
          text['mentioned_list'] = mentioned_list if mentioned_list

          body['text'] = text
        end

        # 2、markdown类型
        # {
        #   "touser": ["userid1", "userid2", "CorpId1/userid1", "CorpId2/userid2"],
        #   "toparty": ["partyid1", "partyid2", "LinkedId1/partyid1", "LinkedId2/partyid2"],
        #   "totag": ["tagid1", "tagid2"],
        #   "toall": 0,
        #   "msgtype": "markdown",
        #   "agentid": 1,
        #   "markdown": {
        #     "content": "您的会议室已经预定，稍后会同步到`邮箱` >
        #       ** 事项详情 **
        #       >
        #       事　 项： < font color = \"info\">开会</font> >
        #       组织者： @miglioguan >
        #       参与者： @miglioguan、 @kunliu、 @jamdeezhou、 @kanexiong、 @kisonwang >
        #       >
        #       会议室： < font color = \"info\">广州TIT 1楼 301</font> >
        #       日　 期： < font color = \"warning\">2018年5月18日</font> >
        #       时　 间： < font color = \"comment\">上午9:00-11:00</font> >
        #       >
        #       请准时参加会议。 >
        #       >
        #       如需修改会议信息， 请点击：[修改会议信息](https: //work.weixin.qq.com)"
        #   }
        # }
        if msgtype == 'markdown'
          markdown = {}
          if mentioned_list
            m_mentioned_list = mentioned_list.map {|e| "@#{e.strip}"}.join(", ")
            msgcontent.concat("\n#{m_mentioned_list}")
          end
          markdown['content'] = msgcontent

          body['markdown'] = markdown
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
          image = { 'content' => msgcontent }
          image['mentioned_list'] = mentioned_list if mentioned_list

          body['image'] = image
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
          articles = params[:articles]
          news = { 'articles' => articles }
          news['mentioned_list'] = mentioned_list if mentioned_list

          body['news'] = news
        end

        body.to_json
      end

      def self.request_access_token(url, agent_id, secret)
        token_uri = URI(url)

        http = Net::HTTP.new(token_uri.host, token_uri.port)
        http.use_ssl = true if token_uri.scheme == 'https'

        request = Net::HTTP::Get.new(token_uri)
        request['agentid'] = agent_id.to_s
        request['secret'] = secret.to_s

        resp = http.request(request)
        JSON.parse(resp.body)["access_token"]
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
            key: :touser,
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
            key: :msgcontent,
            description: "wechat message text",
            type: String,
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :articles,
            description: "news articles",
            type: Array,
            optional: true,
            conflicting_options: [:msgcontent]
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
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end

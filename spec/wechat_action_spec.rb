describe Fastlane::Actions::WechatAction do
  describe '#run' do
    it 'request_access_token' do
      puts Fastlane::Actions::WechatAction.request_access_token(
        'http://smsc.in.zhihu.com/token', 
        '10024', 
        'dccae6ea9369a64d5131cfcf0e75a045'
      )
    end

    it 'http_body - text' do
      pp Fastlane::Actions::WechatAction.http_body(
        recievers: ['xiongzenghui'],
        msgtype: 'text',
        text: "haha ~"
      )
    end

    it 'http_body - mardown' do
      pp Fastlane::Actions::WechatAction.http_body(
        recievers: ['xiongzenghui'],
        msgtype: 'markdown',
        text: "## ✅ build success \n \n> 1. ........ \n> 2. .......... \n> 3. ........"
      )
    end

    it 'http_body - text - webhook' do
      pp Fastlane::Actions::WechatAction.http_body(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxx',
        recievers: ['xiongzenghui'],
        msgtype: 'text',
        text: "haha ~"
      )
    end

    it 'http_body - mardown - webhook' do
      pp Fastlane::Actions::WechatAction.http_body(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxx',
        recievers: ['xiongzenghui'],
        msgtype: 'markdown',
        text: "## ✅ build success \n \n> 1. ........ \n> 2. .......... \n> 3. ........"
      )
    end

    it 'send_with_token -  text' do
      Fastlane::Actions::WechatAction.send_with_token(
        access_token_url: 'http://smsc.in.zhihu.com/token',
        agentid: '10024',
        secret: 'dccae6ea9369a64d5131cfcf0e75a045',
        recievers: ['xiongzenghui'],
        msgtype: 'text',
        text: "xxxxxxxxxx",
        send_message_url: "http://smsc.in.zhihu.com/message/send?userid=xiongzenghui"
      )
    end

    it 'send_with_token -  markdown' do
      Fastlane::Actions::WechatAction.send_with_token(
        access_token_url: 'http://smsc.in.zhihu.com/token',
        agentid: '10024',
        secret: 'dccae6ea9369a64d5131cfcf0e75a045',
        recievers: ['xiongzenghui'],
        msgtype: 'markdown',
        text: "实时新增用户反馈<font color=\"warning\">132例</font>，请相关同事注意.\n >类型:<font color=\"comment\">用户反馈</font>\n >普通用户反馈:<font color=\"comment\">117例</font>\n >VIP用户反馈:<font color=\"comment\">15例</font>",
        send_message_url: "http://smsc.in.zhihu.com/message/send?userid=xiongzenghui"
      )
    end

    it 'send_with_webhook - text' do
      Fastlane::Actions::WechatAction.send_with_webhook(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=bd1e56d7-d034-466a-89dc-8c4102b310ff',
        msgtype: 'text',
        text: "hello world ~"
      )
    end

    it 'send_with_webhook - markdown' do
      Fastlane::Actions::WechatAction.send_with_webhook(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=bd1e56d7-d034-466a-89dc-8c4102b310ff',
        msgtype: 'markdown',
        text: "## ✅ build success \n \n> 1. ........ \n> 2. .......... \n> 3. ........"
      )
    end

    it 'run - send_with_token - text' do
      Fastlane::Actions::WechatAction.run(
        access_token_url: 'http://smsc.in.zhihu.com/token',
        agentid: '10024',
        secret: 'dccae6ea9369a64d5131cfcf0e75a045',
        recievers: ['xiongzenghui'],
        msgtype: 'text',
        text: "xxxxxxxxxx",
        send_message_url: "http://smsc.in.zhihu.com/message/send?userid=xiongzenghui"
      )
    end

    it 'run - send_with_token - markdown' do
      Fastlane::Actions::WechatAction.run(
        access_token_url: 'http://smsc.in.zhihu.com/token',
        agentid: '10024',
        secret: 'dccae6ea9369a64d5131cfcf0e75a045',
        recievers: ['xiongzenghui'],
        msgtype: 'markdown',
        text: "实时新增用户反馈<font color=\"warning\">132例</font>，请相关同事注意.\n >类型:<font color=\"comment\">用户反馈</font>\n >普通用户反馈:<font color=\"comment\">117例</font>\n >VIP用户反馈:<font color=\"comment\">15例</font>",
        send_message_url: "http://smsc.in.zhihu.com/message/send?userid=xiongzenghui"
      )
    end

    it 'run - send_with_webhook - text' do
      Fastlane::Actions::WechatAction.run(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=bd1e56d7-d034-466a-89dc-8c4102b310ff',
        msgtype: 'text',
        text: "hello world ~"
      )
    end

    it 'run - send_with_webhook - markdown' do
      Fastlane::Actions::WechatAction.run(
        webhook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=bd1e56d7-d034-466a-89dc-8c4102b310ff',
        msgtype: 'markdown',
        text: "## ✅ build success \n \n> 1. ........ \n> 2. .......... \n> 3. ........"
      )
    end
  end
end

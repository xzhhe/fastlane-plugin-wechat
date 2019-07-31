describe Fastlane::Actions::WechatAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The wechat plugin is working!")

      Fastlane::Actions::WechatAction.run(nil)
    end
  end
end

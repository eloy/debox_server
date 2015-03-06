require 'spec_helper'

describe DeboxServer::AESCrypt do
  let(:dummy_class) { Class.new { include DeboxServer::AESCrypt } }
  let(:dummy) { dummy_class.new }

  it 'should encrypt and dectrypt' do
    text = "foo bar wadus"
    crypted = dummy.encrypt(text)
    expect(dummy.decrypt(crypted)).to eq text
  end
end

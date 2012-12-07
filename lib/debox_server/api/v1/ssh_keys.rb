module DeboxServer
  module API
    module V1

      class SshKeys < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
        end

        desc "Return the public rsa key for the debox user"
        get "/public_key" do
          ssh_public_key || "SSH keys not found"
        end

      end
    end
  end
end

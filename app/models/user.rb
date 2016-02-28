class User < ActiveRecord::Base
  # attr_accessible :title, :body

  class << self

    def find_or_create_from_auth_hash(user_data)
      u = User.find_by_provider_and_email(user_data[:provider], user_data[:uid])
      if u.nil?
        u = User.create().tap do |u|
          u.uid = user_data[:uid]
          u.name = user_data[:name]
          u.email = user_data[:email]
          u.provider = user_data[:provider]
          u.save
        end
      end
    end

  end

end

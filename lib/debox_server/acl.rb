module DeboxServer
  # Define Access Control List for apps and envs
  # Each ACL entry shound contain the use email and the action
  # for the ACL. Valid actions are:
  # * : Wildcard action. Allow all actions
  module ACL

    # Find the app acl for the given user.
    # Return nil if not found
    def acl_find(app, env, user)
      acl = redis.hget acl_key_name(app, env), user.email
      JSON.parse(acl).map(&:to_sym) if acl
    end

    # Add an action to the app acl for the given user
    def acl_add(app, env, user, action)
      acl = acl_find(app, env, user) || []
      unless acl.include? action
        acl << action
        redis.hset acl_key_name(app, env), user.email, acl.to_json
      end
    end

    def acl_allow?(app, env, user, action)
      return true if user.admin
      acl = acl_find app, env, user
      return false unless acl
      acl.each do |allowed|
        if allowed == :* || allowed == action
          return true
        end
      end
      return false
    end

    # Return the app acl key nane
    def acl_key_name(app, env)
      "acl_#{app}_#{env}"
    end

  end
end

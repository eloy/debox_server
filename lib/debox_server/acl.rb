module DeboxServer
  # Define Access Control List for apps and envs
  # Each ACL entry shound contain the use email and the action
  # for the ACL. Valid actions are:
  # * : Wildcard action. Allow all actions
  module ACL

    # Find the app acl for the given user.
    # Return nil if not found
    def acl_find(app, env, user)
      acl = redis.hget acl_key_name(app, env), user
      JSON.parse(acl).map(&:to_sym) if acl
    end

    # Add an action to the app acl for the given user
    def acl_add(app, env, user, action)
      acl = acl_find(app, env, user) || []
      unless acl.include? action
        acl << action
        redis.hset acl_key_name(app, env), user, acl.to_json
      end
    end

    # Return the app acl key nane
    def acl_key_name(app, env)
      "acl_#{app}_#{env}"
    end

  end
end

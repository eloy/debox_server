module DeboxServer
  module Apps

    def app_exists?(name)
      App.where('name=?', name).exists?
    end

  end
end

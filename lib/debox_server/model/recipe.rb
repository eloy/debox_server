class Recipe < ActiveRecord::Base

  # associations
  #----------------------------------------------------------------------

  belongs_to :app
  has_many :jobs
  has_many :permissions

  # validations
  #----------------------------------------------------------------------

  validates_presence_of :name, :content
  validates_uniqueness_of :name, scope: :app_id


  def tasks
    begin
      capistrano = Capistrano::Configuration.new
      capistrano.load_paths << File.join(DeboxServer::Config.debox_root, 'capistrano')

      # Load the recipe content and extract config to make it available to status
      capistrano.load string: self.content
      tasks = capistrano.task_list(:all).map do |task|
        { name: task.fully_qualified_name, description: task.brief_description, long_description: task.description }
      end
    rescue Exception => ex
      DeboxServer::log.error ex
      return []
    end
  end


  def last_job
    @last ||= self.jobs.success.order('id desc').first
  end

  def to_jbuilder
    Jbuilder.new do |json|
      json.(self, :id, :name, :app_id)
      if last_job.present?
        json.last_job last_job.to_jbuilder(no_log: true)
      end
    end
  end
end

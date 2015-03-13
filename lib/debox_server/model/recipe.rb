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

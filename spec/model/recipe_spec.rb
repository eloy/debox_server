require 'spec_helper'

describe Recipe do
  it { should belong_to :app }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:app_id) }
  it { should validate_presence_of :content }
end

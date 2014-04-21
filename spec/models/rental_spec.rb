require 'spec_helper'

describe Rental do

  it { should validate_presence_of(:num_bedrooms) }
  it { should validate_presence_of(:num_bathrooms) }
  it { should validate_presence_of(:sq_footage) }
  it { should validate_presence_of(:monthly_rent) }
  it { should validate_presence_of(:owner) }

  it { should belong_to(:owner) }
end
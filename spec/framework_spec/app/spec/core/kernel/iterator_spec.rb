require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/fixtures/classes'

describe "Kernel#iterator?" do
  it "is a private method" do
    Kernel.should have_private_instance_method(:iterator?)
  end
end

describe "Kernel.iterator?" do
  it "needs to be reviewed for spec completeness"
end
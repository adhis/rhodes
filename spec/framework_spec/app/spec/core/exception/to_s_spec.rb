require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/shared/to_s'

describe "Exception#to_s" do
  it_behaves_like :to_s, :to_s
end  

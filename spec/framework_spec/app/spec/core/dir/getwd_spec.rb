require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/fixtures/common'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/shared/pwd'

describe "Dir.pwd" do
  it_behaves_like :dir_pwd, :getwd
end

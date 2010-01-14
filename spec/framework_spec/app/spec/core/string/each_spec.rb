require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/fixtures/classes'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/shared/each_line'

describe "String#each" do
  ruby_version_is ''...'1.9' do
    it_behaves_like(:string_each_line, :each)
  end
end

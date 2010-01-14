require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'

describe "IOError" do
  it "is a superclass of EOFError" do
    IOError.should be_ancestor_of(EOFError)
  end
end

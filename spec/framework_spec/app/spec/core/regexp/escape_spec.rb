require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/shared/quote'

describe "Range.escape" do
  it_behaves_like(:regexp_quote, :escape)
end

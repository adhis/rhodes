require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../../spec_helper'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/../../../shared/file/setgid'
require File.dirname(File.join(__rhoGetCurrentDir(), __FILE__)) + '/fixtures/classes'

describe "File::Stat#setgid?" do
  it_behaves_like :file_setgid, :setgid?, FileStat
end

describe "File::Stat#setgid?" do
  it "needs to be reviewed for spec completeness"
end

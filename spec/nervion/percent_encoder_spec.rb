#encoding: utf-8

require 'nervion/percent_encoder'

describe Nervion::PercentEncoder do
  include described_class

  it 'encodes string values' do
    encode('Ladies + Gentlemen').should eq 'Ladies%20%2B%20Gentlemen'
    encode('An encoded string!').should eq 'An%20encoded%20string%21'
    encode('Dogs, Cats & Mice').should eq 'Dogs%2C%20Cats%20%26%20Mice'
  end

  it 'encodes non string values' do
    encode(123456789).should eq '123456789'
    encode(:get_post).should eq 'get_post'
  end

  it 'encodes UTF-8 values' do
    encode('☃').should eq '%E2%98%83'
  end
end

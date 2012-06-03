#encoding: utf-8

require 'nervion/percent_encoder'

describe Nervion::PercentEncoder do
  it 'encodes string values' do
    subject.encode('Ladies + Gentlemen').should eq 'Ladies%20%2B%20Gentlemen'
    subject.encode('An encoded string!').should eq 'An%20encoded%20string%21'
    subject.encode('Dogs, Cats & Mice').should eq 'Dogs%2C%20Cats%20%26%20Mice'
  end

  it 'encodes non string values' do
    subject.encode(123456789).should eq '123456789'
    subject.encode(:get_post).should eq 'get_post'
  end

  it 'encodes UTF-8 values' do
    subject.encode('☃').should eq '%E2%98%83'
  end
end

#!/usr/bin/env rspec
require 'spec_helper'

describe "the empty function" do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("empty").should == "function_empty"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { @scope.function_empty([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should return a true for an empty string" do
    result = @scope.function_empty([''])
    result.should(eq(true))
  end

  it "should return a false for a non-empty string" do
    result = @scope.function_empty(['asdf'])
    result.should(eq(false))
  end

end

#!/usr/bin/env rspec
require 'spec_helper'

describe "the downcase function" do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("downcase").should == "function_downcase"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { @scope.function_downcase([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should downcase a string" do
    result = @scope.function_downcase(["ASFD"])
    result.should(eq("asfd"))
  end

  it "should do nothing to a string that is already downcase" do
    result = @scope.function_downcase(["asdf asdf"])
    result.should(eq("asdf asdf"))
  end

end

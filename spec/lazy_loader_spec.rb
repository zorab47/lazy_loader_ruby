# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'lazy_loader'

describe LazyLoader do

  it "performs basic operations" do
    i = 0
    lazy_load = LazyLoader.create_lazy_loader do
      i += 1
      i
    end

    lazy_load.get.should == 1
    lazy_load.get.should == 1
  end

  it "performs basic operations with threads" do
    i = 0
    lazy_load = LazyLoader.create_lazy_loader do
      i += 1
      i
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        lazy_load.get.should == 1
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "throws error on nil" do
    lazy_load = LazyLoader.create_lazy_loader do
      nil
    end

    proc { lazy_load.get }.should raise_error(StandardError) do |e|
      e.message.should == "nil object"
    end
  end

  it "throws error each time on nil" do
    lazy_load = LazyLoader.create_lazy_loader do
      nil
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        proc { lazy_load.get }.should raise_error(StandardError) do |e|
          e.message.should == "nil object"
        end
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "does not throw error on false" do
    lazy_load = LazyLoader.create_lazy_loader do
      false
    end
    lazy_load.get.should == false
  end

  it "does not throw error on false with threads" do
    lazy_load = LazyLoader.create_lazy_loader do
      false
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        lazy_load.get.should == false
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end
end

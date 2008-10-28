require 'test/unit'
require 'rubygems'
require 'activesupport'
require File.join(File.dirname(__FILE__), '../lib/has_scoped_time_zone')

class MockColumn
  attr_accessor :name, :type

  def initialize(name, type)
    @name, @type = name, type
  end
end

class BaseModel
  class << self
    def columns
      [MockColumn.new(:now, :datetime), MockColumn.new(:yesterday, :datetime)]
    end
  end

  include HasScopedTimeZone


  def now
    Time.now.utc
  end

  def yesterday
    1.day.ago.utc
  end

  def time_zone
    'Buenos Aires'
  end

  private
  def read_attribute(attribute)
    send(attribute)
  end
end

class MockModel < BaseModel
  has_scoped_time_zone :now, lambda { |e| e.time_zone }
end

class MockAllModel < BaseModel
  has_scoped_time_zone lambda { |e| e.time_zone }
end

class HasScopedTimeZoneTest < Test::Unit::TestCase
  def setup
    @mock = MockModel.new
  end

  def test_should_create_new_accessor
    assert @mock.respond_to?(:now_tz)
  end

  def test_should_not_create_new_accessor
    assert !@mock.respond_to?(:yesterday_tz)
  end

  def test_should_return_date_without_scope
    assert_equal 'UTC', @mock.now.zone
  end

  def test_should_return_time_zone_scoped_date
    assert_equal 'ARST', @mock.now_tz.zone
  end
end


class HasScopedAllMethodTimeZoneTest < Test::Unit::TestCase
  def setup
    @mock = MockAllModel.new
  end

  def test_should_create_new_accessors
    assert @mock.respond_to?(:now_tz)
    assert @mock.respond_to?(:yesterday_tz)
  end

  def test_should_return_time_zone_scoped_date
    assert_equal 'ARST', @mock.now_tz.zone
    assert_equal 'ARST', @mock.yesterday_tz.zone
  end
end
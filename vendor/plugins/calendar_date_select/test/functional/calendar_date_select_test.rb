require File.join(File.dirname(__FILE__), '../test_helper.rb')

class HelperMethodsTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  
  include CalendarDateSelect::FormHelper
  
  def setup
    @controller = ActionController::Base.new
    @request = OpenStruct.new
    @controller.request = @request
    
    @model = OpenStruct.new
  end
  
  def test_mixed_time__model_returns_date__should_render_without_time
    @model.start_datetime = Date.parse("January 2, 2007")
    output = calendar_date_select(:model, :start_datetime, :time => "mixed")
    assert_no_match(/12:00 AM/, output, "Shouldn't have outputted a time")
  end
    
  def test_mixed_time__model_returns_time__should_render_with_time
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, :start_datetime, :time => "mixed")
    assert_match(/12:00 AM/, output, "Should have outputted a time")
  end
  
  def test_time_true__model_returns_date__should_render_with_time
    @model.start_datetime = Date.parse("January 2, 2007")
    output = calendar_date_select(:model, :start_datetime, :time => "true")
    assert_match(/12:00 AM/, output, "Should have outputted a time")
  end
  
  def test_time_false__model_returns_time__should_render_without_time
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, :start_datetime, :time => false)
    assert_no_match(/12:00 AM/, output, "Shouldn't have outputted a time")
  end
  
end
class CalendarDateSelect
  FORMATS = {
    :natural => {
      :date => "%B %d, %Y",
      :time => " %I:%M %p"
    },
    :hyphen_ampm => {
      :date => "%Y-%m-%d",
      :time => " %I:%M %p",
      :javascript_include => "format_hyphen_ampm"
    },
    :finnish => {
      :date => "%d.%m.%Y",
      :time => " %H:%M",
      :javascript_include => "format_finnish"
    }
  }
  
  cattr_accessor :image
  @@image = "calendar_date_select/calendar.gif"
  
  cattr_reader :format
  @@format = FORMATS[:natural]
  
  class << self
    def format=(format)
      raise "CalendarDateSelect: Unrecognized format specification: #{format}" unless FORMATS.has_key?(format)
      @@format = FORMATS[format]
    end
    
    def javascript_format_include
      @@format[:javascript_include] && "calendar_date_select/#{@@format[:javascript_include]}"
    end
    
    def date_format_string(time=false)
      @@format[:date] + ( time ? @@format[:time] : "" )
    end
    
    def has_time?(value)
      /[0-9]:[0-9]{2}/.match(value.to_s)
    end
  end
  
  module FormHelper
    def calendar_date_select_tag( name, value = nil, options = {})
      calendar_options = calendar_date_select_process_options(options)
      value = (value.strftime(calendar_options[:format]) rescue value) if (value.respond_to?("strftime"))
      
      calendar_options.delete(:format)
      
      options[:id] ||= name
      tag = calendar_options[:hidden] || calendar_options[:embedded] ? 
        hidden_field_tag(name, value, options) :
        text_field_tag(name, value, options)
      
      calendar_date_select_output(tag, calendar_options)
    end
    
    # extracts any options passed into calendar date select, appropriating them to either the Javascript call or the html tag.
    def calendar_date_select_process_options(options)
      calendar_options = {}
      callbacks = [:before_show, :before_close, :after_show, :after_close, :after_navigate]
      for key in [:time, :embedded, :buttons, :format, :year_range, :month_year, :popup, :hidden] + callbacks
        calendar_options[key] = options.delete(key) if options.has_key?(key)
      end
      
      # if passing in mixed, pad it with single quotes
      calendar_options[:time] = "'mixed'" if calendar_options[:time].to_s=="mixed"
      calendar_options[:month_year] = "'#{calendar_options[:month_year]}'" if calendar_options[:month_year]
      
      # if we are forcing the popup, automatically set the readonly property on the input control.
      if calendar_options[:popup].to_s == "force"
        calendar_options[:popup] = "'force'"
        options[:readonly] = true 
      end
      
      calendar_options[:popup_by] ||= "this" if calendar_options[:hidden]
      
      # surround any callbacks with a function, if not already done so
      for key in callbacks
        calendar_options[key] = "function(param) { #{calendar_options[key]} }" unless calendar_options[key].include?("function") if calendar_options[key]
      end
      
      calendar_options[:year_range] ||= 10
      calendar_options
    end
    
    def calendar_date_select(object, method, options={})
      obj = instance_eval("@#{object}") || options[:object]
      
      if !options.include?(:time) && obj.class.respond_to?("columns_hash")
        column_type = (obj.class.columns_hash[method.to_s].type rescue nil)
        options[:time] = true if column_type == :datetime
      end
      
      use_time = options[:time]
      
      if options[:time].to_s=="mixed"
        use_time = false if Date===obj.send(method)
      end
      
      calendar_options = calendar_date_select_process_options(options)
      
      value = if obj.send(method).respond_to?(:strftime)
        obj.send(method).strftime(CalendarDateSelect.date_format_string(use_time))
      elsif obj.respond_to?("#{method}_before_type_cast") 
        obj.send("#{method}_before_type_cast")
      else
        obj.send(method).to_s
      end
      
      options = options.merge(:value => value)

      tag = ActionView::Helpers::InstanceTag.new(object, method, self, nil, options.delete(:object))
      calendar_date_select_output(
        tag.to_input_field_tag( (calendar_options[:hidden] || calendar_options[:embedded]) ? "hidden" : "text", options), 
        calendar_options
      )
    end  
    
    def calendar_date_select_output(input, calendar_options = {})
      out = input
      if calendar_options[:embedded]
        uniq_id = "cds_placeholder_#{(rand*100000).to_i}"
        # we need to be able to locate the target input element, so lets stick an invisible span tag here we can easily locate
        out << content_tag(:span, nil, :style => "display: none; position: absolute;", :id => uniq_id)
        
        out << javascript_tag("new CalendarDateSelect( $('#{uniq_id}').previous(), #{options_for_javascript(calendar_options)} ); ")
      else
        out << " "
        
        out << image_tag(CalendarDateSelect.image, 
            :onclick => "new CalendarDateSelect( $(this).previous(), #{options_for_javascript(calendar_options)} );",
            :style => 'border:0px; cursor:pointer;')
      end
      
      out
    end
  end
end


module ActionView
  module Helpers
    class FormBuilder
      def calendar_date_select(method, options = {})
        @template.calendar_date_select(@object_name, method, options.merge(:object => @object))
      end
    end
  end
end

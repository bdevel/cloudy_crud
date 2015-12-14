

module CloudyCrud::Validation
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def ensure_nil_or_hash(value, label)
      if !value.is_a?(Hash) && !value.nil?
        InvalidRequest.new("#{label} must be a JSON object or NULL")
      end
    end
    
    def ensure_nil_or_array(value, label)
      if !value.is_a?(Array) && !value.nil?
        InvalidRequest.new("#{label} must be a JSON array or NULL")
      end
    end
    
    # Must be nil or array of strings or numbers
    def ensure_nil_or_array_of_values(value, label)
      msg = "#{label} must be a NULL or an array of strings or numbers."
      if !value.is_a?(Array) && !value.nil?
        InvalidRequest.new(msg)
      end
      
      if value.is_a?(Array)
        value.each do |v|
          if !v.is_a?(Numeric) && !v.is_a?(String)
            InvalidRequest.new(msg)
          end
        end
      end
      
    end
  end
end

  

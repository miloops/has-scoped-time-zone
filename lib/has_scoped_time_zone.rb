module HasScopedTimeZone

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def has_scoped_time_zone(*attrs)
      lamb = attrs.pop
      raise ArgumentError unless lamb.respond_to?(:call)
      names = attrs.empty? ? columns.select{|c| c.type.eql?(:datetime)}.map(&:name) : attrs

      names.each do |name|
        define_method "#{name}_tz" do
          read_attribute(name).in_time_zone(lamb.call(self)) unless read_attribute(name).blank?
        end
      end
    end
  end
end
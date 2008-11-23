# TODO: figure out Module.nesting shit for this... write some tests
#       try eval("Module.nesting", binding) or osme shti

class Object
  alias_method :orig_method_missing, :method_missing

  def method_missing(m, *a, &b)
    begin
      klass = (self.is_a?(Module) ? self : self.class).const_get(m)
    rescue NameError
    else
      return klass.send(:parens, *a, &b)  if klass.respond_to? :parens
    end
      
    orig_method_missing m, *a, &b
  end
end

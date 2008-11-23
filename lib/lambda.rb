require 'rubygems'
require 'ruby-debug'
Debugger.start

class Object
  alias_method :orig_method_missing, :method_missing

  def method_missing(m, *a, &b)
    begin
      l = eval(m.to_s, binding_n(1))
    rescue NameError
    else
      return l.call(*a)  if l.respond_to? :call
    end
    orig_method_missing m, *a, &b
  end
end

def call_a_lambda_with_parenths(val)
  l = lambda {|v| p v }
  l(val)
end

call_a_lambda_with_parenths(6)

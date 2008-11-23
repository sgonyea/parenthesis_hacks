require 'test/unit'

class InstanceEvalNestingTest < Test::Unit::TestCase
  def test_module_nesting_doesnt_work_in_instance_eval
    eval <<-EOF
      module ::M
        X = 5
        class D
          def self.x(s = nil, &b)
            return self.instance_eval(s)  if s
            self.instance_eval(&b)
          end
        end
      end
    EOF

    assert_raises(NameError) {  M::D.x { X } }
    assert_equal 5, M::D.x('X')
  end
end

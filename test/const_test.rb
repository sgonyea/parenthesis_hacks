require 'test/unit'

require File.dirname(__FILE__) + "/../lib/const"

class ConstTest < Test::Unit::TestCase
  def test_simple
    eval <<-EOS
      class ::X
        def self.parens
          :Xparens
        end
      end
    EOS

    assert_equal :Xparens, X()
  ensure
    Object.send :remove_const, :X
  end

  def test_constant_lookup_through_ancestors
    eval <<-EOS
      module ::G
        class K
          def self.parens(v); v; end
        end
      end
      class ::X
        include G

        def call_k
          K(42)
        end

        def self.call_k
          K(42)
        end
      end
    EOS

    assert_equal 42, X.new.call_k
    assert_equal 42, X.call_k
  ensure
    Object.send :remove_const, :G
    Object.send :remove_const, :X
  end

  def test_bad_const_lookup_raises_NoMethodError
    assert_raises(NoMethodError) do
      eval <<-EOS
        class ::X
          BadConstName()
        end
      EOS
    end
  ensure
    Object.send :remove_const, :X
  end

  def test_bad_const_lookup_falls_through_to_orig_method_missing
    $mm_called_with = nil
    eval <<-EOS
      class ::X
        def self.method_missing m, *a
          $mm_called_with = m
        end
        BadConstName()
      end
    EOS

    assert_equal :BadConstName, $mm_called_with
  ensure
    $mm_called_with = nil
    Object.send :remove_const, :X
  end

  # This fails because 1) we resolve in a different scope (method_missing) and
  # 2) const_get doesnt use lexical scope to resolve constants
  def test_constant_lookup_through_lexical_scope_should_FAIL
    assert_raise(NoMethodError) do
      eval <<-EOS
        module K
          class C
            def self.parens
              42
            end
          end

          class D
            C()
          end
        end
      EOS
    end
  end
end

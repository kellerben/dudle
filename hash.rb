class Hash
	def compare_by_values(other, fieldarray)
		return  0 if fieldarray.size == 0
		return -1 if  self[fieldarray[0]].nil?
		return  1 if other[fieldarray[0]].nil?

		if self[fieldarray[0]] == other[fieldarray[0]]
			if fieldarray.size == 1
				return 0
			else
				return self.compare_by_values(other, fieldarray[1,fieldarray.size-1])
			end
		else
			self[fieldarray[0]] <=> other[fieldarray[0]]
		end
	end
end

if __FILE__ == $0
require "test/unit"
  class Hash_test < Test::Unit::TestCase
    def test_compare_by_values
			a = {1 =>1, 2=>2, 3=>3}
			b = {1 =>1, 2=>2, 3=>2}
			c = {1 =>1, 2=>3, 3=>3}
			d = {1 =>1, 2=>3}

      assert_equal( 0,a.compare_by_values(a,[1,2,3]))
      assert_equal( 1,a.compare_by_values(b,[1,2,3]))
      assert_equal(-1,a.compare_by_values(c,[1,2,3]))
      assert_equal( 1,c.compare_by_values(d,[1,2,3]))
      assert_equal(-1,d.compare_by_values(c,[1,2,3]))
      assert_equal( 0,d.compare_by_values(c,[]))
    end
  end 
end


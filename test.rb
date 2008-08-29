require 'test/unit'
require 'yaml'

load "index.cgi"
SITE = "glvhc_8nuv_8fchi09bb12a-23_uvc"
class Poll
	attr_accessor :head, :data, :comment
end

class PollTest < Test::Unit::TestCase
	def setup
		@poll = Poll.new
	end
	def teardown
		File.delete("#{SITE}.yaml") if File.exists?("#{SITE}.yaml")
	end
	def test_init
		assert(@poll.head.empty?)
	end
	def test_add_participant
		@poll.head << "Item 2"
		@poll.add_participant("bla",{"Item 2" => true})
		assert_equal(Time, @poll.data["bla"]["timestamp"].class)
		assert(@poll.data["bla"]["Item 2"])
	end
	def test_delete
		@poll.data["bla"] = {}
		@poll.delete(" bla ")
		assert(@poll.data.empty?)
	end
	def test_store
		@poll.add_remove_column("uaie")
		@poll.add_remove_column("gfia")
		@poll.add_participant("bla",{"uaie"=>true, "gfia"=>true})
		@poll.add_comment("blabla","commentblubb")
		@poll.store
		assert_equal(@poll.data,YAML::load_file("#{SITE}.yaml").data)
		assert_equal(@poll.head,YAML::load_file("#{SITE}.yaml").head)
		assert_equal(@poll.comment,YAML::load_file("#{SITE}.yaml").comment)
	end
	def test_add_comment
		@poll.add_comment("blabla","commentblubb")
		assert_equal(Time, @poll.comment[0][0].class)
		assert_equal("blabla", @poll.comment[0][1])
	end
	def test_add_remove_column
		assert(@poll.add_remove_column(" bla  "))
		assert_equal("bla",@poll.head[0])
		assert(@poll.add_remove_column("   bla "))
		assert(@poll.head.empty?)
	end
end

class DatePollTest < Test::Unit::TestCase
	def setup
		@poll = DatePoll.new
	end
	def teardown
		File.delete("#{SITE}.yaml") if File.exists?("#{SITE}.yaml")
	end
	def test_add_remove_column
		assert(!@poll.add_remove_column("bla"))
		assert(!@poll.add_remove_column("31-02-2001"))
		assert(@poll.add_remove_column("2008-02-20"))
		assert_equal(Date,@poll.head[0].class)
		assert(@poll.add_remove_column(" 2008-02-20  "))
		assert(@poll.head.empty?)
	end

end

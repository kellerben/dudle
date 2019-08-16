# encoding: utf-8
############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of Dudle.                                              #
#                                                                          #
# Dudle is free software: you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# Dudle is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public     #
# License for more details.                                                #
#                                                                          #
# You should have received a copy of the GNU Affero General Public License #
# along with dudle.  If not, see <http://www.gnu.org/licenses/>.           #
############################################################################

require "time"
require_relative "log"
require "open3"
require 'tempfile'

def runcmd *args
	Open3.popen3(*args) {|i,o,e,t| o.read }
end

class VCS
	GITCMD="git"
	def VCS.init
		runcmd(GITCMD, "init")
	end

	def VCS.rm file
		runcmd(GITCMD, "rm", file)
	end

	def VCS.add file
		runcmd(GITCMD, "add", file)
	end

	def VCS.revno
		# there is a bug in git log --format, which suppresses the \n on the last line
		runcmd(GITCMD, "log", "--format=format:x").scan("\n").size + 1
	end

	def VCS.cat revision, file
		revs = runcmd(GITCMD, "log", "--format=format:%H").split("\n").reverse
		runcmd(GITCMD, "show", "#{revs[revision-1]}:#{file}")
	end

	def VCS.history
		log = runcmd(GITCMD, "log", "--format=format:%s\t%ai").force_encoding('utf-8').split("\n").reverse
		ret = Log.new
		log.each_with_index{|s,i|
			a = s.scan(/^([^\t]*)(.*)$/).flatten
			ret.add(i+1, Time.parse(a[1]), a[0])
		}
		ret
	end

	def VCS.commit comment
		tmpfile = Tempfile.new("commit")
		tmpfile.write(comment)
		tmpfile.close
		ret = runcmd(GITCMD, "commit", "-a", "-F", tmpfile.path)
		tmpfile.unlink
		ret
	end

	def VCS.branch source, target
		runcmd(GITCMD, "clone", source, target)
	end

	def VCS.revert revno
		revhash = runcmd(GITCMD, "log", "--format=%H").split("\n").reverse[revno-1]
		runcmd(GITCMD, "checkout", revhash, ".")
		VCS.commit("Reverted Poll to version #{revno}")
	end

	def VCS.reset revno
		revhash = runcmd(GITCMD, "log", "--format=%H").split("\n").reverse[revno-1]
		runcmd(GITCMD, "checkout", "-B", "master", revhash)
	end
end



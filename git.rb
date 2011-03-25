############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of dudle.                                              #
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
require "log"

class VCS
	GITCMD="export LC_ALL=de_DE.UTF-8; git"
	def VCS.init
		`#{GITCMD} init`
	end

	def VCS.rm file
		`#{GITCMD} rm #{file}`
	end

	def VCS.add file
		`#{GITCMD} add #{file}`
	end

	def VCS.revno
		# there is a bug in git log --format, which supresses the \n on the last line
		`#{GITCMD} log --format="format:x"`.scan("\n").size + 1
	end

	def VCS.cat revision, file
		revs = `#{GITCMD} log --format="format:%H"`.scan(/^(.*)$/).flatten.reverse
		`#{GITCMD} show #{revs[revision-1]}:#{file}`
	end

	def VCS.history
		log = `#{GITCMD} log --format="format:%s|%ai"`.split("\n").reverse
		ret = Log.new
		log.each_with_index{|s,i|
			a = s.scan(/^([^\|]*)(.*)$/).flatten
			ret.add(i+1, Time.parse(a[1]), a[0])
		}
		ret
	end

	def VCS.commit comment
		tmpfile = "/tmp/commitcomment.#{rand(10000)}"
		File.open(tmpfile,"w"){|f|
			f<<comment
		}
		ret = `#{GITCMD} commit -a -F #{tmpfile}`
		File.delete(tmpfile)
		ret
	end
	
	def VCS.branch source, target
		`#{GITCMD} clone #{source} #{target}`
	end

	def VCS.revert revno
		revhash = `#{GITCMD} log --format="%H"`.split("\n").reverse[revno-1]
		`#{GITCMD} checkout #{revhash} .`
		VCS.commit("Reverted Poll to version #{revno}")
	end
end



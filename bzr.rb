############################################################################
# Copyright 2009 Benjamin Kellermann                                       #
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

BZRCMD="export LC_ALL=de_DE.UTF-8; bzr"
require "time"

class VCS
	def VCS.init
		`#{BZRCMD} init`
	end

	def VCS.add file
		`#{BZRCMD} add #{file}`
	end

	def VCS.revno
		`#{BZRCMD} revno`.to_i
	end

	def VCS.cat revision, file
		`#{BZRCMD} cat -r #{revision.to_i} #{file}`
	end

	def VCS.history
		`#{BZRCMD} log --forward`.split("-"*60)
	end
	
	def VCS.longhistory dir
		log = `#{BZRCMD} log -r -10.. "#{dir}"`.split("-"*60)
		log.collect!{|s| s.scan(/\nrevno: (.*)\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
		log.shift
		log.collect!{|r,t,c| [r.to_i,Time.parse(t),c]}
	end

	def VCS.commit comment
		tmpfile = "/tmp/commitcomment.#{rand(10000)}"
		File.open(tmpfile,"w"){|f|
			f<<comment
		}
		ret = `#{BZRCMD} commit -q -F #{tmpfile}`
		File.delete(tmpfile)
		ret
	end
end

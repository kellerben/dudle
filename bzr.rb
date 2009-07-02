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

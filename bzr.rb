BZRCMD="export LC_ALL=de_DE.UTF-8; bzr"
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

	def VCS.commit comment
		tmpfile = "/tmp/commitcomment.#{rand(10000)}"
		File.open(tmpfile,"w"){|f|
			f<<comment
		}
		ret = `#{BZRCMD} commit -F #{tmpfile}`
		File.delete(tmpfile)
		ret
	end
end

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
		`#{BZRCMD} cat -r #{revision} #{file}`
	end

	def VCS.history
		`#{BZRCMD} log --forward`.split("-"*60)
	end

	def VCS.commit comment
		`#{BZRCMD} commit -m '#{comment}'`
	end
end

class VCS
	def VCS.init
		`bzr init`
	end

	def VCS.add file
		`bzr add #{file}`
	end

	def VCS.revno
		`bzr revno`.to_i
	end

	def VCS.cat revision, file
		`export LC_ALL=de_DE.UTF-8;bzr cat -r #{revision} #{file}`
	end

	def VCS.history
		`export LC_ALL=de_DE.UTF-8; bzr log --forward`.split("-"*60)
	end

	def VCS.commit comment
		`export LC_ALL=de_DE.UTF-8; bzr commit -m '#{comment}'`
	end
end

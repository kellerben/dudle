def vcs_init
	`bzr init`
end

def vcs_add(file)
	`bzr add #{file}`
end

def vcs_revno
	`bzr revno`.to_i
end

def vcs_cat revision, file
	`export LC_ALL=de_DE.UTF-8;bzr cat -r #{revision} #{file}`
end

def vcs_history
	`export LC_ALL=de_DE.UTF-8; bzr log --forward`.split("-"*60)
end

def vcs_commit comment
	`export LC_ALL=de_DE.UTF-8; bzr commit -m '#{comment}'`
end

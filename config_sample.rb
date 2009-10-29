# Choose your favorite version control system
load "bzr.rb"

# Change this if the url is not determined correctly
SITEURL = "http://#{$cgi.server_name}#{$cgi.script_name.gsub(/[^\/]*$/,"")}"

# add this htmlcode to the startpage
NOTICE = <<NOTICE
<fieldset><legend>Examples</legend>
	If you want to play around with the Tool, you may want to take a look at these two Example Polls:<br />
	<a href='EventScheduleExample'>Event Schedule Poll</a><br />
	<a href='NormalExample'>Normal Poll</a>	
</fieldset>
NOTICE



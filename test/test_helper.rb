require "cgi" unless defined? CGI
require_relative "../lib/stretchr"

def test_stretchr_object
  Stretchr::Client.new({transporter: Stretchr::TestTransporter.new, private_key: 'ABC123-private', public_key: "test", project: "project.company"})
end

module URI

	def get_param(param)
		CGI.parse(CGI.unescape(self.query))[param]
	end

	def validate_param_value(param, value)
		CGI.parse(CGI.unescape(self.query))[param].include?(value)
	end

	def validate_param_presence(param)
    return false if self.query == nil
		CGI.parse(CGI.unescape(self.query))[param] == [] ? false : true
	end

end
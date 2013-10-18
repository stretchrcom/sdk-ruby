require "test_helper"

describe "Request Object" do
	it "Should let you build up a url" do
		r = Stretchr::Request.new
		r.people(1).cars
		assert_equal "people/1/cars", r.path, "Should have built up a path"
	end

	it "Should know how to build a complete url including path" do
		c = Stretchr::Client.new({project: "project", api_version: "v1.1"})
		r = Stretchr::Request.new({client: c})
		assert_equal "http://project.stretchr.com/api/v1.1/people/1/cars", r.people(1).cars.to_url, "Should have built the url properly"
	end

	it "Should let you pass in params" do
		c = Stretchr::Client.new({project: "project", api_version: "v1.1"})
		r = Stretchr::Request.new({client: c})
		r.param("key", "asdf")
		assert r.to_url.include?("?key=asdf"), "Should have added the params"
	end

	it "should let you chain params" do
		c = Stretchr::Client.new({project: "project", api_version: "v1.1"})
		r = Stretchr::Request.new({client: c})
		r.param("key", "asdf").param("key2", "asdf2")
		uri = r.to_uri
		assert_equal "asdf", uri.get_param("key").first, "should have set key"
		assert_equal "asdf2", uri.get_param("key2").first, "Should have set key2"
	end

	it "should let you add filters" do
		c = Stretchr::Client.new({project: "project", api_version: "v1.1"})
		r = Stretchr::Request.new({client: c})
		r.where("name", "ryan").where("age", "21")
		assert_equal ["ryan"], r.to_uri.get_param(":name"), "Should have added filters"
		assert_equal ["21"], r.to_uri.get_param(":age"), "Should have added filter for age"
	end

	it "Should let you add multiple filters" do
		c = Stretchr::Client.new({project: "project", api_version: "v1.1"})
		r = Stretchr::Request.new({client: c})
		r.where("age", [">21", "<40"])
		assert_equal [">21", "<40"], r.to_uri.get_param(":age"), "Should have added multiple ages"
	end

	it "Should let you get objects" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people.get
		assert_equal :get, t.requests.first[:method], "Should have performed a get request"
	end

	it "Should let you create new objects" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people.create({name: "ryan"})
		assert_equal :post, t.requests.first[:method], "Should have performed a post"
		assert_equal "ryan", t.requests.first[:body][:name], "Should have sent the body to the transporter"
	end

	it "Should let you replace an existing object" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people(1).replace({name: "ryan"})
		assert_equal :put, t.requests.first[:method], "Should have performed a put"
		assert_equal "ryan", t.requests.first[:body][:name], "Should have sent the body to the transporter"
	end

	it "Should let you update an existing object" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people(1).update({name: "ryan"})
		assert_equal :patch, t.requests.first[:method], "Should have performed a put"
		assert_equal "ryan", t.requests.first[:body][:name], "Should have sent the body to the transporter"
	end

	it "Should let you remove an object or collection" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people(1).remove
		assert_equal :delete, t.requests.first[:method], "Should have performed a put"
	end

	it "Should set a default api version" do
		r = Stretchr::Request.new
		assert r.api_version, "it should have set a default api version"
	end

	it "Should let me pass in a client" do
		client = Object.new
		r = Stretchr::Request.new({client: client})
		assert_equal client, r.client, "Should have passed the client to the request"
	end

	it "Should pass the client to the transporter" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people.get
		assert_equal c, t.requests.first[:client], "Should have passed the client to the transporter"
	end

	it "should pass the correct uri to the transporter" do
		t = Stretchr::TestTransporter.new
		c = Stretchr::Client.new({project: "project", api_version: "v1.1", transporter: t})
		r = Stretchr::Request.new({client: c})
		r.people.get
		assert_equal "http://project.stretchr.com/api/v1.1/people", r.to_url, "Should have saved the right url in the request"
		assert_equal "http://project.stretchr.com/api/v1.1/people", t.requests.first[:uri].to_s, "Should have created the right URL and sent it to the transporter"
	end
end
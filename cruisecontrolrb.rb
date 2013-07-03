require 'httparty'
require 'nokogiri'

class Cruisecontrolrb

  include HTTParty

  def initialize base_url, username = nil, password = nil, number
    @auth = { :username => username, :password => password }
    @base_url = base_url
    @number = number - 1
  end

  def fetch
    options = { :basic_auth => @auth }

    noko = Nokogiri::XML(self.class.get("http://#{@base_url}/XmlStatusReport.aspx", options).parsed_response)

    return {} unless project = noko.search("Project")[@number]
    status_hash = { :lastBuildStatus => project.attributes["lastBuildStatus"].value,
      :webUrl => project.attributes["webUrl"].value,
      :lastBuildLabel => project.attributes["lastBuildLabel"].value,
      :activity => project.attributes["activity"].value,
      :projectName => project.attributes["name"].value }

    link_text = status_hash[:projectName] + ": "
    link_text += status_hash[:activity] == "Building" ? "build" : status_hash[:lastBuildStatus]

    url = status_hash[:webUrl].gsub("projects", "builds")

    status_hash[:link_to_build] = "<a href=\"" + url + "/" + status_hash[:lastBuildLabel] +
      "\">" + link_text + "</a>"

    status_hash
  end

end
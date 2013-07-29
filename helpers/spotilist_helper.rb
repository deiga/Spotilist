
def env(varname)
  ENV.fetch(varname) do
    raise ConfigurationError, "Missing ENV['#{varname}']."
  end
end

class ConfigurationError < StandardError
end

def hallon
  Hallon::Session.instance
end

def cache_for(mins = 1)
  if settings.environment != :development
    response['Cache-Control'] = "public, max-age=#{60*mins}"
  end
end

def logged_in_text
  if hallon.logged_in?
    user = hallon.user.load
    "logged in as #{link_to user.name, user}"
  else
    "lot logged in"
  end
end

def link_to(text, object)
  link = object.to_link
  %Q{<a class="#{link.type}" href="/#{link.to_uri}">#{text}</a>}
end

def image_to(image_link)
  %Q{<img src="/#{image_link.to_str}" class="#{image_link.type}">}
end

def uri_for(type)
  lambda do |uri|
    uri = uri.sub(%r{\A/}, '')
    return unless Hallon::Link.valid?(uri)
    return unless Hallon::Link.new(uri).type == type
    Hallon::URI.match(uri)
  end.tap do |matcher|
    matcher.singleton_class.send(:alias_method, :match, :call)
  end
end

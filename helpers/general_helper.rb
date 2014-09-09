def add_leading_zero(number)
  number.to_s.length < 2 ? "0#{number}" : number
end

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
  return false if settings.environment == :development
  response['Cache-Control'] = "public, max-age=#{60 * mins}"
end

def logged_in_text
  if hallon.logged_in?
    user = hallon.user.load
    "logged in as #{link_to user.name, user}"
  else
    'not logged in'
  end
end

def link_to(text, object)
  link = object.to_link
  %(<a class="#{link.type}" href="#{url('/' + link.to_uri)}">#{text}</a>)
end

def image_to(image_link)
  %(<img src="#{url '/' + image_link.to_str}" class="#{image_link.type}">)
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

class ApplicationController < ActionController::Base
  protect_from_forgery

  # Get a unique HTML hex color for a particular string
  def web_color(string)
    hashable = "#{string}"
    "#" + Digest::SHA1.hexdigest(hashable)[0..5]
  end

end

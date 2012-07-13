module ApplicationHelper

  # Get a unique HTML hex color for a particular deployment environment
  def uniq_env_color(environment)
    environment = environment.to_s.downcase
    case environment
      when 'production'
        return "#FF7F02" # orange-red
      when 'staging', 'princess'
        return "#007211" # green
      when 'qa'
        return "#2A68F7" # blue
      else
        return uniq_color(environment)
      end
  end

  # Get a unique HTML hex color for a particular string
  def uniq_color(string)
    "#" + Digest::SHA1.hexdigest(string)[0..5]
  end
end

if defined?(ChefSpec)
  ChefSpec.define_matcher :firewall_ex

  # Temporary matcher since firewall cookbook is missing it.
  def allow_firewall_rule(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall_rule, :allow, resource_name)
  end
end

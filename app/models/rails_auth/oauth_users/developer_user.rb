class DeveloperUser < OauthUser
  attribute :provider, :string, default: 'developer'

  def save_info(oauth_params)

  end

end unless RailsAuth.config.disabled_models.include?('DeveloperUser')

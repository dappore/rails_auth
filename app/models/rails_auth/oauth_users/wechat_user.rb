class WechatUser < OauthUser
  attribute :provider, :string, default: 'wechat'
  has_one :same_wechat_user, -> (o){ where.not(id: o.id, unionid: nil, user_id: nil) }, class_name: self.name, foreign_key: :unionid, primary_key: :unionid

  def sync_user_info
    userinfo_url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{uid}"
    user_response = HTTParty.get(userinfo_url)
    res = JSON.parse(user_response)

    if res['errcode'].present?
      self.errors.add :base, "#{res['errcode']}, #{res['errmsg']}"
    end

    info_params = res.slice('nickname', 'headimgurl')
    assign_user_info(info_params)

    raw_info = res.slice('unionid')
    assign_raw_info(raw_info)
    self
  end

  def assign_info(oauth_params)
    info_params = oauth_params.fetch('info', {})
    assign_user_info(info_params)

    raw_info = oauth_params.dig('extra', 'raw_info') || {}
    assign_raw_info(raw_info)

    credential_params = oauth_params.fetch('credentials', {})
    credential_params['access_token'] = credential_params['token']
    assign_token_info(credential_params)
  end

  def assign_token_info(credential_params)
    self.access_token = credential_params['access_token']
    self.refresh_token = credential_params['refresh_token']
    self.expires_at = credential_params['expires_in']
  end

  def assign_user_info(info_params)
    self.name = info_params['nickname']
    self.avatar_url = info_params['headimgurl']
  end

  def assign_raw_info(raw_info)
    self.unionid = raw_info['unionid']
    self.user_id = same_wechat_user&.user_id if self.unionid
  end

  def save_info(oauth_params)
    assign_info(oauth_params)
    self.save
  end

end unless RailsAuth.config.disabled_models.include?('WechatUser')

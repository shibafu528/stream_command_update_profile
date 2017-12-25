# -*- coding: utf-8 -*-

Plugin.create(:stream_command_update_profile) do

  defspell(:update_profile_name, :twitter) do |twitter, name:|
    (twitter/'account/update_profile').json(name: name)
  end

  defspell(:update_profile_location, :twitter) do |twitter, location:|
    (twitter/'account/update_profile').json(location: location)
  end

  defspell(:update_profile_url, :twitter) do |twitter, url:|
    (twitter/'account/update_profile').json(url: url)
  end

  defspell(:update_profile_biography, :twitter) do |twitter, biography:|
    (twitter/'account/update_profile').json(description: biography)
  end

  def update_name(service, message,
                  prefix: UserConfig[:sc_update_profile_prefix],
                  suffix: UserConfig[:sc_update_profile_suffix])
    # changed?
    prefix_changed = prefix != UserConfig[:sc_update_profile_prefix]
    suffix_changed = suffix != UserConfig[:sc_update_profile_suffix]
    
    # save prefix/suffix
    UserConfig[:sc_update_profile_prefix] = prefix
    UserConfig[:sc_update_profile_suffix] = suffix

    # compose new name
    base_name = UserConfig[:sc_update_profile_base_name]
    new_name = (prefix + base_name + suffix)[0..49]
    overflow = (prefix + base_name + suffix) != new_name

    # update profile
    (service.twitter/'account/update_profile').json(name: new_name).next do
      msg = "@" + message.user.idname + " "
      msg += case
             when prefix_changed && suffix_changed
               prefix = "(未設定)" if prefix.empty?
               suffix = "(未設定)" if suffix.empty?
               "接頭辞を[#{prefix}]、接尾辞を[#{suffix}]にしました。"
             when prefix_changed && prefix.empty?
               "接頭辞を消去しました。"
             when prefix_changed
               "接頭辞を[#{prefix}]に変更しました。"
             when suffix_changed && suffix.empty?
               "接尾辞を消去しました。"
             when suffix_changed
               "接尾辞を[#{suffix}]に変更しました。"
             else
               "接頭辞および接尾辞の変更は行なわれていません。"
             end
      if overflow
        msg += "文字数オーバーのため、切り詰めています。"
      end
      service.twitter.update(message: msg, replyto: message.id)
    end
  end

  # -----------------------------------

  stream_command(:update_name,
                 private: true) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    (service.twitter/'account/update_profile').json(name: args[0]).next do
      service.twitter.update(message: "@#{msg.user.idname} 名前を[#{args[0]}]に設定しました。",
                             replyto: msg.id)
    end
  end

  # -----------------------------------

  command_alias :update_location, :update_locate

  stream_command(:update_location,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    (service.twitter/'account/update_profile').json(location: args[0]).next do
      service.twitter.update(message: ".@#{msg.user.idname}さんの指示でプロフィールのロケーション情報を\"#{args[0]}\"に変更しました (#{Time.now})",
                             replyto: msg.id)
    end
  end

  # -----------------------------------

  stream_command(:update_prefix,
                  rate_limit: 3,
                  rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    
    if args[0] == 'clear'
      update_name(service, msg, prefix: '')
    else
      update_name(service, msg, prefix: args[0])
    end
  end

  # -----------------------------------

  stream_command(:update_suffix,
                  rate_limit: 3,
                  rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    if args[0] == 'clear'
      update_name(service, msg, suffix: '')
    else
      update_name(service, msg, suffix: args[0])
    end
  end

  # -----------------------------------

  stream_command(:get_prefix,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    prefix = UserConfig[:sc_update_profile_prefix]
    service.twitter.update(message: "@#{msg.user.idname} 現在の接頭辞は[#{prefix}]です。",
                           replyto: msg.id)
  end

  # -----------------------------------

  stream_command(:get_suffix,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    suffix = UserConfig[:sc_update_profile_suffix]
    service.twitter.update(message: "@#{msg.user.idname} 現在の接尾辞は[#{suffix}]です。",
                           replyto: msg.id)
  end

  # -----------------------------------

  stream_command(:reset_base_name,
                 private: true) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    UserConfig[:sc_update_profile_base_name] = args[0]
    (service.twitter/'account/update_profile').json(name: args[0]).next do
      service.twitter.update(message: "@#{msg.user.idname} 基本名を[#{args[0]}]に設定しました",
                             replyto: msg.id)
    end

  end

  # -----------------------------------

  stream_command(:set_base_name,
                 private: true) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    UserConfig[:sc_update_profile_base_name] = args[0]
    service.twitter.update(message: "@#{msg.user.idname} 基本名を[#{args[0]}]に設定しました",
                           replyto: msg.id)

  end

  # -----------------------------------

  stream_command(:get_base_name,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    base_name = UserConfig[:sc_update_profile_base_name]
    service.twitter.update(message: "@#{msg.user.idname} 現在の基本名は[#{base_name}]です。",
                           replyto: msg.id)
  end
end

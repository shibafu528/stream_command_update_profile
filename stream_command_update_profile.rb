# -*- coding: utf-8 -*-

Plugin.create(:stream_command_update_profile) do

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

  stream_command(:update_suffix,
                  rate_limit: 3,
                  rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    base_name = UserConfig[:sc_update_profile_base_name]

    if args[0] == 'clear'
      (service.twitter/'account/update_profile').json(name: base_name).next do
        UserConfig[:sc_update_profile_suffix] = ''
        service.twitter.update(message: "@#{msg.user.idname} 接尾辞を消去します",
                               replyto: msg.id)
      end
    else
      (service.twitter/'account/update_profile').json(name: base_name + args[0]).next do
        UserConfig[:sc_update_profile_suffix] = args[0]
        service.twitter.update(message: "@#{msg.user.idname} 接尾辞を\"#{args[0]}\"に変更します",
                               replyto: msg.id)
      end
    end
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

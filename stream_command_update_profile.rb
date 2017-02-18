# -*- coding: utf-8 -*-

Plugin.create(:stream_command_update_profile) do

  # -----------------------------------

  command_private :update_name

  on_command_update_name do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    (service.twitter/'account/update_profile').json(name: args[0]).next do
      service.twitter.update(message: "@#{msg.user.idname} 名前を[#{args[0]}]に設定しました。",
                             replyto: msg.id)
    end
  end

  # -----------------------------------

  command_rate_limit :update_location, 3, 15
  command_alias :update_location, :update_locate

  on_command_update_location do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    (service.twitter/'account/update_profile').json(location: args[0]).next do
      service.twitter.update(message: ".@#{msg.user.idname}さんの指示でプロフィールのロケーション情報を\"#{args[0]}\"に変更しました (#{Time.now})",
                             replyto: msg.id)
    end
  end

  # -----------------------------------

  command_rate_limit :update_suffix, 3, 15
  
  on_command_update_suffix do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    base_name = UserConfig[:sc_update_profile_base_name]

    if args[0] == 'clear'
      (service.twitter/'account/update_profile').json(name: base_name).next do
        service.twitter.update(message: "@#{msg.user.idname} 接尾辞を消去します",
                               replyto: msg.id)
      end
    else
      (service.twitter/'account/update_profile').json(name: base_name + args[0]).next do
        service.twitter.update(message: "@#{msg.user.idname} 接尾辞を\"#{args[0]}\"に変更します",
                               replyto: msg.id)
      end
    end
  end

  # -----------------------------------

  command_private :set_base_name

  on_command_set_base_name do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    UserConfig[:sc_update_profile_base_name] = args[0]
    service.twitter.update(message: "@#{msg.user.idname} 基本名を[#{args[0]}]に設定しました",
                           replyto: msg.id)

  end

  # -----------------------------------

  command_rate_limit :get_base_name, 3, 15

  on_command_get_base_name do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }

    base_name = UserConfig[:sc_update_profile_base_name]
    service.twitter.update(message: "@#{msg.user.idname} 現在の基本名は[#{base_name}]です。",
                           replyto: msg.id)
  end
end

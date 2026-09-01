=begin
           メッセージウィンドウ表示/非表示
  機能
  Bボタンを押すと、メッセージウィンドウを表示/非表示
  
  再定義箇所
  Window_Message

=end
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　文章表示に使うメッセージウィンドウです。
#==============================================================================

class Window_Message < Window_Base
  def update_winoff
    unless $game_party.in_battle #バトル中は無効。
      if Input.trigger?(Input::L)
        if self.visible == true
          self.visible = false
          @background = 777 if @back_sprite != nil and @background == 1 #「背景を暗くする」
          @tail.visible = false if @tail != nil
        else
          self.visible = true
          @background = 1 if @back_sprite != nil and @background == 777 #「背景を暗くする」
        end
        if @name_window != nil
          if @name_window.visible == false and $name != nil and $name != ""
            @name_window.visible = true
            @name_sprite.visible = true
          else
            @name_window.visible = false
            @name_sprite.visible = false
          end
        end
      elsif Input.trigger?(Input::C) or Input.trigger?(Input::B)
        if self.visible == false
          self.visible = true 
          @back_sprite.visible = true unless @back_sprite
        end
        @tail.visible = true if @tail != nil and @tail.visible == false
        if @name_window != nil and $name != nil
          if $name != ""
            @name_window.visible = true
            @name_sprite.visible = true
          end
        end
      end
    end
    update_winoff_default
  end
  alias :update_winoff_default :update
  alias :update :update_winoff
end

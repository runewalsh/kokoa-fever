class Scene_Battle
  #--------------------------------------------------------------------------
  # ● アクターコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias saba_kiseki_escape_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    saba_kiseki_escape_create_actor_command_window
    @actor_command_window.set_handler(:escape, method(:command_escape))
  end
end

class Window_ActorCommand
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias saba_kiseki_escape_make_command_list make_command_list
  def make_command_list
    saba_kiseki_escape_make_command_list
    add_command(Vocab::escape, :escape, BattleManager.can_escape?)
  end
end
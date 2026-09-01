#==============================================================================
# ■ステートの残りターンを表示 for RGSS3 Ver1.01-β
# □作成者 kure
#==============================================================================

#==============================================================================
# ■ RPG::State(追加定義)
#==============================================================================
class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆残りターン非表示の定義(追加定義)
  #--------------------------------------------------------------------------  
  def view_turns?
    return true unless @note
    return false if @note.include?("<残りターン非表示>")
    return true
  end
end

#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● ステートおよび強化／弱体のアイコンを描画(再定義)
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = (actor.state_icons_adv + actor.buff_icons_adv)[0, width / 24]
    
    last = contents.font.size
    contents.font.size = 18
    change_color(crisis_color)
    icons.each_with_index {|n, i| draw_state_icon_turns(n, x + 24 * i, y) }
    change_color(normal_color)
    contents.font.size = last
    
  end
  #--------------------------------------------------------------------------
  # ● 残りのターンを加えたアイコンの描画(追加定義)
  #--------------------------------------------------------------------------
  def draw_state_icon_turns(data, x, y)
    draw_icon(data[0], x, y)
    draw_text(x + 12, y + 8, 12, 18, data[1],2)
  end
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 現在のステートをアイコンINDEX、残りターン、ステートIDで取得(追加定義)
  #--------------------------------------------------------------------------
  def state_icons_adv
    icons = states.collect {|state| [state.icon_index, @state_turns[state.id], state.id] }
    for i in 0..icons.size - 1
      if icons[i][0] == 0
        icons[i] = nil
      else
        icons[i][1] = "" if $data_states[icons[i][2]].auto_removal_timing == 0
        icons[i][1] = "" unless $data_states[icons[i][2]].view_turns?
      end
    end
    icons.compact!
    return icons
  end
  #--------------------------------------------------------------------------
  # ● 現在の強化／弱体をアイコンINDEX、残りターンで取得(追加定義)
  #--------------------------------------------------------------------------
  def buff_icons_adv
    icons = []
    @buffs.each_with_index {|lv, i| [icons.push(buff_icon_index(lv, i)),@buff_turns[i]] }
    for i in 0..icons.size - 1
      icons[i] = nil if icons[i][0] == 0
    end
    icons.compact!
    return icons
  end
end
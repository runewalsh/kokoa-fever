=begin
  能力の限界を突破するスクリプト。
　上限突破の方法はデータベースの『特徴』らんの『通常能力値』の倍率変更と
装備による上限の突破。
　また、攻撃力～運までの能力値の表示を修正。
new 敵キャラの能力値を直接指定できるように。
  @ステータス[値]で指定　ステータスは{mhp,mmp,atk,def,mat,mdf,agi,luk}の八つ
new 武器、防具の値を直接指定できるように。
  @ステータス[値]で指定　ステータスは{hp,mp,atk,def,mat,mdf,agi,luk}の八つ
new  下限値を減らす　HP 1　MP 0 その他 -9999 に

@hp[1000] 敵は@mhp[1000]
@mp[]
@atk[]

=end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    equips.compact.inject(super) {|r, item| 
      item.paramm
      r += item.params[param_id] 
    }
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の最小値取得 [再定義]
  #--------------------------------------------------------------------------
  def param_min(param_id)
    return super
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得 [再定義]
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return super
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 通常能力値の最小値取得 [再定義]
  #--------------------------------------------------------------------------
  def param_min(param_id)
    return 1 if param_id == 0  # MHP
    return 0 if param_id == 1  # MMP
    return -99999
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得 [再定義]
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 999999999999999 if param_id == 0  # MHP
    return 9999999999999 if param_id == 1  # MMP
    return 999999999999999
  end
end

class Game_Enemy < Game_Battler
  def param_base(param_id)

    case param_id
    when 0
      n = enemy.note.scan(/@mhp\[(\d+)\]/)
    when 1
      n = enemy.note.scan(/@mmp\[(\d+)\]/)
    when 2
      n = enemy.note.scan(/@atk\[(\d+)\]/)
    when 3
      n = enemy.note.scan(/@def\[(\d+)\]/)
    when 4
      n = enemy.note.scan(/@mat\[(\d+)\]/)
    when 5
      n = enemy.note.scan(/@mdf\[(\d+)\]/)
    when 6
      n = enemy.note.scan(/@agi\[(\d+)\]/)
    when 7
      n = enemy.note.scan(/@luk\[(\d+)\]/)
    end
      
    return enemy.params[param_id] if n.empty?
    return n[0][0].to_i
    
  end
end

#--------------------------------------------------------------------------
#  ウィンドウ制御
#--------------------------------------------------------------------------
  
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 能力値の描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 100, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 100, y, 42, line_height, actor.param(param_id), 2)
  end
end

class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 項目の描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 80, y, param_id) if @actor
    draw_right_arrow(x + 120, y)
    draw_new_param(x + 140, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ● 能力値の名前を描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #--------------------------------------------------------------------------
  # ● 現在の能力値を描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 42, line_height, @actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ● 右向き矢印を描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 20, line_height, "→", 1)
  end
  #--------------------------------------------------------------------------
  # ● 装備変更後の能力値を描画 [再定義]
  #--------------------------------------------------------------------------
  def draw_new_param(x, y, param_id)
    new_value = @temp_actor.param(param_id)
    change_color(param_change_color(new_value - @actor.param(param_id)))
    draw_text(x, y, 42, line_height, new_value, 2)
  end
end


class RPG::EquipItem < RPG::BaseItem
  def initialize
    super
    @price = 0
    @etype_id = 0
    @params = [0] * 8
  end
  
  def paramm
    n = note.scan(/@hp\[(\d+)\]/)
    @params[0] = n[0][0].to_i if !n.empty?
    n = note.scan(/@mp\[(\d+)\]/)
    @params[1] = n[0][0].to_i if !n.empty?
    n = note.scan(/@atk\[(\d+)\]/)
    @params[2] = n[0][0].to_i if !n.empty?
    n = note.scan(/@def\[(\d+)\]/)
    @params[3] = n[0][0].to_i if !n.empty?
    n = note.scan(/@mat\[(\d+)\]/)
    @params[4] = n[0][0].to_i if !n.empty?
    n = note.scan(/@mdf\[(\d+)\]/)
    @params[5] = n[0][0].to_i if !n.empty?
    n = note.scan(/@agi\[(\d+)\]/)
    @params[6] = n[0][0].to_i if !n.empty?
    n = note.scan(/@luk\[(\d+)\]/)
    @params[7] = n[0][0].to_i if !n.empty?
  end
end
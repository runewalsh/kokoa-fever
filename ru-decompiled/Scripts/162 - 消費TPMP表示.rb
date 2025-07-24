#==============================================================================
# ■ MP/TP表示 kusotool script Ver. 1.00
#------------------------------------------------------------------------------
# 　スキルがMPとTPの両方を消費する場合、デフォルトでは消費TPのみ表示されますが
# 　両方の消費量を表示するように変更します
#==============================================================================

#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　スキル画面で、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================
class Window_SkillList
  alias kusotool_draw_skill_cost draw_skill_cost
  def draw_skill_cost(rect, skill)
    if @actor.skill_tp_cost(skill) > 0 && @actor.skill_mp_cost(skill) > 0
      x = rect.x
      y = rect.y
      w = rect.width
      h = rect.height

      change_color(tp_cost_color, enable?(skill))
      draw_text(x, y, w, h, @actor.skill_tp_cost(skill), 2)
      w -= @actor.skill_tp_cost(skill).to_s.length * contents.font.size * 3 / 8
      change_color(system_color)
      draw_text(x, y, w, h, '/', 2)
      w -= contents.font.size * 3 / 8
      change_color(mp_cost_color, enable?(skill))
      draw_text(x, y, w, h, @actor.skill_mp_cost(skill), 2)
    else
      kusotool_draw_skill_cost(rect, skill)
    end
  end
end


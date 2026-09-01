#==============================================================================
# ■バトルリザルト for RGSS3 Ver1.00-β3
# □作成者 kure
#
# 導入位置：併用化ベーススクリプト、職業レベルスクリプトより下
#===============================================================================

$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:BattleResult] = 0
p "バトルリザルト"

module KURE
  module BattleResult
    #経験値バーのアニメーションにかけるフレーム数(0にしない事)
    ANIMATION_TIME = 80
    
    #成功時のSEの演奏可否(0=OFF 1=ON)
    LEVEL_UP_SE_PLAY = 1
    
    #成功時SEの設定[ファイル名,ボリューム,ピッチ]
    LEVEL_UP_SE = ['Chime2',100,100]
  end
end

#==============================================================================
# ▲ BattleManager(再定義)
#==============================================================================
class << BattleManager
  #--------------------------------------------------------------------------
  # ● お金の獲得と表示(再定義)
  #--------------------------------------------------------------------------
  def gain_gold
    if $game_troop.gold_total > 0
      $game_party.gain_gold($game_troop.gold_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの獲得と表示(再定義)
  #--------------------------------------------------------------------------
  def gain_drop_items
    @drop_item = []
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      @drop_item.push(item)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 待機用処理(追加定義)
  #--------------------------------------------------------------------------
  def waiting_process
    if ($game_party.battle_members.size - 1).div(5) > 0
    if Input.trigger?(:L)
      @result_window.pt_copy
      
      @result_window.page += 1
      KURE::BattleResult::ANIMATION_TIME.times{|i|
        @result_window.refresh_2(i)
        call_wait
      }
    end
    
    if Input.trigger?(:R)
      @result_window.pt_copy
      @result_window.page -= 1
      KURE::BattleResult::ANIMATION_TIME.times{|i|
        @result_window.refresh_2(i)
        call_wait
      }
    end
    end
    Graphics.update
    Input.update
  end
  #--------------------------------------------------------------------------
  # ● 待機用処理(追加定義)
  #--------------------------------------------------------------------------
  def call_wait
    Graphics.update
    Input.update
  end
  #--------------------------------------------------------------------------
  # ● リザルトのデータ(追加定義)
  #--------------------------------------------------------------------------
  def result_data
    data = [[0,"Exp"],[0,"JobExp"],[0,"獲得" + Vocab::currency_unit],[0,"装備Exp"],[0,"獲得AP"],[0,"StatusPoint"],[0,"SkillPoint"]]
    data[0][0] = $game_troop.exp_total
    data[1][0] = $game_troop.jobexp_total if $kure_base_script[:JobLvSystem]
    data[2][0] = $game_troop.gold_total
    data[3][0] = $game_troop.equip_exp_total if $kure_base_script[:SortOut]
    data[4][0] = $game_troop.ability_exp_total
    data[5][0] = $game_troop.status_exp_total
    data[6][0] = $game_troop.skill_exp_total
    return data
  end
  #--------------------------------------------------------------------------
  # ● リザルトのデータ(追加定義)
  #--------------------------------------------------------------------------
  def party_data_set
    @party_data = []
    $game_party.battle_members.each do |actor|
      next unless actor
      if $kure_base_script[:JobLvSystem]
        basic_class_id = $data_actors[actor.id].use_exp_curve
        basic_class_id = actor.class_id if basic_class_id == 0
      else
        basic_class_id = actor.class_id
      end
      @party_data[actor.id] = [0,0,0,0,0,0,0,0,0,[],0,0]
      @party_data[actor.id][0] = actor.exp
      @party_data[actor.id][1] = actor.jobexp if $kure_base_script[:JobLvSystem]
      @party_data[actor.id][2] = 0
      @party_data[actor.id][3] = basic_class_id
      @party_data[actor.id][4] = actor.class_id if $kure_base_script[:JobLvSystem]
      @party_data[actor.id][5] = 0
      @party_data[actor.id][6] = actor.level
      @party_data[actor.id][7] = actor.joblevel if $kure_base_script[:JobLvSystem]
      @party_data[actor.id][8] = 0
      @party_data[actor.id][9] = actor.learned_skill_list.clone
      @party_data[actor.id][10] = actor.exr
      @party_data[actor.id][11] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● リザルトのデータ(追加定義)
  #--------------------------------------------------------------------------
  def skill_data_set
    basic_data = [] ; @skill_data = []
    $game_party.battle_members.each do |actor|
      next unless actor
      next if actor.learned_skill_list - @party_data[actor.id][9] == []
      basic_data.push([actor.id, actor.learned_skill_list - @party_data[actor.id][9]])
    end
    
    line = 11 ; block = 0
    basic_data.each do |data|
      line -= (2 + data[1].size.div(3))
      if line >= 0
        @skill_data[block] = [] unless @skill_data[block]
        @skill_data[block].push(data)
      end
      if line < 0
        line = 11 ; block += 1
        @skill_data[block] = [] unless @skill_data[block]
        @skill_data[block].push(data)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● リザルトの表示(追加定義)
  #--------------------------------------------------------------------------
  def show_result_window
    skill_data_set
    @result_window = Window_k_BattleResult.new(result_data,@party_data,@drop_item)
    20.times{waiting_process}
    @result_window.pt_copy
    
    KURE::BattleResult::ANIMATION_TIME.times{|i|
      @result_window.refresh_2(i)
      call_wait
    }
    
    if @drop_item != []
      waiting_process until Input.trigger?(:C)
      @result_window.refresh_3
      10.times{call_wait}
    end
    
    @skill_data.each do |data|
      waiting_process until Input.trigger?(:C)
      @result_window.refresh_4(data)
      10.times{call_wait}
    end
    
    call_wait until Input.trigger?(:C)
    @result_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 勝利の処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_process_victory process_victory
  def process_victory
    party_data_set
    k_before_process_victory
  end
end

#==============================================================================
# ■ Game_Actor(再定義項目集積)
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ▲ レベルアップメッセージの表示(再定義)
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
  end
  #--------------------------------------------------------------------------
  # ▲ レベルアップメッセージの表示(追加定義)
  #--------------------------------------------------------------------------
  def display_job_level_up(new_skills, job = 0, sub = 0)
  end
  #--------------------------------------------------------------------------
  # ▲ APシステムによるスキル習得メッセージの表示(再定義)
  #--------------------------------------------------------------------------
  def display_ap_skilll_learn(new_skills)
  end
end

#==============================================================================
# ■ Window_k_BattleResult
#==============================================================================
class Window_k_BattleResult < Window_Base
  attr_accessor :page
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(data, party,items)
    @data = data
    @party = party
    @items = items
    @page = 0
    @need_refresh = []
    @gauge = [0,0]
    wx = (Graphics.width - 520) / 2
    wy = 15
    ww = 520
    wh = 300
    super(wx, wy, ww, wh)
    refresh_1
  end
  #--------------------------------------------------------------------------
  # ● ページ設定
  #--------------------------------------------------------------------------
  def page=(index)
    @page = index
    max = ($game_party.battle_members.size - 1).div(5)
    @page = 0 if @page > max
    @page = max if @page < 0
    return if max == 0
    refresh_1
  end
  #--------------------------------------------------------------------------
  # ● ページ設定
  #--------------------------------------------------------------------------
  def pt_copy
    @task_party = Marshal.load(Marshal.dump(@party))
    @task_oldlevel = Marshal.load(Marshal.dump(@old_level))
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ(ベース)
  #--------------------------------------------------------------------------
  def refresh_1
    contents.clear
    title_gauge_drawing(0,0,"戦闘結果")
    draw_text(0, 0, contents.width, line_height, "LR:6人目以降表示切替", 2)if $game_party.battle_members.size > 5
    index = 1
    
    @old_level = [] ; @need_refresh = [] ; @gauge = []
    $game_party.battle_members.each do |actor|
      @old_level[actor.id] = [@party[actor.id][6],@party[actor.id][7]]
    end
    
    #獲得経験値表示
    @data.each do |exp|
      next if exp[0] == 0
      change_color(system_color)
      draw_text(0, line_height * index, 150, line_height, exp[1])
      change_color(normal_color)
      draw_text(0, line_height * index, 150, line_height, exp[0], 2)
      index += 1
    end
    
    #ページにより表示する範囲を設定
    first = 5 * @page 
    last = [4 * (@page + 1),$game_party.battle_members.size].min
    
    index = 0
    #アクターのグラフィック、ゲージのベーシックを描画
    $game_party.battle_members[first..last].each do |actor|
      next unless actor
      @gauge[actor.id] = [-1,-1]
      actor_data = @party[actor.id]
      
      draw_actor_harf_face(165 ,24 + 48 * index,actor)
      change_color(system_color)
      
      draw_text(265, 24 + 48 * index, 50, line_height, "Base", 2)
      
      #ベースのゲージを描画
      if actor.max_level > @old_level[actor.id][0]
        exp_gauge_drawing(320, 30 + 48 * index, actor_data, 0, mp_gauge_color2, mp_gauge_color1, actor.id)
      end
      
      if $kure_base_script[:JobLvSystem]
        draw_text(265, 48 + 48 * index, 50, line_height, "Job", 2)
        if actor.max_joblevel > @old_level[actor.id][1]
          exp_gauge_drawing(320, 54 + 48 * index, actor_data, 1, tp_gauge_color2, tp_gauge_color1, actor.id)
        end
      end
    
      change_color(normal_color)
      index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh_2(count)
    first = 5 * @page 
    last = [4 * (@page + 1),$game_party.battle_members.size].min
    
    g_exp = @data[0][0].to_f / KURE::BattleResult::ANIMATION_TIME
    g_jexp = @data[1][0].to_f / KURE::BattleResult::ANIMATION_TIME
    
    index = 0
    change_color(power_up_color)
    $game_party.battle_members[first..last].each do |actor|
      
      actor_data = @task_party[actor.id]
      
      #EXPの獲得
      actor_data[0] += (g_exp * actor_data[10])
      actor_data[1] += (g_jexp * actor_data[10])
      
      #レベルアップの処理
      if actor.max_level > actor_data[6]
      while actor_data[0] >= $data_classes[actor_data[3]].exp_for_level(actor_data[6] + 1) do
        #レベルを1上げる
        actor_data[6] += 1
        contents.clear_rect(425, 24 + 48 * index, 80, line_height)
        play_lv_up_se
        draw_text(425, 24 + 48 * index, 80, line_height, (actor_data[6] - @task_oldlevel[actor.id][0]).to_s + "LvUP")

        #ゲージの背景を初期化
        contents.fill_rect(320, 30 + 48 * index, 100, 12, gauge_back_color)
      end
      end
      
      #職業レベルのレベルアップ処理
      if $kure_base_script[:JobLvSystem]
        if actor.max_joblevel > actor_data[7]
        while actor_data[1] >= $data_classes[actor_data[4]].exp_for_level(actor_data[7] + 1) do
          #レベルを1上げる
          actor_data[7] += 1
          contents.clear_rect(425, 48 + 48 * index, 80, line_height)
          play_lv_up_se
          draw_text(425, 48 + 48 * index, 80, line_height, (actor_data[7] - @task_oldlevel[actor.id][1]).to_s + "JOBUP")
      
          #ゲージの背景を初期化
          contents.fill_rect(320, 54 + 48 * index, 100, 12, gauge_back_color)
        end
        end
      end
          
      #ベースのゲージを描画
      if actor.max_level > actor_data[6]
        exp_gauge_drawing(320, 30 + 48 * index, actor_data, 0, mp_gauge_color2, mp_gauge_color1, actor.id)
      end
      
      #職業レベルのゲージを描画
      if $kure_base_script[:JobLvSystem]
        if actor.max_joblevel > actor_data[7]
          exp_gauge_drawing(320, 54 + 48 * index, actor_data, 1, tp_gauge_color2, tp_gauge_color1, actor.id)
        end
      end
      index += 1
    end
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh_3
    contents.clear
    title_gauge_drawing(0,0,"獲得アイテム")    
    index = 0
    pos_y = 0
    @items.each do |item|
      pos_x = 175 * index.modulo(2)
      pos_y = 1 + index.div(2)
      draw_item_name(item, pos_x, line_height * pos_y)
      index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh_4(skill_data)
    contents.clear
    index = 0
    skill_data.each do |actor_obj|
      title_gauge_drawing(0,line_height * index, $game_actors[actor_obj[0]].name + "の習得スキル")
      index += 1
    
      count = 0
      #習得スキルをチェックする    
      actor_obj[1].each do |item|
        pos_x = 175 * count.modulo(3)
        draw_item_name(item, pos_x, line_height * (index + count.div(3)))
        count += 1
      end
      index += (1 + count.div(3))
    end
  end
  #--------------------------------------------------------------------------
  # ● バーを描画
  #--------------------------------------------------------------------------
  def title_gauge_drawing(x,y,txt)
    draw_gauge(x, y, contents.width, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    draw_text(x, y, 200, contents.font.size, txt)    
  end
  #--------------------------------------------------------------------------
  # ● EXPバーを描画
  #--------------------------------------------------------------------------
  def exp_gauge_drawing(x, y, actor_data, type, color1, color2, id, width = 100)
    now_exp = actor_data[0 + type] - $data_classes[actor_data[3 + type]].exp_for_level(actor_data[6 + type])
    next_exp = $data_classes[actor_data[3 + type]].exp_for_level(actor_data[6 + type] + 1) - $data_classes[actor_data[3 + type]].exp_for_level(actor_data[6 + type])
        
    fill_ew = (width * (now_exp.to_f / next_exp)).to_i
    return if @gauge[id][type] == fill_ew
    contents.fill_rect(x, y, width, 12, gauge_back_color)
    contents.gradient_fill_rect(x + width - fill_ew, y, fill_ew, 12, color2, color1)
    @gauge[id][type] = fill_ew
  end
  #--------------------------------------------------------------------------
  # ● 半分のフェイスグラフィックを描画
  #--------------------------------------------------------------------------
  def draw_actor_harf_face(x,y,actor)
    bitmap = Cache.face(actor.face_name)
    rect = Rect.new(actor.face_index % 4 * 96, actor.face_index / 4 * 96 + 26 , 96, 44)
    contents.blt(x, y, bitmap, rect)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● LvUPのSEを演奏
  #--------------------------------------------------------------------------
  def play_lv_up_se
    return if KURE::BattleResult::LEVEL_UP_SE_PLAY == 0
    sound = KURE::BattleResult::LEVEL_UP_SE
    Audio.se_play('Audio/SE/' + sound[0], sound[1], sound[2])
  end
end
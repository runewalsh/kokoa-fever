#==============================================================================
#  ■スキルメモライズシステム for RGSS3 Ver1.21-β9-fix
#　□author kure、星潟
#
#　呼び出し方法　SceneManager.call(Scene_SkillMemorize)
#　
#==============================================================================
#　※追加イベントコマンド(スクリプトに挿入して使用)
#　　・memory_skill_ad(アクターID, スキルID)
#　　　アクターにメモライズを追加、メモライズ制限無視
#
#　　・memory_skill_ad_l(アクターID, スキルID)
#　　　アクターにメモライズを追加、メモライズ制限適用
#
#　　・memory_skill_dl(アクターID, スキルID)
#  　　アクターのメモライズから指定スキルを削除
#
#　　・memory_skill_dl_all(アクターID)
#　　　アクターのメモライズを初期化
#
#==============================================================================
#　※メモライズ追加設定
#　　メモ欄に「<メモライズ不要>」と書かれたスキルはメモライズ無しで使用可
#　　アクター毎に個別設定したい場合は「<メモライズ不要 1>」と書いて下さい
#==============================================================================
module KURE
  module SkillMemorize
    #基本設定(変更しない事)
    CHAIN_MEMORIZE = []
    
    #動作設定-------------------------------------------------------------------
    #メモライズ適用範囲(0=常に適用 1=戦闘中のみ)
    ADOPT_MEMORIZE = 0
    #LvUP時のメモライズ自動登録(0=OFF、1=ON)
    AUTO_MEMORIZE = 0
    #メモライズ自動登録外のスキルタイプ
    NOT_AUTO_MEMORIZE = []
    
    #表示設定-------------------------------------------------------------------
    #メモライズ容量ゲージの表示(0=表示しない 1=表示する)
    #VIEW_MEMORIZE_GAGE = [スキルタイプ1,スキルタイプ2,…]
    VIEW_MEMORIZE_GAGE = [1,1,1,1,1]
    #メモライズ容量表示(0=表示しない 1=表示する)
    VIEW_MEMORIZE_CAPACITY = 1
    #表示しないスキルタイプの設定
    #NOT_VIEW_SKILLTYPE = [スキルタイプID]
    NOT_VIEW_SKILLTYPE = []
    
    #スキルメモライズ数(記憶数)に関する設定-------------------------------------
    #メモライズ数制限を適用しないスキルタイプ
    #NOT_ADOPT_SKILL_TYPE = [スキルタイプID]
    NOT_ADOPT_MAX_MEMORY_SKILL_TYPE = []
    
    #スキルメモライズ基礎最大数
    #BASE_MAX_MEMORY = [スキルタイプ1,スキルタイプ2,…]
    BASE_MAX_MEMORY = [3,2,150,2,2]
    
    #スキルメモライズ数Lv補正値
    #Lv_MAX_MEMORY = [スキルタイプ1,スキルタイプ2,…]
    Lv_MAX_MEMORY = [0.3,0.2,0.1,0.1,0.1]
    
    #スキルメモライズ上限数(0=上限なし)
    #MAX_MEMORY_CAP = [スキルタイプ1,スキルタイプ2,…]
    MAX_MEMORY_CAP = [0,0,0,0,0]
    
    #メモライズ容量(記憶容量)に関する設定---------------------------------------
    #メモライズ容量制限を適用しないスキルタイプ
    #NOT_ADOPT_SKILL_TYPE = [スキルタイプID]
    NOT_ADOPT_MEMORIZE_CAPACITY_SKILL_TYPE = []
    
    #メモライズ基礎容量
    #BASE_MEMORIZE_CAPACITY = [スキルタイプ1,スキルタイプ2,…]　
    BASE_MEMORIZE_CAPACITY = [1,1,2,1,1]
    
    #メモライズ容量Lv補正値
    #Lv_MEMORIZE_CAPACITY = [スキルタイプ1,スキルタイプ2,…]
    Lv_MEMORIZE_CAPACITY = [0.1,0.1,1.4,0.1,0.1]
    
    #スキルメモライズ上限容量(0=上限なし)
    #MAX_MEMORY_CAP = [スキルタイプ1,スキルタイプ2,…]
    MAX_MEMORIZE_CAP = [0,0,0,0,0]
    
    #メモライズ容量の表示名
    MEMORIZE_CAPACITY_NAME = "CP"

    #スキルに関する設定---------------------------------------------------------
    #チェインメモライズ
    #CHAIN_MEMORIZE[判定順(0～数字を入れていってください)] = [追加スキルID,要求スキルID,要求スキルID,…]
#~     CHAIN_MEMORIZE[0] = [74,76,77,78]
#~     CHAIN_MEMORIZE[1] = [73,96,77,78]
#~     CHAIN_MEMORIZE[2] = [72,96,95,78]
  end
end

#==============================================================================
# ■ Scene_SkillMemorize
#==============================================================================
class Scene_SkillMemorize < Scene_Skill
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    #保存変数
    @keep_index = -1
    
    create_help_window
    create_command_window
    create_status_window
    create_item_window
    create_pop_window
    
    setup_actor
    setup_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成(再定義)
  #--------------------------------------------------------------------------
  def create_item_window
    create_memorized_skill_window
    create_all_skill_window
    @memorized_skill_window.stype_id = @command_window.current_ext
    @learnd_skill_window.stype_id = @command_window.current_ext
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    wy = @help_window.height
    @command_window = Window_k_Skillmemorize_SkillCommand.new(0, wy)
    @command_window.set_handler(:skill,    method(:command_skill))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    y = @help_window.height
    @status_window = Window_k_SkillMemorize_SkillStatus.new(0, y)
    @status_window.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 記憶スキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_memorized_skill_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @memorized_skill_window = Window_k_SkillMemorize_SkillList.new(wx, wy, ww, wh)
    @memorized_skill_window.set_handler(:ok,     method(:on_memorize_ok))
    @memorized_skill_window.set_handler(:cancel, method(:on_memorize_cancel))
    @memorized_skill_window.deactivate
    @memorized_skill_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● 習得スキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_all_skill_window
    wx = Graphics.width / 2
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @learnd_skill_window = Window_k_LearndSkill_SkillList.new(wx, wy, ww, wh)
    @learnd_skill_window.set_handler(:ok,     method(:on_learnd_ok))
    @learnd_skill_window.set_handler(:cancel, method(:on_learnd_cancel))
    @learnd_skill_window.deactivate
    @learnd_skill_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● ポップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_pop_window
    wx = Graphics.width / 4 - 40
    wy = @status_window.y + @status_window.height - 30
    ww = Graphics.width / 2 + 80
    wh = 24 * 2
    @pop_window = Window__k_SkillMemorize_Popup.new(wx,wy,ww,wh)
    @pop_window.z += 100
    @pop_window.back_opacity = 255
    @pop_window.hide
  end
  #--------------------------------------------------------------------------
  # ● アクターのセットアップ
  #--------------------------------------------------------------------------
  def setup_actor
    @command_window.actor = @actor
    @status_window.actor = @actor
    @memorized_skill_window.actor = @actor
    @learnd_skill_window.actor = @actor
    @pop_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウセットアップ
  #--------------------------------------------------------------------------
  def setup_window
    @command_window.help_window = @help_window
    @command_window.memorized_skill_window = @memorized_skill_window
    @command_window.learnd_skill_window = @learnd_skill_window
    @memorized_skill_window.help_window = @help_window
    @learnd_skill_window.help_window = @help_window
    @memorized_skill_window.pop_window = @pop_window
    @command_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● コマンド［スキル］
  #--------------------------------------------------------------------------
  def command_skill
    @command_window.deactivate
    @memorized_skill_window.activate
    @memorized_skill_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し元のシーンへ戻る
  #--------------------------------------------------------------------------
  def return_scene
    @actor.set_passive_skills
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # ● 記憶ウィンドウ［決定］
  #--------------------------------------------------------------------------
  def on_memorize_ok
    if @pop_window.visible == true
      @pop_window.hide
      @memorized_skill_window.activate
      return
    end  
    #選択位置を保存
    @keep_memorize_index = @memorized_skill_window.index
    
    if @memorized_skill_window.data[@keep_memorize_index] != nil
      @learnd_skill_window.select_skill = @memorized_skill_window.data[@keep_memorize_index].id
    end
    
    @memorized_skill_window.deactivate
    @learnd_skill_window.refresh
    @learnd_skill_window.activate
    @learnd_skill_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 記憶ウィンドウ［キャンセル］
  #--------------------------------------------------------------------------
  def on_memorize_cancel
    set_memorize_to_command
  end
  #--------------------------------------------------------------------------
  # ● 習得ウィンドウ［決定］
  #--------------------------------------------------------------------------
  def on_learnd_ok
    #エクストラ配列をセット
    @actor.chain_memorize_set
    
    #セット前のエクストラ配列を取得
    @before_memorize = @actor.extra_skills.collect {|skill| skill.id}

    
    if @learnd_skill_window.data[@learnd_skill_window.index] != nil
      index = @actor.memory_skills.index(@memorized_skill_window.data[@keep_memorize_index])
      @actor.add_memorize_skill(@learnd_skill_window.data[@learnd_skill_window.index].id,index)
    end
    if @memorized_skill_window.data[@keep_memorize_index] != nil
      @actor.delete_memorize_skill(@memorized_skill_window.data[@keep_memorize_index].id)
      max_memorize_cheack
    end

    #エクストラ配列をセット
    @actor.chain_memorize_set
    #セット後のエクトラ配列を取得
    @after_memorize = @actor.extra_skills.collect {|skill| skill.id}
    
    @learnd_skill_window.select_skill = 0
    @command_window.refresh
    @learnd_skill_window.refresh
    @memorized_skill_window.refresh
    set_learnd_to_memorize
    view_popup
  end
  #--------------------------------------------------------------------------
  # ● 習得ウィンドウ［キャンセル］
  #--------------------------------------------------------------------------
  def on_learnd_cancel
    set_learnd_to_memorize
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    @actor.set_passive_skills
    @actor = $game_party.menu_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    @actor.set_passive_skills
    @actor = $game_party.menu_actor_prev
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    setup_actor
    @command_window.select(0)
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 習得→記録の切り替え
  #--------------------------------------------------------------------------
  def set_learnd_to_memorize
    @learnd_skill_window.deactivate
    @learnd_skill_window.unselect
    @learnd_skill_window.select_skill = 0
    @learnd_skill_window.refresh
    @memorized_skill_window.activate
    @memorized_skill_window.select(@keep_memorize_index)
    @pop_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 記録→コマンドの切り替え
  #--------------------------------------------------------------------------
  def set_memorize_to_command
    @memorized_skill_window.deactivate
    @memorized_skill_window.select(0)
    @memorized_skill_window.unselect
    @command_window.activate
    @command_window.select(0)
    @pop_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 記録容量確認
  #--------------------------------------------------------------------------
  def max_memorize_cheack
    unless KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(@command_window.current_ext)
      if @memorized_skill_window.data.size > @actor.max_memorize[@command_window.current_ext - 1]
        for i in @actor.max_memorize[@command_window.current_ext - 1]..@memorized_skill_window.data.size - 1
          @actor.delete_memorize_skill(@memorized_skill_window.data[i].id)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップを表示
  #--------------------------------------------------------------------------
  def view_popup
    flag = 0
    
    if (@before_memorize - @after_memorize).size > 0
      @pop_window.delete_skill = (@before_memorize - @after_memorize)
      flag = 1
    else
      @pop_window.delete_skill = []
    end
    
    if (@after_memorize - @before_memorize).size > 0
      @pop_window.add_skill = (@after_memorize - @before_memorize)
      flag = 1
    else
      @pop_window.add_skill = []
    end
    
    if flag == 1
      @pop_window.refresh
      Audio.se_play("Audio/SE/Chime2")
      @pop_window.show      
    end
  end 
end

#==============================================================================
# ■ Game_Interpreter(追加定義)
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● メモライズ追加(記憶容量無制限)(追加定義)
  #--------------------------------------------------------------------------
  def memory_skill_ad(index, s_id)
    $game_actors[index].add_memorize_skill_ir(s_id, false)
  end
  #--------------------------------------------------------------------------
  # ● メモライズ追加(記憶容量制限)(追加定義)
  #--------------------------------------------------------------------------
  def memory_skill_ad_l(index, s_id)
    $game_actors[index].add_memorize_skill_ir(s_id, true)
  end
  #--------------------------------------------------------------------------
  # ● メモライズ削除(記憶容量制限)(追加定義)
  #--------------------------------------------------------------------------
  def memory_skill_dl(index, s_id)
    $game_actors[index].delete_memorize_skill(s_id)
  end
  #--------------------------------------------------------------------------
  # ● メモライズ初期化(追加定義)
  #--------------------------------------------------------------------------
  def memory_skill_dl_all(index)
    $game_actors[index].memory_skills_dl
  end
end

#==============================================================================
# ■ Window_SkillList(再定義)
#==============================================================================
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテム名の描画(再定義)
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    
    if @actor.extra_skills.include?(item)
      change_color(crisis_color, enabled)
    else
      change_color(normal_color, enabled)
    end
    draw_text(x + 24, y, width, line_height, item.name)
  end
end

#==============================================================================
# ■ Game_Actor(再定義)
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 記憶スキルオブジェクトの配列取得(追加定義)
  #--------------------------------------------------------------------------
  def memory_skills
    fix_memorys
    @memory_skills.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ● 記憶オブジェクト修正(追加定義)
  #--------------------------------------------------------------------------
  def fix_memorys
    for i in 0..@memory_skills.size - 1
      if @skills.include?(@memory_skills[i]) == false
        if @sub_class_skills.include?(@memory_skills[i]) == false
          if added_skills.include?(@memory_skills[i]) == false
            @memory_skills[i] = nil
          end
        end
      end
    end
    @memory_skills.compact!
    chain_memorize_set
  end
  #--------------------------------------------------------------------------
  # ● チェインメモライズのセット(追加定義)
  #--------------------------------------------------------------------------
  def chain_memorize_set
    extra_skills_dl
    return if KURE::SkillMemorize::CHAIN_MEMORIZE.size == 0
    
    for i in 0..KURE::SkillMemorize::CHAIN_MEMORIZE.size - 1
      #判定フラグ
      add_flag = 0
      skill = 0
      
      if KURE::SkillMemorize::CHAIN_MEMORIZE[i].size >= 2
        for j in 1..KURE::SkillMemorize::CHAIN_MEMORIZE[i].size - 1
          if @memory_skills.include?(KURE::SkillMemorize::CHAIN_MEMORIZE[i][j]) == true
          else
            add_flag = 1
          end
        end
      end
      
      if add_flag == 0
        set_extra_skill(KURE::SkillMemorize::CHAIN_MEMORIZE[i][0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● エクストラメモライズの記憶済み判定(追加定義)
  #--------------------------------------------------------------------------
  def extra_skill_memorize?(skill)
    skill.is_a?(RPG::Skill) && @extra_skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● エクストラメモライズ初期化処理(追加定義)
  #--------------------------------------------------------------------------
  def extra_skills_dl
    @extra_skills = []
  end
  #--------------------------------------------------------------------------
  # ● エクストラメモライズの記憶設定(追加定義)
  #--------------------------------------------------------------------------
  def set_extra_skill(skill_id)
    unless skill_memorize?($data_skills[skill_id])
      @extra_skills.push(skill_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● エクストラメモライズオブジェクトの配列取得(追加定義)
  #--------------------------------------------------------------------------
  def extra_skills
    @extra_skills.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ● スキルの記憶済み判定(追加定義)
  #--------------------------------------------------------------------------
  def skill_memorize?(skill)
    skill.is_a?(RPG::Skill) && @memory_skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● スキルを記憶する(追加定義)
  #--------------------------------------------------------------------------
  def add_memorize_skill(skill_id,index)
    unless skill_memorize?($data_skills[skill_id])
      if index != nil
        @memory_skills[index] = skill_id
        @memory_skills.compact!
      else
        @memory_skills.push(skill_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル記憶を削除する(追加定義)
  #--------------------------------------------------------------------------
  def delete_memorize_skill(skill_id)
    @memory_skills.delete(skill_id)
  end  
  #--------------------------------------------------------------------------
  # ● 最大数記憶数(追加定義)
  #--------------------------------------------------------------------------
  def max_memorize
    #基礎値配列を取得
    memorize = Marshal.load(Marshal.dump(KURE::SkillMemorize::BASE_MAX_MEMORY))
    
    #スキルタイプごとの職業補正を取得
    for i in 0..memorize.size - 1
      if self.class.max_memorize_revise[i] != nil
        memorize[i] = memorize[i] + self.class.max_memorize_revise[i]
      end
    end
    
    #Lv補正を加算
    for j in 0..memorize.size - 1
      memorize[j] = memorize[j] + (KURE::SkillMemorize::Lv_MAX_MEMORY[j] * @level).to_i 
    end    
    
    #スキルタイプごとの変数補正を取得
    for i in 0..memorize.size - 1
      if self.class.add_max_memorize_var[i] != nil
        memorize[i] = memorize[i] + $game_variables[self.class.add_max_memorize_var[i]]
      end
    end
    
    #装備補正を加算
    for k in 0..memorize.size - 1
      memorize[k] += all_gain_max_memorize
    end

    #上限値設定
    for j in 0..memorize.size - 1
      memorize[j] = [memorize[j],KURE::SkillMemorize::MAX_MEMORY_CAP[j]].min if KURE::SkillMemorize::MAX_MEMORY_CAP[j] != 0
      if KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(j+1)
        memorize[j] += 999999
      end
    end
    
    return memorize
  end
  #--------------------------------------------------------------------------
  # ● メモライズ容量最大値(追加定義)
  #--------------------------------------------------------------------------
  def max_memorize_capacity
    #基礎値配列を取得
    capacity = Marshal.load(Marshal.dump(KURE::SkillMemorize::BASE_MEMORIZE_CAPACITY))
    
    #スキルタイプごとの職業補正を取得
    for i in 0..capacity.size - 1
      if self.class.memorize_capacity_revise[i] != nil
        capacity[i] = capacity[i] + self.class.memorize_capacity_revise[i]
      end
    end
    
    #スキルタイプごとの変数補正を取得
    for i in 0..capacity.size - 1
      if self.class.add_max_memorize_cap_var[i] != nil
        capacity[i] = capacity[i] + $game_variables[self.class.add_max_memorize_cap_var[i]]
      end
    end
    
    #Lv補正を加算
    for j in 0..capacity.size - 1
      capacity[j] = capacity[j] + (KURE::SkillMemorize::Lv_MEMORIZE_CAPACITY[j] * @level).to_i 
    end    
    
    #装備補正を加算
    for k in 0..capacity.size - 1
      capacity[k] += all_gain_memorize
    end
    
    #上限値設定
    for j in 0..capacity.size - 1
      capacity[j] = [capacity[j],KURE::SkillMemorize::MAX_MEMORIZE_CAP[j]].min if KURE::SkillMemorize::MAX_MEMORIZE_CAP[j] != 0
      if KURE::SkillMemorize::NOT_ADOPT_MEMORIZE_CAPACITY_SKILL_TYPE.include?(j+1)
        capacity[j] += 999999
      end
    end     
    
    return capacity
  end
  #--------------------------------------------------------------------------
  # ● メモライズ容量(追加定義)
  #--------------------------------------------------------------------------
  def memorize_capacity(stype_id)
    fix_memorys
    capacity = 0
    for i in 0..@memory_skills.size - 1
      if $data_skills[@memory_skills[i]].stype_id  == stype_id
        capacity = capacity + $data_skills[@memory_skills[i]].memorize_capacity
      end
    end
    return capacity
  end
  #--------------------------------------------------------------------------
  # ● イベントコマンド用メモライズ追加処理(追加定義)
  #--------------------------------------------------------------------------
  def add_memorize_skill_ir(skill_id, limit)
    for i in @memory_skills
      delete_memorize_skill(i) unless skills.include?($data_skills[i])
    end
    skill = $data_skills[skill_id]
    return if unselect_skill?(skill.id)
    return if skill_memorize?(skill)
    value = 0
    value2 = 0
    if limit == true
      for i in @memory_skills
        value += 1 if $data_skills[i].stype_id == skill.stype_id
      end
      unless KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(skill.stype_id)
        return if max_memorize[skill.stype_id - 1] <= value
      end
        
      for i in @memory_skills
        value2 = memorize_capacity(skill.stype_id)
      end
      return if max_memorize_capacity[skill.stype_id - 1] < skill.memorize_capacity + value2 
      
    end
    @memory_skills.push(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● イベントコマンド用メモライズ初期化処理(追加定義)
  #--------------------------------------------------------------------------
  def memory_skills_dl
    @memory_skills = []
  end

end

#==============================================================================
# ■ Window_k_Skillmemorize_SkillCommand(新規)
#==============================================================================
class Window_k_Skillmemorize_SkillCommand < Window_Command
  attr_accessor :actor
  attr_accessor :memorized_skill_window
  attr_accessor :learnd_skill_window
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    4
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    return if @index < 0
    @memorized_skill_window.stype_id = current_ext if @memorized_skill_window
    @learnd_skill_window.stype_id = current_ext if @learnd_skill_window
  end
  #--------------------------------------------------------------------------
  # ● 全項目の描画
  #--------------------------------------------------------------------------
  def draw_all_items
    
    item_max.times {|i| draw_item(i) }
    
    draw_actor_memorize
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width - 270
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing) + 270
    rect.y = index / col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 記憶容量の描画
  #--------------------------------------------------------------------------
  def draw_actor_memorize
    x = Graphics.width - 160
    i = 0
    return if @actor == nil
    #スキルタイプの配列を作成
    stype_list = Marshal.load(Marshal.dump(@actor.added_skill_types))
    
    stype_list.sort!
    counter = 0
    for i in 0..stype_list.size - 1
      skill_type = stype_list[i]
      
      #表示しないスキルタイプは扱わない
      unless KURE::SkillMemorize::NOT_VIEW_SKILLTYPE.include?(skill_type)
      
      #容量表示をするのであれば描画する。
      if KURE::SkillMemorize::VIEW_MEMORIZE_GAGE[skill_type - 1] == 1
        memory = @actor.memorize_capacity(skill_type)
        memory_max = @actor.max_memorize_capacity[skill_type - 1]
        memorize_rate = memory.to_f / memory_max if memory_max != 0
        memorize_rate = 0 if memory_max == 0
        
        if memory_max > 999999
          memory_max = "∞" 
          memorize_rate = 0
        end
          
        draw_gauge(x, line_height * counter, 124, memorize_rate, tp_gauge_color1, tp_gauge_color2)
        change_color(system_color)
        draw_text(x, line_height * counter, 30, line_height, KURE::SkillMemorize::MEMORIZE_CAPACITY_NAME)
        draw_current_and_max_values(x, line_height * counter, 124, memory, memory_max,
        mp_color(actor), normal_color)
      end
        counter += 1
      end
    end
  end    
  #--------------------------------------------------------------------------
  # ● 選択項目の拡張データを取得
  #--------------------------------------------------------------------------
  def current_ext
    current_data ? current_data[:ext] : nil
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      if KURE::SkillMemorize::NOT_VIEW_SKILLTYPE.include?(stype_id)
      else
        add_command(name, :skill, true, stype_id)
      end
    end
  end
end

#==============================================================================
# ■ Window_k_SkillMemorize_SkillList(新規)
#==============================================================================
class Window_k_SkillMemorize_SkillList < Window_Command
  attr_reader :data
  attr_accessor :pop_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    @stype_id = 0
    @width = width
    @height = height
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ● スキルの取得
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● カーソルを下に移動
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if @pop_window.visible == true
      @pop_window.hide
      return
    end
    
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルを上に移動
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if @pop_window.visible == true
      @pop_window.hide
      return
    end
    
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプ ID の設定
  #--------------------------------------------------------------------------
  def stype_id=(stype_id)
    return if @stype_id == stype_id
    @stype_id = stype_id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 28
    rect.width -= 8
    rect
  end
  #--------------------------------------------------------------------------
  # ● 全項目の描画
  #--------------------------------------------------------------------------
  def draw_all_items
    item_max.times {|i| draw_item(i) }
    return if @stype_id == nil
    if @stype_id != 0
      if KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(@stype_id)
        (@data.size + 1).times {|i| draw_number(i) } if @actor != nil
      else
        @actor.max_memorize[@stype_id - 1].times {|i| draw_number(i) } if @actor != nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x + 30, rect.y)
      
      if KURE::SkillMemorize::VIEW_MEMORIZE_CAPACITY == 1
        change_color(power_down_color)
        draw_text(rect.width - 30, line_height * index, 30, line_height, skill.memorize_capacity, 2) if skill.memorize_capacity != 0
      end
      
      change_color(normal_color)
    else
      rect = item_rect(index)
      rect.width -= 4
      change_color(normal_color, command_enabled?(index))
      draw_text(item_rect_for_text(index), command_name(index), alignment)
    end
  end
  #--------------------------------------------------------------------------
  # ● 番号の描画
  #--------------------------------------------------------------------------
  def draw_number(index)
    draw_text(0, line_height * index, 24, line_height, index + 1, 2)
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 54
    rect.width -= 8
    rect
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # ● スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.stype_id == @stype_id
  end
  #--------------------------------------------------------------------------
  # ● 記録最大数
  #--------------------------------------------------------------------------
  def max_select
    return @data.size if KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(@stype_id)
    return 0 if @actor == nil
    return 0 if @stype_id == nil
    
    if @actor.max_memorize[@stype_id - 1] > @data.size
      return @data.size
    else
      return @actor.max_memorize[@stype_id - 1] - 1
    end
  end  
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    @data = @actor ? @actor.memory_skills.select {|skill| include?(skill) } : []
    
    for i in 0..max_select
      if @data[i] != nil
        add_command(@data[i].name, :ok)
      else
        add_command("", :ok)       
      end
    end
    
  end
end

#==============================================================================
# ■ Window_k_LearndSkill_SkillList(新規)
#==============================================================================
class Window_k_LearndSkill_SkillList < Window_Command
  attr_reader :data
  attr_accessor :select_skill
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    @select_skill = 0
    @stype_id = 0
    @width = width
    @height = height
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ● スキルの取得
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプ ID の設定
  #--------------------------------------------------------------------------
  def stype_id=(stype_id)
    return if @stype_id == stype_id
    @stype_id = stype_id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x, rect.y, command_enabled?(index))
      
      if KURE::SkillMemorize::VIEW_MEMORIZE_CAPACITY == 1
        change_color(power_down_color)
        draw_text(rect.width - 30, line_height * index, 30, line_height, skill.memorize_capacity, 2) if skill.memorize_capacity != 0
      end
      
      change_color(normal_color)
    else
      change_color(normal_color, command_enabled?(index))
      draw_text(item_rect_for_text(index), command_name(index), alignment)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 24
    rect.width -= 8
    rect
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # ● スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if @actor.extra_skill_memorize?(item)
    return false if item.stype_id != @stype_id or @actor.unselect_skill?(item.id)
    if item.note.include?("<メモライズ不要>")
      return false
    else
      memo = item.note.scan(/<メモライズ不要\s?(\d+)>/)
      memo = memo.flatten
      if memo != nil and not memo.empty?
        return false if memo.include?(@actor_id)
      end
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return if @stype_id == nil
    return unless @actor
    #データ配列を作成
    @data = @actor ? @actor.skills.select {|skill| include?(skill) } : []
    memory = 0
    memory_max = 0
    select = 0
    #メモライズ容量判定用の変数を設定
    if @stype_id > 0
      memory = @actor.memorize_capacity(@stype_id)
      memory_max = @actor.max_memorize_capacity[@stype_id - 1]
    end
    
    if @select_skill != 0
      select = $data_skills[@select_skill].memorize_capacity
    end
    
    #メモライズ中のスキルリストを作成
    not_jumble = Array.new
    @actor.memory_skills.each do |skill|
      not_jumble.push(skill.not_jumble_memorize)
    end
    not_jumble.flatten!
    not_jumble.uniq!
    
      
    if @data.size != 0
      for i in 0..@data.size - 1
        flag = 0
        #共存不可メモライズのチェック
        if not_jumble.include?(@data[i].id)
          add_command(@data[i].name, :ok ,false)
          flag = 1
        end
        
        if flag == 0
          #メモリー合計数を計算
          totalmemory = memory + @data[i].memorize_capacity
          if @actor.skill_memorize?(@data[i])
            add_command(@data[i].name, :ok ,false)
          else
            if totalmemory > memory_max + select
              add_command(@data[i].name, :ok ,false)
            else
              add_command(@data[i].name, :ok ,true)
            end
          end
        end
        
      end
    end
    
    add_command("解除する", :ok)
  end
end

#==============================================================================
# ■ Window_k_SkillMemorize_SkillStatus
#==============================================================================
class Window_k_SkillMemorize_SkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, fitting_height(4))
    @actor = nil
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    280
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_name(@actor, 108, 0)
    draw_actor_level(@actor, 108, line_height * 1)
    draw_actor_class(@actor, 108, line_height * 2)
  end
end

#==============================================================================
# ■ Window__k_SkillMemorize_Popup
#==============================================================================
class Window__k_SkillMemorize_Popup < Window_Base
  attr_accessor :add_skill
  attr_accessor :delete_skill
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @add_skill = [] if @add_skill == nil
    @delete_skill = [] if @delete_skill == nil
    
    self.height = line_height * (4 + @add_skill.size + @delete_skill.size)
    self.height += line_height if @add_skill.size == 0
    self.height += line_height if @delete_skill.size == 0
    create_contents
    contents.clear
    
    #描画位置
    base_y = line_height * (1 + @add_skill.size)
    
    #追加スキルの描画
    draw_gauge(5,0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, contents.width, line_height, "追加メモライズ")
    
    if @add_skill.size != 0
      for i in 0..@add_skill.size - 1
        draw_item_name($data_skills[@add_skill[i]], 5, line_height * (1 + i))
        
        for j in 0..KURE::SkillMemorize::CHAIN_MEMORIZE.size - 1
          if KURE::SkillMemorize::CHAIN_MEMORIZE[j] != nil
            if KURE::SkillMemorize::CHAIN_MEMORIZE[j][0] == $data_skills[@add_skill[i]].id
              for k in 1..KURE::SkillMemorize::CHAIN_MEMORIZE[j].size - 1
                draw_icon($data_skills[KURE::SkillMemorize::CHAIN_MEMORIZE[j][k]].icon_index, 180 + 30 * ( k -1 ), line_height * (1 + i))
              end
            end
          end
        end
        
      end
    end
    
    base_y += line_height if @add_skill.size == 0
    
    #削除スキルの描画
    draw_gauge(5, base_y, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, base_y, contents.width, line_height, "削除メモライズ")
    
    if @delete_skill.size != 0
      for i in 0..@delete_skill.size - 1
        draw_item_name($data_skills[@delete_skill[i]], 5, line_height * (1 + i) + base_y)
        
        for j in 0..KURE::SkillMemorize::CHAIN_MEMORIZE.size - 1
          if KURE::SkillMemorize::CHAIN_MEMORIZE[j] != nil
            if KURE::SkillMemorize::CHAIN_MEMORIZE[j][0] == $data_skills[@delete_skill[i]].id
              for k in 1..KURE::SkillMemorize::CHAIN_MEMORIZE[j].size - 1
                draw_icon($data_skills[KURE::SkillMemorize::CHAIN_MEMORIZE[j][k]].icon_index, 180 + 30 * ( k -1 ), line_height * (1 + i) + base_y)
              end
            end
          end
        end        
        
      end
    end    
    
  end  
end
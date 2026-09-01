#==============================================================================
#  ■装備拡張 for RGSS3 Ver3.02-β10
#　□作成者 kure
#
#　呼び出し方法 　SceneManager.call(Scene_Equip)
#
#   更新用覚書
#   プロセスによる表示内容
#   1 通常装備選択
#   2 アイテムグループ表示(装備品個別管理専用)
#   3 装備候補リスト
#   4 装備候補リスト(装備品個別管理専用)
#   5 スロット用装備選択(装備品個別管理専用)
#   6 選択した装備のスロットリスト(装備品個別管理専用)
#   7 スロット用アイテムグループ表示(装備品個別管理専用)
#   8 スロット用装備候補リスト(装備品個別管理専用)
#==============================================================================

$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:ExEquip] = 3017
p "装備拡張"

module KURE
  module ExEquip
  #初期設定(変更しないこと)-----------------------------------------------------  
    EQUIP_SLOT_NAME = [] ; Vocab_Ex1 = []
        
  #戦闘中挙動-------------------------------------------------------------------
    #戦闘中の装備変更許可を設定(0=常時不可 1=条件付き可能 2=常時可能)
    PERMIT_EDIT_IN_BATTLE = 0
    #戦闘中装備変更許可スイッチ(スイッチ番号を指定、0を入れない事)
    PERMIT_EDIT_IN_BATTLE_SWITH = 3
  
  #画面の表示設定---------------------------------------------------------------
    #AP情報ウィンドウ(0=表示しない 1=表示する)
    AP_VIEWER = 1
        
  #装備スロットの設定----------------------------------------------------
    #装備スロットを設定
      #通常のスロット
      EQUIP_SLOT = [0,1,2,3,4,5]
      #二刀流のスロット
      EQUIP_SLOT_DUAL = [0,0,2,3,4,5]
      
    #空スロット禁止スロット
    FILL_SLOT = []
  
    #装備スロット表示名を設定(EQUIP_SLOT_NAME[ID] = "表示名"
    #スロットID 0～4はシステムより予約されています
    EQUIP_SLOT_NAME[5] = "紋章"
    EQUIP_SLOT_NAME[6] = "スロット6"
  
  #ステータス欄の表示設定-------------------------------------------------------
    #ステータスの表示名
    Vocab_Ex1[0] = "命中率"      #命中率
    Vocab_Ex1[1] = "回避率"      #回避率
    Vocab_Ex1[2] = "会心率"      #会心率
  
  #システム関連設定-------------------------------------------------------------
    #装備重量システムを利用する(0=利用しない 1=利用する)
    USE_WEIGHT_SYSTEM = 1
      #基礎最大重量(全てのアクターが最低限もてる重量を設定します)
      MAX_WEIGHT_BASE = 100
      
      #レベル補正(レベルが上がるごとに増える最大重量を設定します)
      MAX_WEIGHT_Lv = 0
  
      #装備重量の名称
      WEIGHT_NAME = "capa"
  
  #重量0のアイテムの重量表示(0=表示する 1=表示しない)
  WEIGHT_0_ITEM = 1
  
    #装備レベルシステムを利用する(0=利用しない 1=利用する)
    USE_EQUIPLV_SYSTEM = 0
  
    #装備ステータスシステムを利用する(0=利用しない 1=利用する)
    USE_EQUIPSTATUS_SYSTEM = 0
  
    #装備要求変数システムを利用する(0=利用しない 1=利用する)
    USE_EQUIPVAL_SYSTEM = 1
    
  end
end

#==============================================================================
# ●■ RPG::BaseItem(追加定義集積)
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 通常装備スロットの定義(追加定義)
  #--------------------------------------------------------------------------  
  def o_equip_slot
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<通常装備スロット\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 二刀流装備スロットの定義(追加定義)
  #--------------------------------------------------------------------------  
  def o_equip_slot_d
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<二刀流装備スロット\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備封印の定義(追加定義)
  #--------------------------------------------------------------------------  
  def seal_equip_type
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<装備封印\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備固定の定義(追加定義)
  #--------------------------------------------------------------------------  
  def rock_equip_type
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<装備固定\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備重量の定義(追加定義)
  #--------------------------------------------------------------------------  
  def weight
    return 0 unless @note
    cheak_note = @note
    weight = 0
    
    while cheak_note do
      cheak_note.match(/<装備重量\s?(\d+)\s?>/)
      weight += $1.to_i if $1
      cheak_note = $'
    end
    return weight  
  end
  #--------------------------------------------------------------------------
  # ● 最大重量補正の定義(追加定義)
  #--------------------------------------------------------------------------  
  def weight_revise
    return 0 unless @note
    cheak_note = @note
    weight_revise = 0
    
    while cheak_note do
      cheak_note.match(/<最大重量補正\s?(\d+)\s?>/)
      weight_revise += $1.to_i if $1
      cheak_note = $'
    end
    return weight_revise 
  end 
  #--------------------------------------------------------------------------
  # ● 装備重量増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_weight
    return 0 unless @note
    cheak_note = @note
    gain_weight = 0
    
    while cheak_note do
      cheak_note.match(/<最大重量増加\s?(\d+)\s?>/)
      gain_weight += $1.to_i if $1
      cheak_note = $'
    end
    return gain_weight 
  end
  #--------------------------------------------------------------------------
  # ● 装備レベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_level
    return 1 unless @note
    @note.match(/<装備要求レベル\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ●▲ 装備職業レベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_joblevel
    return 1 unless @note
    @note.match(/<装備要求職業レベル\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ● 装備上限レベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_limit_level
    return 10000 unless @note
    @note.match(/<装備要求上限レベル\s?(\d+)\s?>/)
    return 10000 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ●▲ 装備職業上限レベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_limit_joblevel
    return 10000 unless @note
    @note.match(/<装備要求職業上限レベル\s?(\d+)\s?>/)
    return 10000 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ●▲ 装備要求変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_val
    request_val = Array.new
    return request_val unless @note
    @note.match(/<装備要求変数\s?(\d+)\s?,\s?(\d+)\s?>/)
    request_val[0] = 0 ; request_val[1] = 0
    request_val[0] = $1.to_i if $1 ; request_val[1] = $2.to_i if $2
    return request_val
  end
  #--------------------------------------------------------------------------
  # ● 装備ステータスの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_equip_status
    need_status = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    #最大HP
    cheak_note.match(/<装備要求HP\s?(\d+)\s?>/)
    need_status[0] = 0
    need_status[0] = $1.to_i if $1
    
    #最大MP
    cheak_note.match(/<装備要求MP\s?(\d+)\s?>/)
    need_status[1] = 0
    need_status[1] = $1.to_i if $1
    
    #攻撃力
    cheak_note.match(/<装備要求攻撃力\s?(\d+)\s?>/)
    need_status[2] = 0
    need_status[2] = $1.to_i if $1
    
    #防御力
    cheak_note.match(/<装備要求防御力\s?(\d+)\s?>/)
    need_status[3] = 0
    need_status[3] = $1.to_i if $1    
    
    #魔法力
    cheak_note.match(/<装備要求魔法力\s?(\d+)\s?>/)
    need_status[4] = 0
    need_status[4] = $1.to_i if $1
    
    #魔法防御力
    cheak_note.match(/<装備要求魔法防御力\s?(\d+)\s?>/)
    need_status[5] = 0
    need_status[5] = $1.to_i if $1
    
    #敏捷性
    cheak_note.match(/<装備要求敏捷性\s?(\d+)\s?>/)
    need_status[6] = 0
    need_status[6] = $1.to_i if $1
    
    #運
    cheak_note.match(/<装備要求運\s?(\d+)\s?>/)
    need_status[7] = 0
    need_status[7] = $1.to_i if $1
    return need_status
  end
end

#==============================================================================
# ■ RPG::EquipItem(再定義)
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 装備タイプの定義(再定義)
  #--------------------------------------------------------------------------  
  def etype_id
    return @etype_id unless @note
    @note.match(/<装備タイプ\s?(\d+)\s?>/)
    return @etype_id unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ● 拡張装備タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_etype_id
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<拡張装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備可能アクターの定義(追加定義)
  #--------------------------------------------------------------------------  
  def actor_equip_limit
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<装備可能アクター\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプの定義(再定義)
  #--------------------------------------------------------------------------  
  def etype_id=(etype_id)
    @etype_id = etype_id
  end
end

#==============================================================================
# ■ Game_Interpreter(追加定義)
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 指定アクターの装備を変更(追加定義)
  #--------------------------------------------------------------------------
  def change_exslot_equip(actor_id, slot_id, item_id)
    return if $game_actors[actor_id].equip_slots[slot_id] == 0
    $game_actors[actor_id].change_equip_by_id(slot_id, item_id)
  end  
end

#==============================================================================
# ■ Game_BaseItem
#==============================================================================
class Game_BaseItem
  #--------------------------------------------------------------------------
  # ● 封印リスト呼び出し
  #--------------------------------------------------------------------------
  def seal_equip_type
    return object.seal_equip_type  if object
    return []
  end
  #--------------------------------------------------------------------------
  # ● 固定リストの呼び出し
  #--------------------------------------------------------------------------
  def rock_equip_type
    return object.rock_equip_type  if object
    return []
  end 
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  attr_accessor :temp                  # キャッシュフラグ
  #--------------------------------------------------------------------------
  # ● 装備変更の可能判定(再定義)
  #     slot_id : 装備スロット ID
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return false if equip_type_sealed_ex?(equip_slots[slot_id],slot_id)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備封印、固定の判定
  #     etype_id : 装備タイプ ID  slot_id : 装備スロットID
  #--------------------------------------------------------------------------
  def equip_type_sealed_ex?(etype_id,slot_id)
    #封印リスト
    equips_seal_list = @equips.select{|obj| obj != nil}.collect{|obj| obj.seal_equip_type}
    state_seal_list = self.states.select{|obj| obj != nil}.collect{|obj| obj.seal_equip_type}
    job_list = $data_classes[@class_id].seal_equip_type
    all_seal_list = equips_seal_list + state_seal_list + job_list
    all_seal_list.uniq!.flatten!.compact!
    
    
    #固定リスト
    equips_rock_list = @equips.select{|obj| obj != nil}.collect{|obj| obj.rock_equip_type}
    state_rock_list = self.states.collect{|obj| obj.rock_equip_type}
    job_list = $data_classes[@class_id].rock_equip_type
    all_rock_list = equips_rock_list + state_rock_list + job_list
    all_rock_list.uniq!.flatten!.compact!
    
    #封印判定
    if all_seal_list.include?(etype_id)
      change_equip(slot_id, nil)
      return true
    end
    
    #固定判定
    if all_rock_list.include?(etype_id)
      return true
    end
    
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更(再定義)
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    #装備制限
    item_object = @equips[slot_id].object
    
    #拡張装備スロット    
    if item && equip_slots[slot_id] != item.etype_id
      return unless item.add_etype_id.include?(equip_slots[slot_id])
    end
    
    #アクター装備制限
    if item && item.actor_equip_limit != []
      return unless item.actor_equip_limit.include?(@actor_id)
    end
    
    return unless trade_item_with_party(item, equips[slot_id])
    @equips[slot_id].object = item
    refresh unless $kure_base_script[:base_A]
    
    #追加装備のスキル削除処理
    if $kure_base_script[:base_A]
      auto_state_adder_ex(item_object) if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム変更許可を判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_condition?(slot_id, new_item, temp_actor = nil)
    unless temp_actor
      temp_actor = Marshal.load(Marshal.dump(self))
      temp_actor.name = "tester"
      temp_actor.temp = true
      temp_actor.force_change_equip(slot_id, new_item)
    end
    save_condition = [0,0,0,0,0,0]
    
    #装備レベル利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      save_condition[0] = 1 unless equip_lv?(new_item)
    end
    
    #重量システムを利用時だけ判定を行う
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      save_condition[1] = 1 unless equip_weight?(temp_actor)
    end
    
    #スキルメモライズ利用時判定(廃止)
    #if $kure_base_script[:base_A] && $kure_base_script[:Memorize]
    #end
    
    #装備ステータス利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPSTATUS_SYSTEM == 1 
      save_condition[3] = 1 unless equip_status?(new_item)
    end
    
    #装備変数利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPVAL_SYSTEM== 1 
      save_condition[4] = 1 unless equip_val?(new_item)
    end
    
    #空スロット禁止判定
    if slot_id && KURE::ExEquip::FILL_SLOT.include?(slot_id)
      save_condition[5] = 1 unless new_item
    end
    
    return save_condition 
  end
  #--------------------------------------------------------------------------
  # ● 装備レベル判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_lv?(new_item)
    return true unless new_item
    flag = 0
    #装備レベル
    flag = 1 if new_item.need_equip_level > @level
    flag = 1 if new_item.need_equip_limit_level < @level
    #職業レベル
    if $kure_base_script[:base_A] && $kure_base_script[:JobLvSystem]
      flag = 1 if new_item.need_equip_joblevel > @joblevel
      flag = 1 if new_item.need_equip_limit_joblevel < @joblevel
    end
    
    return true if flag == 0
    return false 
  end
  #--------------------------------------------------------------------------
  # ● 重量判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_weight?(temp_actor)
    return true if temp_actor.max_weight >= temp_actor.all_weight
    return false
  end
  #--------------------------------------------------------------------------
  # ● メモライズ容量判定(追加定義)
  #--------------------------------------------------------------------------
  def enough_memorize?
    return true unless $kure_base_script[:Memorize]
    
    case $kure_base_script[:Memorize]
    when 1
      #メモライズ数、容量を保存
      mem_size = [] ; mem_cap = []
      @memory_skills.each do |id|
        next unless id
        skill = $data_skills[id]
        mem_size[skill.stype_id] ||= 0
        mem_cap[skill.stype_id] ||= 0
        
        mem_size[skill.stype_id] += 1
        mem_cap[skill.stype_id] += skill.memorize_capacity
      end
      
      #判定(メモライズ数)
      mem_size.each_with_index {|num, index|
        next if index == 0 
        next unless num
        next if KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(index)
        return false if num > max_memorize[index - 1]
      }
      
      #判定(メモライズ容量)
      mem_cap.each_with_index {|num, index|
        next if index == 0 
        next unless num
        next if KURE::SkillMemorize::NOT_ADOPT_MAX_MEMORY_SKILL_TYPE.include?(index)
        return false if num > memorize_capacity(index)
      } 
      
      return true
    when 2
      return false if memorize_capacity_2 > max_memorize_capacity_2
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備ステータス判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_status?(new_item)
    return true unless new_item
    
    for i in 0..new_item.need_equip_status.size - 1
      return false if new_item.need_equip_status[i] > $game_actors[@actor_id].param_base(i)
    end
    
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備変数判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_val?(new_item)
    return true unless new_item
    
    var = new_item.need_equip_val[0]
    value = new_item.need_equip_val[1]
    return false unless $game_variables[var]
    return false if $game_variables[var] < value
    
    return true 
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得(再定義)
  #--------------------------------------------------------------------------
  def equip_slots
    slot = Array.new
    if dual_wield?
      slot = KURE::ExEquip::EQUIP_SLOT_DUAL
      slot = self.class.o_equip_slot_d if self.class.o_equip_slot_d != []
      slot = actor.o_equip_slot_d if actor.o_equip_slot_d != []
    else
      slot = KURE::ExEquip::EQUIP_SLOT  # 通常
      slot = self.class.o_equip_slot if self.class.o_equip_slot != []
      slot = actor.o_equip_slot if actor.o_equip_slot != []
    end
    
    while slot.size > @equips.size do 
      @equips.push(Game_BaseItem.new)
    end
    
    return slot
  end
  #--------------------------------------------------------------------------
  # ● 装備総重量(追加定義)
  #--------------------------------------------------------------------------  
  def all_weight
    weight = 0
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          weight = weight + @equips[i].object.weight
        end
      end
    return weight
  end
  #--------------------------------------------------------------------------
  # ● 重量増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_weight
    gain_weight = 0
    @equips.each do |obj|
      next unless obj.object
      gain_weight += obj.object.gain_weight
    end
    return gain_weight    
  end
  #--------------------------------------------------------------------------
  # ● 重量最大量(追加定義)
  #--------------------------------------------------------------------------  
  def max_weight
    max_weight = 0
    #追加重量
    max_weight += all_gain_weight
    #基礎値
    max_weight += KURE::ExEquip::MAX_WEIGHT_BASE
    #レベル補正
    max_weight += KURE::ExEquip::MAX_WEIGHT_Lv * @level
    #アクター補正
    max_weight += actor.weight_revise
    #職業補正
    max_weight += self.class.weight_revise  
    #スキル補正を加算
    skills.each do |skill|
      max_weight += skill.weight_revise 
    end
      
    return max_weight
  end
end

#==============================================================================
# ■ Scene_Equip(再定義)
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================
class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    if $kure_base_script[:base_A] && $kure_base_script[:SortOut]
      $game_party.refresh_equip_name_list_both 
      @actor.release_unequippable_items if KURE::SortOut::USE_DURABLE == 1
    end
    
    create_help_window
    create_small_status_window
    create_command_window
    create_slot_window
    create_status_window
    create_pop_window
    
    set_window_task
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_small_status_window
    wx = 0
    wy = @help_window.height
    ww = 305
    wh = 48
    @small_status_window = Window_Equip_Small_Status.new(wx,wy,ww,wh)
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    wx = 0
    wy = @help_window.height + @small_status_window.height
    ww = @small_status_window.width   
    
    @command_window = Window_Ex_EquipCommand.new(wx,wy,ww)
    @command_window.help_window = @help_window
    @command_window.set_handler(:equip,    method(:command_equip))
    @command_window.set_handler(:slot,     method(:command_slot))
    @command_window.set_handler(:optimize, method(:command_optimize))
    @command_window.set_handler(:clear,    method(:command_clear))
    @command_window.set_handler(:cancel,   method(:command_cancel))
    @command_window.set_handler(:pagedown, method(:next_actor_cm))
    @command_window.set_handler(:pageup,   method(:prev_actor_cm))
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● スロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_slot_window
    wx = 0
    wy = @command_window.height + @help_window.height + @small_status_window.height
    ww = 305
    wh = Graphics.height - wy
    
    @slot_window = Window_Ex_Multi_Equip.new(wx, wy, ww, wh)
    @slot_window.help_window = @help_window
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
    @slot_window.set_handler(:pagedown, method(:next_actor_sl))
    @slot_window.set_handler(:pageup,   method(:prev_actor_sl))
    @slot_window.deactivate
    @slot_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_Ex_EquipStatus.new(@slot_window.width, @help_window.height,Graphics.width - @slot_window.width,Graphics.height - @help_window.height)
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_pop_window
    @popup_window = Window_Ex_Equip_Popup.new(Graphics.width / 4 - 50,Graphics.height / 4 )
    @popup_window.z += 100
    @popup_window.unselect
    @popup_window.deactivate
    @popup_window.back_opacity = 255
    @popup_window.hide
    
    #呼び出しのハンドラをセット
    @popup_window.set_handler(:ok,method(:pop_ok))
    @popup_window.set_handler(:cancel,method(:pop_cancel))
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセッティング処理
  #--------------------------------------------------------------------------
  def set_window_task
    @small_status_window.actor = @actor
    @slot_window.actor = @actor
    @status_window.actor = @actor
    
    @slot_window.status_window = @status_window
    
    #プロセスを初期化
    @process = 0
    @slot_window.process = 0
    
    @need_reset_name = false
    @keep_index = 0
    @keep_slot_index = 0
    @keep_slot_item = nil
    @last_index = [0,0]
    @last_call = nil
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[決定]
  #--------------------------------------------------------------------------
  def pop_ok
    case @popup_window.index
    when 0
      @actor.memory_skills_dl
      case @last_call
      when 0
        return_scene
      when 1,2
        next_actor
        pop_close(@last_call)
      when 3,4
        prev_actor
        pop_close(@last_call)
      end
    when 1
      pop_close(@last_call)
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def pop_cancel
    pop_close(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[開く]
  #--------------------------------------------------------------------------
  def pop_open(call)
    @popup_window.show
    @popup_window.select(1)
    @popup_window.activate
    
    case call
    when 0,1,3
      @command_window.deactivate
    when 2,4
      @slot_window.deactivate
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[閉じる]
  #--------------------------------------------------------------------------
  def pop_close(call)
    @popup_window.hide
    @popup_window.unselect
    @popup_window.deactivate

    case call
    when 0,1,3
      @command_window.activate
    when 2,4
      @slot_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド［装備変更］
  #--------------------------------------------------------------------------
  def command_equip
    @process = 1
    @status_window.draw_index = 1
    command_to_slot
  end
  #--------------------------------------------------------------------------
  # ● コマンド［スロット］
  #--------------------------------------------------------------------------
  def command_slot
    @process = 5
    @status_window.draw_index = 1
    command_to_slot
  end
  #--------------------------------------------------------------------------
  # ● コマンド［最強装備］
  #--------------------------------------------------------------------------
  def command_optimize
    Sound.play_equip
    @actor.optimize_equipments
    @slot_window.refresh
    @command_window.activate
    @need_reset_name = true
    cheak_master_refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンド［全て外す］
  #--------------------------------------------------------------------------
  def command_clear
    Sound.play_equip
    @actor.clear_equipments
    @slot_window.refresh
    @command_window.activate
    @small_status_window.refresh if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
    @need_reset_name = true
    cheak_master_refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンド［キャンセル］
  #--------------------------------------------------------------------------
  def command_cancel
    if @actor.enough_memorize?
      return_scene ; return
    end
    @last_call = 0
    pop_open(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し元のシーンへ戻る
  #--------------------------------------------------------------------------
  def return_scene
    set_passive
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # ● スロット［決定］
  #--------------------------------------------------------------------------
  def on_slot_ok
    #プロセスにより処理を変更する
    case @process
    when 1
      keep_basic_item
      if $kure_base_script[:base_A] && $kure_base_script[:SortOut]
      #装備品個別管理使用時はプロセス2へ
        cheak_master_refresh
        set_process(2, 2, 6)
      else
      #それ以外はプロセス3へ
        set_process(3, 3, 7)
      end
      command_to_slot
    when 2
      #装備品個別管理使用時はグル―プリストを作成
      if @slot_window.current_ext
        @last_index = [@slot_window.page_index,@slot_window.index].clone
        @slot_window.selecter = @slot_window.current_ext
        set_process(4, 4, 7)
        command_to_slot
      else
      #装備解除処理
        change_equip_process
      end
    when 3,4
      #装備変更(個別管理、通常共通処理)
      change_equip_process
    when 5
      #スロットを選択した場合はスロット画面へ
      cheak_master_refresh
      keep_slot_item
      set_process(6, 6, 1)
      command_to_slot
    when 6
      #スロットリストを選択した時の処理
      cheak_master_refresh
      @keep_slot_item = @slot_window.current_ext
      @keep_slot_index = @slot_window.index
      set_process(7, 7, 6)
      command_to_slot
    when 7
      if @slot_window.current_ext
        @slot_window.selecter = @slot_window.current_ext
        @process = 8
        @slot_window.process = 8
        @slot_window.select(0)
        @slot_window.activate
        @status_window.draw_index = 1
      else
        change_slot_equip_process
      end
    when 8
      change_slot_equip_process
    end
  end
  #--------------------------------------------------------------------------
  # ● スロット［キャンセル］
  #--------------------------------------------------------------------------
  def on_slot_cancel
    #プロセスにより処理を変更する
    case @process
    #装備選択
    when 1,5
      slot_to_command
    when 2,3
      @process = 1
      @slot_window.process = 0
      @slot_window.select(@keep_index)
      @slot_window.activate
      @status_window.draw_index = 1
    when 4
      cheak_master_refresh
      @slot_window.page_index = @last_index[0]
      set_process(2, 2, 6)
      command_to_slot
      @slot_window.select(@last_index[1])
      @slot_window.cursor_fix
    when 6
      cheak_master_refresh
      set_process(5, 0, 1)
      command_to_slot
      @slot_window.select(@keep_index)
    when 7
      cheak_master_refresh
      @process = 6
      @slot_window.process = 6
      @slot_window.select(@keep_slot_index)
      @slot_window.activate
      @status_window.draw_index = 1
    when 8
      cheak_master_refresh
      set_process(7, 7, 6)
      command_to_slot      
    end
  end
  #--------------------------------------------------------------------------
  # ● スロット　→　コマンド
  #--------------------------------------------------------------------------
  def command_to_slot
    @command_window.deactivate
    @slot_window.select(0)
    @slot_window.activate
  end
  #--------------------------------------------------------------------------
  # ● スロット　→　コマンド
  #--------------------------------------------------------------------------
  def slot_to_command
    @command_window.activate
    
    #画面のプロセス初期化
    @slot_window.process = 0
    @status_window.draw_index = 0
    
    @slot_window.unselect
    @slot_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    set_window_task
    
    @command_window.select(0)
    slot_to_command
    @slot_window.tmp_item = nil
    @slot_window.status_window_refresh
    
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor_cm
    if @actor.enough_memorize?
      next_actor ; return
    end
    @last_call = 1
    pop_open(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor_sl
    if @actor.enough_memorize?
      next_actor ; return
    end
    @last_call = 2
    pop_open(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor_cm
    if @actor.enough_memorize?
      prev_actor ; return
    end
    @last_call = 3
    pop_open(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor_sl
    if @actor.enough_memorize?
      prev_actor ; return
    end
    @last_call = 4
    pop_open(@last_call)
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    case @process
    when 0,1,5
      set_passive
      @actor = $game_party.menu_actor_next
      on_actor_change
    when 2,3,4,6,7,8
      @slot_window.next_page
      @slot_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    case @process
    when 0,1,5
      set_passive
      @actor = $game_party.menu_actor_prev
      on_actor_change
    when 2,3,4,6,7,8
      @slot_window.prev_page
      @slot_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備変更処理
  #--------------------------------------------------------------------------
  def change_equip_process
    if @status_window.can_equip != [0,0,0,0,0,0]
      Sound.play_buzzer
      @slot_window.activate
      return
    end

    Sound.play_equip
    @actor.change_equip(@keep_index, @slot_window.current_ext)
    #二刀流両手剣問題対応
    if @actor.dual_wield? && @slot_window.current_ext
      case @keep_index
      when 0
        @actor.change_equip(1, nil) if @actor.features_set(54).include?(1)
      when 1
        @actor.change_equip(0, nil) if @actor.features_set(54).include?(1)
      end
    end
    @process = 1
    @slot_window.process = 0
    @slot_window.select(@keep_index)
    @slot_window.activate
    @status_window.draw_index = 1
    
    @need_reset_name = true
    @small_status_window.refresh if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
    set_passive
  end
  #--------------------------------------------------------------------------
  # ● スロット装備変更処理
  #--------------------------------------------------------------------------
  def change_slot_equip_process
    return unless @actor.trade_item_with_party(@slot_window.current_ext , @keep_slot_item)
    @slot_window.slot_master.set_slot_value(@keep_slot_index, @slot_window.current_ext)
    @actor.clear_equip_note_cache
    
    @process = 6
    @slot_window.process = 6
    @slot_window.select(@keep_slot_index)
    @slot_window.activate
    @status_window.draw_index = 1
    
    @need_reset_name = true
    @small_status_window.refresh if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
    set_passive
  end
  #--------------------------------------------------------------------------
  # ● プロセスのセット(メイン、スロット、ステータス)
  #--------------------------------------------------------------------------
  def set_process(main, slot, draw)
    @process = main
    @slot_window.process = slot
    @status_window.draw_index = draw
    @slot_window.temp_actor = nil
    @slot_window.equip_data = nil
  end
  #--------------------------------------------------------------------------
  # ● 選択したアイテム情報をスロットとステータスウィンドウへ渡す
  #--------------------------------------------------------------------------
  def keep_basic_item
    @status_window.basic_item = @slot_window.current_ext
    @slot_window.etype_id = @actor.equip_slots[@slot_window.index]
    
    #INDEXを保存
    @slot_window.slot_index = @slot_window.index
    @keep_index = @slot_window.index
  end
  #--------------------------------------------------------------------------
  # ● 選択したアイテム情報をスロットとステータスウィンドウへ渡す
  #--------------------------------------------------------------------------
  def keep_slot_item
    @slot_window.slot_master = @slot_window.current_ext
    
    #INDEXを保存
    @slot_window.slot_index = @slot_window.index
    @keep_index = @slot_window.index
  end
  #--------------------------------------------------------------------------
  # ● 装備リストの更新確認
  #--------------------------------------------------------------------------
  def cheak_master_refresh
    return unless $kure_base_script[:base_A]
    return unless $kure_base_script[:SortOut]
    if @need_reset_name
      $game_party.refresh_equip_name_list_both
      @need_reset_name = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● パッシブスキル更新
  #--------------------------------------------------------------------------  
  def set_passive
    @actor.fix_memorys if $kure_base_script[:Memorize]
  end
end

#==============================================================================
# ■ Window_Small_Status
#==============================================================================
class Window_Equip_Small_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    super(x, y, width, height)
    refresh
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
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_status
    return unless @actor
    draw_actor_name(@actor, 0, line_height * 0)
    draw_actor_weight(@actor, 160, line_height * 0) if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
  end
  #--------------------------------------------------------------------------
  # ● 装備重量の描画
  #--------------------------------------------------------------------------
  def draw_actor_weight(actor, x, y, width = 124)
    weight = actor.all_weight
    max_weight = actor.max_weight
    weight_rate = 1
    weight_rate = weight.to_f / max_weight if max_weight != 0
    
    draw_gauge(x, y, width, weight_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 35, line_height, KURE::ExEquip::WEIGHT_NAME)
    draw_current_and_max_values(x, y, width, weight, max_weight,
    mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_status
  end
end

#==============================================================================
# ■ Window_Ex_EquipCommand
#------------------------------------------------------------------------------
# 　スキル画面で、コマンド（装備変更、最強装備など）を選択するウィンドウです。
#==============================================================================
class Window_Ex_EquipCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    col_max = 2
    if $kure_base_script[:base_A] && $kure_base_script[:SortOut]
      col_max += 1 if KURE::SortOut::USE_SLOT_EQUIP == 1
    end
    col_max += 1 if KURE::ExEquip::USE_WEIGHT_SYSTEM == 0
    return col_max
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::equip2,   :equip)
    if $kure_base_script[:base_A] && $kure_base_script[:SortOut]
      add_command("スロット", :slot) if KURE::SortOut::USE_SLOT_EQUIP == 1
    end
    add_command(Vocab::optimize, :optimize) if KURE::ExEquip::USE_WEIGHT_SYSTEM == 0
    add_command(Vocab::clear,    :clear)
  end
end

#==============================================================================
# ■ Window_Ex_Multi_Equip
#==============================================================================
class Window_Ex_Multi_Equip < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :status_window            # ステータスウィンドウ
  attr_accessor :process                  # プロセス
  attr_accessor :etype_id                 # 装備タイプ
  attr_accessor :slot_index               # 選択中スロット
  attr_accessor :selecter                 # 装備中装備ID
  attr_accessor :slot_master              # スロットマスターアイテム
  attr_accessor :temp_actor               # キャッシュアクター
  attr_accessor :tmp_item                # キャッシュアイテム
  attr_accessor :equip_data               # キャッシュアクター(装備オブジェクト)
  attr_accessor :page_index               # ページ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @width = width
    @height = height
    super(x, y)
    @actor = nil
    @process = 0
    @set_item = nil
    @slot_master = nil
    @temp_actor = nil
    @equip_data = nil
    @page_index = 0
    @max_page = 0
    @tmp_item = nil
    @last_index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ● 1ページに表示する行数の指定(グループ設定用)
  #--------------------------------------------------------------------------
  def draw_line_number
    case @process
    when 2,7,3
      return ((window_height - padding - padding_bottom) / item_height) - 2
    when 4,8
      return ((window_height - padding - padding_bottom) / item_height) - 1
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
  # ● プロセスの設定
  #--------------------------------------------------------------------------
  def process=(process)
    return if @process == process
    @process = process
    refresh
  end
  #--------------------------------------------------------------------------
  # ● スロットマスターの設定
  #--------------------------------------------------------------------------
  def slot_master=(slot_master)
    return if @slot_master == slot_master
    @slot_master = slot_master
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    return if @index < 0
    status_window_refresh
  end
  #--------------------------------------------------------------------------
  # ● 1ページ進める
  #--------------------------------------------------------------------------
  def next_page
    @page_index += 1
    refresh
    cursor_fix
  end
  #--------------------------------------------------------------------------
  # ● 1ページ戻る
  #--------------------------------------------------------------------------
  def prev_page
    @page_index -= 1
    refresh
    cursor_fix
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置修正
  #--------------------------------------------------------------------------
  def cursor_fix
    return unless [2,3,4,7,8].include?(@process)
    @index = [@index,@last_index].min
    update_cursor
    call_update_help
    status_window_refresh
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置修正
  #--------------------------------------------------------------------------
  def status_window_refresh
    return unless @status_window
    @status_window.set_item(current_ext)
      
    case @process
    when 3,4
      @temp_actor = nil if @tmp_item && @tmp_item.features.select {|ft| ft.code == 54 } != []
      unless @temp_actor
        @temp_actor = Marshal.load(Marshal.dump(@actor))
        @temp_actor.name = "tester"
        @temp_actor.temp = true
      end
      if @tmp_item != current_ext or !@tmp_item
        @temp_actor.force_change_equip(@slot_index, current_ext)
        @status_window.can_equip = @actor.equip_condition?(@slot_index, current_ext, temp_actor)
        @status_window.set_temp_actor(temp_actor)
        @tmp_item = current_ext
      end
    end
    
    @status_window.refresh
  end 
  #--------------------------------------------------------------------------
  # ● →キー入力時動作
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)    
    case @process
    when 0,6,8
      first_page = 1
    when 3,4
      first_page = 7
    end  
    
    case @process
    when 0,3,4
      page_list = [first_page,2]
      if $kure_base_script[:base_A]
        page_list.push(3) if KURE::ExEquip::AP_VIEWER == 1
        page_list.push(4) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SLOT_EQUIP == 1
        page_list.push(5) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SYMBOL == 1
      end
      page_list.push(first_page)
    when 6,8
      page_list = [first_page,2]
      if $kure_base_script[:base_A]
        page_list.push(3) if KURE::ExEquip::AP_VIEWER == 1
        page_list.push(5) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SYMBOL == 1
      end
      page_list.push(first_page)
    end
    
    case @process
    when 0,3,4,6,8
      for page in 0..page_list.size - 1
        if page_list[page] == @status_window.draw_index
          @status_window.draw_index = page_list[page + 1]
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ←キー入力時操作
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)    
    case @process
    when 0,6,8
      first_page = 1
    when 3,4
      first_page = 7
    end 
    
    case @process
    when 0,3,4
      page_list = [first_page,2]
      if $kure_base_script[:base_A]
        page_list.push(3) if KURE::ExEquip::AP_VIEWER == 1
        page_list.push(4) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SLOT_EQUIP == 1
        page_list.push(5) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SYMBOL == 1
      end
      page_list.unshift(page_list[page_list.size - 1])
    when 6,8
      page_list = [first_page,2]
      if $kure_base_script[:base_A]
        page_list.push(3) if KURE::ExEquip::AP_VIEWER == 1
        page_list.push(5) if $kure_base_script[:SortOut] && KURE::SortOut::USE_SYMBOL == 1
      end
      page_list.unshift(page_list[page_list.size - 1])
    end

    case @process
    when 0,3,4,6,8
      for page in 1..page_list.size - 1
        if page_list[page] == @status_window.draw_index
          @status_window.draw_index = page_list[page - 1]
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    #プロセス23478
    case @process
    when 2,7
      equip_list = $game_party.weapons_name_list + $game_party.armors_name_list
      add_list = equip_list.select{|item| item && include?(item)}
    when 3
      add_list = $game_party.equip_items.select {|item| item && include?(item)}
    when 4,8
      equip_list = $game_party.weapons_block(@selecter.id) if @selecter.is_a?(RPG::Weapon)
      equip_list = $game_party.armors_block(@selecter.id) if @selecter.is_a?(RPG::Armor)
      add_list = equip_list.select{|item| item && include?(item)}
    end
    
    case @process
    when 2,3,7,4,8
      @max_page = add_list.size.divmod(draw_line_number)[0] - 1
      @max_page += 1 if add_list.size.divmod(draw_line_number)[1] != 0
      @max_page += 1 if add_list.size == 0
      
      @page_index = 0 if @page_index > @max_page
      @page_index = @max_page if @page_index < 0
      
      first = @page_index * draw_line_number
      last = [((@page_index + 1 ) * draw_line_number) - 1, add_list.size - 1].min
      add_list = add_list[first..last]
      @last_index = last - first
    end
    
    #プロセスにより描画内容を変化させる
    case @process
    when 0
      #装備スロットの描画
      for index in 0..@actor.equip_slots.size - 1
        if @actor.equips[index]
          add_command(@actor.equips[index].name , :ok ,enable?(index) , @actor.equips[index])
        else
          add_command("" , :ok ,enable?(index),nil)
        end
      end
    when 2,7
      #グループリスト
      add_list.each do |item|
        add_command(item.name, :ok, true, item)
      end
      add_command("　装備解除" , :ok ,true ,nil)
    when 3
      #グループリスト
      add_list.each do |item|
        add_command(item.name, :ok, true, item)
      end
      add_command("　装備解除" , :ok ,true ,nil)
    when 4,8
      #グループリスト
      add_list.each do |item|
        add_command(item.name, :ok, true, item)
      end
    when 6
      if @slot_master
        slot_list = @slot_master.slot_list
        max_number = @slot_master.max_slot_number
        for slot in 0..max_number - 1
          if slot_list[slot]
            add_command(slot_list[slot].name , :ok ,true , slot_list[slot])
          else
            add_command("" , :ok ,true)
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    
    case @process
    when 2,3,4      
      return false if @etype_id < 0
      #拡張装備タイプ判定
      if item.etype_id != @etype_id
        return false unless item.add_etype_id.include?(@etype_id)
      end
  
      #アクター装備制限の判定
      if item.actor_equip_limit != []
        return false unless item.actor_equip_limit.include?(@actor.id)
      end
    
      return @actor.equippable?(item)
    when 7,8
      return true if @slot_master.adopt_slot_type.include?(item.etype_id)
      item.add_etype_id.each do |id|
        return true if @slot_master.adopt_slot_type.include?(id)
      end
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 全項目の描画
  #--------------------------------------------------------------------------
  def draw_all_items
    item_max.times {|i| draw_item(i) }
    draw_gide
  end
  #--------------------------------------------------------------------------
  # ● ガイドの描画
  #--------------------------------------------------------------------------
  def draw_gide
    last = contents.font.size
    contents.font.size = 20
    case @process
    when 2,3,7,4,8
      now = @page_index + 1
      max = @max_page + 1
      draw_text(0, contents.height - contents.font.size + 3, contents.width, contents.font.size, "LR：ページ切り替え " + now.to_s + "/" + max.to_s ,1)
    end
    contents.font.size = last
  end   
  #--------------------------------------------------------------------------
  # ● 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(index)
    @actor ? @actor.equip_change_ok?(index) : false
  end  
  #--------------------------------------------------------------------------
  # ● 装備スロットの名前を取得(Process1)
  #--------------------------------------------------------------------------
  def slot_name(index)
    return "" unless @actor
    return Vocab::etype(@actor.equip_slots[index]) if @actor.equip_slots[index] <= 4
    return KURE::ExEquip::EQUIP_SLOT_NAME[@actor.equip_slots[index]]
  end
  #--------------------------------------------------------------------------
  # ● 番号の描画
  #--------------------------------------------------------------------------
  def draw_number(index)
    return unless @slot_master
    change_color(system_color)
    draw_text(0, contents.font.size * index, 24, contents.font.size, index + 1)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @actor
    change_color(normal_color, command_enabled?(index))
    item = @list[index][:ext]
    rect = item_rect(index)
    
    case @process
    when 0
      draw_text(rect.x, rect.y, 87, line_height, slot_name(index))
      draw_item_name(item, rect.x + 87, rect.y, command_enabled?(index))
      draw_weight(rect, index, item)
    when 2,3,7
      if item
        draw_item_name(item, rect.x, rect.y, command_enabled?(index))
        draw_text(item_rect_for_text(index), sprintf(":%2d", $game_party.item_number(item)), 2)
      else
        draw_text(item_rect_for_text(index), command_name(index))
      end
    when 4,8
      draw_item_name(item, rect.x, rect.y, command_enabled?(index))
      draw_weight(rect, index, item)
    when 6
      draw_number(index)
      draw_item_name(item, rect.x + 24, rect.y, command_enabled?(index))
    end
  end
  #--------------------------------------------------------------------------
  # ● 重量を描画
  #--------------------------------------------------------------------------
  def draw_weight(rect, index, item)  
    #重量システムを利用時は重量を表示する
    return unless item
    return if KURE::ExEquip::USE_WEIGHT_SYSTEM == 0
    weight = item.weight - item.gain_weight
    
    if weight < 0
      change_color(power_up_color)
      draw_text(rect.x, rect.y, rect.width, line_height, weight.to_s,2)
    end
    if weight > 0
      change_color(power_down_color)
      draw_text(rect.x, rect.y, rect.width, line_height, weight.to_s,2)
    end
    
    if weight == 0 && KURE::ExEquip::WEIGHT_0_ITEM == 0
      change_color(power_down_color)
      draw_text(rect.x, rect.y, rect.width, line_height, weight.to_s,2)
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.clear
    @help_window.set_item(current_ext) if @help_window
  end
end

#==============================================================================
# ■ Window_Ex_EquipStatus
#------------------------------------------------------------------------------
# 　装備画面で、アクターの能力値変化を表示するウィンドウです。
#==============================================================================
class Window_Ex_EquipStatus < Window_EquipStatus
  attr_accessor :draw_index
  attr_accessor :basic_item
  attr_accessor :can_equip
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    @can_equip = [0,0,0,0,0,0]
    @draw_index = 0
    @width = width
    @height = height
    @draw_item = nil
    @basic_item = nil
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ◎ 描画INDEXの設定
  #--------------------------------------------------------------------------
  def draw_index=(index)
    @draw_index = index
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ◎ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ◎ 装備アイテム描画を設定
  #--------------------------------------------------------------------------
  def set_item(item)
    return if @draw_item == item
    @draw_item = item
  end
  #--------------------------------------------------------------------------
  # ◎ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    #フォントの設定
    last_font = contents.font.size
    contents.font.size = 20
    
    #タイトルゲージを描画
    draw_gauge(0,0, contents.width, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    
    #ページ切り替えを描画
    case @draw_index
    when 1,2,3,4,5,7
      draw_text(0, contents.height - contents.font.size, contents.width, contents.font.size, "← →:表示切り替え",1)
    end
    
    case @draw_index
    when 0
      draw_index_zero
    when 1
      draw_index_one
    when 2
      draw_index_two
    when 3
      draw_index_three
    when 4
      draw_index_four
    when 5
      draw_index_five
    when 6
      draw_index_six
    when 7
      draw_index_seven
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 操作説明(draw_index = 0)
  #--------------------------------------------------------------------------
  def draw_index_zero
    draw_text(0, 0, 180, contents.font.size, "操作説明")
    draw_text(5, contents.font.size * 2, contents.width, contents.font.size, "LR　：アクター切り替え")
    draw_text(5, contents.font.size * 3, contents.width, contents.font.size, "←→：項目選択")
  end
  #--------------------------------------------------------------------------
  # ◎ 操作説明(draw_index = 1)
  #--------------------------------------------------------------------------
  def draw_index_one
    draw_text(0, 0, 180, contents.font.size, "装備品能力")
    return unless @draw_item
    draw_item_name(@draw_item, 5,line_height * 1) 
    
    8.times {|i| draw_item_index1_1(0, line_height * 1 + contents.font.size * (1 + i), i, @draw_item) }
    draw_equip_type(0,line_height * 1 + contents.font.size * 6, @draw_item)
  end    
  #--------------------------------------------------------------------------
  # ◎ 項目の描画(draw_index = 1)
  #--------------------------------------------------------------------------
  def draw_item_index1_1(x, y, param_id, item)
    left = ""
    left2 = "-"
    
    case param_id 
    when 0,2,4,6
      draw_param_name(x, y - contents.font.size * (param_id / 2), param_id)
    when 1,3,5,7
      draw_param_name(x + contents.width / 2, y - contents.font.size * (param_id / 2 + 1), param_id)
    end
    
    case param_id 
    when 0,1,2,3,4,5,6,7
      if item
        change_color(param_change_color(item.params[param_id]))

        left =" " if item.params[param_id].abs < 100
        left ="  " if item.params[param_id].abs < 10
          
        left2 = "+" if item.params[param_id] > 0
        left2 = " " if item.params[param_id] == 0
          
      end
    end
          
    case param_id 
    when 0,2,4,6
      py = y - contents.font.size * (param_id / 2)
      draw_text(0, py, contents.width / 2 - 5, line_height, left + left2 + (item.params[param_id].abs).to_s, 2)
    when 1,3,5,7
      py = y - contents.font.size * (param_id / 2 + 1)
      draw_text(contents.width / 2, py, contents.width / 2 - 5, line_height, left + left2 + (item.params[param_id].abs).to_s, 2)
    end
    
  end
  #--------------------------------------------------------------------------
  # ◎ 要求条件の描画(draw_index = 1)
  #--------------------------------------------------------------------------
  def draw_equip_type(x,y,item)
    
    change_color(system_color)
    draw_text(x, y + contents.font.size * 0, 100, contents.font.size, "装備タイプ")
    
    if item.is_a?(RPG::Weapon)
      str = $data_system.weapon_types[item.wtype_id]
    elsif item.is_a?(RPG::Armor) 
      str = $data_system.armor_types[item.atype_id]
    else
      return
    end
    
    change_color(normal_color)
    draw_text(x + 110, y + contents.font.size * 0, contents.width - 140, contents.font.size, str)
    
    #装備レベル利用時は要求レベルを描画
    if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      change_color(system_color)
      draw_text(x, y + contents.font.size * 1, 100, contents.font.size, "要求レベル")
      change_color(normal_color)
      draw_text(x + 110, y + contents.font.size * 1, 20, contents.font.size, item.need_equip_level)
      #職業レベルを導入していれば要求レベルを表示
      if $kure_base_script[:base_A] && $kure_base_script[:JobLvSystem] 
        draw_text(x + 135, y + contents.font.size * 1, 10, contents.font.size, "/")
        draw_text(x + 150, y + contents.font.size * 1, 20, contents.font.size, item.need_equip_joblevel)
      end
    end
    
    #装備個別管理を導入していれば装備経験値、スロットを表示
    if $kure_base_script[:base_A] && $kure_base_script[:SortOut] 
      #装備経験値
      change_color(system_color)
      draw_text(x, y + contents.font.size * 2, 100, contents.font.size, "装備Exp")
      change_color(normal_color)
      draw_text(x + 110, y + contents.font.size * 2, contents.width - 140, contents.font.size, item.equip_exp)
      
      #耐久値
      if KURE::SortOut::USE_DURABLE == 1
        change_color(system_color)
        draw_text(x, y + contents.font.size * 3, 100, contents.font.size, "耐久値")
        change_color(normal_color)
        if item.broken?
          draw_text(x + 110, y + contents.font.size * 3, contents.width - 140, contents.font.size, "破損中")
        else
          draw_text(x + 110, y + contents.font.size * 3, contents.width - 140, contents.font.size, item.durable_value)
        end
      end
        
      #スロット
      if KURE::SortOut::USE_SLOT_EQUIP == 1
        change_color(system_color)
        draw_text(x, y + contents.font.size * 4, 100, contents.font.size, "スロット")
        change_color(normal_color)
      
        slot_num = item.max_slot_number
        slot_list = item.slot_list.compact.size
      
        for draw_slot in 0..slot_num - 1
          if draw_slot < 10
            draw_text(x + 67 + 15 * draw_slot, y + contents.font.size * 4, 15, contents.font.size,"■") if slot_list > draw_slot
            draw_text(x + 67 + 15 * draw_slot, y + contents.font.size * 4, 15, contents.font.size,"□") if slot_list <= draw_slot
          else
            draw_text(x + 67 + 15 * (draw_slot - 10), y + contents.font.size * 5, 15, contents.font.size,"■") if slot_list > draw_slot
            draw_text(x + 67 + 15 * (draw_slot - 10), y + contents.font.size * 5, 15, contents.font.size,"□") if slot_list <= draw_slot
          end
        end
      end
    end
  
  end
  #--------------------------------------------------------------------------
  # ◎ 操作説明(draw_index = 2)
  #--------------------------------------------------------------------------
  def draw_index_two
    draw_text(0, 0, 180, contents.font.size, "装備品特徴")
    draw_item_name(@draw_item, 5,line_height * 1) if @draw_item
    
    draw_features(0,line_height * 2,@draw_item)
  end
  #--------------------------------------------------------------------------
  # ◎ 特徴の描画(draw_index = 2)
  #--------------------------------------------------------------------------
  def draw_features(x,y,item)
    return unless item
    #配列数取得変数を初期化
    features_max = 0
    #描画用配列を作成
    draw_list = call_add_feature_txt(item)
    #装備品が有れば特徴最大数を取得
    features_max = draw_list.size - 1

    #実際の描画処理
    for list in 0..features_max
      if features_max < 3
        change_color(normal_color)
        draw_text(x, y + contents.font.size * list , contents.width, contents.font.size, draw_list[list]) 
      else
        case list
        when 0..11
          change_color(normal_color)
          draw_text(x, y + contents.font.size * list , contents.width / 2, contents.font.size, draw_list[list])
        when 12..22
          change_color(normal_color)
          draw_text(x + contents.width / 2, y + contents.font.size * (list - 12) , contents.width / 2, contents.font.size, draw_list[list])
        end
      end
    end      
  end
  #--------------------------------------------------------------------------
  # ◎ 習得スキルリスト(draw_index = 3)
  #--------------------------------------------------------------------------
  def draw_index_three
    draw_text(0, 0, 180, contents.font.size, "習得スキルリスト")
    draw_item_name(@draw_item, 5,line_height * 1) if @draw_item
    
    draw_aplist(0,line_height * 2,@draw_item)
  end      
  #--------------------------------------------------------------------------
  # ◎ APのリストを描画(draw_index = 3)
  #--------------------------------------------------------------------------
  def draw_aplist(x,y,item)
    return unless item
    
    #アビリティポイントを取得
    ap_point = @actor.ability_point
          
    #APリスト作成
    ap_list = item.get_ability_point
    count = 0
    for skill in 0..ap_list.size - 1
      if skill % 2 == 0
        draw_text(0, y + contents.font.size * (count + 1), contents.width, contents.font.size, $data_skills[ap_list[skill]].name)
        
        n_ap = 0
        n_ap = ap_point[ap_list[skill]] if ap_point[ap_list[skill]]
        m_ap = $data_skills[ap_list[skill]].need_ability_point
        
        if @actor.skill_learn?($data_skills[ap_list[skill]])
          draw_text(contents.width - 105, y + contents.font.size * (count + 1), 105, contents.font.size, "MASTER" , 2)
        else
          draw_text(contents.width - 100, y + contents.font.size * (count + 1), 40, contents.font.size, n_ap, 2)
          draw_text(contents.width - 60, y + contents.font.size * (count + 1), 20, contents.font.size,"/",1)
          draw_text(contents.width - 40, y + contents.font.size * (count + 1), 40, contents.font.size, m_ap, 2)
        end
        
        count += 1 
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # ◎ 操作説明(draw_index = 4)
  #--------------------------------------------------------------------------
  def draw_index_four
    draw_text(0, 0, 180, contents.font.size, "装備スロットリスト")
    draw_item_name(@draw_item, 5,line_height * 1) if @draw_item
    
    draw_slotlist(0,line_height * 2,@draw_item)
  end
  #--------------------------------------------------------------------------
  # ◎ スロット内容を描画
  #--------------------------------------------------------------------------
  def draw_slotlist(x,y,item)
    return unless item
    
    #スロットリストを取得
    slot_list = item.slot_list
    slot_max_size = item.max_slot_number
    
    #スロットリストを描画
    counter = 0
    for slot in 0..slot_max_size - 1
      draw_text(5, y + line_height * counter, 25, line_height, counter + 1)
      draw_item_name(slot_list[slot], 30, y + line_height * counter) if slot_list[slot]
      counter += 1
    end
    
  end
  #--------------------------------------------------------------------------
  # ◎ 装備シンボルリスト(draw_index = 5)
  #--------------------------------------------------------------------------
  def draw_index_five
    draw_text(0, 0, 180, contents.font.size, "装備シンボルリスト")
    draw_item_name(@draw_item, 5,line_height * 1) if @draw_item
    
    draw_symbollist(0,line_height * 2,@draw_item)
  end
  #--------------------------------------------------------------------------
  # ◎ シンボル内容を描画
  #--------------------------------------------------------------------------
  def draw_symbollist(x,y,item)
    return unless item
    
    #シンボルリストを取得
    slot_list = item.symbol_list.collect{|obj| obj[0] }
    slot_max_size = item.max_symbol_number
    
    #シンボルリストを描画
    counter = 0
    for slot in 0..slot_max_size - 1
      draw_text(x + 5, y + line_height * counter, 25, line_height, counter + 1)
      draw_item_name(slot_list[slot], x + 30, y + line_height * counter) if slot_list[slot]
      counter += 1
    end    
  end
  #--------------------------------------------------------------------------
  # ◎ 操作説明(draw_index = 6)
  #--------------------------------------------------------------------------
  def draw_index_six
    draw_text(0, 0, 180, contents.font.size, "操作説明")
    draw_text(5, contents.font.size * 2, contents.width, contents.font.size, "LR　：ページ切り替え")
  end
  #--------------------------------------------------------------------------
  # ◎ 装備変更(draw_index = 7)
  #--------------------------------------------------------------------------
  def draw_index_seven
    draw_text(0, 0, 180, contents.font.size, "ステータス変化")
    draw_equip_before(0,line_height * 1)
    draw_right_arrow(0, line_height * 2)
    draw_equip_after(20,line_height * 2)

    11.times {|i| draw_item(0, line_height * 2 + contents.font.size * (1 + i), i) } if @can_equip == [0,0,0,0,0,0]
    draw_need_equip_condition(0, line_height * 2 + contents.font.size * 1) if @can_equip != [0,0,0,0,0,0]
  end
  #--------------------------------------------------------------------------
  # ◎ 装備変更のアイテム表示(draw_index = 7)
  #--------------------------------------------------------------------------
  def draw_equip_before(x,y)
    return unless @actor
    draw_item_name(basic_item, x, y) if basic_item
  end
  #--------------------------------------------------------------------------
  # ◎ 装備変更のアイテム表示(draw_index = 7)
  #--------------------------------------------------------------------------
  def draw_equip_after(x,y)
    return unless @actor
    draw_item_name(@draw_item, x, y) if @draw_item
  end
  #--------------------------------------------------------------------------
  # ◎ 項目の描画(draw_index = 7)
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    value = 0
    value2 = 0    
    case param_id 
    when 0,1,2,3,4,5,6,7
      value = @actor.param(param_id).to_i if @actor
      value2 = @temp_actor.param(param_id).to_i  if @temp_actor
      draw_param_name(x, y, param_id)
      draw_current_param(x + 80, y, param_id) if @actor
      draw_right_arrow(x + 142, y)
      draw_new_param(x + 225, y, param_id) if @temp_actor
    when 8,9,10
      value = (@actor.xparam(param_id - 8) * 100).to_i if @actor
      value2 = (@temp_actor.xparam(param_id - 8) * 100).to_i  if @temp_actor
      change_color(system_color)
      draw_text(x, y, 80, line_height, KURE::ExEquip::Vocab_Ex1[param_id - 8])
      change_color(normal_color)
      draw_text(x + 80, y, 32, line_height, value, 2) if @actor
      draw_right_arrow(x + 132, y)
      change_color(param_change_color(value2 - value)) if @temp_actor
      draw_text(x + 230, y, 32, line_height, value2, 2) if @temp_actor
    end  
      
    if @draw_item
      left = "("
      left = "( "  if (value2 - value).abs < 100
      left = "(  " if (value2 - value).abs < 10
          
      left2 = "-"
      left2 = "+" if (value2 - value) > 0
      left2 = " " if (value2 - value) == 0
            
      change_color(param_change_color(value2 - value))
      draw_text(x + 168, y, 50, line_height, left + left2 + ((value2 - value).abs).to_s + ")", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 要求条件の描画(draw_index = 7)
  #--------------------------------------------------------------------------
  def draw_need_equip_condition(x,y)
    change_color(normal_color)
    draw_text(x + 5, y, contents.width, contents.font.size, "装備条件を満たしていません")
    change_color(power_down_color)
    count = 1
    
    if @can_equip[0] == 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "要求Lv未達成")
      count += 1      
    end
    
    if @can_equip[1] == 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "重量超過")
      count += 1      
    end
    
    case @can_equip[2]
    when 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ容量超過")
      count += 1      
    when 2
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ数超過")
      count += 1
    when 3
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ容量超過")
      count += 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ数超過")
      count += 1
    end
    
    if @can_equip[3] == 1 && @draw_item
      for i in 0..7
        next if @draw_item.need_equip_status[i] == 0
        draw_text(x + 5, y + contents.font.size * count, (contents.width / 2) - 5, contents.font.size, "要求" + Vocab.param(i))
        draw_text(x + contents.width / 2 , y + contents.font.size * count, contents.width / 2, contents.font.size, @draw_item.need_equip_status[i].to_s)
        count += 1
      end  
    end
    
    if @can_equip[4] == 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "装備条件未達成")
      count += 1
    end
      
    if @can_equip[5] == 1
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "装備解除不可")
      count += 1    
    end
  end
end

#==============================================================================
# ■ Window_Ex_Equip_Popup
#==============================================================================
class Window_Ex_Equip_Popup < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2 + 120
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 5
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の高さを計算
  #--------------------------------------------------------------------------
  def contents_height
    line_height * visible_line_number
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = super
    rect.x = index * (item_width + spacing)
    rect.y = line_height * 4
    rect
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("装備を反映する", :ok)
    add_command("装備選択に戻る", :ok)
  end
  #--------------------------------------------------------------------------
  # ● 描画処理
  #--------------------------------------------------------------------------
  def draw_contents
    draw_gauge(5 , 0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, 126, line_height, "装備変更確認")
    draw_text(5, line_height * 1, contents.width, line_height, "メモライズ数または容量がオーバーしています。")
    draw_text(5, line_height * 2, contents.width, line_height, "メモライズを初期化して装備を反映しますか？")
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_contents
  end
end
#==============================================================================
#  ■装備拡張 for RGSS3 Ver2.01-β8-fix
#　□author kure
#
#　呼び出し方法 　SceneManager.call(Scene_Equip)
#
#==============================================================================
module KURE
  module ExEquip
  #戦闘中挙動-------------------------------------------------------------------
  #戦闘中の装備変更許可を設定(0=常時不可 1=条件付き可能 2=常時可能)
  PERMIT_EDIT_IN_BATTLE = 0
  #戦闘中装備変更許可スイッチ(スイッチ番号を指定、0を入れない事)
  PERMIT_EDIT_IN_BATTLE_SWITH = 4
    
  #画面の表示設定
  #装備品のステータス補正表示(0=表示しない 1=表示する)
  VIEW_EQUIP_STATUS = 1
  
  #AP情報ウィンドウ(0=表示しない 1=表示する)
  AP_VIEWER = 0
    
  #装備スロット欄の表示設定----------------------------------------------------
  #装備スロット表示名を設定(EQUIP_SLOT_NAME = [スロット5表示名,…]
  EQUIP_SLOT_NAME = ["Значок","Расшир.","スロット7","スロット8"]
  
  #装備スロットを設定
  #通常のスロット
  EQUIP_SLOT = [0,1,2,3,5,4,4,4]
  #二刀流のスロット
  EQUIP_SLOT_DUAL = [0,0,2,3,5,4,4,4,6]
  
  #ステータス欄の表示設定-------------------------------------------------------
  #ステータス変化に表示する文字列
  #Vocab_Ex1 = [命中率,回避率,会心率]
  Vocab_Ex1 = ["Меткость","Уворот","Крит. шанс"]
  
  #装備重量システム-------------------------------------------------------------
  #装備重量システムを利用する(0=利用しない 1=利用する)
  USE_WEIGHT_SYSTEM = 0
  
  #装備レベルシステム-----------------------------------------------------------
  #装備レベルシステムを利用する(0=利用しない 1=利用する)
  USE_EQUIPLV_SYSTEM = 1
  
  #装備ステータスシステム-----------------------------------------------------------
  #装備ステータスシステムを利用する(0=利用しない 1=利用する)
  USE_EQUIPSTATUS_SYSTEM = 1
  
  #装備要求変数システム
  #装備要求変数システムを利用する(0=利用しない 1=利用する)
  USE_EQUIPVAL_SYSTEM = 1
  
  #最大装備重量設定-------------------------------------------------------------
  #基礎最大重量(全てのアクターが最低限もてる重量を設定します)
  MAX_WEIGHT_BASE = 100
  #レベル補正(レベルが上がるごとに増える最大重量を設定します)
  MAX_WEIGHT_Lv = 20
  
  #スキル補正
  #MAX_WEIGHT_SKILL = [[スキルID,重量補正],[スキルID,重量補正],…]
  MAX_WEIGHT_SKILL = []
  
  #装備重量の名称
  WEIGHT_NAME = "WT"
  
  #重量0のアイテムの重量表示(0=表示する 1=表示しない)
  WEIGHT_0_ITEM = 1
  
  end
end

#==============================================================================
# ●■ RPG::Actor(追加定義集積)
#==============================================================================
class RPG::Actor < RPG::BaseItem
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
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 装備変更の可能判定(再定義)
  #     slot_id : 装備スロット ID
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return false if equip_type_sealed_ex?(slot_id)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備封印、固定の判定
  #     slot_id : 装備スロット ID
  #--------------------------------------------------------------------------
  def equip_type_sealed_ex?(slot_id)
    flag = 0
    state_list = self.states
    
    #装備封印、固定(装備品)
    for i in 0..@equips.size - 1
      item_object = equip_item_data_object(i)
      if item_object != nil
        #装備封印(装備品)
        if item_object.seal_equip_type.include?(slot_id)
          change_equip(slot_id, nil)
          flag = 1
        end
        #装備固定(装備品)
        if item_object.rock_equip_type.include?(slot_id)
          flag = 1
        end
      end
    end
        
    #装備封印(職業)
    if $data_classes[@class_id].seal_equip_type.include?(slot_id)
      change_equip(slot_id, nil)
      flag = 1
    end
    #装備固定(職業)
    if $data_classes[@class_id].rock_equip_type.include?(slot_id)
      flag = 1
    end
    
    #装備封印(ステート)
    if state_list != []
      for list in 0..state_list.size - 1
        if state_list[list].seal_equip_type.include?(slot_id)
          change_equip(slot_id, nil)
          flag = 1
        end
      end
    end
        
    #装備固定(ステート)
    if state_list != []
      for list in 0..state_list.size - 1
        if state_list[list].rock_equip_type.include?(slot_id)
          flag = 1
        end
      end
    end
        
    return true if flag == 1
    return false
  end
  #--------------------------------------------------------------------------
  # ● 指定スロットの装備品のアイテムデータオブジェクトの取得(追加定義)
  #--------------------------------------------------------------------------
  def equip_item_data_object(slot_id)
    object_id = @equips[slot_id].id if @equips[slot_id].object != nil
    if object_id != nil
      item_object = $data_weapons[object_id] if equip_slots[slot_id] == 0
      item_object = $data_armors[object_id] if equip_slots[slot_id] != 0
    end
    return item_object
  end  
  #--------------------------------------------------------------------------
  # ● 装備の変更(再定義)
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    #装備制限
    item_object = equip_item_data_object(slot_id)
    return if equip_condition?(item,item_object) != 0    
    
    #拡張装備スロット    
    if item && equip_slots[slot_id] != item.etype_id
      unless item.add_etype_id.include?(equip_slots[slot_id])
        return
      end
    end
    
    #アクター装備制限
    if item && item.actor_equip_limit != []
      unless item.actor_equip_limit.include?(@actor_id)
        return
      end
    end
    
    
    return unless trade_item_with_party(item, equips[slot_id])
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテム変更許可を判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_condition?(equip_item,change_item)
    save_condition = 0
    #装備レベル利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      save_condition += 1 if equip_lv?(equip_item) == 1
    end
    
    #重量システムを利用時だけ判定を行う
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      save_condition += 2 if equip_weight?(equip_item,change_item) == 1
    end
    
    #スキルメモライズ利用時
    if KURE::BaseScript::USE_Skill_Memorize == 1
      save_condition += 4 if equip_memorize?(equip_item,change_item) == 1
      save_condition += 8 if equip_memorize?(equip_item,change_item) == 2
    end
    
    #装備ステータス利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPSTATUS_SYSTEM == 1 
      save_condition += 16 if equip_status?(equip_item) == 1
    end
    
    #装備変数利用時だけ判定を行う
    if KURE::ExEquip::USE_EQUIPVAL_SYSTEM== 1 
      save_condition += 32 if equip_val?(equip_item,change_item) == 1
    end
    
    return save_condition 
  end
  #--------------------------------------------------------------------------
  # ● 装備レベル判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_lv?(equip_item)
    flag = 0

    if equip_item != nil
      #装備レベル
      flag = 1 if equip_item.need_equip_level > @level
      flag = 1 if equip_item.need_equip_limit_level < @level
      #職業レベル
      if KURE::BaseScript::USE_JOBLv == 1
        flag = 1 if equip_item.need_equip_joblevel > @joblevel
        flag = 1 if equip_item.need_equip_limit_joblevel < @joblevel
      end
    end
    
    return flag 
  end
  #--------------------------------------------------------------------------
  # ● 装備ステータス判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_status?(equip_item)
    flag = 0

    if equip_item != nil
      for i in 0..equip_item.need_equip_status.size - 1
        flag = 1 if equip_item.need_equip_status[i] > $game_actors[@actor_id].param(i)
      end
    end
    
    return flag 
  end
  #--------------------------------------------------------------------------
  # ● 重量判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_weight?(equip_item,change_item)
    change_weight = 0
    change_gain_weight = 0
    flag = 0
    
    #重量取得
    change_weight = change_item.weight if change_item
    change_gain_weight = change_item.gain_weight if change_item
      
    #アイテムが存在する時
    if equip_item != nil
      #総重量
      total_weight = all_weight + equip_item.weight - change_weight
      flag = 1 if total_weight > max_weight + equip_item.gain_weight - change_gain_weight 
    else
      if change_gain_weight != 0
        flag = 1 if all_weight > max_weight - change_gain_weight
      end
    end
    
    return flag
  end
  #--------------------------------------------------------------------------
  # ● メモライズ容量判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_memorize?(equip_item,change_item)
    chage_item_gain_memorize = 0
    chaged_item_gain_max_memorize = 0
    item_gain_memorize = 0
    item_gain_max_memorize = 0
    flag = 0
    

    #容量取得
    chage_item_gain_memorize = change_item.gain_memorize if change_item
    chaged_item_gain_max_memorize = change_item.gain_max_memorize if change_item
    item_gain_memorize = equip_item.gain_memorize if equip_item != nil
    item_gain_max_memorize = equip_item.gain_max_memorize if equip_item != nil
    memorize_cap_list = max_memorize_capacity
    memorize_max_list = max_memorize
 
      
    #データがあれば判定
    if chage_item_gain_memorize + item_gain_memorize != 0
      #メモライズ容量の判定
      for i in 0..memorize_cap_list.size - 1
        max_memorize_cap = memorize_cap_list[i] - chage_item_gain_memorize
        max_memorize_cap = memorize_cap_list[i] + item_gain_memorize - chage_item_gain_memorize if equip_item != nil
        flag = 1 if memorize_capacity(i+1) > max_memorize_cap
      end
    end
      
    #データがあれば判定
    if chaged_item_gain_max_memorize + item_gain_max_memorize != 0      
      #メモライズ数の判定
      for i in 0..memorize_max_list.size - 1
        max_memorize_num = memorize_max_list[i] - chaged_item_gain_max_memorize
        max_memorize_num = memorize_max_list[i] + item_gain_max_memorize - chaged_item_gain_max_memorize if equip_item !=nil
        
        memory_cheak = memory_skills.select{|skill| skill.stype_id == i + 1}
        flag = 2 if memory_cheak.size - 1 > max_memorize_num
      end
    end
      
    #判定値を返す
    return flag
  end
  #--------------------------------------------------------------------------
  # ● 装備変数判定(追加定義)
  #--------------------------------------------------------------------------
  def equip_val?(equip_item,change_item)
    flag = 0

    if equip_item != nil
      #装備変数
      var = equip_item.need_equip_val[0]
      value = equip_item.need_equip_val[1]
      
      flag = 1 if $game_variables[var] < value
    end
    
    return flag 
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得(再定義)
  #--------------------------------------------------------------------------
  def equip_slots
    if dual_wield?
      return actor.o_equip_slot_d if actor.o_equip_slot_d != []
      return KURE::ExEquip::EQUIP_SLOT_DUAL
    end
    
    return actor.o_equip_slot if actor.o_equip_slot != []
    return KURE::ExEquip::EQUIP_SLOT  # 通常
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
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          gain_weight += @equips[i].object.gain_weight
        end
      end
    return gain_weight    
  end
  #--------------------------------------------------------------------------
  # ● 記憶容量増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_memorize
    gain_memorize = 0
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          gain_memorize += @equips[i].object.gain_memorize
        end
      end
    return gain_memorize    
  end
  #--------------------------------------------------------------------------
  # ● 記憶数増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_max_memorize
    gain_max_memorize = 0
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          gain_max_memorize += @equips[i].object.gain_max_memorize
        end
      end
    return gain_max_memorize    
  end
  #--------------------------------------------------------------------------
  # ● 重量最大量(追加定義)
  #--------------------------------------------------------------------------  
  def max_weight
    max_weight = 0
    #追加重量
    plus_weight = all_gain_weight
    #基礎値
    max_weight = max_weight + plus_weight + KURE::ExEquip::MAX_WEIGHT_BASE + KURE::ExEquip::MAX_WEIGHT_Lv * @level
    #アクター補正
    max_weight = max_weight + $data_actors[@actor_id].weight_revise
    #職業補正
    max_weight = max_weight + self.class.weight_revise  
    #スキル補正を加算
    for i in 0..KURE::ExEquip::MAX_WEIGHT_SKILL.size-1
      if KURE::ExEquip::MAX_WEIGHT_SKILL[i] != nil
        #スキルを設定していればスキルを保存
        cheack_skill = $data_skills[KURE::ExEquip::MAX_WEIGHT_SKILL[i][0]]
        #念のためnilではないか確認
        if cheack_skill != nil
          #スキルを覚えていれば補正値を加算
          if skill_learn?(cheack_skill)
            if KURE::ExEquip::MAX_WEIGHT_SKILL[i][1] != nil
            max_weight = max_weight + KURE::ExEquip::MAX_WEIGHT_SKILL[i][1]
            end
          end  
        end
      end
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
    @max_weight = @actor.max_weight
    
    create_help_window
    create_small_status_window
    create_command_window
    create_slot_window
    create_item_slot_window
    create_status_window
    create_item_window
    
    @save_item = 0
    @keep_slot_index = 0
    @call_slot = 0
    
    @slot_window.status_window = @status_window
    @item_slot_window.status_window = @status_window
    @item_window.status_window = @status_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_Ex_EquipCommand.new(0,@help_window.height + @small_status_window.height, @small_status_window.width)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:equip,    method(:command_equip))
    @command_window.set_handler(:slot,     method(:command_slot))
    @command_window.set_handler(:optimize, method(:command_optimize))
    @command_window.set_handler(:clear,    method(:command_clear))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● スロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_slot_window
    @slot_window = Window_Ex_EquipSlot.new(0, @command_window.height + @help_window.height + 120, 305,Graphics.height - @command_window.height - @help_window.height - 120)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
    @slot_window.set_handler(:pagedown, method(:next_actor))
    @slot_window.set_handler(:pageup,   method(:prev_actor))
    @slot_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_slot_window
    @item_slot_window = Window_Ex_ItemSlot.new(0, @command_window.height + @help_window.height + 120, 305,Graphics.height - @command_window.height - @help_window.height - 120)
    @item_slot_window.viewport = @viewport
    @item_slot_window.help_window = @help_window
    @item_slot_window.actor = @actor
    @item_slot_window.set_handler(:ok,       method(:on_item_slot_ok))
    @item_slot_window.set_handler(:cancel,   method(:on_item_slot_cancel))
    @item_slot_window.visible = false
    @item_slot_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_Ex_EquipStatus.new(@slot_window.width, @help_window.height,Graphics.width - @slot_window.width,Graphics.height - @help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_small_status_window
    @small_status_window = Window_Equip_Small_Status.new(0,@help_window.height,305,120)
    @small_status_window.viewport = @viewport
    @small_status_window.weight = @actor.all_weight
    @small_status_window.max_weight = @max_weight
    @small_status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_Ex_EquipItem.new(0,@command_window.height +  @help_window.height + 120, 305,Graphics.height - @command_window.height - @help_window.height - 120)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
    @item_slot_window.item_window = @item_window
    @item_window.visible = false
    @item_window.weight = @actor.all_weight
    @item_window.max_weight = @max_weight
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    update_basic
    update_ex_status_window
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update_ex_status_window
    if @item_window.visible == true
      if  @item_window.item != @save_item
        @save_item = @item_window.item
        temp_actor = Marshal.load(Marshal.dump(@actor))
        temp_actor.force_change_equip(@item_window.slot_id, @save_item)
        @status_window.set_temp_actor(temp_actor)
        @status_window.set_select_item2(@save_item)
        @status_window.can_equip = @actor.equip_condition?(@save_item,@item_window.chage_item)
        @status_window.refresh
      end
    end
    
    if @slot_window.visible == true
      if @slot_window.index != @keep_slot_index
        @keep_slot_index = @slot_window.index
        @status_window.set_select_item(@actor.equips[@slot_window.index])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド［装備変更］
  #--------------------------------------------------------------------------
  def command_equip
    @status_window.draw_index = 3
    @call_slot = 0
    slot_window_set_focus
  end
  #--------------------------------------------------------------------------
  # ● コマンド［スロット］
  #--------------------------------------------------------------------------
  def command_slot
    @status_window.draw_index = 3
    @call_slot = 1
    slot_window_set_focus
  end
  #--------------------------------------------------------------------------
  # ● コマンド［全て外す］
  #--------------------------------------------------------------------------
  def command_clear
    Sound.play_equip
    @actor.clear_equipments
    @status_window.refresh
    @slot_window.refresh
    @command_window.activate
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      update_weight     
    end
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
    @save_item = 0
    @slot_window.visible = false
    
    case @call_slot
    when 0
      @item_window.visible = true
      
      @item_window.chage_item = @actor.equips[@slot_window.index]
      @status_window.set_select_item(@actor.equips[@slot_window.index])
      @status_window.draw_index = 1
    when 1
      @item_slot_window.visible = true
      
      @item_window.set_slot_master_item(@actor.equips[@slot_window.index])
      @item_slot_window.set_slot_master_item(@actor.equips[@slot_window.index])
      @status_window.draw_index = 7
    end
    
    update_weight
    
    @item_slot_window.refresh
    @item_window.refresh
    @slot_window.deactivate
    
    case @call_slot
    when 0
      @item_window.activate
      @item_window.select(0)
    when 1
      @item_slot_window.activate
      @item_slot_window.select(0)
    end
  end
  #--------------------------------------------------------------------------
  # ● スロット［キャンセル］
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @slot_window.unselect
    @slot_window.deactivate
    @command_window.activate
    @command_window.select(@call_slot)
    @item_window.chage_item = nil
    @item_slot_window.set_slot_master_item(nil)
    @status_window.draw_index = 0
  end
  #--------------------------------------------------------------------------
  # ● 装備スロット［決定］
  #--------------------------------------------------------------------------
  def on_item_slot_ok
    @item_slot_window.visible = false
    @item_window.visible = true
    slot_item = @item_slot_window.slot_master_item.slot_list[@item_slot_window.index]
    
    @item_window.chage_item = slot_item
    @item_slot_window.deactivate
    
    @item_window.refresh
    @item_window.activate
    @item_window.select(0)
    @status_window.draw_index = 10
  end
  #--------------------------------------------------------------------------
  # ● 装備スロット［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_slot_cancel
    @item_window.set_slot_master_item(nil)
    @item_slot_window.set_slot_master_item(nil)
    @status_window.draw_index = 3
    slot_window_set_focus
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    if @status_window.can_equip != 0
      Sound.play_buzzer
      @item_window.activate
      return
    end
    
    Sound.play_equip
    
    case @call_slot
    when 0
      index = @slot_window.index
      @actor.change_equip(@slot_window.index, @item_window.item)
    
      #二刀流両手剣問題対応
      if @actor.dual_wield?
        if @slot_window.index == 0
          @actor.change_equip(1, nil) if @actor.features_set(54).include?(1)
        elsif @slot_window.index == 1
          @actor.change_equip(0, nil) if @actor.features_set(54).include?(1)
        end
      end

    when 1
      index = @item_slot_window.index
      return unless @actor.trade_item_with_party(@item_window.item , @item_window.chage_item)
      @item_window.slot_master_item.set_slot_value(@item_slot_window.index, @item_window.item)
      
    end
    
    set_passive
    
    case @call_slot
    when 0
      @status_window.draw_index = 3
      @item_window.chage_item = nil
      slot_window_set_focus
      delete_plus_status
      @slot_window.index = index
    when 1
      @status_window.draw_index = 7
      @item_window.chage_item = nil
      item_slot_window_set_focus
      delete_plus_status
      @item_slot_window.index = index
    end

    update_weight
  end
  #--------------------------------------------------------------------------
  # ● アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    case @call_slot
    when 0
      @status_window.draw_index = 3
      index = @slot_window.index
      slot_window_set_focus
      @slot_window.index = index
    when 1
      @status_window.draw_index = 7
      index = @item_slot_window.index
      item_slot_window_set_focus
      @item_slot_window.index = index
    end
    
    delete_plus_status
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    update_weight   
    @status_window.actor = @actor
    @slot_window.actor = @actor
    @item_slot_window.actor = @actor
    @item_window.actor = @actor
    @command_window.activate
    @command_window.select(0)
    @slot_windowdeactivate
    @slot_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    set_passive
    @actor = $game_party.menu_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    set_passive
    @actor = $game_party.menu_actor_prev
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウ項目消去
  #--------------------------------------------------------------------------
  def delete_plus_status
    @status_window.set_temp_actor(nil)
    @status_window.set_select_item(nil)
    @status_window.set_select_item2(nil)
    @status_window.refresh    
  end
  #--------------------------------------------------------------------------
  # ● スロットウィンドウにカーソルセット
  #--------------------------------------------------------------------------
  def slot_window_set_focus
    @item_window.visible = false
    @item_window.unselect
    @item_window.refresh
    
    @item_slot_window.visible = false
    @item_slot_window.unselect
    @item_slot_window.refresh
    
    @slot_window.visible = true
    @slot_window.activate
    @slot_window.select(0)
    @slot_window.refresh
    
    @command_window.unselect
    @command_window.deactivate
    
    @keep_slot_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットウィンドウにカーソルセット
  #--------------------------------------------------------------------------
  def item_slot_window_set_focus
    @item_window.visible = false
    @item_window.unselect
    @item_window.refresh
        
    @slot_window.visible = false
    @slot_window.unselect
    @slot_window.refresh
    
    @item_slot_window.visible = true
    @item_slot_window.activate
    @item_slot_window.select(0)
    @item_slot_window.refresh
    
    @command_window.unselect
    @command_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● 装備重量更新
  #--------------------------------------------------------------------------  
  def update_weight
    @max_weight = @actor.max_weight
    @small_status_window.weight = @actor.all_weight
    @small_status_window.max_weight = @max_weight 
    @item_window.weight = @actor.all_weight
    @item_window.max_weight = @max_weight
    @small_status_window.refresh     
  end
  #--------------------------------------------------------------------------
  # ● パッシブスキル更新
  #--------------------------------------------------------------------------  
  def set_passive
    @actor.fix_memorys if KURE::BaseScript::USE_Skill_Memorize == 1
    @actor.set_passive_skills
    @actor.release_unequippable_items
    @status_window.refresh
  end
end

#==============================================================================
# ■ Window_Ex_EquipSlot
#==============================================================================
class Window_Ex_EquipSlot < Window_EquipSlot
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  attr_reader   :item_window              # アイテムウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @height = height
    super(x, y, width)
    @actor = nil
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
  # ● →キー入力時動作
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    page_list = [3,4]
    page_list.push(5) if KURE::ExEquip::AP_VIEWER == 1
    page_list.push(13) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
    page_list.push(3)
    
    for page in 0..page_list.size - 1
      if page_list[page] == @status_window.draw_index
        @status_window.draw_index = page_list[page + 1]
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ←キー入力時操作
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    page_list = [3,4]
    page_list.push(5) if KURE::ExEquip::AP_VIEWER == 1
    page_list.push(13) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
    page_list.unshift(page_list[page_list.size - 1])
    
    for page in 1..page_list.size - 1
      if page_list[page] == @status_window.draw_index
        @status_window.draw_index = page_list[page - 1]
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(system_color, enable?(index))
    if @actor.equip_slots[index] <= 4
      draw_text(rect.x, rect.y, 75, line_height, slot_name(index))
    else
      draw_index = @actor.equip_slots[index]
      draw_text(rect.x, rect.y, 75, line_height, KURE::ExEquip::EQUIP_SLOT_NAME[draw_index - 5])      
    end  
    draw_item_name(@actor.equips[index], rect.x + 75, rect.y, enable?(index))
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      if @actor.equips[index] != nil
        if @actor.equips[index].gain_weight != 0
          change_color(power_up_color)
          draw_text(rect.x, rect.y, rect.width, line_height, @actor.equips[index].gain_weight.to_s,2)         
        else
          if KURE::ExEquip::WEIGHT_0_ITEM == 1
            if @actor.equips[index].weight != 0 
              change_color(power_down_color)
              draw_text(rect.x, rect.y, rect.width, line_height, @actor.equips[index].weight.to_s,2)
            end
          else
            change_color(power_down_color)
            draw_text(rect.x, rect.y, rect.width, line_height, @actor.equips[index].weight.to_s,2)
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    #フォントの設定
    last_font = contents.font.size
    contents.font.size = 20
    
    contents.clear
    create_contents
    draw_all_items
    
    #フォントを戻す
    contents.font.size = last_font
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.clear
    @help_window.set_item(item) if @help_window
  end
end


#==============================================================================
# ■ Window_Ex_EquipItem
#==============================================================================
class Window_Ex_EquipItem < Window_EquipItem
  attr_accessor :status_window
  attr_accessor :weight
  attr_accessor :max_weight
  attr_accessor :chage_item
  attr_accessor :slot_master_item
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @actor = $game_party.menu_actor
    @weight = 0
    @max_weight = 0
    @call_slot = 0
    @chage_item = nil
    @slot_master_item = nil
  end
  #--------------------------------------------------------------------------
  # ● スロット用アイテムの変数を設定
  #--------------------------------------------------------------------------
  def set_slot_master_item(item)
    @slot_master_item = item
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● →キー入力時動作
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    case @status_window.draw_index
    when 1,2,6,14
      page_list = [1,2]
      page_list.push(6) if KURE::ExEquip::AP_VIEWER == 1
      page_list.push(14) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
      page_list.push(1)
    
      for page in 0..page_list.size - 1
        if page_list[page] == @status_window.draw_index
          @status_window.draw_index = page_list[page + 1]
          break
        end
      end
    when 10,11,12,15
      page_list = [10,11]
      page_list.push(12) if KURE::ExEquip::AP_VIEWER == 1
      page_list.push(15) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
      page_list.push(10)
    
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
    case @status_window.draw_index
    when 1,2,6,14
      page_list = [1,2]
      page_list.push(6) if KURE::ExEquip::AP_VIEWER == 1
      page_list.push(14) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
      page_list.unshift(page_list[page_list.size - 1])
    
      for page in 1..page_list.size - 1
        if page_list[page] == @status_window.draw_index
          @status_window.draw_index = page_list[page - 1]
          break
        end
      end
    when 10,11,12,15
      page_list = [10,11]
      page_list.push(12) if KURE::ExEquip::AP_VIEWER == 1
      page_list.push(15) if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
      page_list.unshift(page_list[page_list.size - 1])
    
      for page in 1..page_list.size - 1
        if page_list[page] == @status_window.draw_index
          @status_window.draw_index = page_list[page - 1]
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def slot_id
    return @slot_id
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    
    if slot_master_item
      if slot_master_item.adopt_slot_type.include?(item.etype_id)
        return true
      end
      return false
    else
      #return false if @slot_id < 0
      #拡張装備タイプ判定
      if item.etype_id != @actor.equip_slots[@slot_id]
        unless item.add_etype_id.include?(@actor.equip_slots[@slot_id])
          return false 
        end
      end
  
      #アクター装備制限の判定
      if item.actor_equip_limit != []
        unless item.actor_equip_limit.include?(@actor.id)
          return false
        end
      end
    
      return @actor.equippable?(item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
      
      #重量システムを利用時は重量を表示する
      if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
        if item.gain_weight != 0
          change_color(power_up_color)
          draw_text(rect.x, rect.y, rect.width - 30, line_height, item.gain_weight.to_s,2)          
        else
          #重量0をチェック
          if KURE::ExEquip::WEIGHT_0_ITEM == 1
            if item.weight != 0
              change_color(power_down_color)
              draw_text(rect.x, rect.y, rect.width - 30, line_height, item.weight.to_s,2)
            end
          else
            change_color(power_down_color)
            draw_text(rect.x, rect.y, rect.width - 30, line_height, item.weight.to_s,2)
          end
        end
      end
      
    end
  
  end
end

#==============================================================================
# ■ Window_Small_Status
#------------------------------------------------------------------------------
# 　メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================
class Window_Equip_Small_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # 保留位置（並び替え用）
  attr_accessor :weight
  attr_accessor :max_weight
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    super(x, y, width, height)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_status
    @actor = $game_party.menu_actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_name(@actor, 130, line_height * 0)
    draw_actor_icons(@actor, 230, line_height * 0)
    draw_actor_hp(@actor, 130, line_height * 1)
    draw_actor_mp(@actor, 130, line_height * 2)
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      if @max_weight != nil
        draw_actor_weight(@actor, 130, line_height * 3)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備重量の描画
  #--------------------------------------------------------------------------
  def draw_actor_weight(actor, x, y, width = 124)
    if @max_weight != 0
      weight_rate = @weight.to_f / @max_weight 
    else
      weight_rate = 1
    end
    draw_gauge(x, y, width, weight_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, KURE::ExEquip::WEIGHT_NAME)
    draw_current_and_max_values(x, y, width, @weight, @max_weight,
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
# ■ Window_Ex_EquipStatus
#------------------------------------------------------------------------------
# 　装備画面で、アクターの能力値変化を表示するウィンドウです。
#==============================================================================
class Window_Ex_EquipStatus < Window_EquipStatus
  attr_accessor :draw_index
  attr_accessor :can_equip
  attr_accessor :slot_item
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    @can_equip = 0
    @draw_index = 0
    @slot_item = nil
    @width = width
    @height = height
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
  # ◎ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    #フォントの設定
    last_font = contents.font.size
    contents.font.size = 20
    
    return if @draw_index == 0
    
    draw_gauge(0,0, contents.width, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    
    case @draw_index
    when 1
      draw_text(0, 0, 126 + 60, contents.font.size, "Изменение характеристик")
      draw_equip_before(0,line_height * 1)
      draw_right_arrow(0, line_height * 2)
      draw_equip_after(20,line_height * 2)
    when 2,4,8,11
      draw_text(0, 0, 126, contents.font.size, "Особые")
      case @draw_index
      when 2
        draw_equip_after(5,line_height * 1)
      when 4
        draw_item_name(@base_item, 5,line_height * 1) if @base_item
      when 8
        draw_item_name(@slot_item, 5,line_height * 1)
      when 11
        draw_item_name(@change_item, 5,line_height * 1) if @change_item
      end      
    when 3,7,10
      draw_text(0, 0, 126, contents.font.size, "Свойства")
      case @draw_index
      when 3
        item = @base_item
      when 7  
        item = @slot_item
      when 10
        item = @change_item
      end
      draw_item_name(item, 5,line_height * 1) if item
    when 5,6,9,12
      draw_text(0, 0, 170, contents.font.size, "習得スキルリスト")
      case @draw_index
      when 6,12
        item = @change_item
      when 5
        item = @base_item
      when 9
        item = @slot_item
      end
      draw_item_name(item, 5,line_height * 1) if item
    when 13,14
      draw_text(0, 0, 170, contents.font.size, "スロット情報")
      case @draw_index
      when 13
        item = @base_item
      when 14
        item = @change_item
      end
      draw_item_name(item, 5,line_height * 1) if item
    end
      
    case @draw_index
    when 1    
      11.times {|i| draw_item(0, line_height * 2 + contents.font.size * (1 + i), i) } if @can_equip == 0
      draw_need_equip_condition(0, line_height * 2 + contents.font.size * 1) if @can_equip != 0
    when 2,4,8,11
      case @draw_index
      when 2,11
        item = @change_item if @change_item
      when 4
        item = @base_item
      when 8
        item = @slot_item
      end
      draw_features(0,line_height * 2,item)
    when 3,7,10
      case @draw_index
      when 3
        item = @base_item if @base_item
      when 7
        item = @slot_item
      when 10
        item = @change_item
      end
        8.times {|i| draw_item3(0, line_height * 1 + contents.font.size * (1 + i), i, item) }
        draw_equip_type(0,line_height * 1 + contents.font.size * 6, item)
    when 5,6,9,12
      case @draw_index
      when 6,12
        item = @change_item if @change_item
      when 5
        item = @base_item
      when 9
        item = @slot_item
      end
      draw_aplist(0,line_height * 2,item)
    when 13,14,15
      case @draw_index
      when 13
        item = @base_item
      when 14,15
        item = @change_item
      end
      draw_slotlist(0,line_height * 2,item)
    end
    
    case @draw_index
    when 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15     
      change_color(normal_color)
      draw_text(0, contents.height - contents.font.size, contents.width, contents.font.size, "← →: Страница",1) 
    end
    contents.font.size = last_font
  end
  #--------------------------------------------------------------------------
  # ◎ 装備変更のアイテム表示
  #--------------------------------------------------------------------------
  def draw_equip_before(x,y)
    return unless @actor
    if @base_item != nil
      draw_item_name(@base_item, x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 装備変更のアイテム表示
  #--------------------------------------------------------------------------
  def draw_equip_after(x,y)
    return unless @actor
    if @change_item != nil
      draw_item_name(@change_item, x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 装備アイテム描画を設定
  #--------------------------------------------------------------------------
  def set_select_item(item)
    return if @base_item == item
    @base_item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 変更装備アイテムの変数を設定
  #--------------------------------------------------------------------------
  def set_select_item2(index)
    return if @change_item == index
    @change_item = index
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ スロット用アイテムを設定
  #--------------------------------------------------------------------------
  def set_slot_item(item)
    @slot_item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 項目の描画(draw_index = 1)
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    case param_id 
    when 0,1,2,3,4,5,6,7
      value = 0
      value2 = 0
      value = @actor.param(param_id).to_i if @actor
      value2 = @temp_actor.param(param_id).to_i  if @temp_actor
      draw_param_name(x, y, param_id)
      draw_current_param(x + 80, y, param_id) if @actor
      draw_right_arrow(x + 112, y)
      draw_new_param(x + 136, y, param_id) if @temp_actor
      
      if KURE::ExEquip::VIEW_EQUIP_STATUS == 1
        if @change_item
          change_color(param_change_color(@change_item.params[param_id]))

          if (value2 - value).abs < 10
            left ="(  "
          elsif (value2 - value).abs < 100
            left ="( "
          else  
            left = "("
          end  
          
          if (value2 - value) > 0
            left2 = "+"
          elsif (value2 - value) == 0
            left2 = " "
          else
            left2 = "-"
          end
          
          change_color(param_change_color(value2 - value))
          draw_text(x + 168, y, 50, line_height, left + left2 + ((value2 - value).abs).to_s + ")", 2)
        end
      end
      
    when 8,9,10
      value = 0
      value2 = 0
      value = (@actor.xparam(param_id - 8) * 100).to_i if @actor
      value2 = (@temp_actor.xparam(param_id - 8) * 100).to_i  if @temp_actor
      change_color(system_color)
      draw_text(x, y, 80, line_height, KURE::ExEquip::Vocab_Ex1[param_id - 8])
      change_color(normal_color)
      draw_text(x + 80, y, 32, line_height, value, 2) if @actor
      draw_right_arrow(x + 112, y)
      change_color(param_change_color(value2 - value)) if @temp_actor
      draw_text(x + 136, y, 32, line_height, value2, 2) if @temp_actor
      
      if KURE::ExEquip::VIEW_EQUIP_STATUS == 1
        if @change_item
          if (value2 - value).abs < 10
            left = "(  "
          elsif (value2 - value).abs < 100
            left ="( "
          else  
            left = "("
          end  
          
          if (value2 - value) > 0
            left2 = "+"
          elsif (value2 - value) == 0
            left2 = " "
          else
            left2 = "-"
          end
          
          change_color(param_change_color(value2 - value))
          draw_text(x + 168, y, 50, line_height, left + left2 + ((value2 - value).abs).to_s + ")", 2)
        end
      end
      
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 要求条件の描画(draw_index = 1)
  #--------------------------------------------------------------------------
  def draw_need_equip_condition(x,y)
    change_color(normal_color)
    draw_text(x + 5, y, contents.width, contents.font.size, "Условия для экипирования не выполнены.")
    change_color(power_down_color)
    count = 1
    
    case @can_equip
    when 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "Не достигнут требуемый уровень.")
      count += 1
    end
    
    case @can_equip
    when 2,3,6,7,10,11,14,15,18,19,22,23,26,27,30,31
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "重量超過")
      count += 1
    end
    
    case @can_equip
    when 4,5,6,7,12,13,14,15,20,21,22,23,28,29,30,31
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ容量超過")
      count += 1
    end

    case @can_equip
    when 8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31
      draw_text(x + 5, y + contents.font.size * count, contents.width, contents.font.size, "メモライズ数超過")
      count += 1
    end

    case @can_equip
    when 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
      if @change_item
        for i in 0..7
          if @change_item.need_equip_status[i] != 0
            draw_text(x + 5, y + contents.font.size * count, (contents.width / 2) - 5, contents.font.size, "要求" + Vocab.param(i))
            draw_text(x + contents.width / 2 , y + contents.font.size * count, contents.width / 2, contents.font.size, @change_item.need_equip_status[i].to_s)
            count += 1
          end
        end  
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 特徴の描画(draw_index = 2)
  #--------------------------------------------------------------------------
  def draw_features(x,y,item)
    return if item == nil
    
    #装備レベル利用時は要求レベルを描画
    if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      change_color(system_color)
      draw_text(5, y, 110, contents.font.size, "Треб. уровень")
      change_color(normal_color)
      draw_text(110, y, 20, contents.font.size, item.need_equip_level ,2)
    
      #職業レベルを導入していれば要求レベルを表示
      if KURE::BaseScript::USE_JOBLv == 1 
        draw_text(130, y, 10, contents.font.size, "/" )
        draw_text(140, y, 20, contents.font.size, item.need_equip_joblevel ,2)
      end
    end         
    
    #特徴を描画
    change_color(system_color)
    draw_text(5, y + contents.font.size, 126, contents.font.size, "Особые свойства")
    
    #配列数取得変数を初期化
    features_max = 0
    #描画用配列を作成
    draw_list = Array.new(100)
    #配列用カウンターをセット
    @draw_counter = 0
    #装備品が有れば特徴最大数を取得
    features_max = item.features.size - 1
       
    #項目をチェックして描画用配列に入れる
      
  #攻撃属性がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 31
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.elements[keep[drow]]
          draw_list[@draw_counter] = "Элемент: " + draw_str
          @draw_counter += 1
        end
      end
      
  #属性耐性がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 11
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_system.elements[drow]+ " (сопр.) "
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[@draw_counter] = draw_str + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end
      
  #弱体化有効度がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 12
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = "耐"+Vocab::param(drow)+ "減少"
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[@draw_counter] = draw_str + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end
      
  #ステート耐性がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 13
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_states[drow].name + " (сопр.) "
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[@draw_counter] = draw_str + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end
      
  #ステート無効化がある場合
      keep = [] 
      #項目をチェックして描画用配列に入れる
      for l in 0..features_max
        if item.features[l].code == 14
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_states[keep[drow]].name
          draw_list[@draw_counter] = draw_str + "無効"
          @draw_counter += 1
        end
      end
      
  #通常能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 21
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          draw_str = Vocab::param(drow)
          value = (keep[drow] * 100).to_i - 100
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[@draw_counter] = draw_str + " " + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end
              
  #特殊能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 22
          keep[item.features[l].data_id] = 0 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] += item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          case drow
          when 0
            draw_str = "Меткость"
          when 1
            draw_str = "Уворот"
          when 2
            draw_str = "Крит. шанс"
          when 3
            draw_str = "Крит. уворот"
          when 4
            draw_str = "Маг. уворот"
          when 5
            draw_str = "Маг. отражение"
          when 6
            draw_str = "Контратака"
          when 7
            draw_str = "Реген. HP/ход"
          when 8
            draw_str = "Реген. MP/ход"
          when 9
            draw_str = "Реген. TP/ход"
          end
          value = (keep[drow] * 100).to_i
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[@draw_counter] = draw_str + " " + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end       
          
  #特殊能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 23
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          case drow
          when 0
            draw_str = "Точность"
          when 1
            draw_str = "Эфф. защиты"
          when 2
            draw_str = "Эфф. лечения"
          when 3
            draw_str = "Эфф. зелий"
          when 4
            draw_str = "Затраты MP"
          when 5
            draw_str = "Зарядка TP"
          when 6
            draw_str = "Получ. физ. урон"
          when 7
            draw_str = "Получ. маг. урон"
          when 8
            draw_str = "Урон ловушек"
          when 9
            draw_str = "Опыт"
          end
          value = (keep[drow] * 100).to_i - 100
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[@draw_counter] = draw_str + " " + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end   

  #攻撃時ステート判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 32
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_states[drow].name + "追加"
          value = (keep[drow] * 100).to_i
          if value != 0
            draw_list[@draw_counter] = draw_str + value.to_s + "% "
            @draw_counter += 1
          end
        end
      end
      
  #攻撃追加がある場合
      keep = 1
      for l in 0..features_max
        if item.features[l].code == 34
          keep += (item.features[l].value).to_i
        end
      end
        
      if keep != 1
        draw_list[@draw_counter] = keep.to_s + "回攻撃 "
        @draw_counter += 1
      end
      
  #スキルタイプ追加がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 41
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.skill_types[keep[drow]]
          draw_list[@draw_counter] = draw_str + "使用可"
          @draw_counter += 1
        end
      end
      
  #スキルタイプ削除がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 42
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.skill_types[keep[drow]]
          draw_list[@draw_counter] = draw_str + "使用不可"
          @draw_counter += 1
        end
      end
        
  #スキル追加がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 43
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_skills[keep[drow]].name
          draw_list[@draw_counter] = draw_str + "使用可"
          @draw_counter += 1
        end
      end
      
  #スキル削除がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 44
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_skills[keep[drow]].name
          draw_list[@draw_counter] = draw_str + "使用不可"
          @draw_counter += 1
        end
      end  
           
  #行動追加がある場合
      for l in 0..features_max
        if item.features[l].code == 61
          #項目を取得
          value = (item.features[l].value * 100).to_i
          draw_list[@draw_counter] = "Доп. действие " + value.to_s + "% "
          @draw_counter += 1
        end
      end
      
  #特殊フラグがある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 62
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        case keep[drow]
        when 0
          value = "自動戦闘"
        when 1
          value = "自動防御"
        when 2
          value = "自動献身"
        when 3
          value = "TP持越"
        end
          draw_list[@draw_counter] = value
          @draw_counter += 1
      end
          
    #パーティー能力がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 64
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        case keep[drow]
        when 0
          value = "敵出現率↓"
        when 1
          value = "敵出現率0"
        when 2
          value = "被先制無効"
        when 3
          value = "先制率上昇"
        when 4
          value = "獲得金額2倍"              
        when 5
          value = "Drop率2倍" 
        end
          draw_list[@draw_counter] = value
          @draw_counter += 1
      end
        
      #追加特徴項目
      for add in 0..5
        if item.party_add_ability(add) != 100
          case add
          when 0
            value = "Получ. золото ×" + (item.party_add_ability(add).to_f / 100).to_s
          when 1
            value = "Получ. предметы ×" + (item.party_add_ability(add).to_f / 100).to_s
          when 2
            value = "Шанс нападения ×" + (item.party_add_ability(add).to_f / 100).to_s
          when 3
            value = "Получ. опыт ×" + (item.party_add_ability(add).to_f / 100).to_s
          when 4
            value = "獲得JEXP" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 5
            value = "獲得EEXP" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          end
          draw_list[@draw_counter] = value
          @draw_counter += 1
        end
      end  

      #追加特徴項目2
      for add in 0..16
        case add
        when 0
          if item.battler_add_ability(add) != 100
            value = "スティール率" + (item.battler_add_ability(add).to_f / 100).to_s + "倍"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 1
          if item.battler_add_ability(add)[0] != 0
            value = "自動復活"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 2
          if item.battler_add_ability(add) != 0 
            value = "踏みとどまり" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 3
          if item.battler_add_ability(add) != 0
            value = "回復反転" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 4
          if item.battler_add_ability(add) != []
            for state in 0..item.battler_add_ability(add).size - 1
              value = "Вызывает: " + $data_states[item.battler_add_ability(add)[state]].name
              draw_list[@draw_counter] = value
              @draw_counter += 1
            end
          end
        when 5
          if item.battler_add_ability(add) != 0
            value = "メタルボディ"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 6
          multi_skill = Array.new
          all_list = item.battler_add_ability(add)
          for list in 0..all_list.size - 1
            if list % 2 == 0
              if all_list[list] && all_list[list + 1]
                multi_skill[all_list[list]] = 0 unless multi_skill[all_list[list]]
                multi_skill[all_list[list]] = [multi_skill[all_list[list]],all_list[list + 1]].max
              end
            end
          end
          
          for skill_type in 1..multi_skill.size - 1
            if multi_skill[skill_type] != 0
              value = $data_system.skill_types[skill_type] + multi_skill[skill_type].to_s + "回発動"
              draw_list[@draw_counter] = value
              @draw_counter += 1
            end
          end
        when 7
          if item.battler_add_ability(add) != 0
            value = "即死反転"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 8
          if item.battler_add_ability(add) != 0
            value = "仲間想い" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 9
          if item.battler_add_ability(add) != 0
            value = "弱気" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 10
          if item.battler_add_ability(add) != 0
            value = "防御壁" + item.battler_add_ability(add).to_s + "枚展開"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 11
          if item.battler_add_ability(add) != 0
            value = "無効化" + item.battler_add_ability(add).to_s
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 12
          if item.battler_add_ability(add) != 100
            value = "TP消費率" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 13
          if item.battler_add_ability(add) != []
            value = "スキル変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 14
          if item.battler_add_ability(add) != []
            value = "スキル強化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 15
          if item.battler_add_ability(add) != []
            value = "行動変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 16
          if item.battler_add_ability(add) != []
            value = "最終反撃能力"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 17
          if item.battler_add_ability(add) != []
            value = "反撃変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 18
          if item.battler_add_ability(add) != []
            value = "戦闘後回復"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 19
          if item.battler_add_ability(add) != []
            value = "HP消費率変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 20
          if item.battler_add_ability(add) != []
            value = "MP消費率変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 21
          if item.battler_add_ability(add) != []
            value = "TP消費率変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 22
          if item.battler_add_ability(add) != 100
            value = "HP消費率" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 23
          if item.battler_add_ability(add) != 0
            value = "憑依強化" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 24
          if item.battler_add_ability(add) != 0
            value = "反撃強化" + item.battler_add_ability(add).to_s + "%"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 25
          if item.battler_add_ability(add) != []
            value = "逆境時強化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 26
          if item.battler_add_ability(add) != 0
            value = "衝撃MP変換"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 27
          if item.battler_add_ability(add) != 0
            value = "衝撃G変換"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 28
          if item.battler_add_ability(add) != 0
            value = "必中反撃"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 29
          if item.battler_add_ability(add) != 0
            value = "魔法反撃"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        end
      end 
      
    #追加特徴項目3
    booster = item.multi_booster(0)
    drain = item.multi_booster(1)
    keep = []
    if booster
      for i in 0..booster.size - 1
        if i % 2 == 0
          keep[booster[i]] = 0 unless keep[booster[i]]
          keep[booster[i]] += booster[i + 1]
        end
      end
      
      for drow in 0..keep.size - 1
        if keep[drow]
          value = $data_system.elements[drow] + "追加" + keep[drow].to_s + "%"
          draw_list[@draw_counter] = value
          @draw_counter += 1
        end
      end
      
    end
    
    keep = []
    if drain
      for i in 0..drain.size - 1
        if i % 2 == 0
          keep[drain[i]] = 0 unless keep[drain[i]]
          keep[drain[i]] += drain[i + 1]
        end
      end
      
      for drow in 0..keep.size - 1
        if keep[drow]
          value = $data_system.elements[drow] + "吸収" + keep[drow].to_s + "%"
          draw_list[@draw_counter] = value
          @draw_counter += 1
        end
      end
    end  
      
      #実際の描画処理
      for j in 0..@draw_counter
        if draw_list[j] != nil or 0
          if @draw_counter < 11
            change_color(normal_color)
            draw_text(x, y + contents.font.size * (j + 2) , contents.width, contents.font.size, draw_list[j])
          else
            case j
            when 0..9
              change_color(normal_color)
              draw_text(x, y + contents.font.size * (j + 2) , contents.width / 2, contents.font.size, draw_list[j])
            when 10..20
              change_color(normal_color)
              draw_text(x + contents.width / 2, y + contents.font.size * (j - 8) , contents.width / 2, contents.font.size, draw_list[j])
            end
          end
        end
      end      
    
  end
  #--------------------------------------------------------------------------
  # ◎ 項目の描画(draw_index = 3)
  #--------------------------------------------------------------------------
  def draw_item3(x, y, param_id, item)

    return unless item
    left = ""
    left2 = ""
    
    case param_id 
    when 0,2,4,6
      draw_param_name(x, y - contents.font.size * (param_id / 2), param_id)
    when 1,3,5,7
      draw_param_name(x + contents.width / 2, y - contents.font.size * (param_id / 2 + 1), param_id)
    end
    
    case param_id 
    when 0,1,2,3,4,5,6,7
      if KURE::ExEquip::VIEW_EQUIP_STATUS == 1
        if item
          change_color(param_change_color(item.params[param_id]))

          if item.params[param_id].abs < 10
            left ="  "
          elsif item.params[param_id].abs < 100
            left =" "
          else 
            left = ""
          end  
          
          if item.params[param_id] > 0
            left2 = "+"
          elsif item.params[param_id] == 0
            left2 = " "
          else
            left2 = "-"
          end
        end
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
  # ◎ 要求条件の描画(draw_index = 3)
  #--------------------------------------------------------------------------
  def draw_equip_type(x,y,item)
    return unless item
    
    change_color(system_color)
    draw_text(x, y + contents.font.size * 0, 100, contents.font.size, "Тип предмета")
    
    if item.is_a?(RPG::Weapon)
      str = $data_system.weapon_types[item.wtype_id]
    elsif item.is_a?(RPG::Armor) 
      str = $data_system.armor_types[item.atype_id]
    else
      return
    end
    
    change_color(normal_color)
    draw_text(x + 110, y + contents.font.size * 0, contents.width - 140, contents.font.size, str)
    
    #装備個別管理を導入していれば装備経験値、スロットを表示
    if KURE::BaseScript::USE_SortOut == 1 
      #装備経験値
      change_color(system_color)
      draw_text(x, y + contents.font.size * 1, 100, contents.font.size, "Опыт предмета")
      change_color(normal_color)
      draw_text(x + 110, y + contents.font.size * 1, contents.width - 140, contents.font.size, item.equip_exp)
      
      #耐久値
      if KURE::SortOut::USE_DURABLE == 1
        change_color(system_color)
        draw_text(x, y + contents.font.size * 2, 100, contents.font.size, "耐久値")
        change_color(normal_color)
        if item.broken?
          draw_text(x + 110, y + contents.font.size * 2, contents.width - 140, contents.font.size, "破損中")
        else
          draw_text(x + 110, y + contents.font.size * 2, contents.width - 140, contents.font.size, item.durable_value)
        end
      end
        
      #スロット
      if KURE::SortOut::USE_SLOT_EQUIP == 1
        change_color(system_color)
        draw_text(x, y + contents.font.size * 3, 100, contents.font.size, "スロット")
        change_color(normal_color)
      
        slot_num = item.max_slot_number
        slot_list = item.slot_list.compact.size
      
        for draw_slot in 0..slot_num - 1
          if draw_slot < 10
            draw_text(x + 67 + 15 * draw_slot, y + contents.font.size * 3, 15, contents.font.size,"■") if slot_list > draw_slot
            draw_text(x + 67 + 15 * draw_slot, y + contents.font.size * 3, 15, contents.font.size,"□") if slot_list <= draw_slot
          else
            draw_text(x + 67 + 15 * (draw_slot - 10), y + contents.font.size * 4, 15, contents.font.size,"■") if slot_list > draw_slot
            draw_text(x + 67 + 15 * (draw_slot - 10), y + contents.font.size * 4, 15, contents.font.size,"□") if slot_list <= draw_slot
          end
        end
      end
      
    end
  
  end
  #--------------------------------------------------------------------------
  # ◎ APのリストを描画(draw_index = 2)
  #--------------------------------------------------------------------------
  def draw_aplist(x,y,item)
    return if item == nil
    
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
  # ◎ スロット内容を描画(draw_index = 2)
  #--------------------------------------------------------------------------
  def draw_slotlist(x,y,item)
    return if item == nil
    
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
    if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
      col_max += 1
    end
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 0
      col_max += 1
    end
    return col_max
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::equip2,   :equip)
    if KURE::BaseScript::USE_SortOut == 1
      if KURE::SortOut::USE_SLOT_EQUIP == 1
        add_command("スロット", :slot)
      end
    end
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 0
      add_command(Vocab::optimize, :optimize)
    end
    add_command(Vocab::clear,    :clear)
  end
end

#==============================================================================
# ■ Window_Ex_ItemSlot
#==============================================================================
class Window_Ex_ItemSlot < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :status_window            # ステータスウィンドウ
  attr_accessor :item_window              # アイテムウィンドウ
  attr_accessor :slot_master_item
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @width = width
    @height = height
    super(x, y)
    @actor = nil
    @set_item = nil
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
  # ● スロット用アイテムの変数を設定
  #--------------------------------------------------------------------------
  def set_slot_master_item(item)
    @slot_master_item = item
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
  # ● →キー入力時動作
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    case @status_window.draw_index
    when 7
      @status_window.draw_index = 8
    when 8
      @status_window.draw_index = 9
    when 9
      @status_window.draw_index = 7
    end
  end
  #--------------------------------------------------------------------------
  # ● ←キー入力時操作
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    case @status_window.draw_index
    when 7
      @status_window.draw_index = 9
    when 8
      @status_window.draw_index = 7
    when 9
      @status_window.draw_index = 8
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 24
    rect.width -= 28
    rect
  end       
  #--------------------------------------------------------------------------
  # ● 項目を描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    item = @list[index][:ext]
    
    rect = item_rect(index)
    rect.x += 24
    rect.width -= 28
    
    draw_item_name(item, rect.x, rect.y, command_enabled?(index))
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    return if @index < 0
    @status_window.set_slot_item(current_ext) if @status_window
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    create_contents
    super
    draw_number
  end
  #--------------------------------------------------------------------------
  # ● 番号の描画
  #--------------------------------------------------------------------------
  def draw_number
    return unless @slot_master_item
    for number in 0..@slot_master_item.max_slot_number - 1
      change_color(system_color)
      draw_text(0, contents.font.size * number, 24, contents.font.size, number + 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if @slot_master_item
      slot_list = @slot_master_item.slot_list
      max_number = @slot_master_item.max_slot_number
      for slot in 0..max_number - 1
        if slot_list[slot]
          add_command(slot_list[slot].name , :ok ,true , slot_list[slot])
        else
          add_command("" , :ok ,true)
        end
      end
    else
      add_command("" , :ok ,false)
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


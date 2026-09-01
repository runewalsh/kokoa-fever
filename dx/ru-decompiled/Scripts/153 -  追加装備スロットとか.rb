#==============================================================================
#  ■装備拡張 for RGSS3 Ver3.00-β3 オプションスクリプトＡ
#　□作成者 kure kurokuro
#　
#　導入位置：装備拡張の真下
#==============================================================================

#==============================================================================
# ●■ RPG::BaseItem(追加定義集積)
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 封印対応キーの定義(追加定義)
  #--------------------------------------------------------------------------  
  def seal_key
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<封印対応キー\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 装備封印キーの定義(追加定義)
  #--------------------------------------------------------------------------  
  def unlock_seal_key
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<封印解除キー\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 追加装備スロットの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_equip_slot
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<追加装備スロット\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
end


#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 装備可能判定(エイリアス再々定義)
  #--------------------------------------------------------------------------
  alias kuro_kuro_before_equippable? equippable?
  def equippable?(item)
    #封印解除キーの判定
    if item && item.seal_key != []
      flag = 0
      for i in 0..item.seal_key.size - 1
        flag = 1 if self.all_unlock_key.include?(item.seal_key[i])
      end
      return false if flag == 0
    end
    kuro_kuro_before_equippable?(item)
  end
end
  
#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 所持している装備封印キーの定義(追加定義)
  #--------------------------------------------------------------------------  
  def all_unlock_key 
    unlock = Array.new
    equips.each do |obj|
      unlock += obj.unlock_seal_key if obj
    end
    return unlock
  end
  #--------------------------------------------------------------------------
  # ● 追加装備スロットの定義(追加定義)
  #--------------------------------------------------------------------------  
  def all_add_equip_slot 
    add = Array.new
    equips.each do |obj|
      add += obj.add_equip_slot if obj
    end
    return add
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得(再々定義)
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
    slot += all_add_equip_slot
    
    
    while slot.size > @equips.size do 
      @equips.push(Game_BaseItem.new)
    end
    
    return slot
  end
end

#==============================================================================
# ■ Window_Ex_Multi_Equip
#==============================================================================
class Window_Ex_Multi_Equip < Window_Command
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか(再定義)
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
      
      #封印解除キーの判定
      if item.seal_key != []
        flag = 0
        for i in 0..item.seal_key.size - 1
          flag = 1 if @actor.all_unlock_key.include?(item.seal_key[i])
        end
        return false if flag == 0
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
end
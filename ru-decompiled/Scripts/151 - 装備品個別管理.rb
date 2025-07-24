#==============================================================================
# ■装備品個別管理 for RGSS3 Ver2.01-β18-fix
# □作成者 kure
#===============================================================================
module KURE
  module SortOut
    #基本設定-------------------------------------------------------------------
    #ID管理用変数
    ID_BASE = 10000
    
    #拡張ステータス項目()
    ADD_STATUS = 9
    
    #能力付与に関する項目-------------------------------------------------------
    #装備品のランダム能力付与機能(0=OFF、1=ON)
    RANDOM_PARAM = 0
    
    #ショップ購入アイテムのランダム能力付与(0=OFF、1=ON)
    #RANDOM_PARAM = 1の時のみ有効
    SHOP_RANDOM_PARAM = 0
    
    #装備品接頭語別能力管理機能(0=OFF 1=ON)
    #※使用時は装備品個別管理設定ファイルを導入してください。
    USE_NAME_VALUE = 0
    
    #ショップ購入アイテムの接頭語付与(0=OFF 1=ON)
    #USE_NAME_VALUE = 1の時のみ有効
    SHOP_NAME_VALUE = 0
    
    #初期装備アイテムの接頭語付与(0=OFF 1=ON)
    #USE_NAME_VALUE = 1の時のみ有効
    FIRST_EQUIP_NAME_VALUE = 0
    
    #スロット関連の設定---------------------------------------------------------
    #スロット装備システムの機能使用の設定(0=OFF、1=ON)
    USE_SLOT_EQUIP = 0
    
    #スロット数の設定の反映方法(0=設定数を反映 1=設定数を上限としてランダム)
    SLOT_NUM_MODE = 0
    
    #耐久値関連の設定-----------------------------------------------------------
    #耐久値機能使用の設定(0=OFF、1=ON)
    USE_DURABLE = 0

    #破壊したアイテムの設定(0=以下の設定を適用 1=消滅)
    BROKEN_SETTING = 0
    
      #BROKEN_SETTING = 0の時の処理設定-----------------------------------------
      #破損中のアイテムにつく名前
      BROKEN_ITEM_NAME = "[壊]"
      
      #能力下降設定
      #破損時の装備能力発揮率(％指定)
      BROKEN_PERFORM = 30
      
      #特徴反映設定(0=反映される 1=反映されない)
      BROKEN_FEATURE = 1
      
      #装備可能設定(0=装備可能 1=装備不可)
      BROKEN_CAN_EQUIP = 1
      
      #破損中装備の価格設定(0=通常通り 1=2になる)
      BROKEN_PRICE = 1
  end
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ◆ 固有ID取得
  #--------------------------------------------------------------------------
  def identify_id
    return 0
  end
  #--------------------------------------------------------------------------
  # ◆ カスタム数取得
  #--------------------------------------------------------------------------
  def custom_num
    return 0
  end
  #--------------------------------------------------------------------------
  # ◆ 耐久値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def first_durable
    return 100 unless @note
    @note.match(/<耐久値\s?(\d+)\s?>/)
    return 100 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ◆ 使用する接頭語リストの定義(追加定義)
  #--------------------------------------------------------------------------  
  def use_name_value_list
    return 0 unless @note
    @note.match(/<接頭語リスト\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ◆ 接頭語数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def name_value_number
    return 1 unless @note
    @note.match(/<接頭語数\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i 
  end
  #--------------------------------------------------------------------------
  # ◆ 拡張接頭語数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_name_value_number
    return 1 unless @note
    @note.match(/<追加最大接頭語数\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i 
  end
  #--------------------------------------------------------------------------
  # ◆ スロット数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def slot_number
    return 0 unless @note
    @note.match(/<スロット数\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ◆ 拡張スロット最大数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_slot_number
    return 0 unless @note
    @note.match(/<追加最大スロット数\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ● スロット対応装備タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def adopt_slot_type
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<スロット対応装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ ランダム能力付与許可の定義(追加定義)
  #--------------------------------------------------------------------------  
  def permit_randomize
    cheack_note = @note
    return false if cheack_note.include?("<ランダム付与禁止>")
    return true
  end
  #--------------------------------------------------------------------------
  # ◆ ランダム能力付与許可の定義(追加定義)
  #--------------------------------------------------------------------------  
  def permit_namevalue
    cheack_note = @note
    return false if cheack_note.include?("<接頭語付与禁止>")
    return true
  end
  #--------------------------------------------------------------------------
  # ◆ 耐久値減少無効の定義(追加定義)
  #--------------------------------------------------------------------------  
  def protect_durable
    cheack_note = @note
    return true if cheack_note.include?("<耐久値減少無効>")
    return false
  end
  #--------------------------------------------------------------------------
  # ◆ 強化値減少無効の定義(追加定義)
  #--------------------------------------------------------------------------  
  def protect_custom
    cheack_note = @note
    return true if cheack_note.include?("<強化値減少無効>")
    return false
  end
  #--------------------------------------------------------------------------
  # ◇ ランダム能力付与倍率の定義(追加定義)
  #--------------------------------------------------------------------------  
  def vest_random_rate
    cheack_note = @note
    random_list = Array.new
    for param in 0..7
      random_list[param] = 1
    end
    #メモ欄から配列を作成
    cheack_note.match(/<HP付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[0] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<MP付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[1] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<攻撃力付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[2] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<防御力付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[3] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<魔法力付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[4] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<魔法防御付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[5] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<敏捷性付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[6] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    cheack_note.match(/<運付与倍率\s?(\d+)%\s?-\s?(\d+)%\s?>/)
    if $1 && $2
      random_list[7] = (1 + $1.to_i + rand($2.to_i - $1.to_i)).to_f / 100
    end
    
    return random_list  
  end
end

#==============================================================================
# ■ RPG::EquipItem
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  attr_accessor :add_features
  attr_accessor :name_value
  attr_accessor :custom_param
  attr_accessor :durable_value
  #--------------------------------------------------------------------------
  # ● 同一オブジェクトの作成
  #--------------------------------------------------------------------------
  def clone
    same_obj = super
    return same_obj
  end
  #--------------------------------------------------------------------------
  # ● 装備品のidを返す
  #--------------------------------------------------------------------------
  def id
    return identify_id * KURE::SortOut::ID_BASE + @id if identify_id
    return @id
  end
  #--------------------------------------------------------------------------
  # ● 装備品データベースのidを返す
  #--------------------------------------------------------------------------
  def database_id
    return @id
  end
  #--------------------------------------------------------------------------
  # ● 同一アイテムの判定処理
  #--------------------------------------------------------------------------
  def ==(obj)
    return equal?(obj)
  end
  #--------------------------------------------------------------------------
  # ◆ 共通の初期化処理
  #--------------------------------------------------------------------------
  def common_setting
    @add_features = []
    @name_value = []
    @name_value_param = [0,0,0,0,0,0,0,0]
    @name_value_feature = []
    @name_value_note = ''
    @slot = []
    @slot_param = [0,0,0,0,0,0,0,0]
    @slot_feature = []
    @slot_note = ''
    @add_slot = 0
    @add_name_value = 0
    @durable_value = first_durable
    @base_note = @note.clone unless @base_note
    @base_price = @price
    @view_name = ""
    @uniq_name = ""
    
    @slot_number = slot_number
    @slot_number = rand(slot_number + 1) if KURE::SortOut::SLOT_NUM_MODE == 1
  end
  #--------------------------------------------------------------------------
  # ◆ 取得時初期の処理
  #--------------------------------------------------------------------------
  def first_setting
    return if @first_seted == true
    common_setting
    set_name_value
    random_param
    reset_name_random_params
    @first_seted = true 
  end
  #--------------------------------------------------------------------------
  # ◆ 初期装備の処理
  #--------------------------------------------------------------------------
  def first_equip_setting
    return if @first_seted == true
    common_setting
    set_name_value if KURE::SortOut::FIRST_EQUIP_NAME_VALUE == 1
    random_param
    reset_name_random_params
    @first_seted = true 
  end
  #--------------------------------------------------------------------------
  # ◆ 能力更新処理
  #--------------------------------------------------------------------------
  def reset_name_random_params
    #接頭語をセット
    set_name_value_str
    
    #接頭語用パラメータセット
    set_name_value_param
    
    #スロット用パラメータセット
    set_slot_param  
    
    #メモ欄の更新
    set_note
    
    #価格更新
    set_price
    
    #基礎能力値を更新
    set_basic_params 
    
    #表示名を更新
    set_name
  end
  #--------------------------------------------------------------------------
  # ● 価格
  #--------------------------------------------------------------------------
  def set_price
    #接頭語オブジェクトの価格を読み込む
    name_value_price = 0
    for i in 0..@name_value.size - 1
      if @name_value[i][0]
        if @name_value[i][0].class == RPG::Weapon or @name_value[i][0].class == RPG::Armor
          name_value_price += @name_value[i][0].price
        end
      end
    end
    
    @price = @base_price + name_value_price
    @price = 2 if KURE::SortOut::BROKEN_PRICE == 1 && broken?
  end
  #--------------------------------------------------------------------------
  # ◆ 接頭語のランダム付与
  #--------------------------------------------------------------------------
  def set_name_value
    @name_value = [] unless @name_value
    #接頭語付与の管理
    return if KURE::SortOut::USE_NAME_VALUE == 0
    #ショップシーンで付与しない設定
    if SceneManager.scene_is?(Scene_Shop) 
      return if KURE::SortOut::SHOP_NAME_VALUE == 0
    end
    #固有IDが振られていなければ付与しない
    return unless identify_id
    #禁止されていれば付与しない
    return unless permit_namevalue
    
    #使用するネームバリューリストの確認
    list = use_name_value_list
    
    #ネームバリューリストを読み込む
    use_list = KURE::SortOut::NAME_VALUE_LIST[list]
    return unless use_list
    
    #ネームバリューリストよりリスト決定変数を算出
    total_dice = 0
    for i in 1..use_list.size - 1
      total_dice += use_list[i][2]
    end
    
    #付与するネームバリューを決定する
    dice = 1 + rand(total_dice)
    add_value = 1
    while dice > 0 do
      dice -= use_list[add_value][2]
      add_value += 1
    end
    add_value -= 1
    
    #ネームバリューを付与
    cat = 0
    case use_list[add_value][0]
    when "W"
      cat = 1
      @name_value.push([$data_weapons[use_list[add_value][1]],use_list[add_value][3],1])
    when "A"
      cat = 2
      @name_value.push([$data_armors[use_list[add_value][1]],use_list[add_value][3],1])
    when "J"
      cat = 3
      @name_value.push([$data_classes[use_list[add_value][1]],use_list[add_value][3],2])
    when "S"
      cat = 4
      @name_value.push([$data_states[use_list[add_value][1]],use_list[add_value][3],3])
    end
    
    $game_party.push_name_value_list(list, add_value, cat)
    
    #能力更新
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ● 接頭語の取得
  #--------------------------------------------------------------------------
  def set_name_value_str
    @add_name_before = ""
    @add_name_after = ""
    
    return "" unless @name_value
    return "" if @name_value == []
    
    for list in 0..@name_value.size - 1
      case @name_value[list][1]
      when 1
        @add_name_before += @name_value[list][0].name
      when 2
        @add_name_after += @name_value[list][0].name
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◆ 全ての接頭語消去の処理
  #--------------------------------------------------------------------------
  def delete_all_name_value
    @name_value = []
    @name_value_param = [0,0,0,0,0,0,0,0]
    
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ● 接頭語付与の処理
  #--------------------------------------------------------------------------
  def add_name_value(list,value)
    return if @name_value.size >= name_value_number && name_value_number > 1
    @name_value = [] if name_value_number == 1
    @name_value = [] unless @name_value
    @name_value_param = [0,0,0,0,0,0,0,0]

    add_name = KURE::SortOut::NAME_VALUE_LIST[list][value]
    #ネームバリューを付与
    cat = 0
    case add_name[0]
    when "W"
      cat = 1
      @name_value.push([$data_weapons[add_name[1]],add_name[3],1])
    when "A"
      cat = 2
      @name_value.push([$data_armors[add_name[1]],add_name[3],1])
    when "J"
      cat = 3
      @name_value.push([$data_classes[add_name[1]],add_name[3],2])  
    when "S"
      cat = 4
      @name_value.push([$data_states[add_name[1]],add_name[3],3])
    end    
    
    #付与済みリスト更新
    $game_party.push_name_value_list(list, value, cat)
    
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ● 接頭語用パラメータの取得
  #--------------------------------------------------------------------------
  def set_name_value_param
    @name_value_param = [0,0,0,0,0,0,0,0]
    @name_value_feature = []
    @name_value_note = ''
    for name in 0..@name_value.size - 1
      @name_value_feature += @name_value[name][0].features
      @name_value_note += @name_value[name][0].note
      
      case @name_value[name][2]
      #武器防具
      when 1
        for param in 0..7
          @name_value_param[param] += @name_value[name][0].params[param]
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◆ 接頭語数の取得
  #--------------------------------------------------------------------------
  def max_name_value_number
    return name_value_number + @add_name_value
  end  
  #--------------------------------------------------------------------------
  # ◆ 接頭語数の拡張
  #--------------------------------------------------------------------------
  def gain_name_value_number
    @add_name_value = 0 unless @add_name_value
    @add_name_value += 1 if @add_name_value < add_name_value_number
  end
  #--------------------------------------------------------------------------
  # ◆ スロットの取得
  #--------------------------------------------------------------------------
  def slot_list 
    @slot = [] unless @slot
    return @slot
  end  
  #--------------------------------------------------------------------------
  # ◆ スロット数の取得
  #--------------------------------------------------------------------------
  def max_slot_number
    return @slot_number + @add_slot
  end  
  #--------------------------------------------------------------------------
  # ◆ スロット数の拡張
  #--------------------------------------------------------------------------
  def gain_slot_number
    @add_slot = 0 unless @add_slot
    @add_slot += 1 if max_slot_number < add_max_slot_number
    #@add_slot += 1 if @add_slot < add_max_slot_number
  end
  #--------------------------------------------------------------------------
  # ◆ スロット拡張できるか
  #--------------------------------------------------------------------------
  def gain_slot?
    @add_slot = 0 unless @add_slot
    return true if max_slot_number < add_max_slot_number
    #return true if @add_slot < add_max_slot_number
    return false
  end
  #--------------------------------------------------------------------------
  # ◆ スロットにアイテムを追加する処理
  #--------------------------------------------------------------------------
  def set_slot_value(slot, item)
    return if KURE::SortOut::USE_SLOT_EQUIP == 0
    @slot = [] unless @slot
    unless item
      @slot[slot] = nil
      reset_name_random_params
      return
    end
    
    return if slot - 1 >= max_slot_number
    return if item.identify_id == 0
    
    etype = 2
    etype = 1 if item.is_a?(RPG::Weapon)
    case etype
    when 1
      @slot[slot] = $game_party.set_weapon(item.id)
    when 2
      @slot[slot] = $game_party.set_armor(item.id)
    end
    
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ● スロット用パラメータの取得
  #--------------------------------------------------------------------------
  def set_slot_param
    @slot_param = [0,0,0,0,0,0,0,0]
    @slot_feature = []
    @slot_note = ''
    for slot in 0..@slot.size - 1
      if @slot[slot]
        @slot_feature += @slot[slot].features
        @slot_note += @slot[slot].note
        for param in 0..7
          @slot_param[param] += @slot[slot].params[param]
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◆ 耐久値の取得
  #--------------------------------------------------------------------------
  def durable_value 
    @durable_value = first_durable unless @durable_value
    return @durable_value
  end
  #--------------------------------------------------------------------------
  # ◆ 破損状態の取得
  #--------------------------------------------------------------------------
  def broken?
    return false unless @durable_value
    return true if @durable_value < 0
    return false
  end
  #--------------------------------------------------------------------------
  # ◆ 修復する
  #--------------------------------------------------------------------------
  def recover_durable
    @durable_value = first_durable
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ◆ 耐久値の増減
  #--------------------------------------------------------------------------
  def reduce_durable_value=(value)
    return if KURE::SortOut::USE_DURABLE == 0
    return if protect_durable && value > 0
    @durable_value = first_durable unless @durable_value
    @durable_value -= value
    @durable_value = first_durable if @durable_value > first_durable
    
    if @durable_value < 1
      @durable_value = -1
      reset_name_random_params
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム名をセット
  #--------------------------------------------------------------------------
  def set_name
    @uniq_name = "" unless @uniq_name
    @view_name = "" unless @view_name
    set_name_value_str unless @add_name_before
    set_name_value_str unless @add_name_after
    break_name = ""
    
    if broken?
      break_name = KURE::SortOut::BROKEN_ITEM_NAME
    end
    
    if @uniq_name == "" 
      @view_name = break_name + @add_name_before + @name + @add_name_after if custom_num == 0
      @view_name = break_name + @add_name_before + @name + @add_name_after + "+" + custom_num.to_s if custom_num != 0
    else
      @view_name = break_name + @uniq_name if custom_num == 0
      @view_name = break_name + @uniq_name + "+" + custom_num.to_s if custom_num != 0
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム名
  #--------------------------------------------------------------------------
  def name
    set_name unless @view_name
    return @view_name
  end
  #--------------------------------------------------------------------------
  # ● 基礎能力値変化量の取得
  #--------------------------------------------------------------------------
  def set_basic_params  
    set_name_value_param unless @name_value_param
    set_slot_param unless @slot_param
    @basic_params = @params.clone
    for param in 0..7
      #ランダム能力付与
      @basic_params[param] = (@basic_params[param] * random_param[param]).to_i
        
      #ネームバリューの付与
      @basic_params[param] += @name_value_param[param]
      
      #スロット能力の付与
      @basic_params[param] += @slot_param[param]
      
      #破損中は0補正
      if @basic_params[param] > 0
        if broken?
          per = KURE::SortOut::BROKEN_PERFORM
          @basic_params[param] = (@basic_params[param] * (per.to_f / 100)).to_i
        end
      end
    end
    
    return @basic_params 
  end
  #--------------------------------------------------------------------------
  # ◆ メモ欄の取得
  #--------------------------------------------------------------------------
  def set_note 
    @slot_note = '' unless @slot_note
    @name_value_note = '' unless @name_value_note
    @base_note = '' unless @base_note
    
    #反映しては困る設定を消去
    #装備タイプ
    @name_value_note.gsub!(/<装備タイプ\s?(\d+)\s?>/,'')
    @slot_note.gsub!(/<装備タイプ\s?(\d+)\s?>/,'')
    
    #強化設定
    @name_value_note.gsub!(/<強化上限\s?(\d+)\s?>/,'')
    @slot_note.gsub!(/<強化上限\s?(\d+)\s?>/,'')    
    
    @name_value_note.gsub!(/<強化パラメータ\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')
    @slot_note.gsub!(/<強化パラメータ\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')    

    @name_value_note.gsub!(/<強化補正上限\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')
    @slot_note.gsub!(/<強化補正上限\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')   
 
    @name_value_note.gsub!(/<強化全補正\s?(\d+)\s?>/,'')
    @slot_note.gsub!(/<強化全補正\s?(\d+)\s?>/,'')   
 
    @name_value_note.gsub!(/<強化補正\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')
    @slot_note.gsub!(/<強化補正\s?(\d+(?:\s?*,\s?*\d+)*)>/,'')  
 
    @note = @base_note + @slot_note + @name_value_note
  end
  #--------------------------------------------------------------------------
  # ◆ 本体のメモ欄の取得
  #--------------------------------------------------------------------------
  def base_note 
    @base_note = '' unless @base_note
    return @base_note
  end
  #--------------------------------------------------------------------------
  # ◆ 本体のメモ欄を更新
  #--------------------------------------------------------------------------
  def add_txt(str)
    @base_note += str
    reset_name_random_params
  end
  #--------------------------------------------------------------------------
  # ◆ 個別の名前を設定
  #--------------------------------------------------------------------------
  def set_uniq_name(str)
    @uniq_name = "" unless @uniq_name
    @uniq_name = str
    set_name
  end
  #--------------------------------------------------------------------------
  # ● ランダム能力倍率配列の取得
  #--------------------------------------------------------------------------
  def random_param
    unless @random_param
      @random_param = [1] * KURE::SortOut::ADD_STATUS
      if KURE::SortOut::RANDOM_PARAM == 1
        for param in 0..7
          if SceneManager.scene_is?(Scene_Shop)
            if KURE::SortOut::SHOP_RANDOM_PARAM == 1
              @random_param[param] = vest_random_rate[param] if permit_randomize
            end
          else
            @random_param[param] = vest_random_rate[param] if permit_randomize
          end
        end
      end
    end
    return @random_param
  end
  #--------------------------------------------------------------------------
  # ● カスタム値を取得
  #--------------------------------------------------------------------------
  def all_custom
    result = 0
    result = @custom_param[0] if @custom_param
    return result
  end
  #--------------------------------------------------------------------------
  # ● カスタム数取得
  #--------------------------------------------------------------------------
  def custom_num
    result = 0
    result = @custom_param[0] if @custom_param
    return result
  end
  #--------------------------------------------------------------------------
  # ● カスタム配列の取得
  #--------------------------------------------------------------------------
  def custom_param
    @custom_param = [0] * KURE::SortOut::ADD_STATUS unless @custom_param 
    return @custom_param
  end
  #--------------------------------------------------------------------------
  # ◆ 強化値の増減
  #--------------------------------------------------------------------------
  def custom_value(value)
    return if value < 0 && protect_custom
    @custom_param[0] += value
    @custom_param[0] = add_plus_limit if @custom_param[0] > add_plus_limit
    @custom_param[0] = 0 if @custom_param[0] < 0
    reset_name_random_params
  end 
  #--------------------------------------------------------------------------
  # ● 能力値変化量の取得
  #--------------------------------------------------------------------------
  def params
    return @params unless identify_id
    
    set_basic_params unless @basic_params
    params = @basic_params.clone
    if custom_param
      for param in 0..7

        #カスタム能力付与
        gain = 1
        gain = add_plus_revise_all
        gain = add_plus_revise[param] if add_plus_revise[param]
        params[param] += custom_param[0] * gain if custom_param[0]
        params[param] += custom_param[param + 1] if custom_param[param + 1]
      
      end
    end
    return params
  end
  #--------------------------------------------------------------------------
  # ● 経験値
  #--------------------------------------------------------------------------
  def equip_exp
    return 0 unless @equip_exp
    return @equip_exp
  end
  #--------------------------------------------------------------------------
  # ● 経験値
  #--------------------------------------------------------------------------
  def equip_exp=(value)
    @equip_exp = 0 unless @equip_exp
    @equip_exp += value
  end
  #--------------------------------------------------------------------------
  # ● スロット用経験値加算
  #--------------------------------------------------------------------------
  def slot_equip_exp=(value)
    return unless @slot
    for slot in 0..@slot.size - 1
      if @slot[slot]
        @slot[slot].equip_exp = value
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 特徴の取得
  #--------------------------------------------------------------------------
  def features
    return [] if KURE::SortOut::BROKEN_FEATURE == 1 && @durable_value == -1
    features = @features.clone
    features += @add_features if @add_features
    features += @name_value_feature if @name_value_feature
    features += @slot_feature if @slot_feature
    return features 
  end
  #--------------------------------------------------------------------------
  # ● 追加特徴の出力
  #--------------------------------------------------------------------------
  def push_add_features(code, data_id, value)
    @add_features = [] unless @add_features
    @add_features.push(RPG::BaseItem::Feature.new(code, data_id, value))
  end
  #--------------------------------------------------------------------------
  # ● メモ欄より付与された特徴の個別ID配列
  #--------------------------------------------------------------------------
  def reinforced_feature_list
    @reinforced_feature_list = [] unless @reinforced_feature_list
    return @reinforced_feature_list
  end
  #--------------------------------------------------------------------------
  # ● 特徴の個別ID配列を出力
  #--------------------------------------------------------------------------
  def reinforced_feature_list=(value)
    @reinforced_feature_list = [] unless @reinforced_feature_list
    @reinforced_feature_list.push(value)
  end
end

#==============================================================================
# ■ RPG::Weapon
#==============================================================================
class RPG::Weapon < RPG::EquipItem
  attr_accessor :weapon_id
  #--------------------------------------------------------------------------
  # ● 固有IDを設定する
  #--------------------------------------------------------------------------
  def identify_id=(value)
    @weapon_id = value
  end
  #--------------------------------------------------------------------------
  # ● 固有IDを取得(判定用)
  #--------------------------------------------------------------------------
  def self.identify_id
    @weapon_id
  end
  #--------------------------------------------------------------------------
  # ● 固有IDを取得
  #--------------------------------------------------------------------------
  def identify_id
    return @weapon_id
  end
  #--------------------------------------------------------------------------
  # ● 同ーオブジェクトか判定します。
  #--------------------------------------------------------------------------
  def equal?(obj)
    return false unless obj.is_a?(RPG::Weapon)
    if obj.weapon_id == nil
      return obj.id == id
    end
    return obj.weapon_id == @weapon_id
  end
end

#==============================================================================
# ■ RPG::Armor
#==============================================================================
class RPG::Armor < RPG::EquipItem
  attr_accessor :armor_id
  #--------------------------------------------------------------------------
  # ● 固有IDを設定する
  #--------------------------------------------------------------------------
  def identify_id=(value)
    @armor_id = value
  end
  #--------------------------------------------------------------------------
  # ● 固有IDを取得(判定用)
  #--------------------------------------------------------------------------
  def self.identify_id
    @armor_id
  end
  #--------------------------------------------------------------------------
  # ● 固有IDを取得
  #--------------------------------------------------------------------------
  def identify_id
    return @armor_id
  end
  #--------------------------------------------------------------------------
  # ● 同ーオブジェクトか判定します。
  #--------------------------------------------------------------------------
  def equal?(obj)
    return false unless obj.is_a?(RPG::Armor)
    if obj.armor_id == nil
      return obj.id == id
    end
    return obj.armor_id == @armor_id
  end
end

#==============================================================================
# ■ Game_Party
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 全アイテムリストの初期化(再定義)
  #--------------------------------------------------------------------------
  def init_all_items
    @items = []
    @weapons = []
    @weapons_master = []
    @armors = []
    @armors_master = []
    @get_list = []
  end
  #--------------------------------------------------------------------------
  # ● 獲得アイテム名リストを取得(追加定義)
  #--------------------------------------------------------------------------
  def get_list
    return @get_list
  end
  #--------------------------------------------------------------------------
  # ● 獲得アイテム名リストを初期化(追加定義)
  #--------------------------------------------------------------------------
  def clear_get_list
    @get_list = []
  end
  #--------------------------------------------------------------------------
  # ● マスターコンテナオブジェクトを取得(追加定義)
  #--------------------------------------------------------------------------
  def item_master_container(item_class)
    return @weapons_master if item_class == RPG::Weapon
    return @armors_master  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # ● マスターコンテナオブジェクトを圧縮(追加定義)
  #--------------------------------------------------------------------------
  def compact_item_master_container(item_class)
    container = item_master_container(item_class)
    return unless container
    count = container.size - 1
    
    while count > 0
      break if container[count]
      container.delete_at(-1) unless container[count] 
      count -= 1
    end    
  end
  #--------------------------------------------------------------------------
  # ● マスターコンテナオブジェクトを取得(追加定義)
  #--------------------------------------------------------------------------
  def item_master_container(item_class)
    return @weapons_master if item_class == RPG::Weapon
    return @armors_master  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの配列取得(再定義) 
  #--------------------------------------------------------------------------
  def items
    item = Array.new
    for i in 1..@items.size
      if @items[i] and @items[i] != 0
        item.push($data_items[i])
      end
    end
    return item
  end
  #--------------------------------------------------------------------------
  # ● 付与済み接頭語オブジェクトを出力(追加定義)
  #--------------------------------------------------------------------------
  def push_name_value_list(list, id, cat)
    @push_name_value_list = [] unless @push_name_value_list
    @push_name_value_list[list] = [] unless @push_name_value_list[list]
    @push_name_value_list[list][id] = cat
  end
  #--------------------------------------------------------------------------
  # ● 付与済み接頭語オブジェクトを取得(追加定義)
  #--------------------------------------------------------------------------
  def know_name_value_list
    @push_name_value_list = [] unless @push_name_value_list
    return @push_name_value_list
  end
  #--------------------------------------------------------------------------
  # ● 固有ID判定(追加定義)
  #--------------------------------------------------------------------------
  def identify?(item_id)
    return item_id > KURE::SortOut::ID_BASE
  end
  #--------------------------------------------------------------------------
  # ● 固有ID取得(追加定義)
  #--------------------------------------------------------------------------
  def turn_identify_id(item_id)
    return item_id / KURE::SortOut::ID_BASE
  end  
  #--------------------------------------------------------------------------
  # ● アイテムID取得(追加定義)
  #--------------------------------------------------------------------------
  def turn_item_id(item_id)
    return item_id % KURE::SortOut::ID_BASE
  end  
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトの取得(追加定義)
  #--------------------------------------------------------------------------
  def set_weapon(item_id)
    if identify?(item_id)
      identify_id = turn_identify_id(item_id)
      return @weapons_master[identify_id]
    end
    return $data_weapons[item_id]
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトの取得(追加定義)
  #--------------------------------------------------------------------------
  def set_armor(item_id)
    if identify?(item_id)
      identify_id = turn_identify_id(item_id)
      return @armors_master[identify_id]
    end
    return $data_armors[item_id]
  end
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def weapons
    weapon = @weapons.compact
    weapon.sort!{|a, b|
      a1 = turn_item_id(a.id)
      b1 = turn_item_id(b.id)
      if a1 != b1
        ret = a1 <=> b1
      else
        ret = b.custom_num <=> a.custom_num
      end
    }
    return weapon
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def armors
    armors = @armors.compact
    armors.sort!{|a, b|
      a1 = turn_item_id(a.id)
      b1 = turn_item_id(b.id)
      if a1 != b1
        ret = a1 <=> b1
      else
        ret = b.custom_num <=> a.custom_num
      end
      }
    return armors
  end
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトのマスター配列取得(再定義)
  #--------------------------------------------------------------------------
  def master_weapons_list
    return @weapons_master
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトのマスター配列取得(再定義)
  #--------------------------------------------------------------------------
  def master_armors_list
    return @armors_master
  end
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def weapons_param
    return @weapons_param
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def armors_param
    return @armors_param
  end
  #--------------------------------------------------------------------------
  # ● アイテムの所持数取得(再定義)
  #--------------------------------------------------------------------------
  def item_number(item)
    #対応するコンテナを取得
    container = item_container(item.class)
    return 0 unless container
    #通常アイテムの場合
    if item.class == RPG::Item
      return 0 if container[item.id] == 0
      return 0 if container[item.id] == nil
      return container[item.id] 
    else
      return container.compact.count{|obj| turn_item_id(obj.id) == turn_item_id(item.id)}     
    end  
  end
  #--------------------------------------------------------------------------
  # ● アイテムの増加（減少)(再定義)
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false, change_equip = false)
    #対応するアイテムコンテナを取得
    container = item_container(item.class)
    master_container = item_master_container(item.class)
    compact_item_master_container(item.class)
    return unless container
    
    #現在の所持数と、増加後のアイテム数を設定
    last_number = item_number(item)
    new_number = last_number + amount
    
    #通常アイテムならば個数をID位置に出力
    if item.class == RPG::Item
      container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    else
      #アイテムが増える場合
      if new_number > last_number
        count = new_number - last_number
        same_object = Marshal.load(Marshal.dump(item))
        #装備切り替えの場合の処理
        if change_equip 
          if same_object.identify_id != (0 or nil)
            container[same_object.identify_id] = same_object
            count -= 1
          end
        end
        
          count.times{
          same_object = Marshal.load(Marshal.dump(item))
          new_identify_id = set_id(same_object)
          same_object.identify_id = new_identify_id
          same_object.first_setting
          container[new_identify_id] = same_object
          master_container[new_identify_id] = same_object
          @get_list.unshift(same_object.name)
          }
      #アイテムが減る場合
      else
        #減少個数を算出
        count = last_number - new_number
        #同一アイテムを検索する
        same_object = Marshal.load(Marshal.dump(item))
        
        #装備切り替えの場合の処理
        if change_equip
          lose_item_id = set_delete(same_object)
          if lose_item_id
            container[lose_item_id] = nil 
            count -= 1
          end
        else
          #同一アイテムを検索して削除する
          delete_identify_id = same_object.identify_id        
          for delete in 0..container.size - 1
            unless container[delete] == nil
              if container[delete].identify_id == delete_identify_id 
                recycle_slot(container[delete])
                container[delete] = nil
                master_container[delete_identify_id] = nil
                count -= 1
              end
            end
          end
      
          #同一アイテムが存在しなければ弱いアイテムより削除
          count.times{
          lose_item_id = week_object(same_object)
          recycle_slot(container[lose_item_id])
          container[lose_item_id] = nil
          master_container[lose_item_id] = nil
          }
        end
      end
    end
    
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● アイテムの減少(再定義)
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  def lose_item(item, amount, include_equip = false, change_equip = false)
    gain_item(item, -amount, include_equip, change_equip)
  end
  #--------------------------------------------------------------------------
  # ● スロットにささった装備の回収(追加定義)
  #--------------------------------------------------------------------------
  def recycle_slot(item)
    if item.class == RPG::Weapon or item.class == RPG::Armor
      if item.identify_id != 0
        back_item = item.slot_list
        for back in 0..back_item.size - 1
          $game_party.gain_item(back_item[back], 1 ,false ,true) if back_item[back]
        end
      end
    end    
  end
  #--------------------------------------------------------------------------
  # ● 空白のID位置を取得(追加定義)
  #--------------------------------------------------------------------------
  def set_id(item)
    if item.class == RPG::Weapon
      return 1 if @weapons_master.size == 0
      for weapon in 1..@weapons_master.size - 1
        if weapon == item.identify_id
          return weapon
        end
        if @weapons_master[weapon] == nil
          return weapon
        end
      end
      return @weapons_master.size
    end
    if item.class == RPG::Armor
      return 1 if @armors_master.size == 0
      for armor in 1..@armors_master.size - 1
        if armor == item.identify_id
          return armor
        end
        if @armors_master[armor] == nil
          return armor
        end
      end
      return @armors_master.size
    end
  end
  #--------------------------------------------------------------------------
  # ● 削除する配列位置を取得(追加定義)
  #--------------------------------------------------------------------------
  def set_delete(item)
    if item.class == RPG::Weapon
      for weapon in 1..@weapons.size - 1
        if @weapons[weapon]
          if @weapons[weapon].id == item.id
            return weapon
          end
        end
      end
    end
    if item.class == RPG::Armor
      for armor in 1..@armors.size - 1
        if @armors[armor]
          if @armors[armor].id == item.id 
            return armor
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● メンバーの装備品を破棄する
  #--------------------------------------------------------------------------
  def discard_members_equip(item, amount)
    n = amount
    
    if item.class == RPG::Weapon
      seek_item = $data_weapons[turn_item_id(item.id)]
    elsif item.class == RPG::Armor
      seek_item = $data_armors[turn_item_id(item.id)]
    end
    
    for actor in members
      if n > 0
      for slot in 0..actor.equips.size - 1  
        if actor.equips[slot]
          if actor.equips[slot].class == RPG::Weapon  
            if seek_item == $data_weapons[turn_item_id(actor.equips[slot].id)]
              actor.discard_equip(seek_item)
              n -= 1
            end  
          elsif actor.equips[slot].class == RPG::Armor
            if seek_item == $data_armors[turn_item_id(actor.equips[slot].id)]
              actor.discard_equip(seek_item)
              n -= 1
            end
          end
        end
      end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 該当アイテムの中で最も能力が低いもののIDを取得(追加定義)
  #--------------------------------------------------------------------------
  def week_object(item)
    if item.class == RPG::Weapon
      weapon = @weapons.compact.select{|obj| turn_item_id(item.id) == turn_item_id(obj.id)}
      weapon.sort!{|a, b| a.all_custom <=> b.all_custom}
      return weapon[0].identify_id if weapon[0]
      return 0
    end
    if item.class == RPG::Armor
      armor = @armors.compact.select{|obj| turn_item_id(item.id) == turn_item_id(obj.id)}
      armor.sort!{|a, b| a.all_custom <=> b.all_custom}
      return armor[0].identify_id if armor[0]
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備品の強化(追加定義)
  #--------------------------------------------------------------------------
  def custom_object_plus(actor_id, slot_id, param, plus)
    item = $game_actors[actor_id].equips[slot_id]
    return unless item
    
    serch_identify_id = item.identify_id
    return if serch_identify_id == 0
    
    master_container = item_master_container(item.class)    
    
    int_item = master_container[serch_identify_id]
    return unless int_item
    
    if param + 1 == 0
      int_item.custom_value(plus)
    else
      int_item.custom_param[param + 1] += plus
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備品にスロットを追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_object_add_slot(actor_id, slot_id, plus)
    item = $game_actors[actor_id].equips[slot_id]
    return unless item
    
    serch_identify_id = item.identify_id
    return if serch_identify_id == 0
    
    master_container = item_master_container(item.class)    
    
    int_item = master_container[serch_identify_id]
    return unless int_item
    
    plus.times{int_item.gain_slot_number}
    
  end
  #--------------------------------------------------------------------------
  # ● 装備品に特徴を追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_features(actor_id, slot_id, code, data_id, value)
    item = $game_actors[actor_id].equips[slot_id]
    return unless item
    
    serch_identify_id = item.identify_id
    return if serch_identify_id == 0
    
    master_container = item_master_container(item.class)    
    
    int_item = master_container[serch_identify_id]
    return unless int_item
    
    int_item.push_add_features(code, data_id, value)
  end
  #--------------------------------------------------------------------------
  # ● 装備品にメモを追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_notes(actor_id, slot_id, str)
    item = $game_actors[actor_id].equips[slot_id]
    return unless item
    
    serch_identify_id = item.identify_id
    return if serch_identify_id == 0
    
    master_container = item_master_container(item.class)    
    
    int_item = master_container[serch_identify_id]
    return unless int_item
    
    int_item.add_txt(str)
  end
  #--------------------------------------------------------------------------
  # ● 装備品の名前を変更(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_name(actor_id, slot_id, str)
    item = $game_actors[actor_id].equips[slot_id]
    return unless item
    
    serch_identify_id = item.identify_id
    return if serch_identify_id == 0
    
    master_container = item_master_container(item.class)    
    
    int_item = master_container[serch_identify_id]
    return unless int_item
    
    int_item.set_uniq_name(str)
  end
  #--------------------------------------------------------------------------
  # ● 指定したアクターの破損した装備の数を取得(追加定義)
  #--------------------------------------------------------------------------
  def broken_equip_num(actor_id)
    eruip = $game_actors[actor_id].equips.select{|obj| obj != nil && obj.broken?}
    return eruip.size
  end
  #--------------------------------------------------------------------------
  # ● 指定したアクターの破損した装備を全て修復(追加定義)
  #--------------------------------------------------------------------------
  def fix_all_equip(actor_id)
    for slot in 0..$game_actors[actor_id].equips.size - 1 
      if $game_actors[actor_id].equips[slot]
        $game_actors[actor_id].equips[slot].recover_durable
        container = item_master_container($game_actors[actor_id].equips[slot].class)
        container[$game_actors[actor_id].equips[slot].identify_id].recover_durable
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 所持している全ての破損装備を数える(追加定義)
  #--------------------------------------------------------------------------
  def all_broken_equip_num
    num = 0
    for list in 0..@weapons_master.size - 1
      if @weapons_master[list]
        num += 1 if @weapons_master[list].broken?
      end
    end
    for list in 0..@armors_master.size - 1
      if @armors_master[list]
        p @armors_master[list].broken?
        num += 1 if @armors_master[list].broken?
      end
    end
    return num
  end
  #--------------------------------------------------------------------------
  # ● 所持している破損装備を全て修復(追加定義)
  #--------------------------------------------------------------------------
  def fix_all_party_equip
    for list in 0..@weapons_master.size - 1
      if @weapons_master[list]
        if @weapons_master[list].broken?
          @weapons_master[list].recover_durable 
          @weapons[list].recover_durable 
        end
      end
    end
    for list in 0..@armors_master.size - 1
      if @armors_master[list]
        if @armors_master[list].broken?
          @armors_master[list].recover_durable
          @armors[list].recover_durable
        end
      end
    end
  end
end

#==============================================================================
# ■ Game_BaseItem
#==============================================================================
class Game_BaseItem
  #--------------------------------------------------------------------------
  # ● IDの取得
  #--------------------------------------------------------------------------
  def id
    return @item_id % KURE::SortOut::ID_BASE if @item_id > KURE::SortOut::ID_BASE
    return @item_id
  end
  #--------------------------------------------------------------------------
  # ● 固有IDの設定
  #--------------------------------------------------------------------------
  def identify_id=(value)
    object.identify_id = value if object
  end
  #--------------------------------------------------------------------------
  # ● 固有IDの呼び出し
  #--------------------------------------------------------------------------
  def identify_id
    return object.identify_id  if object
  end
  #--------------------------------------------------------------------------
  # ● カスタム数の呼び出し
  #--------------------------------------------------------------------------
  def custom_num
    return object.custom_num  if object
  end
  #--------------------------------------------------------------------------
  # ● スロットの呼び出し
  #--------------------------------------------------------------------------
  def slot_list
    return object.slot_list  if object
    return []
  end  
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの設定
  #--------------------------------------------------------------------------
  def object=(item)
    @class = item ? item.class : nil
    @item_id = item ? item.id : 0
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの取得
  #--------------------------------------------------------------------------
  def object
    return $data_skills[@item_id]  if is_skill?
    return $data_items[@item_id]   if is_item?
    return $game_party.set_weapon(@item_id) if is_weapon?
    return $game_party.set_armor(@item_id)  if is_armor?
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 装備品を ID で設定
  #     is_weapon : 武器かどうか
  #     item_id   : 武器／防具 ID
  #--------------------------------------------------------------------------
  def set_equip(is_weapon, item_id)
    @class = is_weapon ? RPG::Weapon : RPG::Armor
    @item_id = item_id
    
    #固有IDが未設定の場合
    if @item_id < KURE::SortOut::ID_BASE
      obj = $data_armors[item_id]
      obj = $data_weapons[item_id] if is_weapon
      if obj
        same_obj = Marshal.load(Marshal.dump(obj))
        new_identify_id = $game_party.set_id(same_obj)
        same_obj.identify_id = new_identify_id
        same_obj.first_equip_setting
      
        master_container = $game_party.item_master_container(same_obj.class)
      
        master_container[new_identify_id] = same_obj
        @item_id = same_obj.id if object
      end
    end          
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler 
  #--------------------------------------------------------------------------
  # ● パーティとアイテムを交換する
  #     new_item : パーティから取り出すアイテム
  #     old_item : パーティに返すアイテム
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1, false, true)
    $game_party.lose_item(new_item, 1, false, true)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備の強制変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    same_object = nil
    same_object = Marshal.load(Marshal.dump(item)) if item
    
    if same_object && same_object.identify_id == 0
      new_identify_id = $game_party.set_id(same_object)
      same_object.identify_id = new_identify_id
      same_object.first_setting
      master_container = $game_party.item_master_container(same_object.class)
      master_container[new_identify_id] = same_object      
    end
    @equips[slot_id].object = item
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更（ID で指定)(再定義)
  #     slot_id : 装備スロット ID
  #     item_id : 武器／防具 ID
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    change_item = nil
    if item_id != (0 or nil)
      if equip_slots[slot_id] == 0
        item = $data_weapons[item_id]
        container = $game_party.item_container(item.class)
        if container
          for block in 0..container.size - 1
            if container[block] && change_item == nil
              if $game_party.turn_item_id(container[block].id) == item.id
                change_item = container[block]
              end
            end
          end
          
          if change_item
            change_equip(slot_id, change_item)
            #過剰削除？
            #container[block] = nil
          end
        end
      else
        item = $data_armors[item_id]
        container = $game_party.item_container(item.class)
        if container
          for block in 0..container.size - 1
            if container[block] && change_item == nil
              if $game_party.turn_item_id(container[block].id) == item.id
                change_item = container[block]
              end
            end
          end

          if change_item
            change_equip(slot_id, change_item)
            #過剰削除？
            #container[block] = nil
          end
        end
      end
    else
      change_equip(slot_id, nil)
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備の破棄
  #     item : 破棄する武器／防具
  #--------------------------------------------------------------------------
  def discard_equip(item)
    for slot in 0..equips.size - 1
      if equips[slot]
        if equips[slot].class == RPG::Weapon
          if $data_weapons[$game_party.turn_item_id(equips[slot].id)] == item
            slot_id = slot
          end
        elsif equips[slot].class == RPG::Armor
          if $data_armors[$game_party.turn_item_id(equips[slot].id)] == item
            slot_id = slot
          end
        end
      end
    end
    
    if slot_id
      master_container = $game_party.item_master_container(item.class)
      delete_item_id = @equips[slot_id].identify_id
      @equips[slot_id].object = nil 
      master_container[delete_item_id] = nil
    end
  end
end
  
#==============================================================================
# ■ Game_Interpreter(追加定義)
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 指定アクターの装備武器を強化(+値追加)(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_item(actor_id, slot_id, plus)
    $game_party.custom_object_plus(actor_id, slot_id, -1, plus)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの装備武器のステータスを強化(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_param(actor_id, slot_id, param, plus)
    $game_party.custom_object_plus(actor_id, slot_id, param, plus)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの武器に特徴を追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_features(actor_id, slot_id, code, data_id, value)
    $game_party.custom_equip_features(actor_id, slot_id, code, data_id, value)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの武器のメモ欄を追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_notes(actor_id, slot_id, txt)
    $game_party.custom_equip_notes(actor_id, slot_id, txt)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの武器の名前を変更(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_name(actor_id, slot_id, txt)
    $game_party.custom_equip_name(actor_id, slot_id, txt)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの破損装備数を取得(追加定義)
  #--------------------------------------------------------------------------
  def broken_equip_num(actor_id)
    $game_party.broken_equip_num(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの装備を修復(追加定義)
  #--------------------------------------------------------------------------
  def fix_all_equip(actor_id)
    $game_party.fix_all_equip(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 全ての破損装備数を取得(追加定義)
  #--------------------------------------------------------------------------
  def all_broken_equip_num
    $game_party.all_broken_equip_num
  end
  #--------------------------------------------------------------------------
  # ● 全ての装備を修復(追加定義)
  #--------------------------------------------------------------------------
  def fix_all_party_equip
    $game_party.fix_all_party_equip
  end
  #--------------------------------------------------------------------------
  # ● 指定アクターの装備武器にスロットを追加(追加定義)
  #--------------------------------------------------------------------------
  def custom_equip_add_slot(actor_id, slot_id, plus)
    $game_party.custom_object_add_slot(actor_id, slot_id, plus)
  end
end

#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================
class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムの個数を描画(再定義)
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    if item.is_a?(RPG::Weapon) or item.is_a?(RPG::Armor)
      draw_text(rect, sprintf(":%2d", 1), 2)
    else
      draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
    end
  end
end
#==============================================================================
#  ■併用化ベーススクリプトＢ for RGSS3 Ver3.10-β2
#　□作成者 kure
#　　
#　併用化対応スクリプト
#　●装備拡張
#　■スキルメモライズシステム
#　★スキルポイントシステム
#　▲職業レベル
#　◆転職画面
#　◎拡張ステータス画面
#　☆拡張機能集積
#　◇装備品個別管理
#　§ステータス振り分け
#　
#==============================================================================

#==============================================================================
# ●■ RPG::BaseItem(追加定義集積)
#==============================================================================
class RPG::BaseItem
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
  # ●■ 記憶数増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_max_memorize  
    return 0 unless @note
    cheak_note = @note
    gain_max_memorize = 0
    
    while cheak_note do
      cheak_note.match(/<最大記憶数増加\s?(\d+)\s?>/)
      gain_max_memorize += $1.to_i if $1
      cheak_note = $'
    end
    return gain_max_memorize 
  end
  #--------------------------------------------------------------------------
  # ●■ 記憶容量増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_memorize
    return 0 unless @note
    cheak_note = @note
    gain_memorize = 0
    
    while cheak_note do
      cheak_note.match(/<最大記憶容量増加\s?(\d+)\s?>/)
      gain_memorize += $1.to_i if $1
      cheak_note = $'
    end
    return gain_memorize 
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
  #--------------------------------------------------------------------------
  # ▲ 使用する経験値曲線の定義(追加定義)
  #--------------------------------------------------------------------------  
  def use_exp_curve
    return 0 unless @note
    @note.match(/<経験値曲線\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ▲ 最大職業レベル定義(追加定義)
  #--------------------------------------------------------------------------  
  def max_job_level_value
    return 99 unless @note
    @note.match(/<最大職業Lv\s?(\d+)\s?>/)
    return 99 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ▲ アクター固有習得スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def actor_peculiar_skill
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<固有習得\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ▲ 初期サブクラスの定義(追加定義)
  #--------------------------------------------------------------------------  
  def first_sub_class
    return 0 unless @note
    @note.match(/<初期サブクラス\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ▲ 適用外特徴の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_applied_features
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<適用外特徴\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ▲ 適用外特徴(指定DATAID)の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_applied_features_data
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<適用外特徴データ\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 職業ランクの定義(追加定義)
  #--------------------------------------------------------------------------  
  def class_lank
    return 0 unless @note
    @note.match(/<職業ランク\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◆ 転職レベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_level
    request_lv = Array.new
    return [0,0] unless @note
    @note.match(/<転職レベル\s?(\d+)\s?,\s?(\d+)\s?>/)
    request_lv[0] = 0 ; request_lv[1] = 0
    request_lv[0] = $1.to_i if $1 ; request_lv[1] = $2.to_i if $2
    return request_lv
  end
  #--------------------------------------------------------------------------
  # ◆ 要求経験職クラスIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_class
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<要求経験職\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 選択経験職クラスIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def select_jobchange_class
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<選択経験職\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 要求未経験職クラスIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def unless_need_jobchange_class
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<要求未経験職\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 両立不可職クラスIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_same_time_jobchange_class
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<両立不可職\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 経験済み職業クラスIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def exp_jobchange_class
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<経験済職業\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 転職可能アクターIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_actor
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<転職許可\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 転職要求スキルIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_skill
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<転職スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 転職要求スイッチIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_swith
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<転職スイッチ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ 転職要求アイテムIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_jobchange_item
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<転職アイテム\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ リスト表示の定義(追加定義)
  #--------------------------------------------------------------------------  
  def view_class_name
    return true unless @note
    return false if @note.include?("<非公開表示>")
    return true
  end
  #--------------------------------------------------------------------------
  # ◆ サブクラス封印の定義(追加定義)
  #--------------------------------------------------------------------------  
  def seal_sub_class
    return false unless @note
    return true if @note.include?("<サブクラス封印>")
    return false
  end
  #--------------------------------------------------------------------------
  # ◆ 単独職の定義(追加定義)
  #--------------------------------------------------------------------------  
  def only_one_class
    return false unless @note
    return true if @note.include?("<単独職>")
    return false
  end
  #--------------------------------------------------------------------------
  # ◆ メイン、サブ専用クラス定義(追加定義)
  #--------------------------------------------------------------------------  
  def change_class_kind
    return 2 unless @note
    return 0 if @note.include?("<サブクラス専用職>")
    return 1 if @note.include?("<メインクラス専用職>")
    return 2
  end
  #--------------------------------------------------------------------------
  # ◆ グラフィック変更許可(追加定義)
  #--------------------------------------------------------------------------  
  def can_change_graphic
    return 0 unless @note
    @note.match(/<グラフィック変更許可\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◆ 短縮職業名(追加定義)
  #--------------------------------------------------------------------------  
  def short_class_name
    return @name unless @note
    @note.match(/<短縮名称\s?(.+?)\s?>/)
    return @name unless $1
    return $1
  end
  #--------------------------------------------------------------------------
  # ◆ 転職時グラフィック設定(追加定義)
  #--------------------------------------------------------------------------  
  def use_job_graphic
    graphic = Array.new
    graphic = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    
    for i in 0..3
      if @note
      @note.match(/<使用グラフィック(\d+)\s?(.+?),\s?(\d+),\s?(.+?),\s?(\d+)>/)
      graphic[i][0] = $1.to_i if $1
      graphic[i][1] = $2 if $2
      graphic[i][2] = $3.to_i if $3
      graphic[i][3] = $4 if $4
      graphic[i][4] = $5.to_i if $5
      @note = $'
      end
    end
    return graphic
  end
  #--------------------------------------------------------------------------
  # ◆ 転職画面追加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_jobchange_window
    return -1 unless @note
    @note.match(/<転職画面許可\s?(\d+)\s?>/)
    return -1 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◆ 転職画面表示の定義(追加定義)
  #--------------------------------------------------------------------------  
  def view_jobchange_window
    return 0 unless @note
    @note.match(/<転職画面表示\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ■ 記憶容量の定義(追加定義)
  #--------------------------------------------------------------------------  
  def memorize_capacity
    return 0 unless @note
    @note.match(/<記憶容量\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ■ スキルの表示、非表示定義(追加定義)
  #--------------------------------------------------------------------------  
  def view_skill_mode
    return 3 unless @note
    return 0 if @note.include?("<常時非表示>")
    return 1 if @note.include?("<戦闘中非表示>")
    return 2 if @note.include?("<メニュー非表示>")
    return 3
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応武器IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_w
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<パッシブ能力武器\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応防具IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_a
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<パッシブ能力防具\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応職業IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_c
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<パッシブ能力職業\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ メモライズ数の職業補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def max_memorize_revise
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<メモライズ数補正\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ 追加メモライズ数を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_memorize_var
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<追加メモライズ数保存変数\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ メモライズ容量の職業補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def memorize_capacity_revise
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<メモライズ容量補正\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ 追加メモライズ容量を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_memorize_cap_var
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<追加メモライズ容量保存変数\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ 初期メモライズ定義(追加定義)
  #--------------------------------------------------------------------------  
  def first_memorize
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<初期メモライズ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ■ 共存不可メモライズ定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_jumble_memorize
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<共存不可メモライズ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◆ オートメモライズ不要の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_auto_memorize
    return false unless @note
    return true if @note.include?("<自動メモライズ不要>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ アクターの基本能力値を取得する職業IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def base_param_index
    return 0 unless @note
    @note.match(/<基本能力値\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ 職業別TP基本値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def base_tp
    return 50 unless @note
    @note.match(/<TP基本値\s?(\d+)\s?>/)
    return 50 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ 職業別TP上限値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def upper_limit_tp
    return 9999 unless @note
    @note.match(/<TP上限値\s?(\d+)\s?>/)
    return 9999 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ アクター別TPのLv補正値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def tp_level_revise
    return 0 unless @note
    @note.match(/<TPLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value   
  end
  #--------------------------------------------------------------------------
  # ☆ 通常攻撃に使用するスキルIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def normal_attack_id
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<通常攻撃\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘開始時のTP値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def battle_start_tp
    return 0 unless @note
    @note.match(/<開始時TP\s?(\d+)%>/)
    return 0 unless $1
    return 100 if $1.to_i > 100
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ パーティー追加能力(追加定義)
  #--------------------------------------------------------------------------  
  def party_add_ability(id)
    party_add = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    case id
    when 0
      #獲得金額倍率設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<獲得金額倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = read_arr.min
      party_add = 100 unless read_arr.min
      
    when 1
      #アイテムドロップ率の設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<獲得アイテム倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = read_arr.min
      party_add = 100 unless read_arr.min
      
    when 2
      #エンカウント率の設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<エンカウント倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = 100
      for i in 0..read_arr.size - 1
        party_add *= (read_arr[i].to_f / 100)
      end
      party_add.to_i

    when 3
      #獲得経験値倍率の設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<獲得経験値倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = read_arr.min
      party_add = 100 unless read_arr.min
      
    when 4
      #獲得職業経験値倍率の設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<獲得職業経験値倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = read_arr.min
      party_add = 100 unless read_arr.min
      
    when 5
      #獲得職業経験値倍率の設定
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<獲得装備経験値倍率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      party_add = read_arr.min
      party_add = 100 unless read_arr.min
      
    end
    return party_add
  end
  #--------------------------------------------------------------------------
  # ☆ アクター追加能力(追加定義)
  #--------------------------------------------------------------------------  
  def battler_add_ability(id)
    battler_add = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    case id
    when 0
      #スティール成功率
      read_arr = Array.new
      while cheak_note do
        value = 100
        cheak_note.match(/<スティール成功率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 1
      #オートリザレクション
      read_arr = [0,0,0,0]
      while cheak_note do
        cheak_note.match(/<オートリザレクション\s?(\d+)%\s?,\s?(\d+)%\s?,\s?(\d+)\s?,\s?(\d+)>/)
        if $1 && $2 && $3 && $4
          value = [[read_arr[0],$1.to_i].max,[read_arr[1],$2.to_i].max,[read_arr[2],$3.to_i].max,[read_arr[3],$4.to_i].max]
          read_arr = value
        end
        cheak_note = $'
      end
      battler_add = read_arr

    when 2
      #踏みとどまり
      read_arr = Array.new
      while cheak_note do
        value = nil
        cheak_note.match(/<踏みとどまり\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.compact!
      battler_add = read_arr.min
      battler_add = 0 unless read_arr.min
    
    when 3
      #回復反転
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<回復反転\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 4
      #オートステート
      list = cheak_note.scan(/<オートステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      auto_state = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| auto_state.push(num.to_i)}
        end
      end
      battler_add = auto_state
    
    when 5
      #メタルボディ
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<メタルボディ\s?(\d+)\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 6
      #連続使用
      list = cheak_note.scan(/<連続発動\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      multi_use = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| multi_use.push(num.to_i)}
        end
      end
      battler_add = multi_use
    
    when 7
      #即死反転
      battler_add = 0
      battler_add = 1 if cheak_note.include?("<即死反転>")
    
    when 8
      #仲間想い
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<仲間想い\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 9
      #弱気
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<弱気\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 10
      #防御壁
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<防御壁展開\s?(\d+)\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 11
      #無効化障壁
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<無効化障壁\s?(\d+)\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
    
    when 12
      #TP消費率
      read_arr = Array.new
      while cheak_note do
        value = 100
        cheak_note.match(/<TP消費率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.min
    
    when 13
      #スキル変化
      list = cheak_note.scan(/<スキル変化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      change_skill = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| change_skill.push(num.to_i)}
        end
      end
      battler_add = change_skill
      
    when 14
      #武器タイプスキル強化
      list = cheak_note.scan(/<武器スキル倍率強化\s?(\d+-\d+-\d+(?:\s?*,\s?*\d+-\d+-\d+)*)>/)
      gain_skill = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| gain_skill.push(num.to_i)}
        end
      end
      battler_add = gain_skill
      
    when 15
      #行動変化
      list = cheak_note.scan(/<行動変化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      change_skill = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| change_skill.push(num.to_i)}
        end
      end
      battler_add = change_skill      
      
    when 16
      #最終反撃
      list = cheak_note.scan(/<最終反撃\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      final_skill = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| final_skill.push(num.to_i)}
        end
      end
      battler_add = final_skill
      
    when 17
      #反撃スキル
      list = cheak_note.scan(/<反撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      counter_skill = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| counter_skill.push(num.to_i)}
        end
      end
      battler_add = counter_skill
      
    when 18
      #戦闘終了後自動回復
      auto_heel = Array.new
      while cheak_note do
        cheak_note.match(/<戦闘後回復\s?(\d+)\s?,\s?(\d+)\s?>/)
        if $1 && $2
          auto_heel.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = auto_heel

      
    when 19
      #HPタイプ消費率
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<HPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 20
      #MPタイプ消費率
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<MPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 21
      #TPタイプ消費率
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<TPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 22
      #HP消費率
      read_arr = Array.new
      while cheak_note do
        value = 100
        cheak_note.match(/<HP消費率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.min
      
    when 23
      #オーバーソウル
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<オーバーソウル\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
      
    when 24
      #反撃強化
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<反撃強化\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
      
    when 25
      #HP減少時強化能力
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<HP減少時強化\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 26
      #ダメージMP変換
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<ダメージMP変換\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.delete(0)
      if read_arr != []
        battler_add = read_arr.min
      else
        battler_add = 0
      end  
      
    when 27
      #ダメージG変換
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<ダメージゴールド変換\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      read_arr.delete(0)
      if read_arr != []
        battler_add = read_arr.min
      else
        battler_add = 0
      end  
    
    when 28
      #必中反撃判定
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<必中反撃\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 29
      #魔法反撃判定
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<魔法反撃\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 30
      #追撃ステート
      list = cheak_note.scan(/<追撃対象ステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      read_arr = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| read_arr.push(num.to_i)}
        end
      end
      battler_add = read_arr
    
    when 31
      #耐久値減少率
      read_arr = Array.new
      while cheak_note do
        value = 100
        cheak_note.match(/<耐久値減少率\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.min
      
    when 32
      #ディレイステート
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ディレイステート\s?(\d+)\s?,\s?(\d+)\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 33
      #トリガー発動ステート
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<トリガーステート\s?([HMT])\s?,\s?(\d+)\s?,\s?(\d+)%\s?,\s?(\d+)\s?>/)
        if $1 && $2 && $3 && $4
          case $1
          when "H"
            tri = 1
          when "M"
            tri = 2
          when "T"
            tri = 3
          end
          read_arr.push([tri, $2.to_i ,$3.to_i, $4.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 34
      #自爆耐性
      battler_add = 0
      battler_add = 1 if cheak_note.include?("<自爆耐性>")
      
    when 35
      #ダメージMP吸収
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<ダメージMP吸収\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
      
    when 36
      #ダメージG吸収
      read_arr = Array.new
      while cheak_note do
        value = 0
        cheak_note.match(/<ダメージゴールド回収\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr.push(value)
        cheak_note = $'
      end
      battler_add = read_arr.max
      
    when 37
      #戦闘開始時自動発動能力
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<戦闘開始時発動\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 38
      #ターン開始時自動発動能力
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ターン開始時発動\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 39
      #ターン終了時自動発動能力
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ターン終了時発動\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 40
      #拡張反撃判定
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<拡張反撃\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 41
      #拡張魔法反撃判定
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<拡張魔法反撃\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr

    when 42
      #拡張必中反撃判定
      read_arr = 0
      while cheak_note do
        value = 0
        cheak_note.match(/<拡張必中反撃\s?(\d+)%\s?>/)
        value = $1.to_i if $1
        read_arr += value
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 43
      #常時オートステート
      list = cheak_note.scan(/<常時オートステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      auto_state = Array.new
      unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| auto_state.push(num.to_i)}
      end
      end
      battler_add = auto_state
      
    when 44
      #最大TP増減
      read_arr = [0,0]
      gain_cheak_note = cheak_note.clone
      decrease_cheak_note = cheak_note.clone
      #最大TP増加
      while gain_cheak_note do
        gain_cheak_note.match(/<最大TP増加\s?(\d+)([%])?>/)
        if $2 && $1
          read_arr[1] += $1.to_i 
        elsif $1
          read_arr[0] += $1.to_i 
        end
        gain_cheak_note = $'
      end
      
      #最大TP減少
      while gain_cheak_note do
        gain_cheak_note.match(/<最大TP減少\s?(\d+)([%])?>/)
        if $2 && $1
          read_arr[1] -= $1.to_i 
        elsif $1
          read_arr[0] -= $1.to_i 
        end
        gain_cheak_note = $'
      end
      battler_add = read_arr
    end
    
    #装備品個別管理の破損アイテム設定
    if self.class == RPG::Weapon or self.class == RPG::Armor
      if KURE::BaseScript::USE_SortOut == 1 
        if KURE::SortOut::BROKEN_FEATURE == 1
          case id
          when 0,12
            battler_add = 100
          when 1
            battler_add = [0,0,0,0] if self.broken?
          when 4,6,13,14,15
            battler_add = [] if self.broken?
          when 2,3,5,7,8,9,10,11
            battler_add = 0
          end
        end
      end
    end  
  
    return battler_add
  end
  #--------------------------------------------------------------------------
  # ☆ ブースターの定義(追加定義)
  #--------------------------------------------------------------------------  
  def multi_booster(id)
    booster = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    case id
    when 0
      #属性ブースター
      list = cheak_note.scan(/<属性強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
      
    when 1
      #属性吸収
      list = cheak_note.scan(/<属性吸収\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
   
    when 2
      #武器ブースター
      list = cheak_note.scan(/<武器強化物理\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 3
      list = cheak_note.scan(/<武器強化魔法\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 4 
      list = cheak_note.scan(/<武器強化必中\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 5
      #通常攻撃強化
      list = cheak_note.scan(/<通常攻撃強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 6
      #ステートブースター
      list = cheak_note.scan(/<ステート割合強化タイプ\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 7
      #ステートブースター
      list = cheak_note.scan(/<ステート固定強化タイプ\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 8
      #ステートブースター
      list = cheak_note.scan(/<ステート指定割合強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    
    when 9
      #ステートブースター
      list = cheak_note.scan(/<ステート指定固定強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
      
    when 10
      #スキルタイプブースター
      list = cheak_note.scan(/<スキルタイプ強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| booster.push(num.to_i)}
        end
      end
    end
    
    #装備品個別管理の破損アイテム設定
    if self.class == RPG::Weapon or self.class == RPG::Armor
      if KURE::BaseScript::USE_SortOut == 1 
        if KURE::SortOut::BROKEN_FEATURE == 1
          booster = [] if self.broken?
        end
      end
    end  
      
    return booster
  end
  #--------------------------------------------------------------------------
  # ☆ 複数属性の定義(追加定義)
  #--------------------------------------------------------------------------  
  def attack_elements_list
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<攻撃属性\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 属性反映の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reflect_elements
    return false unless @note
    return true if @note.include?("<攻撃属性スキル反映>")
    return false 
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def get_ability_point
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<習得AP\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    
    return save_list
  end
  #--------------------------------------------------------------------------
  # ☆ 必要アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_ability_point
    return 1000 unless @note
    @note.match(/<必要AP\s?(\d+)\s?>/)
    return 1000 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 強化上限の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_plus_limit
    return 10 unless @note
    @note.match(/<強化上限\s?(\d+)\s?>/)
    return 10 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 強化するパラメータの定義(追加定義)
  #--------------------------------------------------------------------------  
  def reinforce_param
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<強化パラメータ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    
    8.times{|i|save_list.push(i)} if save_list == ([] or empty?)
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ◇ 強化補正上限の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_plus_revise_limit
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<強化補正上限\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    end
    (8 - save_list.size).times{|i|save_list.push(10)}
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◇ 強化補正値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_plus_revise_all
    return 1 unless @note
    @note.match(/<強化全補正\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 強化補正値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_plus_revise
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<強化補正\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    end
    (8 - save_list.size).times{|i|save_list.push(1)}
    return save_list
  end
  #--------------------------------------------------------------------------
  # ★ 追加スキルポイント数を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_skillpoint_var
    return 0 unless @note
    @note.match(/<追加ポイント数保存変数\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i 
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのアクター補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_revise
    return 0 unless @note
    @note.match(/<スキルポイント補正\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i  
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのLv補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_level_revise
    return 0 unless @note
    @note.match(/<スキルポイントLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value  
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのJobLv補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_joblevel_revise
    return 0 unless @note
    @note.match(/<スキルポイントJobLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value  
  end
  #--------------------------------------------------------------------------
  # ☆ 死亡時残留ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_delete_state
    return false unless @note
    return true if @note.include?("<死亡時残留>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 全回復残留ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_delete_state_healing
    return false unless @note
    return true if @note.include?("<全回復時残留>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ アイテム仕様不可ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def can_not_use_item
    return false unless @note
    return true if @note.include?("<アイテム使用不可>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ ドロップ率増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_drop_rate
    return 100 unless @note
    @note.match(/<ドロップ変化\s?(\d+)%\s?>/)
    return 100 unless $1
    return $1.to_i
  end
end

#==============================================================================
# ■ RPG::UsableItem(追加定義)
#==============================================================================
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆ 耐久値ダメージ、回復の定義(追加定義)
  #--------------------------------------------------------------------------  
  def durable_damage
    durable_damage = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<耐久値ダメージ\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
      if $1 && $2 && $3
        durable_damage.push([$1.to_i, $2.to_i, $3.to_i])
      end
      cheak_note = $'
    end
    
    cheak_note = @note if @note
    while cheak_note do
      cheak_note.match(/<耐久値回復\s?(\d+)\s?,\s?(\d+)\s?>/)
      if $1 && $2
        durable_damage.push([$1.to_i, -1 * ($2.to_i), 100])
      end
      cheak_note = $'
    end
    
    return durable_damage    
  end
  #--------------------------------------------------------------------------
  # ☆ 連続回数の定義(再定義)
  #--------------------------------------------------------------------------  
  def repeats
    return @repeats unless @note
    @note.match(/<連続回数\s?(\d+)\s?>/)
    return @repeats unless $1
    return $1.to_i     
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果の定義(再定義)
  #--------------------------------------------------------------------------  
  def effects
    effect = @effects.clone
    effect += add_effects
    return effect     
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果の追加定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_effects
    add_effect = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    #盗むのメモ欄設定適用
    cheak_note.match(/<スティール付与\s?(\d+)\s?>/)   
    if $1
      add_effect.push(RPG::UsableItem::Effect.new(45, $1.to_i))
    end
    
    #スキルポイントリセットのメモ欄設定適用
    if cheak_note.include?("<スキルポイントリセット>")   
      add_effect.push(RPG::UsableItem::Effect.new(46))
    end
    
    #装備破壊のメモ欄設定適用
    cheak_note.match(/<耐久値ダメージ\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
    if $1 && $2 && $3
      add_effect.push(RPG::UsableItem::Effect.new(47))
    end
    
    #耐久力回復のメモ欄設定適用
    cheak_note.match(/<耐久値回復\s?(\d+)\s?,\s?(\d+)\s?>/)
    if $1 && $2
      add_effect.push(RPG::UsableItem::Effect.new(47))
    end
    
    #アイテム獲得のメモ欄設定適用
    cheak_note.match(/<獲得アイテム\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    if $1
      add_effect.push(RPG::UsableItem::Effect.new(48))
    end
    
    return add_effect
  end
  #--------------------------------------------------------------------------
  # ☆ 自爆スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def life_cost
    return false unless @note
    return true if @note.include?("<自爆スキル>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転無視スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ignore_reverse_heel
    return false unless @note
    return true if @note.include?("<回復反転無視>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 発動スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def random_skill_effect
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<発動スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 連続発動スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def multi_skill_effect
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<連続発動スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 発動アイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def random_item_effect
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<発動アイテム\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 仲間想い補正の定義(追加定義)
  #--------------------------------------------------------------------------  
  def companion_revise
    return 0 unless @note
    @note.match(/<仲間想い\s?(\d+)%\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ 武器倍率の定義(追加定義)
  #--------------------------------------------------------------------------  
  def weapon_d_rate
    cheak_note = ""
    cheak_note = @note if @note

    list = cheak_note.scan(/<武器倍率\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    save_list = Array.new
    weapon_rate = Array.new
    
    return weapon_rate if list == [] and list.empty? 
    $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    
    for list in 0..save_list.size - 1
      if list % 2 == 0
        if save_list[list] && save_list[list + 1]
          weapon_rate[save_list[list]] = 0 unless weapon_rate[save_list[list]]
          weapon_rate[save_list[list]] = save_list[list + 1]
        end
      end
    end
    
    return weapon_rate
  end
  #--------------------------------------------------------------------------
  # ☆ エラー回避(追加定義)
  #--------------------------------------------------------------------------  
  def is_skill?
    return false
  end
end

#==============================================================================
# ■ RPG::Skill(再定義)
#==============================================================================
class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ☆ 消費TPの定義(追加定義)
  #--------------------------------------------------------------------------  
  def tp_cost_ex
    tp_cost = Array.new
    tp_cost[0] = @tp_cost ; tp_cost[1] = 0
    return tp_cost unless @note
    
    @note.match(/<消費TP\s?(\d+)([%])?>/)
    tp_cost[0] = $1.to_i if $1 ; tp_cost[1] = 1 if $2
    return tp_cost if $1
    
    @note.match(/<消費MAXTP\s?(\d+)%>/)
    tp_cost[0] = $1.to_i if $1 ; tp_cost[1] = 2 if $1
    return tp_cost
  end
  #--------------------------------------------------------------------------
  # ☆ 消費HPの定義(追加定義)
  #--------------------------------------------------------------------------  
  def hp_cost
    hp_cost = Array.new
    hp_cost[0] = 0 ; hp_cost[1] = 0   
    return hp_cost unless @note
    @note.match(/<消費HP\s?(\d+)([%])?>/)
    hp_cost[0] = $1.to_i if $1 ; hp_cost[1] = 1 if $2
    return hp_cost if $1
    
    @note.match(/<消費MAXHP\s?(\d+)%>/)
    hp_cost[0] = $1.to_i if $1 ; hp_cost[1] = 2 if $1
    return hp_cost
  end
  #--------------------------------------------------------------------------
  # ☆ 消費MPの定義(追加定義)
  #--------------------------------------------------------------------------  
  def mp_cost_ex
    mp_cost = Array.new
    mp_cost[0] = @mp_cost ; mp_cost[1] = 0   
    return mp_cost unless @note
    @note.match(/<消費MP\s?(\d+)([%])?>/)
    mp_cost[0] = $1.to_i if $1 ; mp_cost[1] = 1 if $2
    return mp_cost if $1
    
    @note.match(/<消費MAXMP\s?(\d+)%>/)
    mp_cost[0] = $1.to_i if $1 ; mp_cost[1] = 2 if $1
    return mp_cost
  end
  #--------------------------------------------------------------------------
  # ☆ 消費GOLDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def gold_cost
    return 0 unless @note
    @note.match(/<消費金額\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ 消費アイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def item_cost
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<消費アイテム\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ☆ 獲得アイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def get_item_list
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<獲得アイテム\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ☆ 必要アイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_used_item
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<必要アイテム\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 必要武器タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def required_add_wtype_id
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<必要武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 要求装備タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_etype_id
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<要求装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 要求武器タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_wtype_id_all
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<要求武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 二刀流スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_two_weapon
    return false unless @note
    return true if @note.include?("<二刀流要求>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 二刀流２倍消費の定義(追加定義)
  #--------------------------------------------------------------------------  
  def use_double_item
    return false unless @note
    return true if @note.include?("<二刀流倍消費>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 二刀流同一ID要求の定義(追加定義)
  #--------------------------------------------------------------------------  
  def request_same_weapon_id
    return false unless @note
    return true if @note.include?("<同一タイプ二刀流専用>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ スキルディレイの定義(追加定義)
  #--------------------------------------------------------------------------  
  def skill_delay
    return 0 unless @note
    @note.match(/<スキルディレイ\s?(\d+)\s?>/)
    return 0 unless $1
    return 1 + $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ロストスキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def lost_skill?
    return false unless @note
    return true if @note.include?("<ロストスキル>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ エラー回避(追加定義)
  #--------------------------------------------------------------------------  
  def is_skill?
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 発動条件の定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_condition_list(id)
    passive_condition = Array.new
    
    case id
    when 0
      #発動要求武器
      list = @note.scan(/<発動要求武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      need_weapon = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| need_weapon.push(num.to_i)}
        end
      end
      passive_condition = need_weapon
    when 1
      #発動要求防具
      list = @note.scan(/<発動要求装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      need_armor = Array.new
      unless list == [] and list.empty?
        list.flatten!
        list.each do |value|
          value.scan(/\d+/).each { |num| need_armor.push(num.to_i)}
        end
      end
      passive_condition = need_armor
    end
    
    return passive_condition
  end
  #--------------------------------------------------------------------------
  # ☆ 耐久値減少の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reduce_durable
    reduce_durable = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<耐久値消費\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
      if $1 && $2 && $3
        reduce_durable.push([$1.to_i, $2.to_i, $3.to_i])
      end
      cheak_note = $'
    end
    return reduce_durable    
  end
  #--------------------------------------------------------------------------
  # ☆ 拡張スキルタイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_skilltype_id
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<拡張スキルタイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list  
  end
  #--------------------------------------------------------------------------
  # ☆ 習得不可の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_learn_list
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<習得不可\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty?
      list.flatten!
      list.each do |value|
        value.scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
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
# ■ RPG::Enemy(追加定義)
#==============================================================================
class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 初期化(エイリアス再定義)
  #--------------------------------------------------------------------------  
  alias kure_jobLv_before_initialize initialize
  def initialize
    kure_jobLv_before_initialize
    @jobexp = 0       #職業レベル
    @equip_exp = 0    #装備個別管理
    @ability_exp = 0  #AP制スキル習得
    @status_exp = 0   #ステータスポイント
  end
  #--------------------------------------------------------------------------
  # ▲ 職業経験値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def jobexp
    return @exp unless @note 
    @note.match(/<職業Exp\s?(\d+)\s?>/)
    return @exp unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def equip_exp
    return @exp unless @note    
    @note.match(/<装備Exp\s?(\d+)\s?>/)
    return @exp unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ability_exp
    return 0 unless @note 
    @note.match(/<獲得AP\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def status_exp
    return 0 unless @note 
    @note.match(/<ステータスポイント\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # § スキルポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def skill_exp
    return 0 unless @note 
    @note.match(/<スキルポイント\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def equip_exp=(equip_exp)
    @equip_exp = equip_exp
  end
  #--------------------------------------------------------------------------
  # ▲ 職業経験値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def jobexp=(jobexp)
    @jobexp = jobexp
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ability_exp=(ability_exp)
    @ability_exp = ability_exp
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def status_exp=(status_exp)
    @status_exp = status_exp
  end
  #--------------------------------------------------------------------------
  # ☆ ドロップアイテムの定義(再定義)
  #--------------------------------------------------------------------------  
  def drop_items
    add_drop_items unless @add_drop_items
    return @drop_items + @add_drop_items if @add_drop_items
    return @drop_items
  end
  #--------------------------------------------------------------------------
  # ☆ 追加ドロップアイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_drop_items
    @add_drop_items = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<追加ドロップ\s?([IWA])\s?,\s?(\d+)\s?,\s?(\d+)>/)
      if $1 && $2 && $3
        new_drop = RPG::Enemy::DropItem.new
        case $1.upcase
        when "I"
          new_drop.kind = 1
        when "W"
          new_drop.kind = 2
        when "A"
          new_drop.kind = 3
        end
        new_drop.data_id = $2.to_i
        new_drop.denominator = $3.to_f
        
        @add_drop_items.push(new_drop)
      end
      cheak_note = $'
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 盗めるアイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def steal_list
    steal_list = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<スティールリスト\s?(\d+)\s?,\s?([IWA])\s?,\s?(\d+)\s?,\s?(\d+)>/)
      if $1 && $2 && $3 && $4
        case $2.upcase
        when "I"
          kind = 1
        when "W"
          kind = 2
        when "A"
          kind = 3
        end
        data_id = $3.to_i
        denominator = $4.to_f
        
        steal_list[$1.to_i] = [] unless steal_list[$1.to_i]
        steal_list[$1.to_i].push([kind, data_id, denominator])
      end
      cheak_note = $'
    end
    
    return steal_list
  end 
end

#==============================================================================
# ■ RPG::State(追加定義)
#==============================================================================
class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆拡張混乱の定義(追加定義)
  #--------------------------------------------------------------------------  
  def adv_confusion
    return false unless @note
    return true if @note.include?("<拡張混乱>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆身代わり対象設定の定義(追加定義)
  #--------------------------------------------------------------------------  
  def adv_substitute_t
    return false unless @note
    return true if @note.include?("<身代わり対象設定>")
    return false
  end
  #--------------------------------------------------------------------------
  # ☆反射先の定義(追加定義)
  #--------------------------------------------------------------------------  
  def mirror_mode
    return 0 unless @note
    return 1 if @note.include?("<敵単体反射>")
    return 2 if @note.include?("<敵全体反射>")
    return 3 if @note.include?("<味方単体反射>")
    return 4 if @note.include?("<味方全体反射>")
    return 0
  end 
end
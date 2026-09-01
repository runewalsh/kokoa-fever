#==============================================================================
# ■ RGSS3 スキルコスト拡張 Ver2.02 by 星潟
#------------------------------------------------------------------------------
# スキル使用時のコストに「アイテム/武器/防具」の指定や
# 所持金/変数/HP/MP/TPの「固定値/割合/計算式」分の消費を指定できます。
# また、スキル使用時のHP/TPの消費量を軽減する特徴や
# HP/MP/TP軽減特徴の効果を受けないようにするスキルの作成が可能になります。
#------------------------------------------------------------------------------
# ★スキルコストの設定（スキルのメモ欄に記述）
#------------------------------------------------------------------------------
#   ☆アイテムを消費させたい場合
#
#   　<アイテム消費:1,2>
#   
#     この場合、アイテムID1を2つ消費する。
#------------------------------------------------------------------------------
#   ☆武器を消費させたい場合
#
#   　<武器消費:3,1>
#   
#     この場合、アイテムID3を1つ消費する。
#------------------------------------------------------------------------------
#   ☆防具を消費させたい場合
#
#   　<防具消費:2>
#   
#     この場合、防具ID2を1つ消費する。（個数を省略すると、1扱いとなる）
#------------------------------------------------------------------------------
#   ☆所持金を固定値消費させたい場合
#
#   　<所持金固定消費:1000>
#   
#     この場合、所持金を1000消費する。
#------------------------------------------------------------------------------
#   ☆所持金を割合消費させたい場合
#
#   　<所持金割合消費:10>
#   
#     この場合、所持金を10％消費する。
#------------------------------------------------------------------------------
#   ☆所持金を計算式で消費させたい場合（上級者向け？）
#
#   　<所持金消費式:$game_variables[1]*50>
#   
#     この場合、変数1の50倍の値分の所持金を消費する。
#------------------------------------------------------------------------------
#   ☆変数の値を固定値消費させたい場合
#
#   　<変数固定消費:4,200>
#   
#     この場合、変数4の値をを200消費する。
#------------------------------------------------------------------------------
#   ☆変数の値を割合消費させたい場合
#
#   　<変数割合消費:7,5>
#   
#     この場合、変数7の値をを5％消費する。
#------------------------------------------------------------------------------
#   ☆変数の値を計算式で消費させたい場合（上級者向け？）
#
#   　<変数固定消費:3,self.level+5>
#   
#     この場合、変数3の値を使用者のレベル＋５分消費する。
#------------------------------------------------------------------------------
#   ☆HPを固定値消費させたい場合
#
#   　<HP固定消費:1000>
#   
#     この場合、HPを1000消費する。
#------------------------------------------------------------------------------
#   ☆HPを割合消費させたい場合
#
#   　<HP割合消費:10>
#   
#     この場合、HPを10％消費する。
#------------------------------------------------------------------------------
#   ☆HPを最大値に対して割合消費させたい場合
#
#   　<最大HP割合消費:10>
#   
#     この場合、最大HPの10％のHPを消費する。
#------------------------------------------------------------------------------
#   ☆HPを計算式で消費させたい場合（上級者向け？）
#
#   　<HP消費式:self.mp>
#   
#     この場合、自らのMP分のHPを消費する。
#------------------------------------------------------------------------------
#   ☆MPを固定値消費させたい場合
#
#   　<MP固定消費:30000>
#   
#     この場合、MPを30000消費する。
#     （デフォルトでは9999までですが、それを超えて設定できます）
#------------------------------------------------------------------------------
#   ☆MPを割合消費させたい場合
#
#   　<MP割合消費:20>
#   
#     この場合、MPを20％消費する。
#------------------------------------------------------------------------------
#   ☆MPを最大値に対して割合消費させたい場合
#
#   　<最大MP割合消費:40>
#   
#     この場合、最大MPの40％のMPを消費する。
#------------------------------------------------------------------------------
#   ☆MPを計算式で消費させたい場合（上級者向け？）
#
#   　<MP消費式:self.hp>
#   
#     この場合、自らのHP分のMPを消費する。
#------------------------------------------------------------------------------
#   ☆TPを固定値消費させたい場合
#
#   　<TP固定消費:120>
#   
#     この場合、TPを120消費する。
#     （デフォルトでは100までですが、TP消費軽減装備の存在を考えて
#       100を超える値を指定してみるのも手かもしれません）
#------------------------------------------------------------------------------
#   ☆TPを割合消費させたい場合
#
#   　<TP割合消費:15>
#   
#     この場合、TPを15％消費する。
#------------------------------------------------------------------------------
#   ☆TPを最大値に対して割合消費させたい場合
#
#   　<最大TP割合消費:50>
#   
#     この場合、最大TPの50％のTPを消費する。
#------------------------------------------------------------------------------
#   ☆TPを計算式で消費させたい場合（上級者向け？）
#
#   　<TP消費式:(self.hp-self.mp).abs>
#   
#     この場合、自らのHPとMPの差分のTPを消費する。
#------------------------------------------------------------------------------
# ★スキル消費HP/TP軽減の設定（アクターや装備品、ステート等のメモ欄に記述）
#------------------------------------------------------------------------------
#   ☆スキル消費HPを軽減させたい場合
#
#   　<消費HP軽減割合:10>
#   
#     この場合、スキル使用時の消費HPが10％軽減される。
#------------------------------------------------------------------------------
#   ☆スキル消費TPを軽減させたい場合
#
#   　<消費TP軽減割合:20>
#   
#     この場合、スキル使用時の消費TPが20％軽減される。
#------------------------------------------------------------------------------
# ★スキル消費HP/MP/TP軽減無効スキルの設定（スキルのメモ欄に記述）
#------------------------------------------------------------------------------
#   ☆スキル消費HPを軽減させたい場合
#
#   　<消費HP軽減無効>
#   
#     この場合、スキル使用時の消費HP軽減特徴が無効化される。
#------------------------------------------------------------------------------
#   ☆スキル消費MPを軽減させたい場合
#
#   　<消費MP軽減無効>
#   
#     この場合、スキル使用時の消費MP軽減特徴が無効化される。
#------------------------------------------------------------------------------
#   ☆スキル消費TPを軽減させたい場合
#
#   　<消費TP軽減無効>
#   
#     この場合、スキル使用時の消費TP軽減特徴が無効化される。
#============================================================================== 
# Ver2.01 HP計算の不具合で、反撃で敵を倒した際等に敵が蘇生する不具合を修正。
# Ver2.02 MP消費量軽減効果の記載が残ったままになっていたので削除しました。
#         （MP消費軽減はデフォルトの機能で存在しています）
#         TP消費量軽減効果が追加機能での消費TPにしか機能していない不具合を修正。
#============================================================================== 
module EXTRA_SKILL_COST
  
  #コストとしてアイテムを消費する場合の設定用ワード
  
  WORD1A  = "アイテム消費"
  
  #コストとして武器を消費する場合の設定用ワード
  
  WORD1B  = "武器消費"
  
  #コストとして防具を消費する場合の設定用ワード
  
  WORD1C  = "防具消費"
  
  #コストとして所持金を固定値消費する場合の設定用ワード
  
  WORD2A = "所持金固定消費"
  
  #コストとして所持金を割合消費する場合の設定用ワード
  
  WORD2B = "所持金割合消費"
  
  #コストとして所持金を消費する式を設定する場合の設定用ワード
  
  WORD2C = "所持金消費式"
  
  #コストとして変数の値を固定値消費する場合の設定用ワード
  
  WORD3A = "変数固定消費"
  
  #コストとして変数の値を割合消費する場合の設定用ワード
  
  WORD3B = "変数割合消費"
  
  #コストとして変数の値を消費する式を設定する場合の設定用ワード
  
  WORD3C = "変数消費式"
  
  #コストとしてHPを固定値消費する場合の設定用ワード
  
  WORD4A = "HP固定消費"
  
  #コストとしてHPを割合消費する場合の設定用ワード
  
  WORD4B = "HP割合消費"
  
  #コストとしてHPを最大値に対する一定割合分消費する式を設定する場合の設定用ワード
  
  WORD4C = "最大HP割合消費"
  
  #コストとしてHPを消費する式を設定する場合の設定用ワード
  
  WORD4D = "HP消費式"
  
  #コストとしてMPを固定値消費する場合の設定用ワード
  
  WORD5A = "MP固定消費"
  
  #コストとしてMPを割合消費する場合の設定用ワード
  
  WORD5B = "MP割合消費"
  
  #コストとしてMPを最大値に対する一定割合分消費する式を設定する場合の設定用ワード
  
  WORD5C = "最大MP割合消費"
  
  #コストとしてMPを消費する式を設定する場合の設定用ワード
  
  WORD5D = "MP消費式"
  
  #コストとしてTPを固定値消費する場合の設定用ワード
  
  WORD6A = "TP固定消費"
  
  #コストとしてTPを割合消費する場合の設定用ワード
  
  WORD6B = "TP割合消費"
  
  #コストとしてTPを最大値に対する一定割合分消費する式を設定する場合の設定用ワード
  
  WORD6C = "最大TP割合消費"
  
  #コストとしてTPを消費する式を設定する場合の設定用ワード
  
  WORD6D = "TP消費式"
  
  #消費HP軽減特徴の設定用ワード
  
  WORD7A = "消費HP軽減割合"
  
  #消費HP軽減無効スキルの設定用ワード
  
  WORD7B = "消費HP軽減無効"
  
  #消費MP軽減無効スキルの設定用ワード
  
  WORD8  = "消費MP軽減無効"
  
  #消費TP軽減特徴の設定用ワード
  
  WORD9A = "消費TP軽減割合"
  
  #消費TP軽減無効スキルの設定用ワード
  
  WORD9B = "消費TP軽減無効"
  
  #スキル使用時、消費HPによる戦闘不能を有効にするか否かの設定用ワード
  
  WORD10 = "戦闘不能許可"
  
  #HPのスキルコスト表示色（テキストカラーIDに準じる）
  
  HPCC   = 2
  
  #MPのスキルコスト表示色（テキストカラーIDに準じる）
  
  MPCC   = 23
  
  #TPのスキルコスト表示色（テキストカラーIDに準じる）
  
  TPCC   = 29
  
  #コストとして変数の値を消費する場合
  #使用後、変数の値がマイナスになる場合でも使用可とするか
  #true = 使用可能　false = 使用不可
  
  V_MIN1 = false
  
  #コストとして変数の値を消費する場合
  #敵が使用する場合も判定を行うか
  #true = 行う　false = 行わない
  
  V_MIN2 = false
  
  #HP/MP/TPコストの表示形式
  #0   デフォルト（HPは表示しない）
  #1   HP/MP/TPを全て表示（表示形式は揃えない）
  #2～ 数字分だけ区切って表示
  
  COST_D = 0
  
  #COST_Dが2以上の場合の表示設定
  
  #HPを表示するか（trueで表示 falseで非表示）
  
  HP_D   = false
  
  #MPを表示するか
  
  MP_D   = true
  
  #TPを表示するか
  
  TP_D   = true
  
  #スキルコストの対象表示（項目名の短縮名表示 trueで表示 falseで非表示）
  
  CTITLE = true
  
  #スキルリストの桁数
  
  COLMAX = 2
  
  #スキルコスト表示位置の調整
  
  COS_OX = -2
  
end

class Game_BattlerBase
  
  #MP・TPコストの計算に別名定義で変更
  
  alias skill_cost_payable_extra_cost? skill_cost_payable?
  def skill_cost_payable?(skill)
    
    #元の処理を実行
    
    return false unless skill_cost_payable_extra_cost?(skill)
    
    #追加された消費系統の可否を判定
    
    return false unless skill_ex_cost_payble(skill)
    
    #全てクリアならtrueを返す
    
    return true
  end
  
  #概念ごと新たに追加された消費系統の可否
  
  def skill_ex_cost_payble(skill)
    
    #アクターの場合のみ、アイテムと所持金のコスト判定を行う
    
    if self.actor?
      
      #アイテムのコスト可否判定
      
      return false unless skill_item_cost_payble(skill)
      
      #所持金のコスト可否判定
      
      return false unless skill_gold_cost_payble(skill)
      
    end
    
    #変数のコスト可否判定
    
    return false unless skill_var_cost_payble(skill)
    
    #HPのコスト可否判定
    
    return false unless skill_hp_cost_payble(skill)
    return true
  end
  
  #HP以外で新たに追加された消費系統の実行
  
  alias pay_skill_cost_extra_cost pay_skill_cost
  def pay_skill_cost(skill)
    
    #元の処理を実行
    
    pay_skill_cost_extra_cost(skill)
    
    #アクターの場合のみ、アイテムと所持金のコスト消費を行う
    
    if self.actor?
      
      #アイテムのコスト処理
      
      pay_item_cost(skill)
      
      #所持金のコスト処理
      
      pay_gold_cost(skill)
    end
    
    #変数のコスト処理
    
    pay_var_cost(skill)
  end
  
  #総合アイテム消費可否
  
  def skill_item_cost_payble(skill)
    
    #アイテムコストが存在しない場合はtrueを返す
    
    return true if skill.item_cost.empty?
    
    #コスト別に判定
    
    skill.item_cost.each do |data|
      case data[0]
      when 0#アイテムの場合
        item = $data_items[data[1]]
      when 1#武器の場合
        item = $data_weapons[data[1]]
      when 2#防具の場合
        item = $data_armors[data[1]]
      end
      
      #指定された消費量より所持数が少ない場合はfalseを返す
      
      return false if $game_party.item_number(item) < data[2]
    end
    
    #trueを返す
    
    return true
  end
  
  #総合アイテム消費
  
  def pay_item_cost(skill)
    
    #アイテムコストが存在しない場合は処理しない
    
    return if skill.item_cost.empty?
    
    #コスト別に処理
    
    skill.item_cost.each do |data|
      case data[0]
      when 0#アイテムの場合
        item = $data_items[data[1]]
      when 1#武器の場合
        item = $data_weapons[data[1]]
      when 2#防具の場合
        item = $data_armors[data[1]]
      end
      
      #アイテム消費処理
      
      $game_party.lose_item(item, data[2])
      
    end
  end
  
  #総合所持金消費可否
  
  def skill_gold_cost_payble(skill)
    
    #所持金が消費量以上か？
    
    $game_party.gold >= skill_gold_cost(skill)
    
  end
  
  #総合所持金消費
  
  def pay_gold_cost(skill)
    
    #所持金の消費処理
    
    $game_party.gain_gold(-skill_gold_cost(skill))
  end
  
  #総合所持金消費量
  
  def skill_gold_cost(skill)
    
    #それぞれの所持金消費量計算をまとめた後、整数化する
    
    (gold_cost_fix(skill) + gold_cost_rate(skill) + gold_cost_eval(skill)).to_i
    
  end
  
  #所持金固定値消費
  
  def gold_cost_fix(skill)
    
    #スキルの所持金固定値消費を返す
    
    skill.gold_cost_fix
    
  end
  
  #所持金消費割合
  
  def gold_cost_rate(skill)
    
    #スキルの所持金消費割合と現在値をかけた後、0.01をかけた数字を返す
    
    skill.gold_cost_rate * $game_party.gold * 0.01
    
  end
  
  #所持金消費式
  
  def gold_cost_eval(skill)
    
    #スキルの所持金消費式を返す
    
    eval(skill.gold_cost_eval)
  end
  
  #全ての消費変数の消費可否
  
  def skill_var_cost_payble(skill)
    
    #設定次第では、判定を無視する
    
    return true if EXTRA_SKILL_COST::V_MIN1
    
    #設定次第では、敵の場合は判定を無視する
    
    return true if !self.actor? && !EXTRA_SKILL_COST::V_MIN2
    
    #変数の固定値消費
    
    #変数の固定値消費が存在しない場合は飛ばす
    
    if !skill.var_cost_fix.empty?
      
      #消費データ別に判定
      
      skill.var_cost_fix.each do |data|
      
        #消費可否判定
      
        return false unless var_cost_fix_payble(data)
        
      end
    end
    
    #変数の割合消費
    
    #変数の割合消費が存在しない場合は飛ばす
    
    if !skill.var_cost_rate.empty?
      
      #消費データ別に判定
      
      skill.var_cost_rate.each do |data|
      
        #消費可否判定
      
        return false unless var_cost_rate_payble(data)
        
      end
    end
    
    #変数の消費式
    
    #変数の消費式が存在しない場合は飛ばす
    
    if !skill.var_cost_eval.empty?
      
      #消費データ別に判定
      
      skill.var_cost_eval.each do |data|
      
        #消費可否判定
      
        return false unless var_cost_eval_payble(data)
        
      end
    end
    
    #全てクリアならtrueを返す
    
    return true
  end
  
  #全ての消費変数の消費実行
  
  def pay_var_cost(skill)
    
    #設定次第では、敵の場合は処理をしない
    
    return if !self.actor? && !EXTRA_SKILL_COST::V_MIN2
    
    #変数の固定値消費
    
    #変数の固定値消費が存在しない場合は飛ばす
    
    if !skill.var_cost_fix.empty?
      
      #消費データ別に処理
      
      skill.var_cost_fix.each do |data|
        
        #消費処理
        
        pay_var_cost_fix(data)
        
      end
    end
    
    #変数の割合消費
    
    #変数の割合消費が存在しない場合は飛ばす
    
    if !skill.var_cost_rate.empty?
      
      #消費データ別に処理
      
      skill.var_cost_rate.each do |data|
        
        #消費処理
        
        pay_var_cost_rate(data)
        
      end
    end
    
    #変数の消費式
    
    #変数の消費式が存在しない場合は飛ばす
    
    if !skill.var_cost_eval.empty?
      
      #消費データ別に処理
      
      skill.var_cost_eval.each do |data|
        
        #消費処理
        
        pay_var_cost_eval(data)
        
      end
    end
  end
  
  #消費固定変数の可否
  
  def var_cost_fix_payble(data)
    
    #変数の値が消費値以上か否か
    
    $game_variables[data[0]] >= data[1]
    
  end
  
  #消費割合変数の可否
  
  def var_cost_rate_payble(data)
    
    #変数の値が消費割合で計算された消費値以上か否か
    
    $game_variables[data[0]] >= ($game_variables[data[0]] * data[1]) * 0.01
    
  end
  
  #消費変数式の可否
  
  def var_cost_eval_payble(data)
    
    #変数の値が消費式で計算された消費値以上か否か
    
    $game_variables[data[0]] >= eval(data[1])
    
  end
  
  #消費固定変数の消費
  
  def pay_var_cost_fix(data)
    
    #変数の固定値消費実行
    
    $game_variables[data[0]] -= data[1]
    
  end
  
  #消費割合変数の消費
  
  def pay_var_cost_rate(data)
    
    #変数の割合消費実行
    
    $game_variables[data[0]] -= (($game_variables[data[0]] * data[1]) * 0.01).to_i
    
  end
  
  #消費変数式の消費
  
  def pay_var_cost_eval(data)
    
    #変数の消費式実行
    
    $game_variables[data[0]] -= eval(data[1])
    
  end
  
  #総合消費HPの可否
  
  def skill_hp_cost_payble(skill)
    
    #スキルによる自滅が認められていない場合は現在HPが消費HP以上か否か。
    #認められている場合はtrueを返す
    
    !skill.suicidable? ? self.hp > skill_hp_cost(skill) : true
    
  end
  
  #総合消費HP
  
  def skill_hp_cost(skill)
    
    #それぞれのHP消費をまとめた後、整数化する
    
    ((hp_cost_fix(skill) + hp_cost_rate(skill) + hp_cost_mrate(skill) + hp_cost_eval(skill)) * special_ex_hcr(skill)).to_i
    
  end
  
  #消費固定HP
  
  def hp_cost_fix(skill)
    
    #スキルの消費固定HPを返す
    
    skill.hp_cost_fix
    
  end
  
  #消費HP割合（現在値）
  
  def hp_cost_rate(skill)
    
    #スキルの消費HP割合と現在値をかけた後、0.01をかけた数字を返す
    
    skill.hp_cost_rate * self.hp * 0.01
    
  end
  
  #消費HP割合（最大値）
  
  def hp_cost_mrate(skill)
    
    #スキルの消費最大HP割合と最大値をかけた後、0.01をかけた数字を返す
    
    skill.hp_cost_mrate * self.mhp * 0.01
  end
  
  #消費HP式
  
  def hp_cost_eval(skill)
    
    #スキルの消費HP割合式を返す
    
    eval(skill.hp_cost_eval)
  end
  
  #消費HP軽減割合
  
  def special_ex_hcr(skill)
    
    #消費HP軽減特徴が無効の場合は消費HP軽減特徴の効果を反映させる
    
    return [(100.0 - ex_hcr)/100, 0].max unless skill.ex_hcr_zero?
    
    #消費HP軽減特徴が有効の場合は1.0を返す
    
    return 1.0
  end
  
  #MP消費計算を別名定義で変更し、総合消費MPを計算
  
  alias skill_mp_cost_extra_cost skill_mp_cost
  def skill_mp_cost(skill)
    
    #元のデータを取得する
    
    data = skill_mp_cost_extra_cost(skill)
    
    #元のデータに新規処理の総和を足す
    
    data += (mp_cost_fix(skill) + mp_cost_rate(skill) + mp_cost_mrate(skill) + mp_cost_eval(skill)) * special_mcr(skill)
    
    #整数化して返す
    
    return data.to_i
  end
  
  #消費固定MP
  
  def mp_cost_fix(skill)
    
    #スキルの消費固定MPを返す
    
    skill.mp_cost_fix
    
  end
  
  #消費MP割合（現在値）
  
  def mp_cost_rate(skill)
    
    #スキルの消費MP割合と現在値をかけた後、0.01をかけた数字を返す
    
    skill.mp_cost_rate * self.mp * 0.01
    
  end
  
  #消費MP割合（最大値）
  
  def mp_cost_mrate(skill)
    
    #スキルの消費最大MP割合と最大値をかけた後、0.01をかけた数字を返す
    
    skill.mp_cost_mrate * self.mmp * 0.01
    
  end
  
  #消費MP式
  
  def mp_cost_eval(skill)
    
    #スキルの消費MP割合式を返す
    
    eval(skill.mp_cost_eval)
    
  end
  
  #消費MP軽減割合
  
  def special_mcr(skill)
    
    #消費MP軽減特徴が無効の場合は消費MP軽減特徴の効果を反映させる
    
    return mcr unless skill.mcr_zero?
    
    #消費MP軽減特徴が有効の場合は1.0を返す
    
    return 1.0
    
  end
  
  #TP消費計算を別名定義で変更し、総合消費TPを計算
  
  alias skill_tp_cost_extra_cost skill_tp_cost
  def skill_tp_cost(skill)
    
    #元のデータを取得する
    
    data = skill_tp_cost_extra_cost(skill)
    
    #元のデータに新規処理の総和を足す
    
    data += tp_cost_fix(skill) + tp_cost_rate(skill) + tp_cost_mrate(skill) + tp_cost_eval(skill)
    
    #軽減特徴を適用
    
    data *= special_ex_tcr(skill)
    
    #整数化して返す
    
    return data.to_i
  end
  
  #消費固定TP
  
  def tp_cost_fix(skill)
    
    #スキルの消費固定TPを返す
    
    skill.tp_cost_fix
    
  end
  
  #消費TP割合（現在値）
  
  def tp_cost_rate(skill)
    
    #スキルの消費TP割合と現在値をかけた後、0.01をかけた数字を返す
    
    skill.tp_cost_rate * self.tp * 0.01
  end
  
  #消費TP割合（最大値）
  
  def tp_cost_mrate(skill)
    
    #スキルの消費最大TP割合と最大値をかけた後、0.01をかけた数字を返す
    
    skill.tp_cost_mrate * self.max_tp * 0.01
  end
  
  #消費TP式
  
  def tp_cost_eval(skill)
    
    #スキルの消費TP割合式を返す
    
    eval(skill.tp_cost_eval)
  end
  
  #消費TP軽減割合
  
  def special_ex_tcr(skill)
    
    #消費TP軽減特徴が無効の場合は消費MP軽減特徴の効果を反映させる
    
    return [(100.0 - ex_tcr)/100, 0].max unless skill.ex_tcr_zero?
    
    #消費TP軽減特徴が有効の場合は1.0を返す
    
    return 1.0
  end
  
  #消費HP軽減割合の取得
  
  def ex_hcr
    
    #とりあえず0にする
    
    data = 0
    
    #特徴別に処理
    
    feature_objects.each do |f|
    
      #消費HP軽減割合を加算
    
      data += f.ex_hcr
    end
    
    #データを返す
    
    return data
  end
  
  #消費TP軽減割合の取得
  
  def ex_tcr
    
    #とりあえず0にする
    
    data = 0
    
    #特徴別に処理
    
    feature_objects.each do |f|
    
      #消費TP軽減割合を加算
    
      data += f.ex_tcr
    end
    
    #データを返す
    
    return data
  end
end
class Scene_Skill < Scene_ItemBase
  
  #スキル使用時のアクターへの効果のタイミングで
  #HP消費の効果を反映させる。
  
  alias use_item_to_actors_extra_cost use_item_to_actors
  def use_item_to_actors
    
    #使用者とスキルを取得。
    
    target = user
    item = target.last_skill.object
    
    #本来の処理を実行。
    
    use_item_to_actors_extra_cost
    
    #スキルではない場合は処理を飛ばす。
    
    return unless item.is_a?(RPG::Skill)
    
    #スキル使用による戦闘不能が認められていて
    #なおかつ使用者が生存している場合はHP消費を反映。
    #認められていない場合は、HPの最低値を1としてHP消費を反映。
    if target.alive? && target.hp > 0
      if item.suicidable?
        target.hp -= target.skill_hp_cost(item)
      else
        target.hp = [target.hp - target.skill_hp_cost(item), 1].max
      end
    end
  end
end
class Scene_Battle < Scene_Base
  
  #スキル使用後のタイミングで
  #HP消費の効果を反映させる。
  
  alias use_item_extra_cost use_item
  def use_item
    
    #使用者とスキルを取得。
    
    target = @subject
    item = target.current_action.item
    
    #本来の処理を実行。
    
    use_item_extra_cost
    
    #スキルではない場合は処理を飛ばす。
    
    return unless item.is_a?(RPG::Skill)
    
    #スキル使用による戦闘不能が認められていて
    #なおかつ使用者が生存している場合はHP消費を反映。
    #認められていない場合は、HPの最低値を1としてHP消費を反映。
    if target.alive? && target.hp > 0
      if item.suicidable?
        
        target.hp -= target.skill_hp_cost(item)
        
        #HP消費によって戦闘不能となった場合
        #ログウィンドウにその旨を出力する。
        
        if !target.alive?
          state = $data_states[1]
          state_msg = target.actor? ? state.message1 : state.message2
          target.perform_collapse_effect
          @log_window.replace_text(target.name + state_msg)
          @log_window.wait
          @log_window.wait_for_effect
        end
      else
        target.hp = [target.hp - target.skill_hp_cost(item), 1].max
      end
    end
  end
end
class Window_Base < Window
  
  #新たな制御文字として\ALPHACを加える。
  #\ALPHACは、文字色変更時に透過度を保持する。
  
  alias process_escape_character_extra_cost process_escape_character
  def process_escape_character(code, text, pos)
    if code.upcase == 'ALPHAC'
      alpha = contents.font.color.alpha
      change_color(text_color(obtain_escape_param(text)))
      contents.font.color.alpha = alpha
      return
    end
    process_escape_character_extra_cost(code, text, pos)
  end
  
  #コスト表示用に、制御文字付きの描写方法を新たに定義する。
  #通常の制御文字付き文章描画と異なり、文体のリセットを行わない。
  
  def draw_text_ex_cost(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
end
class Window_SkillList < Window_Selectable
  
  #桁数の変更
  
  alias col_max_extra_cost col_max
  def col_max
    data = col_max_extra_cost
    data = EXTRA_SKILL_COST::COLMAX if data != EXTRA_SKILL_COST::COLMAX
    return data
  end
  
  #スキルコストの記述方法を変更。
  
  alias draw_skill_cost_extra_cost draw_skill_cost
  def draw_skill_cost(rect, skill)
      
    #表示形式が0の場合は本来の処理を実行
      
    return draw_skill_cost_extra_cost(rect, skill) if EXTRA_SKILL_COST::COST_D == 0
      
    #HP/MP/TP消費量を取得。
      
    flag = [@actor.skill_hp_cost(skill),@actor.skill_mp_cost(skill),@actor.skill_tp_cost(skill)]
      
    #スキルの使用可否に応じて記述内容の透過度を設定する。
      
    contents.font.color.alpha = enable?(skill) ? 255 : translucent_alpha
      
    #文字列の長さを取得する為、二つの文字列データを作成する。
    
    text = ""
    
    sub_text = ""
    
    #HP
    
    if EXTRA_SKILL_COST::HP_D && (EXTRA_SKILL_COST::COST_D > 1 or flag[0] > 0)
      t = EXTRA_SKILL_COST::CTITLE ? Vocab::basic(3) : ""
      if EXTRA_SKILL_COST::COST_D > 1 && flag[0].to_s.length != EXTRA_SKILL_COST::COST_D
        number = EXTRA_SKILL_COST::COST_D - flag[0].to_s.length
        number.times do
          t+= " "
        end
      end
      t += flag[0].to_s
      sub_text += t
      text += hp_cost_color_text + t
    end
    
    #MP
    
    if EXTRA_SKILL_COST::MP_D && (EXTRA_SKILL_COST::COST_D > 1 or flag[1] > 0)
      if text != ""
        text += "\\ALPHAC[0]/"
        sub_text += "/"
      end
      t = EXTRA_SKILL_COST::CTITLE ? Vocab::basic(5) : ""
      if EXTRA_SKILL_COST::COST_D > 1 && flag[1].to_s.length != EXTRA_SKILL_COST::COST_D
        number = EXTRA_SKILL_COST::COST_D - flag[1].to_s.length
        number.times do
          t+= " "
        end
      end
      t += flag[1].to_s
      sub_text += t
      text += mp_cost_color_text + t
    end
    
    #TP
    
    if EXTRA_SKILL_COST::TP_D && (EXTRA_SKILL_COST::COST_D > 1 or flag[2] > 0)
      if text != ""
        text += "\\ALPHAC[0]/"
        sub_text += "/"
      end
      t = EXTRA_SKILL_COST::CTITLE ? Vocab::basic(7) : ""
      if EXTRA_SKILL_COST::COST_D > 1 && flag[2].to_s.length != EXTRA_SKILL_COST::COST_D
        number = EXTRA_SKILL_COST::COST_D - flag[2].to_s.length
        number.times do
          t+= " "
        end
      end
      t += flag[2].to_s
      sub_text += t
      text += tp_cost_color_text + t
    end
    
    #文字列の長さを取得し、描写を実行する。
    
    sub_x = text_size(sub_text).width
    x = rect.x + rect.width - sub_x + EXTRA_SKILL_COST::COS_OX
    y = rect.y
    draw_text_ex_cost(x, y, text)
    
  end
  
  #消費HP記述用のキャッシュを生成。
  
  def hp_cost_color_text
    return @hp_cost_color_set if @hp_cost_color_set != nil
    @hp_cost_color_set = "\\ALPHAC[" + EXTRA_SKILL_COST::HPCC.to_s + "]"
    return @hp_cost_color_set
  end
  
  #消費MP記述用のキャッシュを生成。
  
  def mp_cost_color_text
    return @mp_cost_color_set if @mp_cost_color_set != nil
    @mp_cost_color_set = "\\ALPHAC[" + EXTRA_SKILL_COST::MPCC.to_s + "]"
    return @mp_cost_color_set
  end
  
  #消費TP記述用のキャッシュを生成。
  
  def tp_cost_color_text
    return @tp_cost_color_set if @tp_cost_color_set != nil
    @tp_cost_color_set = "\\ALPHAC[" + EXTRA_SKILL_COST::TPCC.to_s + "]"
    return @tp_cost_color_set
  end
  
end
class RPG::BaseItem
  
  #消費HP軽減特徴。
  
  def ex_hcr
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @feature_ex_hcr if @feature_ex_hcr != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD7A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @feature_ex_hcr = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @feature_ex_hcr
  end
  
  #消費TP軽減特徴。
  
  def ex_tcr
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @feature_ex_tcr if @feature_ex_tcr != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD9A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @feature_ex_tcr = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @feature_ex_tcr
  end
end
class RPG::Skill < RPG::UsableItem
  
  #消費HP軽減無効。
  
  def ex_hcr_zero?
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @ex_hcr_zero if @ex_hcr_zero != nil
    
    #メモ欄からデータを取得。
    
    @ex_hcr_zero = self.note.include?(EXTRA_SKILL_COST::WORD7B)
    
    #データを返す。
    
    return @ex_hcr_zero
  end
  
  #消費MP軽減無効。
  
  def mcr_zero?
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @mcr_zero if @mcr_zero != nil
    
    #メモ欄からデータを取得。
    
    @mcr_zero = self.note.include?(EXTRA_SKILL_COST::WORD8)
    
    #データを返す。
    
    return @mcr_zero
  end
  
  #消費TP軽減無効。
  
  def ex_tcr_zero?
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @ex_tcr_zero if @ex_tcr_zero != nil
    
    #メモ欄からデータを取得。
    
    @ex_tcr_zero = self.note.include?(EXTRA_SKILL_COST::WORD9B)
    
    #データを返す。
    
    return @ex_tcr_zero
  end
  def item_cost
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @item_cost if @item_cost != nil
    
    @item_cost = []
    
    #メモ欄からデータを取得。
    
    self.note.each_line do |l|
    
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD1A}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
      
      if memo != nil && !memo.empty?
        
        memo = memo[0].split(/\s*,\s*/)
      
        @item_cost.push([0, memo[0].to_i, memo[1] ? memo[1].to_i : 1])
      
      end
      
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD1B}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
        
      if memo != nil && !memo.empty?
        
        memo = memo[0].split(/\s*,\s*/)
      
        @item_cost.push([1, memo[0].to_i, memo[1] ? memo[1].to_i : 1])
      
      end
    
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD1C}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
        
      if memo != nil && !memo.empty?
        
        memo = memo[0].split(/\s*,\s*/)
      
        @item_cost.push([2, memo[0].to_i, memo[1] ? memo[1].to_i : 1])
      
      end    
    end
    
    #データを返す。
    
    return @item_cost
  end
  def gold_cost_fix
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @gold_cost_fix if @gold_cost_fix != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD2A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @gold_cost_fix = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @gold_cost_fix
  end
  def gold_cost_rate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @gold_cost_rate if @gold_cost_rate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD2B}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @gold_cost_rate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @gold_cost_rate
  end
  def gold_cost_eval
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @gold_cost_eval if @gold_cost_eval != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD2C}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @gold_cost_eval = (memo != nil && !memo.empty?) ? memo[0].to_s : "0"
    
    #データを返す。
    
    return @gold_cost_eval
  end
  def var_cost_fix
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @var_cost_fix if @var_cost_fix != nil
    
    #配列を作成。
    
    @var_cost_fix = []
    
    #メモ欄からデータを取得。
    
    self.note.each_line do |l|
    
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD3A}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
      
      if memo != nil && !memo.empty?
      
        memo = memo[0].split(/\s*,\s*/)
        
        @var_cost_fix.push([memo[0].to_i, memo[1].to_i])
        
      end
       
    end
    
    #データを返す。
    
    return @var_cost_fix
  end
  def var_cost_rate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @var_cost_rate if @var_cost_rate != nil
    
    #配列を作成。
    
    @var_cost_rate = []
    
    #メモ欄からデータを取得。
    
    self.note.each_line do |l|
    
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD3B}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
      
      if memo != nil && !memo.empty?
      
        memo = memo[0].split(/\s*,\s*/)
        
        @var_cost_rate.push([memo[0].to_i, memo[1].to_i])
        
      end
       
    end
    
    #データを返す。
    
    return @var_cost_rate
  end
  def var_cost_eval
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @var_cost_eval if @var_cost_eval != nil
    
    #配列を作成。
    
    @var_cost_eval = []
    
    #メモ欄からデータを取得。
    
    self.note.each_line do |l|
    
      memo = l.scan(/<#{EXTRA_SKILL_COST::WORD3C}[：:](\S+)>/).flatten
      
      #データを取得出来無かった場合は飛ばす。
      
      if memo != nil && !memo.empty?
      
        memo = memo[0].split(/\s*,\s*/)
        
        @var_cost_eval.push([memo[0].to_i, memo[1].to_s])
        
      end
       
    end
    
    #データを返す。
    
    return @var_cost_eval
  end
  def hp_cost_fix
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @hp_cost_fix if @hp_cost_fix != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD4A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @hp_cost_fix = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @hp_cost_fix
  end
  def hp_cost_rate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @hp_cost_rate if @hp_cost_rate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD4B}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @hp_cost_rate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @hp_cost_rate
  end
  def hp_cost_mrate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @hp_cost_mrate if @hp_cost_mrate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD4C}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @hp_cost_mrate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @hp_cost_mrate
  end
  def hp_cost_eval
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @hp_cost_eval if @hp_cost_eval != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD4D}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @hp_cost_eval = (memo != nil && !memo.empty?) ? memo[0].to_s : "0"
    
    #データを返す。
    
    return @hp_cost_eval
  end
  def mp_cost_fix
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @mp_cost_fix if @mp_cost_fix != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD5A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @mp_cost_fix = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @mp_cost_fix
  end
  def mp_cost_rate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @mp_cost_rate if @mp_cost_rate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD5B}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @mp_cost_rate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @mp_cost_rate
  end
  def mp_cost_mrate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @mp_cost_mrate if @mp_cost_mrate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD5C}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @mp_cost_mrate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @mp_cost_mrate
  end
  def mp_cost_eval
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @mp_cost_eval if @mp_cost_eval != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD5D}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @mp_cost_eval = (memo != nil && !memo.empty?) ? memo[0].to_s : "0"
    
    #データを返す。
    
    return @mp_cost_eval
  end
  def tp_cost_fix
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @tp_cost_fix if @tp_cost_fix != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD6A}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @tp_cost_fix = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @tp_cost_fix
  end
  def tp_cost_rate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @tp_cost_rate if @tp_cost_rate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD6B}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @tp_cost_rate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @tp_cost_rate
  end
  def tp_cost_mrate
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @tp_cost_mrate if @tp_cost_mrate != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD6C}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @tp_cost_mrate = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #データを返す。
    
    return @tp_cost_mrate
  end
  def tp_cost_eval
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @tp_cost_eval if @tp_cost_eval != nil
    
    #メモ欄からデータを取得。
    
    memo = self.note.scan(/<#{EXTRA_SKILL_COST::WORD6D}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @tp_cost_eval = (memo != nil && !memo.empty?) ? memo[0].to_s : "0"
    
    #データを返す。
    
    return @tp_cost_eval
  end
  def suicidable?
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @suicidable if @suicidable != nil
    
    #メモ欄からデータを取得。
    
    @suicidable = self.note.include?(EXTRA_SKILL_COST::WORD10)
    
    #データを返す。
    
    return @suicidable
  end
end
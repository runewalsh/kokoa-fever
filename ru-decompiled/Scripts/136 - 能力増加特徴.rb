#==============================================================================
# ■ RGSS3 能力値増加特徴 Ver1.02 by 星潟
#------------------------------------------------------------------------------
# 特徴を有する項目による能力値増加を割合の他に
# 特定の値で増加させる事が可能になります。
# 長すぎて2行になっても、自分で改行を行っていないのであれば機能すると思います。
# 記述方法を変える事で常時増加させる場合と
# 戦闘中のみ増加させる場合とで使い分けが可能です。
# なお、マイナスの値が指定された場合は、減算扱いとなります。
#------------------------------------------------------------------------------
# 設定例(職業・ステート等のメモ欄に記入)
# <MHP:500>
# 最大HPが500増加する。
# 
# <MMP:250>
# 最大HPが250減少する。
# 
# <BATK:self.hp/5>
# 戦闘中、自分の現在HPの5分の1分、攻撃力が増加する。
# 
# <BDEF:friends_unit.alive_members.size*50>
# 戦闘中、生存している味方数の50倍分、防御力が増加する。
# 
# <MAT:$game_variables[9]>
# 魔法力が変数9の値分増加する。
# 
# <MDF:$game_party.item_number($data_items[5])*10>
# 魔法防御がアイテムID5の所持数×10分増加する。
# 
# <AGI:$game_party.gold/1000>
# 敏捷性が所持金の1000分の1の値分増加する。
# 
# <BLUK:rand(1000)>
# 戦闘中、運の値を常に0～999の間のどれかの値で加算する。
#------------------------------------------------------------------------------
# なお、処理によってはループしてエラーを吐く場合がある為
# キャラクターの能力値が相互に影響を及ぼすような設定は避けて下さい。
# （<ATK:self.param(2)>と設定したり
#   <ATK:self.param(3)>と<DEF:self.param(2)>を1キャラクターに設定したり
#    常時増加値として敵のデータを参照するように設定するとエラーを吐きます）
#
# Ver1.01　テスト用のp文を消去。
# Ver1.02　指定値強化・弱体アイテム・スキルとの競合を解消。
#==============================================================================
module V_UP_FEATURE
  
  #常時増加値設定用キーワードを設定します。
  #「,」（鍵括弧は除く）で区切り
  #最大HPから運までの8つを順番に設定します。
  #（変更不要です）
  
  WORD1 = [
  "MHP",
  "MMP",
  "ATK",
  "DEF",
  "MAT",
  "MDF",
  "AGI",
  "LUK"
  ]
  
  #戦闘中に限定して作用する増加値設定用キーワードを設定します。
  #「,」（鍵括弧は除く）で区切り
  #最大HPから運までの8つを順番に設定します。
  #（変更不要です）
  
  WORD2 = [
  "BMHP",
  "BMMP",
  "BATK",
  "BDEF",
  "BMAT",
  "BMDF",
  "BAGI",
  "BLUK"
  ]
  
end
class Game_BattlerBase
  alias param_plus_exppf param_plus
  def param_plus(param_id)
    #元の処理呼び出し
    data = param_plus_exppf(param_id)
    #増加値特徴加算
    data += ppf_param_plus(param_id)
    return data
  end
  def ppf_param_plus(param_id)
    data = 0
    #各特徴のデータを加算
    feature_objects.each do |f|
      data += eval(f.exppf_param[param_id])
      data += eval(f.battle_exppf_param[param_id]) if friends_unit.in_battle
    end
    return data
  end
end
class RPG::BaseItem
  def exppf_param
    #増加値設定が既に存在するならそれを返す
    return @exppf_param_data if @exppf_param_data != nil
    @exppf_param_data = []
    #増加値設定を生成
    for i in 0..7
      data = self.note.scan(/<#{V_UP_FEATURE::WORD1[i]}[：:](\S+)>/).flatten
      data = (data != nil && !data.empty? ? data[0] : 0).to_s
      @exppf_param_data.push(data)
    end
    return @exppf_param_data
  end
  def battle_exppf_param
    #増加値設定が既に存在するならそれを返す
    return @battle_exppf_param_data if @battle_exppf_param_data != nil
    @battle_exppf_param_data = []
    #増加値設定を生成
    for i in 0..7
      data = self.note.scan(/<#{V_UP_FEATURE::WORD2[i]}[：:](\S+)>/).flatten
      data = (data != nil && !data.empty? ? data[0] : 0).to_s
      @battle_exppf_param_data.push(data)
    end
    return @battle_exppf_param_data
  end
end


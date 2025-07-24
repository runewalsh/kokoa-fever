#==============================================================================
# ■ RGSS3 パーティ能力詳細設定 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 「半減する」・「二倍にする」・「無効にする」等と
# 大雑把なパーティ能力の効果を詳細に設定できるようなシステムを追加します。
# 特徴を有する項目（アクター・職業・装備品・ステート等）の
# メモ欄に特定の書式で書き込む事で設定を行います。
# 
# 例
# <エンカウント率増減:-25>
# エンカウント率を25％減少させます。
# 
# <先制攻撃率増減:10>
# 先制攻撃率を10％増加させます。
# 
# <獲得金額率増減:50>
# 獲得金額率を50％増加させます。
# 
# <ドロップ率増減:70>
# アイテムドロップ率を70％増加させます。
# 
#==============================================================================
module DETAIL_PTA
  
  #エンカウント率増減効果設定の為のキーワードを設定します。（変更不要）
  
  WORD1 = "エンカウント率増減"
  
  #先制攻撃率増減効果設定の為のキーワードを設定します。（変更不要）
  
  WORD2 = "先制攻撃率増減"
  
  #獲得金額率増減効果設定の為のキーワードを設定します。（変更不要）
  
  WORD3 = "獲得金額率増減"
  
  #ドロップ率増減効果設定の為のキーワードを設定します。（変更不要）
  
  WORD4 = "ドロップ率増減"
  
end
class Game_BattlerBase
  def extra_pta(n)
    rate = 0
    feature_objects.each do |object|
      data = object.note
      data.each_line { |line|
      case n
      when 0
        memo = line.scan(/<#{DETAIL_PTA::WORD1}[：:](\S+)>/)
      when 1
        memo = line.scan(/<#{DETAIL_PTA::WORD2}[：:](\S+)>/)
      when 2
        memo = line.scan(/<#{DETAIL_PTA::WORD3}[：:](\S+)>/)
      when 3
        memo = line.scan(/<#{DETAIL_PTA::WORD4}[：:](\S+)>/)
      end
      memo = memo.flatten
      rate += memo[0].to_i if memo != nil && !memo.empty?
      }
    end
    return rate
  end
end
class Game_Party < Game_Unit
  def extra_pta(n)
    data = 100
    battle_members.each do |actor|
      data += actor.extra_pta(n)
    end
    data /= 100.0 if data != 0
    data = 0 if data < 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 先制攻撃の確率計算
  #--------------------------------------------------------------------------
  alias rate_preemptive_enh_st rate_preemptive
  def rate_preemptive(troop_agi)
    data = rate_preemptive_enh_st(troop_agi)
    data *= $game_party.extra_pta(1)
    return data
  end
end
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● エンカウント進行値の取得
  #--------------------------------------------------------------------------
  alias encounter_progress_value_enh_st encounter_progress_value
  def encounter_progress_value
    data = encounter_progress_value_enh_st
    data *= $game_party.extra_pta(0)
    return data
  end
end
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● お金の合計計算
  #--------------------------------------------------------------------------
  alias gold_total_enh_st gold_total
  def gold_total
    data = gold_total_enh_st
    return data.to_i
  end
  #--------------------------------------------------------------------------
  # ● お金の倍率を取得
  #--------------------------------------------------------------------------
  alias gold_rate_enh_st gold_rate
  def gold_rate
    data = gold_rate_enh_st
    data *= $game_party.extra_pta(2)
    return data
  end
end
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● ドロップアイテム取得率の倍率を取得
  #--------------------------------------------------------------------------
  alias drop_item_rate_enh_st drop_item_rate
  def drop_item_rate
    data = drop_item_rate_enh_st
    data *= $game_party.extra_pta(3)
    return data
  end
end
#==============================================================================
# ■ RGSS3 アイテムコマンド封印/スキルのアイテム化 Ver1.01 by 星潟
#------------------------------------------------------------------------------
# アイテムコマンドを封印する特徴の作成が可能になります。
# また、指定したスキルをアイテム扱いとすることで
# 敵のスキルでポーション等を作成し
# 「敵がアイテムを使っている戦闘演出」等をする場合に
# アイテムコマンド封印特徴が付与されていれば
# 該当スキルをアイテムとみなし、使用不可能にする事も出来ます。
#------------------------------------------------------------------------------
# 使用方法
# 
# ★アイテムコマンド封印状態にする特徴を作成したい場合
#
# 特徴を有する項目（アクター・職業・装備・ステート等）のメモ欄に
# <アイテム封印>と記入する事で機能します。
# 
# 
# ★スキルをアイテム扱いとして
#   アイテムコマンド封印による使用禁止を有効にしたい場合
#
# スキルのメモ欄に<アイテム扱い>と記入する事で機能します。
#------------------------------------------------------------------------------
# Ver1.01 スキルのアイテム化機能を追加しました。
#==============================================================================
module ITEM_COMMAND_SEAL
  
  #アイテムコマンド封印特徴に指定する際に
  #特徴を有する項目のメモ欄に記入するキーワードを指定します。
  WORD1 = "<アイテム封印>"
  
  #アイテム扱いのスキルに指定する際に
  #スキルのメモ欄に記入するキーワードを指定します。
  WORD2 = "<アイテム扱い>"
  
end
class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● アイテムコマンドをリストに追加
  #--------------------------------------------------------------------------
  alias add_item_command_ics add_item_command
  def add_item_command
    #アクターがアイテムコマンド封印特徴を付与されている場合は
    #アイテムコマンド選択禁止の処理に分岐させる。
    @actor.item_command_seal? ? add_command(Vocab::item, :item, false) : add_item_command_ics
  end
end
class Game_BattlerBase
  def item_command_seal?
    #アイテムコマンドが封印されているか全ての特徴をチェックする。
    feature_objects.each do |f|
      return true if f.note.include?(ITEM_COMMAND_SEAL::WORD1)
    end
    #封印されていなければfalseを返す。
    return false
  end
  alias skill_conditions_met_ics? skill_conditions_met?
  def skill_conditions_met?(skill)
    #通常のスキル使用条件を満たせない場合はfalseを返す。
    return false if !skill_conditions_met_ics?(skill)
    #スキルがアイテム扱いであり
    #なおかつアイテムコマンド封印特徴が付与されている場合はfalseを返す。
    return false if skill.item_skill? && item_command_seal?
    #条件を満たしているのでtrueを返す。
    return true
  end
end
class RPG::Skill < RPG::UsableItem
  def item_skill?
    #アイテム扱いスキルのキャッシュ情報がある場合はその情報を返す。
    return @item_skill if @item_skill != nil
    #スキルのメモ欄からアイテム扱いスキルのキャッシュ情報作成。
    @item_skill = self.note.include?(ITEM_COMMAND_SEAL::WORD2)
    #アイテム扱いスキルのキャッシュ情報を返す。
    return @item_skill
  end
end
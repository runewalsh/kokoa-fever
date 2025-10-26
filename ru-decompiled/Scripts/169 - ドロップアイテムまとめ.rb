#==============================================================================
# ■ ドロップアイテム個数表示 v1.0              by 日車 徹  http://toruic.com/
#------------------------------------------------------------------------------
# 　同じドロップアイテムをまとめ、ドロップアイテムに個数を表示します。
#==============================================================================

module Vocab
  # 戦闘終了メッセージ
  ObtainItems1    = "%s — у меня!"
  ObtainItemsNon1 = "%s ×%s — у меня!"
end
#------------------------------------------------------------------------------
module BattleManager
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの獲得と表示【※再定義※】
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.group_by {|item| item }.each do |item, items|
      $game_party.gain_item(item, items.size)
      if items.size == 1
        $game_message.add(sprintf(Vocab::ObtainItems1, item.name))
      else
        $game_message.add(sprintf(Vocab::ObtainItemsNon1, item.name, items.size))
      end
    end
    wait_for_message
  end
end

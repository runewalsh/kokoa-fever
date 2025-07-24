=begin
■バトル中でも自動実行・並列コモン RGSS2 DAIpage■
●機能と使い方●

★機能★
導入すると戦闘中でも自動実行・並列処理のコモンイベントが機能します。

※全滅時のコモンイベント実行はできません。

★何となく思ったこと★
　◆条件分岐：スクリプトで　$game_temp.in_battle　# 現在戦闘中か？の
　　条件内に実行処理を収めると誤動作しにくいと思います。

★あると便利かもしれない条件分岐例★
  $game_temp.in_battle　                   # 現在戦闘中か？
  $game_troop.can_escape                   # 逃走可能？
  $game_party.existing_members.size == 1   # 生き残りが一人？
  $game_troop.turn_count == 2              # 現在 2ターン目か？

  $game_party.existing_members.size        # 生存者数を取得
  $game_troop.turn_count                   # 現在のターン数を取得
  
●再定義している箇所●

　Scene_Battleをエイリアス

　※同じ箇所を変更するスクリプトと併用した場合は競合する可能性があります。
=end
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理（エイリアス）
  #--------------------------------------------------------------------------
  alias dai_battle_common_start start
  def start
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    dai_battle_common_start
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新（エイリアス）
  #--------------------------------------------------------------------------
  alias dai_battle_common_update update
  def update
    for common_event in @common_events.values
      common_event.refresh
      common_event.update
    end
    dai_battle_common_update
  end
end


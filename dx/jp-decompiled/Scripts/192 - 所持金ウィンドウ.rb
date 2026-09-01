#==============================================================================
# ■ RGSS3 常駐所持金ウィンドウ Ver1.00 by 星潟
#==============================================================================
# マップ/戦闘時に表示しっぱなしの所持金ウィンドウを作成出来ます。
# 
# 通常の所持金ウィンドウと異なり
# 指定スイッチがONの場合は、メッセージウィンドウが閉じていても表示され続けます。
# このウィンドウに表示されている所持金は、所持金の変動で自動更新されます。
# 
# なお、通常の所持金ウィンドウとは別物として扱われる為
# メッセージウィンドウで\$を使用すると、重複して表示されますので
# こちらは使用されない方がよろしいかと思われます。
#==============================================================================
module SubGoldWindow
  
  #基礎知識
  
  #ゴールドウィンドウは幅160、高さ48のウィンドウです。
  #544×416の通常サイズで右上に表示するのであれば[384,0]、
  #640×480の通常サイズで右上に表示するのであれば[480,0]が適正値です。
  
  #マップ画面での座標設定。
  #順にX座標とY座標を設定して下さい。
  
  M_GW_XY = [0,0]
  
  #マップ画面での表示フラグとなるスイッチIDの設定。
  #このIDのスイッチがONの時、マップ画面にゴールドウィンドウが表示されます。
  
  MSwitch = 7
  
  #戦闘画面での座標設定。
  #順にX座標とY座標を設定して下さい。
  
  B_GW_XY = [0,0]
  
  #戦闘画面での表示フラグとなるスイッチIDの設定。
  #このIDのスイッチがONの時、戦闘画面にゴールドウィンドウが表示されます。
  
  BSwitch = 8
  
end
class Window_SubGold < Window_Gold
  #--------------------------------------------------------------------------
  # リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @last_gold = $game_party.gold
    super
  end
end
class Window_MapSubGold < Window_SubGold
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @last_gold != $game_party.gold
    $game_switches[SubGoldWindow::MSwitch] ? open : close
  end
end
class Window_BattleSubGold < Window_SubGold
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @last_gold != $game_party.gold
    $game_switches[SubGoldWindow::BSwitch] ? open : close
  end
end
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias create_all_windows_sub_gold create_all_windows
  def create_all_windows
    create_all_windows_sub_gold
    create_sub_gold_window
  end
  #--------------------------------------------------------------------------
  # ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_sub_gold_window
    @map_gold_window = Window_MapSubGold.new
    a = SubGoldWindow::M_GW_XY
    @map_gold_window.x = a[0]
    @map_gold_window.y = a[1]
    @map_gold_window.openness = 0
  end
end
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias create_all_windows_sub_gold create_all_windows
  def create_all_windows
    create_all_windows_sub_gold
    create_sub_gold_window
  end
  #--------------------------------------------------------------------------
  # ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_sub_gold_window
    @battle_gold_window = Window_BattleSubGold.new
    a = SubGoldWindow::B_GW_XY
    @battle_gold_window.x = a[0]
    @battle_gold_window.y = a[1]
    @battle_gold_window.openness = 0
  end
end
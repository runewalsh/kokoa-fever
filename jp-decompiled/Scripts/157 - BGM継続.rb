#==============================================================================
# ■ VXAce-RGSS3-12 戦闘前後BGM操作 [Ver.1.0.1]        by Claimh
#------------------------------------------------------------------------------
# ・BGMを継続して戦闘へ突入
# ・戦闘終了後のBGM/BGSを指定可能
#------------------------------------------------------------------------------
# ●BGM継続
#   BTIN_BGM_SW_IDで指定したSWがONときにBGMを継続します
# ●復帰BGM/BGS指定
#   戦闘中にイベントのスクリプトで変更します。
#   ・BGMだけ変更
#     BattleManager.set_bgmbgs(RPG::BGM.new("Field1", 100, 100))
#   ・BGM+BGSを変更
#     BattleManager.set_bgmbgs(RPG::BGM.new("Field1", 100, 100), 
#                              RPG::BGS.new("Rain", 100, 100))
#==============================================================================

module BattleManager
  # マップBGM継続スイッチ
  BTIN_BGM_SW_ID = 1
end


#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● 戦闘 BGM の演奏 [再定義]
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play unless $game_switches[BTIN_BGM_SW_ID]
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # ● 復帰BGM/BGSを設定
  #--------------------------------------------------------------------------
  def self.set_bgmbgs(bgm=nil, bgs=nil)
    @map_bgm = bgm.reset_pos  unless bgm.nil?
    @map_bgs = bgs.reset_pos  unless bgs.nil?
  end
end


class RPG::AudioFile
  def reset_pos
    @pos = 0
    self
  end
end

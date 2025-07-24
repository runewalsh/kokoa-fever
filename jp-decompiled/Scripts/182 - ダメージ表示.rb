#==============================================================================
# □ ダメージ表示実装 (for VX Ace)
#------------------------------------------------------------------------------
# Version : 1_20121030
# by サリサ・タイクーン
# http://www.tycoon812.com/rgss/
#==============================================================================

#==============================================================================
# □ 素材スイッチ
#==============================================================================
$rgsslab = {} if $rgsslab == nil
$rgsslab["ダメージ表示実装"] = true

if $rgsslab["ダメージ表示実装"]

#==============================================================================
# □ カスタマイズポイント
#==============================================================================
module RGSSLAB end
module RGSSLAB::Damage_Display_Mounting
  #--------------------------------------------------------------------------
  # ○ ダメージの色の設定
  #    ＨＰ/ＭＰの増減において、使われる色を指定します。
  #
  #    指定には、Colorクラスで行います。
  #--------------------------------------------------------------------------
  HP_HEAL_COLOR     = Color.new(176, 255, 144) # HP回復の色
  MP_HEAL_COLOR     = Color.new(144, 176, 255) # MP回復の色
  HP_DAMAGE_COLOR   = Color.new(255, 255, 255) # HPダメージの色
  MP_DAMAGE_COLOR   = Color.new(255, 176, 144) # MPダメージの色
  HP_CRITICAL_COLOR = Color.new(255, 255, 255) # HPクリティカルの色
  MP_CRITICAL_COLOR = Color.new(255, 255, 255) # MPクリティカルの色
  #--------------------------------------------------------------------------
  # ○ ダメージのその他の文字列設定
  #    ダメージのその他の文字列設定を行います。
  #
  #    フォントによって、表示できない文字もありますので
  #    必ずご確認下さい。
  #--------------------------------------------------------------------------
  MISS     = "Miss"     # ミス
  CRITICAL = "CRITICAL" # クリティカル（HP/MP共用）
  EVASION  = "EVASION"  # 回避（ミスとは別扱い）
  RESIST   = "RESIST"   # 失敗（ミスとは別扱い）
  #--------------------------------------------------------------------------
  # ○ ダメージフォントの設定
  #    ダメージで使われるフォントの指定をします。
  #
  #    無効なフォントは、表示されませんのでご注意下さい。
  #--------------------------------------------------------------------------
  FONT = "Arial Black"
  #--------------------------------------------------------------------------
  # ○ ダメージスプライトの大きさ
  #    ダメージスプライトの大きさを指定します。
  #--------------------------------------------------------------------------
  DAMAGE_SIZE   = 32 # ダメージスプライト（HP/MP共用）
  CRITICAL_SIZE = 20 # クリティカルスプライト（HP/MP共用）
end

# カスタマイズポイントは、ここまで

#==============================================================================
# □ RGSSLAB::Damage_Display_Mounting [module]
#==============================================================================
module RGSSLAB::Damage_Display_Mounting
  #--------------------------------------------------------------------------
  # ○ 素材設定用の定数定義
  #--------------------------------------------------------------------------
  MATERIAL_NAME = "ダメージ表示実装"
  VERSION       = 1
  RELEASE       = 20121030
end

#==============================================================================
# □ Combined_Use_Modules [module]
#==============================================================================
module Combined_Use_Modules
  #============================================================================
  # □ みんとのお部屋（みんとさん）
  #============================================================================
  module Minto_Room
    #--------------------------------------------------------------------------
    # ○ アニメFPS変更スクリプトVXA
    #--------------------------------------------------------------------------
    def self.animation_fps_change_script_vxa
      return true if MINTO::RGSS["アニメFPS変更スクリプトVXA"] if defined?(MINTO)
      return false
    end
  end
end

#==============================================================================
# ■ Game_Battler [class]
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :hp_damage_pop
  attr_accessor :mp_damage_pop
  attr_accessor :critical
  attr_accessor :append_string
  attr_writer   :hp_damage
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 [エイリアス]
  #--------------------------------------------------------------------------
  alias damage_display_initialize initialize
  def initialize
    damage_display_initialize
    @hp_damage_pop = false
    @mp_damage_pop = false
    @critical      = false
    @append_string = ""
  end
end

#==============================================================================
# ■ Sprite_Base [class]
#==============================================================================
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ○ モジュールの設定
  #--------------------------------------------------------------------------
  RGSSLAB_007 = RGSSLAB::Damage_Display_Mounting
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 [エイリアス]
  #     viewport : ビューポート
  #--------------------------------------------------------------------------
  alias damage_display_initialize initialize
  def initialize(viewport = nil)
    damage_display_initialize(viewport)
    @_damage_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 解放 [再定義]
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
    dispose_damage
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示
  #     value    : ダメージの値又は文字列
  #     critical : クリティカルフラグ
  #     s_type   : 文字列タイプ（HP/MP）
  #--------------------------------------------------------------------------
  def damage(value, critical, s_type)
    dispose_damage
    if value == RGSSLAB_007::MISS
      damage_string = RGSSLAB_007::MISS
    end
    damage_string = judge_hp_string(value)
    bitmap = Bitmap.new(160, 48)
    bitmap.font.name = RGSSLAB_007::FONT
    bitmap.font.size = RGSSLAB_007::DAMAGE_SIZE
    if value.is_a?(Numeric) && value < 0
      if s_type == "HP"
        bitmap.font.color = RGSSLAB_007::HP_HEAL_COLOR
      else
        bitmap.font.color = RGSSLAB_007::MP_HEAL_COLOR
      end
    else
      if s_type == "HP"
        bitmap.font.color = judge_hp_critical(critical)
      else
        bitmap.font.color = judge_mp_critical(critical)
      end
    end
    bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
    if critical
      bitmap.font.size = RGSSLAB_007::CRITICAL_SIZE
      if s_type == "HP"
        bitmap.font.color = RGSSLAB_007::HP_CRITICAL_COLOR
      else
        bitmap.font.color = RGSSLAB_007::MP_CRITICAL_COLOR
      end
      bitmap.draw_text(0, 0, 160, 20, RGSSLAB_007::CRITICAL, 1)
    end
    @_damage_sprite = Sprite.new(self.viewport)
    @_damage_sprite.bitmap = bitmap
    @_damage_sprite.ox = 80
    @_damage_sprite.oy = 20
    @_damage_sprite.x = self.x
    @_damage_sprite.y = self.y - self.oy / 2
    @_damage_sprite.z = 3000
    @_damage_duration = 40
    if $rgsslab["ダメージムーブアクション"]
      if value.is_a?(String)
        case value
        when RGSSLAB_007::MISS    ; @damage_kind = "ミス"
        when RGSSLAB_007::EVASION ; @damage_kind = "回避"
        when RGSSLAB_007::RESIST  ; @damage_kind = "レジスト"
        else                      ; @damage_kind = "その他"
        end
      else
        @damage_kind = "ダメージ"
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 数値判定
  #     value : 値
  #--------------------------------------------------------------------------
  def judge_hp_string(value)
    return value.abs.to_s if value.is_a?(Numeric)
    return value.to_s
  end
  #--------------------------------------------------------------------------
  # ○ HPクリティカル判定
  #     critical : クリティカルフラグ
  #--------------------------------------------------------------------------
  def judge_hp_critical(critical)
    return RGSSLAB_007::HP_CRITICAL_COLOR if critical
    return RGSSLAB_007::HP_DAMAGE_COLOR
  end
  #--------------------------------------------------------------------------
  # ○ MPクリティカル判定
  #     critical : クリティカルフラグ
  #--------------------------------------------------------------------------
  def judge_mp_critical(critical)
    return RGSSLAB_007::MP_CRITICAL_COLOR if critical
    return RGSSLAB_007::MP_DAMAGE_COLOR
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ解放
  #--------------------------------------------------------------------------
  def dispose_damage
    if @_damage_sprite != nil
      @_damage_sprite.bitmap.dispose
      @_damage_sprite.dispose
      @_damage_sprite = nil
      @_damage_duration = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 [オーバーライド][再定義]
  #--------------------------------------------------------------------------
  def update
    super
    if Combined_Use_Modules::Minto_Room.animation_fps_change_script_vxa
      unless @animation.nil?
        if anima_update? then
          update_animation
          update_damage if $rgsslab["ダメージ表示実装"]
          @ani_duration -= 1
        end
      end
    else
      update_animation
      update_damage     if $rgsslab["ダメージ表示実装"]
    end
    @@ani_checker.clear
    @@ani_spr_checker.clear
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新：ダメージ
  #--------------------------------------------------------------------------
  def update_damage
    if @_damage_duration > 0
      @_damage_duration -= 1
      $rgsslab["ダメージムーブアクション"] ? damage_move_process(get_action) : damage_move_default
      @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
      dispose_damage if @_damage_duration == 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ ダメージムーブ：デフォルト
  #--------------------------------------------------------------------------
  def damage_move_default
    case @_damage_duration
    when 38..39 ; @_damage_sprite.y -= 4
    when 36..37 ; @_damage_sprite.y -= 2
    when 34..35 ; @_damage_sprite.y += 2
    when 28..33 ; @_damage_sprite.y += 4
    end
  end
end

#==============================================================================
# ■ Sprite_Battler [class]
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● エフェクトの開始 [再定義]
  #     effect_type : 新しいエフェクト
  #--------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 16
      @battler_visible = true
      @effect_start    = false if $rgsslab["消滅エフェクト拡張"]
    when :disappear
      @effect_duration = 32
      @battler_visible = false
    when :whiten
      @effect_duration = 16
      @battler_visible = true
    when :blink
      if $rgsslab["ダメージブリンク設定"]
        damage_blink_process
      else
        @effect_duration = 20
        @battler_visible = true
      end
    when :collapse
      if $rgsslab["戦闘アニメーション"]
        visible_collapse
      else
        @effect_duration = 48
        @battler_visible = false
      end
    when :boss_collapse
      if $rgsslab["戦闘アニメーション"]
        visible_collapse2
      else
        @effect_duration = bitmap.height
        @battler_visible = false
      end
    when :instant_collapse
      if $rgsslab["戦闘アニメーション"]
        visible_collapse3
      else
        @effect_duration = 16
        @battler_visible = false
      end
    when :revive
      @effect_duration = 1
    when :hp_damage_display
      visible_hp_damage
      if $rgsslab["ダメージブリンク設定"]
        damage_blink_process
      else
        @effect_duration = 20
        @battler_visible = true
      end
    when :mp_damage_display
      visible_mp_damage
    end
    revert_to_normal
  end
  #--------------------------------------------------------------------------
  # ○ 新しいエフェクトの設定：ＨＰダメージ
  #--------------------------------------------------------------------------
  def visible_hp_damage
    if @battler.hp_damage_pop || @battler.append_string != ""
      if @battler.is_a?(Game_Enemy) || $rgsslab["アクターバトラー実装"]
        if @battler.append_string == ""
          damage(@battler.result.hp_damage, @battler.critical, "HP")
        else
          damage(@battler.append_string, false, "HP")
        end
        @battler.critical      = false
        @battler.hp_damage_pop = false
        @battler.append_string = ""
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 新しいエフェクトの設定：ＭＰダメージ
  #--------------------------------------------------------------------------
  def visible_mp_damage
    if @battler.mp_damage_pop || @battler.append_string != ""
      if @battler.is_a?(Game_Enemy) || $rgsslab["アクターバトラー実装"]
        if @battler.append_string == ""
          damage(@battler.result.mp_damage, @battler.critical, "MP")
        else
          damage(@battler.append_string, false, "MP")
        end
        @battler.critical      = false
        @battler.mp_damage_pop = false
        @battler.append_string = ""
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● エフェクトの更新 [再定義]
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when :whiten
        update_whiten
      when :blink
        update_blink
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :collapse
        update_collapse
      when :boss_collapse
        judge_boss_collapse if $rgsslab["戦闘アニメーション"]
        update_boss_collapse
      when :instant_collapse
        update_instant_collapse
      when :revive
        update_revive
      when :hp_damage_display
        update_blink
      end
      @effect_type = nil if @effect_duration == 0
    else
      @effect_type = nil if @effect_duration == 0
    end
  end
end

#==============================================================================
# ■ Window_BattleLog [class]
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ モジュールの設定
  #--------------------------------------------------------------------------
  RGSSLAB_007 = RGSSLAB::Damage_Display_Mounting
  #--------------------------------------------------------------------------
  # ● 失敗の表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      add_text(sprintf(Vocab::ActionFailure, target.name))
      failure_process(target) if $rgsslab["ダメージ表示実装"]
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：失敗文字列表示
  #     target : 対象者
  #--------------------------------------------------------------------------
  def failure_process(target)
    target.sprite_effect_type = :hp_damage_display
    target.append_string = RGSSLAB_007::RESIST
  end
  #--------------------------------------------------------------------------
  # ● クリティカルヒットの表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_critical(target, item)
    if target.result.critical
      text = target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy
      critical_process(target) if $rgsslab["ダメージ表示実装"]
      add_text(text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：クリティカル文字列表示
  #     target : 対象者
  #--------------------------------------------------------------------------
  def critical_process(target)
    target.critical = true
  end
  #--------------------------------------------------------------------------
  # ● ミスの表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_miss(target, item)
    if !item || item.physical?
      fmt = target.actor? ? Vocab::ActorNoHit : Vocab::EnemyNoHit
      Sound.play_miss
      target.miss = true if $rgsslab["戦闘アニメーション"]
    else
      fmt = Vocab::ActionFailure
    end
    miss_process(target) if $rgsslab["ダメージ表示実装"]
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：ミス文字列取得
  #     target : 対象者
  #--------------------------------------------------------------------------
  def miss_process(target)
    target.sprite_effect_type = :hp_damage_display
    target.append_string = RGSSLAB_007::MISS
  end
  #--------------------------------------------------------------------------
  # ● 回避の表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_evasion(target, item)
    if !item || item.physical?
      fmt = Vocab::Evasion
      Sound.play_evasion
    else
      fmt = Vocab::MagicEvasion
      Sound.play_magic_evasion
    end
    add_text(sprintf(fmt, target.name))
    target.evasion = true   if $rgsslab["戦闘アニメーション"]
    evasion_process(target) if $rgsslab["ダメージ表示実装"]
    wait
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：回避文字列取得
  #     target : 対象者
  #--------------------------------------------------------------------------
  def evasion_process(target)
    target.sprite_effect_type = :hp_damage_display
    target.append_string = RGSSLAB_007::EVASION
  end
  #--------------------------------------------------------------------------
  # ● HP ダメージ表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    if target.result.hp_damage > 0 && target.result.hp_drain == 0
      target.perform_damage_effect
      target.damage_effect = true if $rgsslab["戦闘アニメーション"]
    end
    Sound.play_recovery if target.result.hp_damage < 0
    add_text(target.result.hp_damage_text)
    hp_damage_pop_process(target) if $rgsslab["ダメージ表示実装"]
    wait
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：HPダメージ文字列取得
  #     target : 対象者
  #--------------------------------------------------------------------------
  def hp_damage_pop_process(target)
    target.sprite_effect_type = :hp_damage_display
    target.hp_damage_pop = true
  end
  #--------------------------------------------------------------------------
  # ● MP ダメージ表示 [再定義]
  #     target : 対象者
  #     item   : スキル／アイテム
  #--------------------------------------------------------------------------
  def display_mp_damage(target, item)
    return if target.dead? || target.result.mp_damage == 0
    Sound.play_recovery if target.result.mp_damage < 0
    add_text(target.result.mp_damage_text)
    mp_damage_pop_process(target) if $rgsslab["ダメージ表示実装"]
    wait
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ表示実装：MPダメージ文字列取得
  #     target : 対象者
  #--------------------------------------------------------------------------
  def mp_damage_pop_process(target)
    target.sprite_effect_type = :mp_damage_display
    target.mp_damage_pop = true
  end
end

end


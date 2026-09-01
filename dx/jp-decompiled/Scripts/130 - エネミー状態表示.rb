#==============================================================================
#  ■エネミーの状態を表示 for RGSS3 Ver0.90-α
#　□作成者 kure


# ※メモ欄の設定
#　●情報表示幅の設定
#　　エネミーのメモ欄に「<情報表示幅 150>」と書いて設定します。
#　　例の場合、HPバーの長さは150となります。
#　　未設定の場合は100となります。

#　●情報非表示
#　　エネミーのメモ欄に「<情報非表示>」と書いて設定します。
#　　設定されたエネミーはHPバーが表示されなくなります。




#==============================================================================
$kure_integrate_script = {} if $kure_integrate_script == nil
$kure_integrate_script[:InfoBar] = 100
p "エネミーの情報表示"
module KURE
  module InfoBar
    #初期設定(変更しない事)-----------------------------------------------------
    COLOR = []
    
    #表示色(IDによって割り当てが決まっています。)
      #バーの背景色(ID0)
      COLOR[0] = Color.new(32 ,32, 64, 255)
      
      #HPバーの色(ID1,ID2)
      COLOR[1] = Color.new(224 ,128, 64, 255)
      COLOR[2] = Color.new(240 ,192, 64, 255)
    
  end
end

#==============================================================================
# ■ RPG::Enemy(追加定義)
#==============================================================================
class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆ バーの表示幅の定義(追加定義)
  #--------------------------------------------------------------------------  
  def infobar_width
    @note.match(/<情報表示幅\s?(\d+)\s?>/)
    return 100 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ バーの表示幅の定義(追加定義)
  #--------------------------------------------------------------------------  
  def infobar_visible?
    return false if @note.include?("<情報非表示>")
    return true
  end
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ☆ バーの表示幅の定義(追加定義)
  #--------------------------------------------------------------------------  
  def infobar_width
    return enemy.infobar_width
  end
  #--------------------------------------------------------------------------
  # ☆ バーの表示幅の定義(追加定義)
  #--------------------------------------------------------------------------  
  def infobar_visible?
    return enemy.infobar_visible?
  end
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 敵キャラスプライトの作成(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_integrate_before_create_enemies create_enemies
  def create_enemies
    k_integrate_before_create_enemies
    @enemy_info_bar = $game_troop.members.reverse.collect do |enemy|
      Sprite_Infobar.new(@viewport1, enemy)
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラスプライトの更新(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_integrate_before_update_enemies update_enemies
  def update_enemies
    k_integrate_before_update_enemies
    @enemy_info_bar.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラスプライトの解放(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_integrate_before_dispose_enemies dispose_enemies
  def dispose_enemies
    k_integrate_before_dispose_enemies
    @enemy_info_bar.each {|sprite| sprite.dispose }
  end
end

#==============================================================================
# ■ Sprite_Infobar
#==============================================================================
class Sprite_Infobar < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @fill_w = nil
    @bitmap_data = Cache.battler(battler.battler_name, battler.battler_hue)
    @state = battler.states
    @icon_set = Cache.system("Iconset")
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if @battler && !@battler.hidden?
      @use_sprite = @battler.use_sprite?
      if @use_sprite
        update_bitmap
        update_origin
        update_position
      end
    else
      self.bitmap = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップの更新
  #--------------------------------------------------------------------------
  def update_bitmap
    fill_w = @battler.infobar_width * (@battler.hp.to_f / @battler.mhp)
    state = battler.states
    if @fill_w != fill_w or @state != state
      @fill_w = fill_w ; @state = state ; @zoom_cheaker = true
      
      width = @battler.infobar_width + 4
      
      new_bitmap = Bitmap.new(width, 35)
      @state.each_with_index {|state, index|
        next if 24 * (index + 1) > new_bitmap.width
        rect = Rect.new(state.icon_index % 16 * 24, state.icon_index / 16 * 24, 24, 24)
        new_bitmap.blt(24 * index, 0, @icon_set, rect, 255)
      }
      new_bitmap.fill_rect(0, 25, width, 10, color(0))
      new_bitmap.gradient_fill_rect(2, 27, fill_w, 6, color(1), color(2))
    
      self.bitmap = new_bitmap
      init_visibility
      self.opacity = 0 unless @battler.infobar_visible?
    end
  end
  #--------------------------------------------------------------------------
  # ● 可視状態の初期化
  #--------------------------------------------------------------------------
  def init_visibility
    @battler_visible = @battler.alive?
    self.opacity = 0 unless @battler_visible
  end
  #--------------------------------------------------------------------------
  # ● 文字色取得
  #--------------------------------------------------------------------------
  def color(num)
    return KURE::InfoBar::COLOR[num]
  end
  #--------------------------------------------------------------------------
  # ● 原点の更新
  #--------------------------------------------------------------------------
  def update_origin
    if bitmap
      self.ox = bitmap.width / 2
      self.oy = bitmap.height
    end
  end
  #--------------------------------------------------------------------------
  # ● 位置の更新
  #--------------------------------------------------------------------------
  def update_position
    self.x = @battler.screen_x
 #   self.y = @battler.screen_y - @bitmap_data.height - 5
    self.y = @battler.screen_y  + 5
    self.z = @battler.screen_z + 10
  end
end
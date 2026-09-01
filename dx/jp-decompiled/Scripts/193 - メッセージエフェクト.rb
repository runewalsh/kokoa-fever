=begin

 ▼ メッセージエフェクト ver. 1.3.4
 
 RPGツクールVXAce用スクリプト
 
 制作 : 木星ペンギン
 URL  : http://woodpenguin.blog.fc2.com/

------------------------------------------------------------------------------
 概要

 □ メッセージを表示する際、ちょっとした演出を行います。

------------------------------------------------------------------------------
 機能説明
 
 □ スキップ機能
  ・シフトキーを押しっぱなしにすることで、文章をメッセージを
  　スキップすることができます。
  ・これはイベントが始まってからシフトキーを押すと機能します。
  　押しながらイベントを開始しても、いきなりスキップすることはありません。
 
 □ エフェクトの種類
   0 : 文字が右にスライドしながら浮かび上がる演出を行います。
   1 : 文字が下にスライドしながら浮かび上がる演出を行います。
   2 : 文字が上にスライドしながら浮かび上がる演出を行います。
   3 : 文字が左にスライドしながら浮かび上がる演出を行います。
   4 : スライドせずに浮かび上がる演出を行います。
   5 : 文字が拡大していく演出が加えられます。
   6 : 文字が回転する演出が加えられます。
   
   上記以外 : カスタム (スクリプト自作用)
 
 □ 制御文字
   \sp[n]   : 文章の表示速度を秒間 n 文字に変更します。
              デフォルト値は 60 です。
              0 にすると瞬間表示となります。
   \a       : スキップ機能や、決定キーによる文章の瞬間表示を無効化します。
   \et[n]   : エフェクトの種類を n 番に変更します。
   \ed[n]   : エフェクトの時間を n フレームに変更します。
   \font[n] : フォントを番号 n に対応したものに変更します。
              0 でデフォルトのフォントに戻します。
   \df      : エフェクト、フォント、文字色、文字サイズ、文章表示の速度を
              デフォルトの値に戻します。
   \fo[n]   : n フレームかけて文章のフェードアウトを行います。
              入力待ちをせずに、次のイベントコマンドへと移行します。
   \set[n]  : 予め設定しておいた文字列 n 番に変換します。
   \save    : 現在のエフェクト、フォント、文字色、文字サイズ、文章表示の速度を
              記憶します。
   \load    : \save で記憶した状態に変更します。
 
=end
module WdTk
module MesEff
#//////////////////////////////////////////////////////////////////////////////
#
# 設定項目
#
#//////////////////////////////////////////////////////////////////////////////
  #--------------------------------------------------------------------------
  # ● スキップの有効状態
  #     false で無効化できます。
  #--------------------------------------------------------------------------
  SKIP = false
  
  #--------------------------------------------------------------------------
  # ● エフェクトの種類のデフォルト値
  #--------------------------------------------------------------------------
  TYPE = 4

  #--------------------------------------------------------------------------
  # ● エフェクトの時間のデフォルト値
  #     エフェクトの種類を 5 以上にする場合は、増やしたほうがいいです。
  #     (24 ～ 32 くらいがおすすめ)
  #--------------------------------------------------------------------------
  DURATION = 8
  
  #--------------------------------------------------------------------------
  # ● フォント
  #     配列にフォント名を入れ、制御文字で \font[n] と入れることで、
  #     n 番目のフォントに変更されます。
  #     0 はデフォルトに戻すのに使用します。
  #--------------------------------------------------------------------------
  FONTS = [nil, "ＭＳ ゴシック"]
  
  #--------------------------------------------------------------------------
  # ● 文字列のセット
  #     制御文字を入れる場合は、ダブルクォート(")ではなく
  #     シングルクォート(')を使ってください。
  #     例 : \set[0] で下記の文字列に置き換わります。
  #--------------------------------------------------------------------------
  ESC_SET = ['\a\sp[15]\ed[12]',     # 0
             ]
  
  #--------------------------------------------------------------------------
  # ● 文字スプライトへのエフェクト
  #  ※ スクリプトが組める人向け
  #     sprite   : 文字スプライト
  #     duration : エフェクトの残り時間
  #     max      : エフェクトの時間
  #     type     : エフェクトの種類
  #   スプライトの x, y, z, bitmap は変更しないでください。
  #--------------------------------------------------------------------------
  def self.effect(sprite, duration, max, type, pos)
    case type
    when 0,1,2,3,4
      sprite.opacity = 256 * (max - duration) / max
      origin = (2 + max * 2 / 3) * duration / max
      case type
      when 0; sprite.ox = origin
      when 1; sprite.oy = origin
      when 2; sprite.oy = -origin
      when 3; sprite.ox = -origin
      end
    when 5,6
      sprite.opacity = 256
      m = (max - max / 4) ** 2
      n = m - (max / 4) ** 2
      return if n == 0
      c = m - (duration - max / 4) ** 2
      sprite.zoom_x = sprite.zoom_y = 1.0 * c / n
      sprite.angle = 90.0 * (n - c) / n if type == 6
    else # カスタム用
      
    end
  end
end

#//////////////////////////////////////////////////////////////////////////////
#
# 以降、変更する必要なし
#
#//////////////////////////////////////////////////////////////////////////////

  @material ||= []
  @material << :MesEff
  def self.include?(sym)
    @material.include?(sym)
  end
  
end

#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias _wooden_meseff_initialize initialize
  def initialize
    @character_sprites = {}
    _wooden_meseff_initialize
  end
  #--------------------------------------------------------------------------
  # ● X 座標の設定
  #--------------------------------------------------------------------------
  def x=(x)
    super
    sx = self.x - x
    @character_sprites.each_key {|sprite| sprite.x += sx } if sx != 0
  end
  #--------------------------------------------------------------------------
  # ● Y 座標の設定
  #--------------------------------------------------------------------------
  def y=(y)
    super
    sy = self.y - y
    @character_sprites.each_key {|sprite| sprite.y += sy } if sy != 0
  end
  #--------------------------------------------------------------------------
  # ● Z 座標の設定
  #--------------------------------------------------------------------------
  def z=(z)
    super
    @character_sprites.each_key {|sprite| sprite.z = z }
  end
  #--------------------------------------------------------------------------
  # ○ 解放
  #--------------------------------------------------------------------------
  alias _wooden_meseff_dispose dispose
  def dispose
    _wooden_meseff_dispose
    dispose_character_sprites
  end
  #--------------------------------------------------------------------------
  # ● 文字スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_character_sprites
    @character_sprites.each_key do |sprite|
      sprite.bitmap.dispose if sprite.bitmap
      sprite.dispose
    end
    @character_sprites.clear
  end
  #--------------------------------------------------------------------------
  # ● フォント設定のリセット
  #--------------------------------------------------------------------------
  def reset_font_settings
    super
    contents.font.name = Font.default_name
  end
  #--------------------------------------------------------------------------
  # ○ フラグのクリア
  #--------------------------------------------------------------------------
  alias _wooden_meseff_clear_flags clear_flags
  def clear_flags
    _wooden_meseff_clear_flags
    clear_wooden_flags
    @auto = false
    @count = 0
  end
  #--------------------------------------------------------------------------
  # ● オリジナルフラグのクリア
  #--------------------------------------------------------------------------
  def clear_wooden_flags
    @effect_type = WdTk::MesEff::TYPE
    @effect_duration = WdTk::MesEff::DURATION
    @speed = 60
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  alias _wooden_meseff_update update
  def update
    _wooden_meseff_update
    update_character_sprites
    if $game_party.in_battle
      @message_skip &&= $game_troop.interpreter.running?
    else
      @message_skip &&= $game_map.interpreter.running?
    end
  end
  #--------------------------------------------------------------------------
  # ● 文字スプライトの更新
  #--------------------------------------------------------------------------
  def update_character_sprites
    @character_sprites.each do |sprite, params|
      next if params.empty?
      params[0] = (@show_fast ? 0 : params[0] - 1)
      if params[0] > 0
        WdTk::MesEff.effect(sprite, *params)
      else
        x = sprite.x - self.x - padding
        y = sprite.y - self.y - padding
        contents.blt(x, y, sprite.bitmap, sprite.src_rect)
        sprite.bitmap.clear
        sprite.visible = false
        params.clear
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 制御文字の事前変換
  #--------------------------------------------------------------------------
  def convert_escape_characters(*)
    result = super
    result.gsub!(/\eSET\[(\d+)\]/i) { ESC_SET[$1.to_i].to_s.gsub(/\\/, "\e") }
    result
  end
  #--------------------------------------------------------------------------
  # ○ ファイバーのメイン処理
  #--------------------------------------------------------------------------
  alias _wooden_meseff_fiber_main fiber_main
  def fiber_main
    _wooden_meseff_fiber_main
    dispose_character_sprites
  end
  #--------------------------------------------------------------------------
  # ○ 全テキストの処理
  #--------------------------------------------------------------------------
  alias _wooden_meseff_process_all_text process_all_text
  def process_all_text
    _wooden_meseff_process_all_text
    Fiber.yield until @show_fast || @character_sprites.all? {|*,p| p.empty? }
  end
  #--------------------------------------------------------------------------
  # ○ 早送りフラグの更新
  #--------------------------------------------------------------------------
  alias _wooden_meseff_update_show_fast update_show_fast
  def update_show_fast
    return if @auto
    _wooden_meseff_update_show_fast
    @message_skip ||= WdTk::MesEff::SKIP && Input.trigger?(:A)
    @show_fast ||= @message_skip && Input.press?(:A)
  end
  #--------------------------------------------------------------------------
  # ● ウェイト (文章表示中)
  #--------------------------------------------------------------------------
  def wait_message(duration)
    duration.times do
      update_show_fast
      return if @show_fast
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # ○ 一文字出力後のウェイト
  #--------------------------------------------------------------------------
  alias _wooden_meseff_wait_for_one_character wait_for_one_character
  def wait_for_one_character
    while @count < 60
      _wooden_meseff_wait_for_one_character
      @count += @speed
    end
    @count -= 60
  end
  #--------------------------------------------------------------------------
  # ○ 改ページ処理
  #--------------------------------------------------------------------------
  alias _wooden_meseff_new_page new_page
  def new_page(text, pos)
    self.contents_opacity = 255
    _wooden_meseff_new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # ☆ 通常文字の処理
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    return super if @show_fast || @speed == 0
    sprite = get_empty_sprite(pos)
    sprite.bitmap.font = contents.font.dup
    text_width = text_size(c).width
    sprite.bitmap.draw_text(0, 0, text_width * 2, pos[:height], c)
    pos[:x] += text_width
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ☆ 制御文字によるアイコン描画の処理
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    return super if @show_fast || @speed == 0
    sprite = get_empty_sprite(pos)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    sprite.bitmap.blt(0, 0, bitmap, rect)
    pos[:x] += 24
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 使用していない文字スプライトの取得
  #--------------------------------------------------------------------------
  def get_empty_sprite(pos)
    sprite, = @character_sprites.find {|*,p| p.empty? }
    if sprite
      sprite.visible = true
      if sprite.bitmap.height < pos[:height]
        sprite.bitmap.dispose
        sprite.bitmap = nil
      end
    else
      sprite = Sprite.new(viewport)
      sprite.z = self.z
    end
    sprite.bitmap ||= Bitmap.new(pos[:height], pos[:height])
    params = []
    params << @effect_duration << @effect_duration
    params << @effect_type
    params << pos.dup
    @character_sprites[sprite] = params
    sprite.x = self.x + self.padding + pos[:x]
    sprite.y = self.y + self.padding + pos[:y]
    sprite.ox = sprite.oy = 0
    sprite.angle = 0
    sprite.zoom_x = sprite.zoom_y = 1.0
    sprite.opacity = 0
    sprite
  end
  #--------------------------------------------------------------------------
  # ◯ 制御文字の処理
  #--------------------------------------------------------------------------
  alias _wooden_meseff_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when '.'
      wait_message(15) unless @show_fast
    when '|'
      wait_message(60) unless @show_fast
    when 'SP'
      @speed = obtain_escape_param(text)
    when 'A'
      @auto = true
    when 'ET'
      @effect_type = obtain_escape_param(text)
    when 'ED'
      @effect_duration = obtain_escape_param(text)
    when 'FONT'
      process_font(obtain_escape_param(text))
    when 'DF'
      process_default
    when 'FO'
      process_fadeout(obtain_escape_param(text))
    when 'SAVE'
      process_save
    when 'LOAD'
      process_load
    else
      _wooden_meseff_process_escape_character(code, text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● フォント変更の処理
  #--------------------------------------------------------------------------
  def process_font(index)
    contents.font.name = WdTk::MesEff::FONTS[index] || Font.default_name
  end
  #--------------------------------------------------------------------------
  # ● デフォルトの処理
  #--------------------------------------------------------------------------
  def process_default
    reset_font_settings
    clear_wooden_flags
    @line_show_fast = false
  end
  #--------------------------------------------------------------------------
  # ● フェードアウトの処理
  #--------------------------------------------------------------------------
  def process_fadeout(duration)
    duration.times do |i|
      self.contents_opacity = 256 * (duration - i - 1) / duration
      Fiber.yield
    end
    @pause_skip = true
  end
  #--------------------------------------------------------------------------
  # ● セーブの処理
  #--------------------------------------------------------------------------
  def process_save
    @save_font            = contents.font.dup
    @save_effect_type     = @effect_type
    @save_effect_duration = @effect_duration
    @save_speed           = @speed
    @save_line_show_fast  = @line_show_fast
  end
  #--------------------------------------------------------------------------
  # ● ロードの処理
  #--------------------------------------------------------------------------
  def process_load
    contents.font    = @save_font.dup        if @save_font
    @effect_type     = @save_effect_type     if @save_effect_type
    @effect_duration = @save_effect_duration if @save_effect_duration
    @speed           = @save_speed           if @save_speed
    @line_show_fast  = @save_line_show_fast  if @save_line_show_fast != nil
  end
  #--------------------------------------------------------------------------
  # ☆ 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    until Input.trigger?(:B) || Input.trigger?(:C) || (@message_skip && Input.press?(:A))
      Fiber.yield
      @message_skip ||= WdTk::MesEff::SKIP && Input.trigger?(:A)
    end
    Input.update
    self.pause = false
  end
end
=begin ************************************************************************
  ◆ ゲージレイアウト Ver.1.00
  ---------------------------------------------------------------------------
    HP MP TP などのゲージのレイアウトを枠付きに変更します。
=end # ************************************************************************

#-information------------------------------------------------------------------
$ziifee ||= {}
$ziifee[:GaugeLayout] = :TypeF
#------------------------------------------------------------------------------
#-memo-------------------------------------------------------------------------
#  [必要画像] 以下の画像を Graphics/System にインポートしてください。
#    ゲージ枠画像 ( ファイル名 : GaugeFrame )
#------------------------------------------------------------------------------

module GaugeLayoutF
  # ▼ 画像設定
  FrameName    = "GaugeFrame"     # ゲージ枠画像名
  GaugePadding = 2                # ゲージの余白
  EdgeWidth    = 12               # 両端処理部分の幅
end

#==============================================================================
# ■ Window_Base
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # ● ゲージに枠を付けるかどうか
  #--------------------------------------------------------------------------
  def ziif_gauge_frame_use?
    return true
  end
  #--------------------------------------------------------------------------
  # ● ゲージの描画
  #--------------------------------------------------------------------------
  alias :ziif_gauge_layout_f_draw_gauge :draw_gauge
  def draw_gauge(x, y, width, rate, color1, color2)
    if ziif_gauge_frame_use?
      draw_gauge_with_ziif_frame(x, y, width, rate, color1, color2)
    else
      ziif_gauge_layout_f_draw_gauge(x, y, width, rate, color1, color2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 枠付きゲージの描画
  #--------------------------------------------------------------------------
  def draw_gauge_with_ziif_frame(x, y, width, rate, color1, color2)
    bitmap = Cache.system(GaugeLayoutF::FrameName)
    # ゲージ描画部
    gp     = GaugeLayoutF::GaugePadding                 # ゲージ余白
    gx     = x + gp                                     # ゲージX座標
    gy     = y + line_height - bitmap.height + gp       # ゲージY座標
    gw     = width - gp * 2                             # ゲージ幅
    gh     = bitmap.height - gp * 2                     # ゲージ高さ
    fill_w = (gw * rate).to_i
    contents.fill_rect(gx, gy, gw, gh, gauge_back_color)
    contents.gradient_fill_rect(gx, gy, fill_w, gh, color1, color2)
    # フレーム描画部
    fy  = y + line_height - bitmap.height               # フレームY座標
    fh  = bitmap.height                                 # フレーム高さ
    lew = [GaugeLayoutF::EdgeWidth, width + 1 / 2].min  # 左端の幅
    rew = [GaugeLayoutF::EdgeWidth, width / 2].min      # 右端の幅
    contents.blt(x, fy, bitmap, Rect.new(0, 0, lew, fh))
    contents.blt(x+width-rew, fy, bitmap, Rect.new(bitmap.width-rew, 0, rew, fh))
    fx  = x + lew
    cw  = bitmap.width - lew - rew
    while fx < x + width - rew
      cw = [cw, x + width - rew - fx].min
      contents.blt(fx, fy, bitmap, Rect.new(lew, 0, cw, fh))
      fx += cw
    end
  end
end


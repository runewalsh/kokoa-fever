#==============================================================================
# ■ ショップの個数入力を快適化 v1.1            by 日車 徹  http://toruic.com/
#------------------------------------------------------------------------------
# 　1個のときにさらに減らすと最大個数に、またその逆を可能にします。
#==============================================================================

class Window_ShopNumber
  #--------------------------------------------------------------------------
  # ● 個数の更新【エイリアス】
  #--------------------------------------------------------------------------
  alias toruic_update_number update_number
  def update_number
    case @number
    when 1
      return @number = @max if Input.trigger?(:LEFT) || Input.trigger?(:DOWN)
    when @max
      return @number = 1 if Input.trigger?(:RIGHT) || Input.trigger?(:UP)
    end
    toruic_update_number
  end
end
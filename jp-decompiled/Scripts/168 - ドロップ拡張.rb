#============================================================================
# ドロップアイテム拡張 ver1.02
# 制作者：TOMO
#
# 敵が落とすアイテムの種類を増やします
# (KAMESOFT様のVX版のに近いです)
#
# ※使い方
# 敵キャラのメモ欄に「<ドロップ タイプ:ID 確率>」を書く
# 「タイプ」はアイテムならI、武器ならW、防具ならAです
# 「ID」は敵が落とすアイテムのIDです
# 「確率」は敵が落とす確率です
#
# 「確率」に指定した値をnとすると、敵が1/nの確率で落とします
# 「確率」に%を付けると、ドロップ率を百分率で指定できます
#============================================================================
module TOMO
  module Drop_Item
    DROP_ITEM = /<(?:DROP|ドロップ)\s*([IWA]):(\d+)\s+(\d+)([%％])?>/i
  end
end

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの配列作成 [再定義]
  #--------------------------------------------------------------------------
  alias tomo_dropplus_make_drop_items make_drop_items
  def make_drop_items
    
    r = tomo_dropplus_make_drop_items
    
    extension = defined?(r) == nil ? [] : r.dup
    enemy.note.each_line{|line|
      case line
      when TOMO::Drop_Item::DROP_ITEM
        case $1.upcase
        when "I"
          kind = 1
        when "W"
          kind = 2
        when "A"
          kind = 3
        else
          next
        end
        data_id = $2.to_i
        denominator = $3.to_i
        
        if kind > 0
          if $4 != nil && rand(100) < denominator * drop_item_rate
            extension.push(item_object(kind, data_id))
          elsif $4 == nil && rand * denominator < drop_item_rate
            extension.push(item_object(kind, data_id))
          end
        end
      end
    }
    return extension
  end
end

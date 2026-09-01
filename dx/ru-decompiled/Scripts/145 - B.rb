#==============================================================================
#  ■併用化ベーススクリプトＢ for RGSS3 Ver5.05-EX14
#　□作成者 kure
#==============================================================================

$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:base_B] = 503
p "併用化ベーススクリプトB"

#==============================================================================
# ■ Kernel(追加定義)
#==============================================================================
module Kernel
  #--------------------------------------------------------------------------
  # ☆ 配列振り分け操作(指定IDに値を加算)(追加定義)
  #--------------------------------------------------------------------------  
  def arr_id_value_flatten(arr)
    result_arr = Array.new
    for i in 0..arr.size - 1
      if i % 2 == 0 && arr[i] && arr[i+1]
        result_arr[arr[i]] ||= 0
        result_arr[arr[i]] += arr[i+1]
      end
    end
    return result_arr
  end
  #--------------------------------------------------------------------------
  # ☆ 配列振り分け操作(指定IDに値を出力)(追加定義)
  #--------------------------------------------------------------------------  
  def arr_id_value_push(arr)
    result_arr = Array.new
    for i in 0..arr.size - 1
      if i % 2 == 0 && arr[i] && arr[i+1]
        result_arr[arr[i]] ||= []
        result_arr[arr[i]].push(arr[i+1])
      end
    end
    return result_arr
  end
  #--------------------------------------------------------------------------
  # ☆ 配列振り分け操作(指定個数毎にパッケージ)(追加定義)
  #--------------------------------------------------------------------------  
  def arr_id_value_pack(arr, num)
    result_arr = Array.new
    first = 0

    while first < arr.size - 1 do
      last = first + num - 1
      result_arr.push(arr[first..last])
      first = last + 1
    end
    return result_arr
  end
  #--------------------------------------------------------------------------
  # ☆ 配列振り分け操作(数値にスライス)(追加定義)
  #--------------------------------------------------------------------------  
  def arr_num_slice(arr)
    result_arr = Array.new
    unless arr == [] and arr.empty?
      arr.flatten!
      arr.each do |value|
        value.scan(/\d+/).each { |num| result_arr.push(num.to_i)}
      end
    end
    return result_arr
  end
  #--------------------------------------------------------------------------
  # ☆ アクター追加能力呼び出し(追加定義)
  #--------------------------------------------------------------------------  
  def call_add_feature(id, note_data)
    
    battler_add = Array.new
    cheak_note = ""
    cheak_note = note_data if note_data
    
    case id
    when 0
      #スティール成功率(割合出力)
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<スティール成功率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 1
      #オートリザレクション(配列最大値出力)
      read_arr = [0,0,0,0]
      while cheak_note do
        cheak_note.match(/<オートリザレクション\s?(\d+)%\s?,\s?(\d+)%\s?,\s?(\d+)\s?,\s?(\d+)>/)
        if $1 && $2 && $3 && $4
          value = [[read_arr[0],$1.to_i].max,[read_arr[1],$2.to_i].max,[read_arr[2],$3.to_i].max,[read_arr[3],$4.to_i].max]
          read_arr = value
        end
        cheak_note = $'
      end
      battler_add = read_arr

    when 2
      #踏みとどまり(最大効果出力)
      read_arr = [150,0]
      while cheak_note do
        cheak_note.match(/<踏みとどまり\s?(\d+)%\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr[0] = $1.to_i if $1.to_i < read_arr[0]
          read_arr[1] = $2.to_i if $2.to_i > read_arr[1]
        end
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 3
      #回復反転(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<回復反転\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f / 100
    
    when 4
      #オートステート(配列出力)
      list = cheak_note.scan(/<オートステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
    
    when 5
      #メタルボディ(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<メタルボディ\s?(\d+)\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 6
      #連続使用(配列出力)
      list = cheak_note.scan(/<連続発動\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      multi_use = arr_num_slice(list)
      battler_add = arr_id_value_flatten(multi_use)
    
    when 7
      #即死反転(true,false出力)
      battler_add = false
      battler_add = true if cheak_note.include?("<即死反転>")
    
    when 8
      #仲間想い(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<仲間想い\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
    
    when 9
      #弱気(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<弱気\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
    
    when 10
      #防御壁(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<防御壁展開\s?(\d+)\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 11
      #無効化障壁(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<無効化障壁\s?(\d+)\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 12
      #TP消費率(割合出力)
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<TP消費率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      battler_add = read_arr
    
    when 13
      #スキル変化(配列出力)
      list = cheak_note.scan(/<スキル変化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      change_skill = arr_num_slice(list)
      battler_add = arr_id_value_push(change_skill)
      
    when 14
      #武器タイプスキル強化(配列出力)
      list = cheak_note.scan(/<武器スキル倍率強化\s?(\d+-\d+-\d+(?:\s?*,\s?*\d+-\d+-\d+)*)>/)
      gain_skill = arr_num_slice(list)
      
      value = Array.new
      for list in 0..gain_skill.size - 1
        if list % 3 == 0
          if gain_skill[list] && gain_skill[list + 1] && gain_skill[list + 2]
            value[gain_skill[list]] = [] unless value[gain_skill[list]]
            value[gain_skill[list]][gain_skill[list + 1]] = 0 unless value[gain_skill[list]][gain_skill[list + 1]]
            value[gain_skill[list]][gain_skill[list + 1]] += gain_skill[list + 2]
          end
        end
      end
      battler_add = value
      
    when 15
      #行動変化(配列出力)
      list = cheak_note.scan(/<行動変化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
      change_skill = arr_num_slice(list)
      battler_add = arr_id_value_pack(change_skill, 2)      
      
    when 16
      #最終反撃(配列出力)
      list = cheak_note.scan(/<最終反撃\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 17
      #反撃スキル(配列出力)
      list = cheak_note.scan(/<反撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 18
      #戦闘終了後自動回復(配列最大値出力)
      auto_heel = [0,0]
      while cheak_note do
        cheak_note.match(/<戦闘後回復\s?(\d+)\s?,\s?(\d+)\s?>/)
        if $1 && $2
          auto_heel= [[auto_heel[0],$1.to_i].max,[auto_heel[1],$2.to_i].max]
        end
        cheak_note = $'
      end
      battler_add = auto_heel

    when 19
      #HPタイプ消費率(配列出力)
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<HPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost[$1.to_i] = 1 unless tp_cost[$1.to_i]
          tp_cost[$1.to_i] *= ($2.to_f / 100)
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 20
      #MPタイプ消費率(配列出力)
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<MPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost[$1.to_i] = 1 unless tp_cost[$1.to_i]
          tp_cost[$1.to_i] *= ($2.to_f / 100)
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 21
      #TPタイプ消費率(配列出力)
      tp_cost = Array.new
      while cheak_note do
        cheak_note.match(/<TPタイプ消費率\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          tp_cost[$1.to_i] = 1 unless tp_cost[$1.to_i]
          tp_cost[$1.to_i] *= ($2.to_f / 100)
        end
        cheak_note = $'
      end
      battler_add = tp_cost
      
    when 22
      #HP消費率(割合出力)
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<HP消費率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 23
      #オーバーソウル(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<オーバーソウル\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 24
      #反撃強化(割合加算出力)
      read_value = 0
      while cheak_note do
        cheak_note.match(/<反撃強化\s?(\d+)%\s?>/)
        read_value += ($1.to_f / 100) if $1
        cheak_note = $'
      end
      battler_add = read_value
      
    when 25
      #HP減少時強化能力(最大値配列出力)
      read_arr = [0,0]
      while cheak_note do
        cheak_note.match(/<HP減少時強化\s?(\d+)\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr= [[read_arr[0],$1.to_i].max,[read_arr[1],$2.to_i].max]
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 26
      #ダメージMP変換(最小値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<ダメージMP変換\s?(\d+)%\s?>/)
        if $1
          read_arr = $1.to_i if read_arr == 0
          read_arr = [read_arr,$1.to_i].min if read_arr != 0
        end
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100

      
    when 27
      #ダメージG変換(最小値出力)        
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<ダメージゴールド変換\s?(\d+)%\s?>/)
        if $1
          read_arr = $1.to_i if read_arr == 0
          read_arr = [read_arr,$1.to_i].min if read_arr != 0
        end
        cheak_note = $'
      end
      battler_add = read_arr.to_f / 100
    
    when 28
      #必中反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<必中反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 29
      #魔法反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<魔法反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 30
      #追撃ステート(配列出力)
      list = cheak_note.scan(/<追撃対象ステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
    
    when 31
      #耐久値減少率(最小値出力)
      read_arr = 100
      while cheak_note do
        cheak_note.match(/<耐久値減少率\s?(\d+)%\s?>/)
        if $1
          read_arr = [read_arr,$1.to_i].min
        end
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 32
      #ディレイステート(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ディレイステート\s?(\d+)\s?,\s?(\d+)\s?>/)
        if $1 && $2
          read_arr.push([$1.to_i, $2.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 33
      #トリガー発動ステート(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<トリガーステート\s?([HMT])\s?,\s?(\d+)\s?,\s?(\d+)%\s?,\s?(\d+)\s?>/)
        if $1 && $2 && $3 && $4
          case $1
          when "H"
            tri = 1
          when "M"
            tri = 2
          when "T"
            tri = 3
          end
          read_arr.push([tri, $2.to_i ,$3.to_i, $4.to_i])
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 34
      #自爆耐性(true,false出力)
      battler_add = false
      battler_add = true if cheak_note.include?("<自爆耐性>")
      
    when 35
      #ダメージMP吸収(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<ダメージMP吸収\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 36
      #ダメージG吸収(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<ダメージゴールド回収\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 37
      #戦闘開始時自動発動能力(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<戦闘開始時発動\s?([NF])\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1,$2.to_i, $3.to_i]) if $1 && $2 && $3
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 38
      #ターン開始時自動発動能力(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ターン開始時発動\s?([NF])\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1,$2.to_i, $3.to_i]) if $1 && $2 && $3
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 39
      #ターン終了時自動発動能力(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ターン終了時発動\s?([NF])\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1,$2.to_i, $3.to_i]) if $1 && $2 && $3
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 40
      #拡張反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<拡張反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 41
      #拡張魔法反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<拡張魔法反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100

    when 42
      #拡張必中反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<拡張必中反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 43
      #常時オートステート(配列出力)
      list = cheak_note.scan(/<常時オートステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 44
      #最大TP増減(配列出力)
      read_arr = [0,100]
      gain_cheak_note = cheak_note.clone
      decrease_cheak_note = cheak_note.clone
      #最大TP増加
      while gain_cheak_note do
        gain_cheak_note.match(/<最大TP増加\s?(\d+)([%])?>/)
        if $2 && $1
          read_arr[1] += $1.to_i 
        elsif $1
          read_arr[0] += $1.to_i 
        end
        gain_cheak_note = $'
      end
      
      #最大TP減少
      while decrease_cheak_note do
        decrease_cheak_note.match(/<最大TP減少\s?(\d+)([%])?>/)
        if $2 && $1
          read_arr[1] -= $1.to_i 
        elsif $1
          read_arr[0] -= $1.to_i 
        end
        decrease_cheak_note = $'
      end
      battler_add = read_arr
      
    when 45
      #オートガード(最大値出力)
      read_arr = [0,0]
      while cheak_note do
        cheak_note.match(/<オートガード\s?(\d+)%\s?,\s?(\d+)%\s?>/)
        if $1 && $2
          read_arr[0] = $1.to_i if $1.to_i > read_arr[0]
          read_arr[1] = $2.to_i if $2.to_i > read_arr[1]
        end
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 46
      #必中無効化(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<必中無効化\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 47
      #物理無効化(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<物理無効化\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr

    when 48
      #魔法無効化(最大値出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<魔法無効化\s?(\d+)%\s?>/)
        read_arr = [read_arr,$1.to_i].max if $1
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 49
      #戦闘終了後全体自動回復(加算出力)
      auto_heel = [0,0]
      while cheak_note do
        cheak_note.match(/<戦闘後全体回復\s?(\d+)\s?,\s?(\d+)\s?>/)
        if $1 && $2
          auto_heel[0] += $1.to_i
          auto_heel[1] += $2.to_i
        end
        cheak_note = $'
      end
      battler_add = auto_heel
      
    when 50
      #カウンターステート(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<カウンターステート\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1.to_i, $2.to_i]) if $1 && $2
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 51
      #反撃スキル(配列出力)
      list = cheak_note.scan(/<物理反撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 52
      #反撃スキル(配列出力)
      list = cheak_note.scan(/<魔法反撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 53
      #反撃スキル(配列出力)
      list = cheak_note.scan(/<必中反撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
      
    when 54
      #属性場展開能力(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<属性場展開\s?(\d+)\s?,\s?(\d+)\s?>/)
        read_arr.push([$1.to_i, $2.to_i]) if $1 && $2
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 55
      #反撃無効化能力(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<反撃無効化\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 56
      #回避反撃判定(加算出力)
      read_arr = 0
      while cheak_note do
        cheak_note.match(/<回避反撃\s?(\d+)%\s?>/)
        read_arr += $1.to_i if $1
        cheak_note = $'
      end
      battler_add = read_arr.to_f/100
      
    when 57
      #ステート転換(配列出力)
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<ステート転換\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1.to_i, $2.to_i, $3.to_i]) if $1 && $2 && $3
        cheak_note = $'
      end
      battler_add = read_arr
      
    when 58
      #追撃スキル(配列出力)
      list = cheak_note.scan(/<追撃スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      battler_add = arr_num_slice(list)
    
    when 59
      #行動反応追撃
      read_arr = Array.new
      while cheak_note do
        cheak_note.match(/<行動反応追撃\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
        read_arr.push([$1.to_i, $2.to_i, $3.to_i, $4.to_i]) if $1 && $2 && $3 && $4
        cheak_note = $'
      end
      battler_add = read_arr
    end

    return battler_add
  end
  #--------------------------------------------------------------------------
  # ☆ ブースター能力呼び出し(追加定義)
  #--------------------------------------------------------------------------  
  def call_multi_booster(id, note_data)
    cheak_note = ""
    cheak_note = note_data if note_data
    
    case id
    when 0
      list = cheak_note.scan(/<属性強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 1
      list = cheak_note.scan(/<属性吸収\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 2
      list = cheak_note.scan(/<武器強化物理\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 3
      list = cheak_note.scan(/<武器強化魔法\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 4 
      list = cheak_note.scan(/<武器強化必中\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 5
      list = cheak_note.scan(/<通常攻撃強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 6
      list = cheak_note.scan(/<ステート割合強化タイプ\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 7
      list = cheak_note.scan(/<ステート固定強化タイプ\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 8
      list = cheak_note.scan(/<ステート指定割合強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 9
      list = cheak_note.scan(/<ステート指定固定強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    when 10
      list = cheak_note.scan(/<スキルタイプ強化\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    end
    return arr_num_slice(list)
    
  end
  #--------------------------------------------------------------------------
  # ☆ パーティー能力呼び出し(追加定義)
  #--------------------------------------------------------------------------  
  def call_party_add_feature(id, note_data)
    party_add = Array.new
    cheak_note = ""
    cheak_note = note_data if note_data
    
    case id
    when 0
      #獲得金額倍率設定(割合出力)
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<獲得金額倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr
      
    when 1
      #アイテムドロップ率の設定
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<獲得アイテム倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr      
      
    when 2
      #エンカウント率の設定
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<エンカウント倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr 

    when 3
      #獲得経験値倍率の設定
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<獲得経験値倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr
      
    when 4
      #獲得職業経験値倍率の設定
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<獲得職業経験値倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr
      
    when 5
      #獲得職業経験値倍率の設定
      read_arr = 1
      while cheak_note do
        cheak_note.match(/<獲得装備経験値倍率\s?(\d+)%\s?>/)
        read_arr *= ($1.to_f / 100) if $1
        cheak_note = $'
      end
      party_add = read_arr
      
    end
    return party_add
  end
  #--------------------------------------------------------------------------
  # ☆ 特徴の文字配列の呼び出し(追加定義)
  #--------------------------------------------------------------------------  
  def call_add_feature_txt(item)
    draw_txt = Array.new
    
    #書きだし
    #攻撃属性
    draw_list = item.features_set_data(31)
    draw_list.each do |id|
      draw_txt.push($data_system.elements[id] + "属性 ")
    end
    
    roop = $data_system.elements.size - 1
    #属性耐性
    for id in 1..roop
      draw_list = item.features_pi_data(11, id)
      next if draw_list == 1
      draw_s = 100 - (draw_list * 100).to_i
      draw_txt.push($data_system.elements[id] + "耐性" + draw_s.to_s + "% ")
    end
    
    #弱体化耐性
    roop = 7
    for id in 0..roop
      draw_list = item.features_pi_data(12, id)
      next if draw_list == 1
      draw_s = 100 - (draw_list * 100).to_i
      draw_txt.push("耐" + Vocab::param(id) + "減少" + draw_s.to_s + "% ")
    end
    
    #ステート耐性
    roop = $data_states.size - 1
    for id in 0..roop
      draw_list = item.features_pi_data(13, id)
      next if draw_list == 1
      draw_s = 100 - (draw_list * 100).to_i
      draw_txt.push($data_states[id].name + "耐性" + draw_s.to_s + "% ")
    end
    
    #ステート無効化
    draw_list = item.features_set_data(14)
    draw_list.each do |id|
      draw_txt.push($data_states[id].name + "無効 ")
    end
    
    #通常能力
    roop = 7
    for id in 0..roop
      draw_list = item.features_pi_data(21, id)
      next if draw_list == 1
      draw_s = (draw_list * 100).to_i - 100
      draw_s = "+" + draw_s.to_s if draw_s > 0
      draw_txt.push(Vocab::param(id) + draw_s.to_s + "% ") 
    end
    
    #特殊能力
    for id in 0..9
      case id
      when 0
        draw_str = "命中率"
      when 1
        draw_str = "回避率"
      when 2
        draw_str = "会心率"
      when 3
        draw_str = "会心回避"             
      when 4
        draw_str = "魔法回避"
      when 5
        draw_str = "魔法反射"
      when 6
        draw_str = "反撃率"
      when 7
        draw_str = "毎ﾀｰﾝHP回復"
      when 8
        draw_str = "毎ﾀｰﾝMP回復"
      when 9
        draw_str = "毎ﾀｰﾝTP回復"
      end
      draw_list = item.features_sum_data(22, id)
      next if draw_list == 0
      draw_s = (draw_list * 100).to_i
      draw_s = "+" + draw_s.to_s if draw_s > 0
      draw_txt.push(draw_str + draw_s.to_s + "% ") 
    end
    
    #特殊能力値
    for id in 0..9
      case id
      when 0
        draw_str = "狙われ率" 
      when 1
        draw_str = "防御効果"
      when 2
        draw_str = "回復効果"
      when 3
        draw_str = "薬知識"
      when 4
        draw_str = "MP消費率"
      when 5
        draw_str = "TP上昇率"
      when 6
        draw_str = "被通常Dmg"
      when 7
        draw_str = "被特殊Dmg"
      when 8
        draw_str = "床Dmg"
      when 9
        draw_str = "経験値"
      end
      draw_list = item.features_pi_data(23, id)
      next if draw_list == 1
      draw_s = (draw_list * 100).to_i - 100
      draw_s = "+" + draw_s.to_s if draw_s > 0
      draw_txt.push(draw_str + draw_s.to_s + "% ") 
    end    
    
    #攻撃時ステート判定
    roop = $data_states.size - 1
    for id in 0..roop
      draw_list = item.features_sum_data(32, id)
      next if draw_list == 0
      draw_s = (draw_list * 100).to_i
      draw_txt.push($data_states[id].name + "追加" + draw_s.to_s + "% ")
    end
    
    #攻撃速度
    draw_list = item.features_sum_all_data(33)
    unless draw_list == 0
      draw_txt.push("攻撃速度増加") if draw_list > 0
      draw_txt.push("攻撃速度減少") if draw_list < 0
    end
    
    #攻撃追加
    draw_list = item.features_sum_all_data(34)
    unless draw_list == 0
      draw_txt.push("攻撃追加" + draw_list.to_s + "回" ) if draw_list > 0
      draw_txt.push("攻撃減少" + draw_list.abs.to_s + "回" ) if draw_list < 0
    end
    
    #スキルタイプ追加
    draw_list = item.features_set_data(41)
    draw_list.each do |id|
      draw_txt.push($data_system.skill_types[id] + "使用可 ")
    end    
    
    #スキルタイプ削除
    draw_list = item.features_set_data(42)
    draw_list.each do |id|
      draw_txt.push($data_system.skill_types[id] + "使用不可 ")
    end  
    
    #スキル追加
    draw_list = item.features_set_data(43)
    draw_list.each do |id|
      draw_txt.push($data_skills[id].name + "使用可 ")
    end 
    
    #スキル削除
    draw_list = item.features_set_data(44)
    draw_list.each do |id|
      draw_txt.push($data_skills[id].name + "使用不可 ")
    end
    
    #装備固定
    draw_list = item.features_set_data(53)
    draw_list.each do |id|
      draw_txt.push($data_system.terms.etypes[id] + "固定 ")
    end
    
    #装備封印
    draw_list = item.features_set_data(54)
    draw_list.each do |id|
      draw_txt.push($data_system.terms.etypes[id] + "封印 ")
    end
    
    #追加行動
    draw_list = item.features_data(61).collect{|ft| ft.value * 100}
    draw_list.each do |id|
      draw_txt.push("追加行動" + id.to_s + "% ")
    end
    
    #特殊フラグ
    for i in 0..3
      case i
      when 0
        value = "自動戦闘"
      when 1
        value = "自動防御"
      when 2
        value = "自動献身"
      when 3
        value = "TP持越"
      end
      draw_txt.push(value) if item.features_data(62).any?{|ft| ft.data_id == i }
    end
   
    #パーティー能力
    for i in 0..5
      case i
      when 0
        value = "敵出現率↓"
      when 1
        value = "敵出現率0"
      when 2
        value = "被先制無効"
      when 3
        value = "先制率上昇"
      when 4
        value = "獲得金額2倍"              
      when 5
        value = "Drop率2倍" 
      end
      draw_txt.push(value) if item.features_data(64).any?{|ft| ft.data_id == i }
    end
    
    
    #追加特徴項目
    for i in 0..57
      data = item.battler_add_ability(i)
      case i
      when 0
        draw_txt.push("スティール率" + data.to_s + "倍") if data != 1
      when 1
        draw_txt.push("自動復活(" + data[2].to_s + ")" + data[1].to_s + "%") if data[1] != 0
      when 2
        draw_txt.push("踏止(" + data[0].to_s + ")" + data[1].to_s + "%") if data != [150,0]
      when 3
        draw_txt.push("回復反転" + ((data*100).to_i).to_s + "%") if data != 0
      when 4,43
        data.each do |id|
          draw_txt.push($data_states[id].name + "発動")
        end
      when 5
        draw_txt.push("メタルボディ(" + data.to_s + ")") if data != 0
      when 6
        for type in 1..data.size - 1
          next if data[type] == nil or data[type] == 0
          draw_txt.push($data_system.skill_types[type] + data[type].to_s + "回発動")
        end
      when 7
        draw_txt.push("即死反転") if data
      when 8
        draw_txt.push("仲間思い" + ((data*100).to_i).to_s + "%") if data != 0
      when 9
        draw_txt.push("弱気" + ((data*100).to_i).to_s + "%") if data != 0
      when 10
        draw_txt.push("防御壁展開(" + data.to_s + ")") if data != 0
      when 11
        draw_txt.push("無効化障壁(" + data.to_s + ")") if data != 0
      when 12
        draw_txt.push("TP消費率" + ((data*100).to_i).to_s + "%") if data != 1
      when 13
        draw_txt.push("スキル変化") if data != []
      when 14
        for wtype in 1..data.size - 1
          next unless data[wtype]
          for stype in 0..data[wtype].size - 1
            next if data[wtype][stype] == nil or data[wtype][stype] == 0
            draw_txt.push($data_system.skill_types[stype] + "強化(" + $data_system.weapon_types[wtype] +")"+ data[wtype][stype].to_s + "%")
          end
        end
      when 15
        draw_txt.push("行動変化") if data != []
      when 16
        draw_txt.push("最終反撃") if data != []
      when 17
        draw_txt.push("反撃変化") if data != []
      when 18
        draw_txt.push("戦後回復("+ data[0].to_s + "%," + data[1].to_s+ "%)" ) if data != [0,0]
      when 19,20,21
        value = "HP消費" if i == 19
        value = "MP消費" if i == 20
        value = "TP消費" if i == 21
        for type in 1..data.size - 1
          next if data[type] == nil or data[type] == 1
          draw_txt.push(value + ((data[type]*100).to_i).to_s + "%(" + $data_system.skill_types[type] +")")
        end
      when 22
        draw_txt.push("HP消費率" + ((data*100).to_i).to_s + "%") if data != 1
      when 23
        draw_txt.push("憑依強化" + ((data*100).to_i).to_s + "%") if data != 0
      when 24
        draw_txt.push("反撃強化" + ((data*100).to_i).to_s + "%") if data != 0
      when 25
        draw_txt.push( "逆境強化(" + data[0].to_s + ")" + data[1].to_s + "%" ) if data != [0,0]
      when 26
        draw_txt.push("衝撃MP変換" + ((data*100).to_i).to_s + "%") if data != 0
      when 27
        draw_txt.push("衝撃G変換" + ((data*100).to_i).to_s + "%") if data != 0
      when 28
        draw_txt.push("必中反撃" + ((data*100).to_i).to_s + "%") if data != 0
      when 29
        draw_txt.push("魔法反撃" + ((data*100).to_i).to_s + "%") if data != 0
      when 30
        data.each do |id|
          draw_txt.push($data_states[id].name + "追撃")
        end
      when 31
        draw_txt.push("耐久減少率" + ((data*100).to_i).to_s + "%") if data != 1
      when 32
        draw_txt.push("遅延ステート") if data != []
      when 33
        draw_txt.push("条件ステート") if data != []
      when 34
        draw_txt.push("自爆耐性") if data
      when 35
        draw_txt.push("衝撃MP吸収" + ((data*100).to_i).to_s + "%") if data != 0
      when 36
        draw_txt.push("衝撃G回収" + ((data*100).to_i).to_s + "%") if data != 0
      when 37
        draw_txt.push("開始時発動") if data != []
      when 38
        draw_txt.push("ターン開始時発動") if data != []
      when 39
        draw_txt.push("ターン終了時発動") if data != []
      when 40
        draw_txt.push("拡張反撃" + ((data*100).to_i).to_s + "%") if data != 0
      when 41
        draw_txt.push("拡張魔法反撃" + ((data*100).to_i).to_s + "%") if data != 0
      when 42
        draw_txt.push("拡張必中反撃" + ((data*100).to_i).to_s + "%") if data != 0
      when 43
        data.each do |id|
          draw_txt.push($data_states[id].name + "発動")
        end
      when 44
        next if data == [0,100]
        if data[0] != 0
          gain = ""
          gain = "+" if data[0] > 0
          draw_txt.push("最大TP" + gain + data[0].to_s)
        end
        if data[1] != 100
          gain = ""
          gain = "+" if data[1] > 0
          draw_txt.push("最大TP" + gain + (data[1] - 100).to_s + "%")
        end
      when 45
        draw_txt.push("自動防御("+ data[1].to_s + "%," + data[0].to_s+ "%)" ) if data != [0,0]
      when 46
        draw_txt.push("必中無効" + data.to_s + "%") if data != 0
      when 47
        draw_txt.push("物理無効" + data.to_s + "%") if data != 0
      when 48
        draw_txt.push("魔法無効" + data.to_s + "%") if data != 0
      when 49
        draw_txt.push("戦後全体回復("+ data[0].to_s + "%," + data[1].to_s+ "%)" ) if data != [0,0]
      when 50
        next if data == []
        data.each do |obj|
          draw_txt.push("反撃付与(" + $data_states[obj[0]].name + obj[1].to_s + "%")
        end
      when 51
        draw_txt.push("物理反撃変化") if data != []
      when 52
        draw_txt.push("魔法反撃変化") if data != []
      when 53
        draw_txt.push("必中反撃変化") if data != []
      when 54
        next if data == []
        data.each do |obj|
          draw_txt.push("属性場展開(" + $data_system.elements[obj[0]] + ")" )
        end
      when 55
        draw_txt.push("反撃無効" + data.to_s + "%") if data != 0
      when 56
        draw_txt.push("回避反撃" + data.to_s + "%") if data != 0
      when 57
        draw_txt.push("ステート転換") if data != []
      end
    end
    
    #追加特徴項目
    for i in 0..10
      data = arr_id_value_flatten(item.multi_booster(i))
      next if data == []
      case i
      when 0,1
        value = "強化" if i == 0
        value = "吸収" if i == 1
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push($data_system.elements[id] + value + data[id].to_s + "%")
        end
      when 2,3,4,5
        value = "物理強化" if i == 2
        value = "魔法強化" if i == 3
        value = "必中強化" if i == 4
        value = "通常強化" if i == 5
        for id in 0..data.size - 1
          next if data[id] == nil
          next if id == 0 && i < 5
          weapon = $data_system.weapon_types[id]
          weapon = "素手" if id == 0 && i == 5
          draw_txt.push(value + "(" + weapon + ")" + data[id].to_s + "%")
        end
      when 6
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push("付与率(" + $data_system.skill_types[id] + ")" + (data[id].to_f / 100).to_s + "倍")
        end
      when 7
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push("付与率(" + $data_system.skill_types[id] + ")+" + data[id].to_s + "%")
        end
      when 8
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push($data_states[id].name + "付与率" + (data[id].to_f / 100).to_s + "倍")
        end
      when 9
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push($data_states[id].name + "付与率+" + data[id].to_s + "%")
        end
      when 10
        for id in 1..data.size - 1
          next if data[id] == nil or data[id] == 0
          draw_txt.push($data_system.skill_types[id] + "強化" + data[id].to_s + "%")
        end
      end
    end
    
    for i in 0..5
      data = item.party_add_ability(i)
      next if data == 1
      case i
      when 0
        draw_txt.push("獲得金額" + data.to_s + "倍")
      when 1
        draw_txt.push("Drop率" + data.to_s + "倍")
      when 2
        draw_txt.push("遭遇率" + data.to_s + "倍")
      when 3
        draw_txt.push("獲得EXP" + data.to_s + "倍")
      when 4
        draw_txt.push("獲得JEXP" + data.to_s + "倍") 
      when 5
      draw_txt.push("獲得装備EXP" + data.to_s + "倍")
      end
    end
    
    #装備品個別管理用描画処理
    if $kure_base_script[:SortOut]
      draw_txt.push("耐久値減少無効") if item.protect_durable
      draw_txt = [] if KURE::SortOut::BROKEN_FEATURE == 1 && item.broken?
    end

    return draw_txt
  end
  #--------------------------------------------------------------------------
  # ☆ 特徴の文字配列の呼び出し(追加定義)
  #--------------------------------------------------------------------------  
  def call_effect_txt(item)
    draw_txt = Array.new    
    #書きだし
    item.effects.each do |effect|
      case effect.code
      #HP回復,MP回復,TP回復
      when 11,12,13
        case effect.code
        when 11
          txt = "HP "
        when 12
          txt = "MP "
        when 13
          txt = "TP "
        end
        if effect.value1 != 0
          txt2 = "% 回復" if effect.value1 > 0
          txt2 = "% 減少" if effect.value1 < 0 
          draw_txt.push(txt + (((effect.value1*100).abs).to_i).to_s + txt2)
        end
        if effect.value2 != 0
          txt2 = " 回復" if effect.value2 > 0
          txt2 = " 減少" if effect.value2 < 0 
          draw_txt.push(txt + ((effect.value2.abs).to_i).to_s + txt2)
        end
      when 21,22
        case effect.code
        when 21
          txt = " 付与 "
        when 22
          txt = " 解除 "
        end
        draw_txt.push($data_states[effect.data_id].name + txt + ((effect.value1*100).to_i).to_s + "%")
      when 31,32,33,34
        case effect.code
        when 31
          txt = " 強化付与 "
          txt2 = (effect.value1.to_i).to_s + "ターン"
        when 32
          txt = " 弱体付与 "
          txt2 = (effect.value1.to_i).to_s + "ターン"
        when 33
          txt = " 強化解除"
          txt2 = ""
        when 34
          txt = " 弱体解除"
          txt2 = ""
        end
        draw_txt.push(Vocab::param(effect.data_id) + txt + txt2)
      when 41
        draw_txt.push("逃走効果")
      when 42
        draw_txt.push(Vocab::param(effect.data_id) + " 成長(" + (effect.value1.to_i).to_s + ")" )
      when 43
        draw_txt.push($data_skills[effect.data_id].name + " 習得")
      when 44
        draw_txt.push("特殊効果")
      when 45
        draw_txt.push("スティール効果")
      when 46
        draw_txt.push("スキルポイントリセット")        
      when 47
        draw_txt.push("耐久値変化")
      when 48
        draw_txt.push("アイテム獲得")
      when 49
        draw_txt.push("ステート解除")
      when 50
        draw_txt.push("ランダムアイテム入手")
      end
    end
    
    return draw_txt
  end
end


#==============================================================================
# ●■ RPG::BaseItem(追加定義集積)
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 特徴オブジェクトの配列取得（特徴コードを限定）(追加定義)
  #--------------------------------------------------------------------------
  def features_data(code)
    features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # ● 特徴オブジェクトの配列取得（特徴コードとデータ ID を限定）(追加定義)
  #--------------------------------------------------------------------------
  def features_with_id_data(code, id)
    features.select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # ● 特徴値の総乗計算(追加定義)
  #--------------------------------------------------------------------------
  def features_pi_data(code, id)
    features_with_id_data(code, id).inject(1.0) {|r, ft| r *= ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 特徴値の総和計算（データ ID を指定）(追加定義)
  #--------------------------------------------------------------------------
  def features_sum_data(code, id)
    features_with_id_data(code, id).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 特徴値の総和計算（データ ID は非指定）(追加定義)
  #--------------------------------------------------------------------------
  def features_sum_all_data(code)
    features_data(code).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 特徴の集合和計算(追加定義)
  #--------------------------------------------------------------------------
  def features_set_data(code)
    features_data(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # ●■ 記憶数増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_max_memorize  
    cheak_note = @note
    gain_max_memorize = 0
    
    while cheak_note do
      cheak_note.match(/<最大記憶数増加\s?(\d+)\s?>/)
      gain_max_memorize += $1.to_i if $1
      cheak_note = $'
    end
    return gain_max_memorize 
  end
  #--------------------------------------------------------------------------
  # ●■ 記憶容量増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_memorize
    cheak_note = @note
    gain_memorize = 0
    
    while cheak_note do
      cheak_note.match(/<最大記憶容量増加\s?(\d+)\s?>/)
      gain_memorize += $1.to_i if $1
      cheak_note = $'
    end
    return gain_memorize 
  end
  #--------------------------------------------------------------------------
  # ◆ 経験済み職業クラスIDの定義(追加定義)[共用]
  #--------------------------------------------------------------------------  
  def exp_jobchange_class
    list = @note.scan(/<経験済職業\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ◆ 転職可能アクターIDの定義(追加定義)[共用]
  #--------------------------------------------------------------------------  
  def need_jobchange_actor
    list = @note.scan(/<転職許可\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ◆ リスト表示の定義(追加定義)[共用]
  #--------------------------------------------------------------------------  
  def view_class_name
    return false if @note.include?("<非公開表示>")
    return true
  end
  #--------------------------------------------------------------------------
  # ◆ 短縮職業名(追加定義)[共用]
  #--------------------------------------------------------------------------  
  def short_class_name
    @note.match(/<短縮名称\s?(.+?)\s?>/)
    return @name unless $1
    return $1
  end
  #--------------------------------------------------------------------------
  # ■ 記憶容量の定義(追加定義)
  #--------------------------------------------------------------------------  
  def memorize_capacity
    @note.match(/<記憶容量\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ■ スキルの表示、非表示定義(追加定義)
  #--------------------------------------------------------------------------  
  def view_skill_mode
    return 0 if @note.include?("<常時非表示>")
    return 1 if @note.include?("<戦闘中非表示>")
    return 2 if @note.include?("<メニュー非表示>")
    return 3
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応武器IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_w
    list = @note.scan(/<パッシブ能力武器\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応防具IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_a
    list = @note.scan(/<パッシブ能力防具\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルの対応職業IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_skill_id_c
    list = @note.scan(/<パッシブ能力職業\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ メモライズ数の職業補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def max_memorize_revise
    list = @note.scan(/<メモライズ数補正\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ 追加メモライズ数を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_memorize_var
    list = @note.scan(/<追加メモライズ数保存変数\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ メモライズ容量の職業補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def memorize_capacity_revise
    list = @note.scan(/<メモライズ容量補正\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ 追加メモライズ容量を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_memorize_cap_var
    list = @note.scan(/<追加メモライズ容量保存変数\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ 初期メモライズ定義(追加定義)
  #--------------------------------------------------------------------------  
  def first_memorize
    list = @note.scan(/<初期メモライズ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ■ 共存不可メモライズ定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_jumble_memorize
    list = @note.scan(/<共存不可メモライズ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ◆ オートメモライズ不要の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_auto_memorize
    return @note.include?("<自動メモライズ不要>")
  end
  #--------------------------------------------------------------------------
  # ☆ アクターの基本能力値を取得する職業IDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def base_param_index
    @note.match(/<基本能力値\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ 職業別TP基本値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def base_tp
    @note.match(/<TP基本値\s?(\d+)\s?>/)
    return 50 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ 職業別TP上限値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def upper_limit_tp
    @note.match(/<TP上限値\s?(\d+)\s?>/)
    return 9999 unless $1
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ アクター別TPのLv補正値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def tp_level_revise
    @note.match(/<TPLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value   
  end
  #--------------------------------------------------------------------------
  # ☆ 通常攻撃に使用するスキルIDの定義(追加定義)
  #--------------------------------------------------------------------------  
  def normal_attack_id
    list = @note.scan(/<通常攻撃\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘開始時のTP値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def battle_start_tp
    @note.match(/<開始時TP\s?(\d+)%\s?>/)
    return -1 unless $1
    return 100 if $1.to_i > 100
    return $1.to_i   
  end
  #--------------------------------------------------------------------------
  # ☆ アクター追加能力(追加定義)
  #--------------------------------------------------------------------------  
  def battler_add_ability(id)
    return call_add_feature(id, @note)
  end
  #--------------------------------------------------------------------------
  # ☆ ブースター能力(追加定義)
  #--------------------------------------------------------------------------  
  def multi_booster(id)
    return call_multi_booster(id, @note)    
  end
  #--------------------------------------------------------------------------
  # ☆ パーティー追加能力(追加定義)
  #--------------------------------------------------------------------------  
  def party_add_ability(id)
    return call_party_add_feature(id, @note)
  end
  #--------------------------------------------------------------------------
  # ☆ 複数属性の定義(追加定義)
  #--------------------------------------------------------------------------  
  def attack_elements_list
    list = @note.scan(/<攻撃属性\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 属性反映の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reflect_elements
    return @note.include?("<攻撃属性スキル反映>")
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def get_ability_point
    list = @note.scan(/<習得AP\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ 必要アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_ability_point
    @note.match(/<必要AP\s?(\d+)\s?>/)
    return 1000 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ★ 追加スキルポイント数を保存している変数の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_max_skillpoint_var
    @note.match(/<追加ポイント数保存変数\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i 
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのアクター補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_revise
    @note.match(/<スキルポイント補正\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i  
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのLv補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_level_revise
    @note.match(/<スキルポイントLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value  
  end
  #--------------------------------------------------------------------------
  # ★ スキルポイントのJobLv補正定義(追加定義)
  #--------------------------------------------------------------------------  
  def skillpoint_joblevel_revise
    @note.match(/<スキルポイントJobLv補正\s?([1-9]\d*|0)(\.\d+)?>/)
    return 0 unless $1
    value = $1.to_f
    value += $2.to_f if $2
    return value  
  end
  #--------------------------------------------------------------------------
  # ☆ 死亡時残留ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_delete_state
    return @note.include?("<死亡時残留>")
  end
  #--------------------------------------------------------------------------
  # ☆ 全回復残留ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_delete_state_healing
    return @note.include?("<全回復時残留>")
  end
  #--------------------------------------------------------------------------
  # ☆ ドロップ率増加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def gain_drop_rate
    @note.match(/<ドロップ変化\s?(\d+)%\s?>/)
    return 100 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◆ 破損状態の取得
  #--------------------------------------------------------------------------
  def broken?
    false
  end
end

#==============================================================================
# ■ RPG::UsableItem(追加定義)
#==============================================================================
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆ 獲得アイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def get_item_list
    list = @note.scan(/<獲得アイテム\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    return arr_id_value_pack(arr_num_slice(list), 2)
  end
  #--------------------------------------------------------------------------
  # ☆ トラップ設置の定義(追加定義)
  #--------------------------------------------------------------------------  
  def trap_setting
    result = nil
    @note.match(/<トラップ設置\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?,\s?([PMCA])\s?>/)
    result = [$1.to_i,$2.to_i,$3.to_i,$4.to_i,$5]  if $1 && $2 && $3 && $4 && $5
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ トラップ発動対象外スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ignore_trap
    return @note.include?("<トラップ発動対象外>")
  end
  #--------------------------------------------------------------------------
  # ☆ 耐久値ダメージ、回復の定義(追加定義)
  #--------------------------------------------------------------------------  
  def durable_damage
    durable_damage = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<耐久値ダメージ\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
      if $1 && $2 && $3
        durable_damage.push([$1.to_i, $2.to_i, $3.to_i])
      end
      cheak_note = $'
    end
    
    cheak_note = @note if @note
    while cheak_note do
      cheak_note.match(/<耐久値回復\s?(\d+)\s?,\s?(\d+)\s?>/)
      if $1 && $2
        durable_damage.push([$1.to_i, -1 * ($2.to_i), 100])
      end
      cheak_note = $'
    end
    
    return durable_damage    
  end
  #--------------------------------------------------------------------------
  # ☆ 発動前コモンの定義(追加定義)
  #--------------------------------------------------------------------------  
  def pre_common
    @note.match(/<発動前コモン\s?(\d+)\s?>/)
    return nil unless $1
    return $1.to_i     
  end
  #--------------------------------------------------------------------------
  # ☆ 連続回数の定義(再定義)
  #--------------------------------------------------------------------------  
  def repeats
    @note.match(/<連続回数\s?(\d+)\s?>/)
    return @repeats unless $1
    return $1.to_i     
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果の定義(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias effects effects
  def effects
    add_effects_before + @effects + add_effects_after
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果の追加定義[基本より前の処理](追加定義)
  #--------------------------------------------------------------------------  
  def add_effects_before
    add_effect = Array.new
    cheak_note = @note
    
    #ステート初期化のメモ欄設定適用
    cheak_note.match(/<ステート初期化\s?(\d+)%\s?>/)
    add_effect.push(RPG::UsableItem::Effect.new(49, $1.to_i)) if $1

    return add_effect
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果の追加定義[基本より後の処理](追加定義)
  #--------------------------------------------------------------------------  
  def add_effects_after
    add_effect = Array.new
    cheak_note = @note
    
    #盗むのメモ欄設定適用
    cheak_note.match(/<スティール付与\s?(\d+)\s?>/)   
    add_effect.push(RPG::UsableItem::Effect.new(45, $1.to_i)) if $1
    
    #スキルポイントリセットのメモ欄設定適用
    add_effect.push(RPG::UsableItem::Effect.new(46)) if cheak_note.include?("<スキルポイントリセット>")   
    
    #装備破壊のメモ欄設定適用
    cheak_note.match(/<耐久値ダメージ\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
    add_effect.push(RPG::UsableItem::Effect.new(47)) if $1 && $2 && $3
    
    #耐久力回復のメモ欄設定適用
    cheak_note.match(/<耐久値回復\s?(\d+)\s?,\s?(\d+)\s?>/)
    add_effect.push(RPG::UsableItem::Effect.new(47)) if $1 && $2
    
    #アイテム獲得のメモ欄設定適用
    cheak_note.match(/<獲得アイテム\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    add_effect.push(RPG::UsableItem::Effect.new(48, 0, get_item_list)) if $1
    
    #トラップ設置のメモ欄設定適用
    cheak_note.match(/<トラップ設置\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?,\s?([PMCA])\s?>/)
    add_effect.push(RPG::UsableItem::Effect.new(51)) if $1 && $2 && $3 && $4 && $5
    
    return add_effect
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転無視スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ignore_reverse_heel
    return @note.include?("<回復反転無視>")
  end
  #--------------------------------------------------------------------------
  # ☆ 連続発動スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def multi_skill_effect
    list = @note.scan(/<連続発動スキル\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 連続アニメーションの定義(追加定義)
  #--------------------------------------------------------------------------  
  def multi_anim_effect
    list = @note.scan(/<連続アニメーション\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 仲間想い補正の定義(追加定義)
  #--------------------------------------------------------------------------  
  def companion_revise
    @note.match(/<仲間想い\s?(\d+)%\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ 武器倍率の定義(追加定義)
  #--------------------------------------------------------------------------  
  def weapon_d_rate
    cheak_note = ""
    cheak_note = @note if @note

    list = cheak_note.scan(/<武器倍率\s?(\d+-\d+(?:\s?*,\s?*\d+-\d+)*)>/)
    save_list = Array.new
    weapon_rate = Array.new
    
    return weapon_rate if list == [] and list.empty? 
    $1.scan(/\d+/).each { |num| save_list.push(num.to_i)}
    
    return arr_id_value_flatten(save_list)
  end
  #--------------------------------------------------------------------------
  # ☆ エラー回避(追加定義)
  #--------------------------------------------------------------------------  
  def is_skill?
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 通常攻撃スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def normal_attack_skill?
    return @note.include?("<通常攻撃判定>")
  end
  #--------------------------------------------------------------------------
  # ☆ ステート反撃対象の定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_counter_state?
    return @note.include?("<ステート反撃対象>")
  end
  #--------------------------------------------------------------------------
  # ☆ 初期化ステートタイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def clear_state_type
    list = @note.scan(/<初期化ステートタイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 初期化対象外ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_clear_state_type
    list = @note.scan(/<ステート初期化対象外\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ 発動後ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def after_add_state
    list = @note.scan(/<発動後付与ステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 連続回数の定義(再定義)
  #--------------------------------------------------------------------------  
  def chain_action
    @note.match(/<連鎖発動\s?(\d+)\s?,\s?(\d+)%\s?>/)
    return [$1.to_i,$2.to_i] if $1 && $2 
    return nil
  end
  #--------------------------------------------------------------------------
  # ☆ 連携発動の定義(再定義)
  #--------------------------------------------------------------------------  
  def team_action
    @note.match(/<連携発動\s?(\d+)\s?,\s?(\d+)\s?>/)
    return [$1.to_i,$2.to_i] if $1 && $2 
    return nil
  end
end

#==============================================================================
# ■ RPG::Skill(再定義)
#==============================================================================
class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ☆ 必要武器タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def required_add_wtype_id
    list = @note.scan(/<必要武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 要求装備タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_etype_id
    list = @note.scan(/<要求装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 要求武器タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_wtype_id_all
    list = @note.scan(/<要求武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)  
  end
  #--------------------------------------------------------------------------
  # ☆ 二刀流スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def need_two_weapon
    return @note.include?("<二刀流要求>")
  end
  #--------------------------------------------------------------------------
  # ☆ 二刀流同一ID要求の定義(追加定義)
  #--------------------------------------------------------------------------  
  def request_same_weapon_id
    return @note.include?("<同一タイプ二刀流専用>")
  end
  #--------------------------------------------------------------------------
  # ☆ エラー回避(追加定義)
  #--------------------------------------------------------------------------  
  def is_skill?
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 発動条件の定義(追加定義)
  #--------------------------------------------------------------------------  
  def passive_condition_list(id)    
    case id
    when 0
      #発動要求武器
      list = @note.scan(/<発動要求武器タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      return arr_num_slice(list)
    when 1
      #発動要求防具
      list = @note.scan(/<発動要求装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
      return arr_num_slice(list)
    end
    return []
  end
  #--------------------------------------------------------------------------
  # ☆ 耐久値減少の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reduce_durable
    reduce_durable = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<耐久値消費\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)%\s?>/)
      if $1 && $2 && $3
        reduce_durable.push([$1.to_i, $2.to_i, $3.to_i])
      end
      cheak_note = $'
    end
    return reduce_durable    
  end
  #--------------------------------------------------------------------------
  # ☆ 習得不可の定義(追加定義)
  #--------------------------------------------------------------------------  
  def not_learn_list
    list = @note.scan(/<習得不可\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
end

#==============================================================================
# ■ RPG::EquipItem(再定義)
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 装備タイプの定義(再定義)
  #--------------------------------------------------------------------------  
  def etype_id
    @note.match(/<装備タイプ\s?(\d+)\s?>/)
    return @etype_id unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ● 拡張装備タイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_etype_id
    list = @note.scan(/<拡張装備タイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ● 装備可能アクターの定義(追加定義)
  #--------------------------------------------------------------------------  
  def actor_equip_limit
    list = @note.scan(/<装備可能アクター\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプの定義(再定義)
  #--------------------------------------------------------------------------  
  def etype_id=(etype_id)
    @etype_id = etype_id
  end
end

#==============================================================================
# ■ RPG::Actor(追加定義)
#==============================================================================
class RPG::Actor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ◇ 初期ジョブレベルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def initial_joblevel    
    @note.match(/<初期職業レベル\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i
  end
end

#==============================================================================
# ■ RPG::Enemy(追加定義)
#==============================================================================
class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の定義(追加定義)
  #--------------------------------------------------------------------------  
  def equip_exp    
    @note.match(/<装備Exp\s?(\d+)\s?>/)
    return @exp unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def ability_exp 
    @note.match(/<獲得AP\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def status_exp 
    @note.match(/<ステータスポイント\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # § スキルポイントの定義(追加定義)
  #--------------------------------------------------------------------------  
  def skill_exp
    @note.match(/<スキルポイント\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ レベルの定義(追加定義)
  #--------------------------------------------------------------------------
  def level
    @note.match(/<レベル\s?(\d+)\s?>/)
    return 1 unless $1
    return $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ドロップアイテムの定義(再定義)
  #--------------------------------------------------------------------------  
  def drop_items
    add_drop_items unless @add_drop_items
    return @drop_items + @add_drop_items if @add_drop_items
    return @drop_items
  end
  #--------------------------------------------------------------------------
  # ☆ 追加ドロップアイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def add_drop_items
    @add_drop_items = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<追加ドロップ\s?([IWA])\s?,\s?(\d+)\s?,\s?(\d+)>/)
      if $1 && $2 && $3
        new_drop = RPG::Enemy::DropItem.new
        case $1.upcase
        when "I"
          new_drop.kind = 1
        when "W"
          new_drop.kind = 2
        when "A"
          new_drop.kind = 3
        end
        new_drop.data_id = $2.to_i
        new_drop.denominator = $3.to_f
        
        @add_drop_items.push(new_drop)
      end
      cheak_note = $'
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 盗めるアイテムの定義(追加定義)
  #--------------------------------------------------------------------------  
  def steal_list
    steal_list = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    while cheak_note do
      cheak_note.match(/<スティールリスト\s?(\d+)\s?,\s?([IWA])\s?,\s?(\d+)\s?,\s?(\d+)>/)
      if $1 && $2 && $3 && $4
        case $2.upcase
        when "I"
          kind = 1
        when "W"
          kind = 2
        when "A"
          kind = 3
        end
        data_id = $3.to_i
        denominator = $4.to_f
        
        steal_list[$1.to_i] ||= []
        steal_list[$1.to_i].push([kind, data_id, denominator])
      end
      cheak_note = $'
    end
    
    return steal_list
  end 
end

#==============================================================================
# ■ RPG::State(追加定義)
#==============================================================================
class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆身代わり対象設定の定義(追加定義)
  #--------------------------------------------------------------------------  
  def adv_substitute_t
    return @note.include?("<身代わり対象設定>")
  end
  #--------------------------------------------------------------------------
  # ☆重複許容の定義(追加定義)
  #--------------------------------------------------------------------------  
  def multi_addable
    result = nil
    @note.match(/<重複許容\s?([AEB])\s?,\s?(\d+)\s?>/)
      if $1 && $2
        result = []
        case $1.upcase
        when "A"
          result[0] = 0
        when "E"
          result[0] = 1
        when "B"
          result[0] = 2
        end
        result[1] = $2.to_i
      end
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ ステートタイプの定義(追加定義)
  #--------------------------------------------------------------------------  
  def state_type
    list = @note.scan(/<ステートタイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ ステート解除時付与の定義(追加定義)
  #--------------------------------------------------------------------------  
  def next_state
    list = @note.scan(/<解除時ステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ 前提ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def basic_state
    list = @note.scan(/<前提ステート\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ 相殺ステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def offset_state_type
    list = @note.scan(/<相殺ステートタイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆ 上書きステートの定義(追加定義)
  #--------------------------------------------------------------------------  
  def overwrite_state_type
    list = @note.scan(/<上書きステートタイプ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    return arr_num_slice(list)
  end
  #--------------------------------------------------------------------------
  # ☆上書きの定義(追加定義)(追加定義)
  #--------------------------------------------------------------------------  
  def overwrite_mode
    return 1 if @note.include?("<効果延長>")
    return 2 if @note.include?("<効果上書き不可>")
    return 0
  end
  #--------------------------------------------------------------------------
  # ☆反射先の定義(追加定義)(未実装)
  #--------------------------------------------------------------------------  
  def mirror_mode
    return 1 if @note.include?("<敵単体反射>")
    return 2 if @note.include?("<敵全体反射>")
    return 3 if @note.include?("<味方単体反射>")
    return 4 if @note.include?("<味方全体反射>")
    return 0
  end
end
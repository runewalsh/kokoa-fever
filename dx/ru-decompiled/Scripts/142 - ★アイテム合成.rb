#==============================================================================
# ■ RGSS3 アイテム合成 ver 1.04
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVX Aceの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================


#SceneManager.call(Scene_ItemSynthesis)	合成画面の呼び出し
#
#・レシピの追加・レシピの削除
#　レシピを追加することで、該当レシピのアイテムが合成できるようになります。
#　ゲーム開始時は、何もレシピがありません。
#　イベントコマンドのスクリプトで以下のように記述します。
#i_recipe_switch_on(n)	n番のアイテムのレシピを追加
#i_recipe_switch_off(n)	n番のアイテムのレシピを削除
#w_recipe_switch_on(n)	n番の武器のレシピを追加
#w_recipe_switch_off(n)	n番の武器のレシピを削除
#a_recipe_switch_on(n)	n番の防具のレシピを追加
#a_recipe_switch_off(n)	n番の防具のレシピを削除
#recipe_all_switch_on	全てのレシピを追加
#recipe_all_switch_off	全てのレシピを削除
#・レシピ追加済みの判定
#　レシピが追加済みかどうか判定したい場合はイベントコマンドのスクリプトで以下のように記述して下さい。
#　指定スイッチがONの時は追加済みです。条件分岐等で使用したい場合にご使用下さい。
#$game_switches[m] = i_recipe_switch_on?(n)	m番のスイッチにn番のアイテムのレシピ追加済み判定を代入
#$game_switches[m] = w_recipe_switch_on?(n)	m番のスイッチにn番の武器のレシピ追加済み判定を代入
#$game_switches[m] = a_recipe_switch_on?(n)	m番のスイッチにn番の防具のレシピ追加済み判定を代入

#--------------------------------------------------------------------------
# ★ 初期設定。
#    合成レシピ等の設定
#--------------------------------------------------------------------------
module WD_itemsynthesis_ini
  
  Cost_view =  false #費用(Ｇ)の表示(合成の費用が全て0Gの場合はfalseを推奨)
  
  Category_i = true #カテゴリウィンドウに「アイテム」の項目を表示
  Category_w = true #カテゴリウィンドウに「武器」の項目を表示
  Category_a = true #カテゴリウィンドウに「防具」の項目を表示
  Category_k = true #カテゴリウィンドウに「大事なもの」の項目を表示
  
  I_recipe = [] #この行は削除しないこと
  W_recipe = [] #この行は削除しないこと
  A_recipe = [] #この行は削除しないこと
  
  #以下、合成レシピ。
  #例: I_recipe[3]  = [100, ["I",1,1], ["W",2,1], ["A",2,2], ["A",3,1]]
  #と記載した場合、ID3のアイテムの合成必要は、100Ｇ。
  #必要な素材は、ID1のアイテム1個、ID2の武器1個、ID2の防具2個、ID3の防具1個
  #となる。
  
  #アイテムの合成レシピ
  #I_recipe[2]  = [10,  ["I",1,2]]
  #I_recipe[3]  = [100, ["I",1,1], ["I",2,1]]
  #I_recipe[17] = [500, ["I",1,10]]
  
   
  I_recipe[25]  = [0, ["I",87,1], ["I",60,1]]
  I_recipe[104]  = [0, ["I",101,1], ["I",103,1]]
  I_recipe[105]  = [0, ["I",102,1], ["I",103,1]]
  I_recipe[460]  = [0, ["I",130,1], ["I",80,3]]
  I_recipe[489]  = [0, ["I",93,1]]
  I_recipe[490]  = [0, ["I",80,1], ["I",87,1]]
  I_recipe[491]  = [0, ["I",93,1]]
  I_recipe[492]  = [0, ["I",80,1], ["I",87,1], ["I",99,1]]
  I_recipe[493]  = [0, ["I",93,1], ["I",66,1]]
  I_recipe[496]  = [0, ["I",104,1]]
  I_recipe[497]  = [0, ["I",80,5],["I",87,3],["I",99,3]]
  I_recipe[600]  = [0, ["I",80,1], ["I",92,1]]
  I_recipe[601]  = [0, ["I",600,1], ["I",66,1]]
  I_recipe[602]  = [0, ["I",600,1], ["I",103,1]]
  I_recipe[951]  = [0, ["I",104,1]]
  I_recipe[952]  = [0, ["I",105,1]]
 


  #武器の合成レシピ
  #W_recipe[3]  = [50,   ["W",1,1], ["W",2,1]]
  #W_recipe[6]  = [600,  ["W",3,1], ["I",17,0]]
  
  W_recipe[4]  = [0,   ["I",81,1],["I",87,1]]
  W_recipe[13]  = [0,   ["I",93,1], ["I",80,1],["I",87,1]]
  W_recipe[14]  = [0,   ["I",93,1], ["I",80,1],["I",87,1]]
  W_recipe[15]  = [0,   ["I",93,1], ["I",80,1],["I",87,1]]
  W_recipe[21]  = [0,   ["I",101,3]]
  W_recipe[22]  = [0,   ["I",101,3]]
  W_recipe[23]  = [0,   ["I",101,3]]
  W_recipe[28]  = [0,   ["I",103,3]]
  W_recipe[29]  = [0,   ["I",103,3]]
  W_recipe[30]  = [0,   ["I",103,3]]
  W_recipe[35]  = [0,   ["I",104,3]]
  W_recipe[36]  = [0,   ["I",104,3]]
  W_recipe[37]  = [0,   ["I",104,3]]
  
  W_recipe[43]  = [0,   ["I",105,3]]
  W_recipe[44]  = [0,   ["I",105,3]]
  W_recipe[45]  = [0,   ["I",105,3]]
  
  #防具の合成レシピ  
  #A_recipe[2]  = [40,   ["A",1,2]]
  #A_recipe[5]  = [400,  ["A",2,1], ["W",2,2], ["I",17,0]]

  A_recipe[110]  = [0,   ["I",81,2],["I",87,1]]
  A_recipe[111]  = [0,   ["I",80,2]]
  A_recipe[112]  = [0,   ["I",80,1]]
  A_recipe[113]  = [0,   ["I",80,3]]
  A_recipe[114]  = [0,   ["I",81,1],["I",80,1]]
  A_recipe[115]  = [0,   ["I",81,2],["I",87,1]]
  A_recipe[116]  = [0,   ["I",81,1],["I",80,1]]
  
  A_recipe[122]  = [0,   ["A",111,1],["I",93,1]]
  A_recipe[123]  = [0,   ["A",112,1],["I",93,1]]
  A_recipe[124]  = [0,   ["A",113,1],["I",93,2]]
  A_recipe[125]  = [0,   ["A",114,1],["I",93,3]]
  A_recipe[126]  = [0,   ["A",114,1],["I",93,3],["I",87,3]]
  A_recipe[127]  = [0,   ["A",115,1],["I",93,3]]
  A_recipe[128]  = [0,   ["A",110,1],["I",93,2]]
  A_recipe[129]  = [0,   ["A",110,1],["I",93,4]]
  A_recipe[132]  = [0,   ["I",93,1],["I",80,2]]
  A_recipe[133]  = [0,   ["I",93,3],["I",80,2]]
  
  A_recipe[134]  = [0,   ["I",101,2],["A",111,1]]
  A_recipe[135]  = [0,   ["I",101,1]]
  A_recipe[136]  = [0,   ["I",101,3],["A",113,1]]
  A_recipe[137]  = [0,   ["I",101,2],["A",114,1]]
  A_recipe[138]  = [0,   ["I",101,5]]
  A_recipe[139]  = [0,   ["I",101,5]]
  A_recipe[140]  = [0,   ["I",101,3],["A",110,1]]
  A_recipe[141]  = [0,   ["I",101,5],["A",110,1]]
  A_recipe[142]  = [0,   ["I",101,10]]
  A_recipe[143]  = [0,   ["I",101,2]]
  A_recipe[144]  = [0,   ["I",101,2]]
  A_recipe[145]  = [0,   ["I",101,3]]
  A_recipe[146]  = [0,   ["I",101,2]]
  A_recipe[147]  = [0,   ["I",101,3],["I",80,2]]
  A_recipe[148]  = [0,   ["I",101,1],["I",80,2]]
  A_recipe[149]  = [0,   ["I",101,3],["I",127,3]]
  A_recipe[150]  = [0,   ["I",101,3],["I",80,3]]
  A_recipe[154]  = [0,   ["I",101,10]]
  
  A_recipe[160]  = [0,   ["I",103,1]]
  A_recipe[161]  = [0,   ["I",103,2]]
  A_recipe[163]  = [0,   ["I",103,5]]
  A_recipe[164]  = [0,   ["I",103,5]]
  A_recipe[165]  = [0,   ["I",103,3]]
  A_recipe[166]  = [0,   ["I",103,5]]
  A_recipe[167]  = [0,   ["I",103,10]]
  A_recipe[168]  = [0,   ["I",103,10]]
  A_recipe[169]  = [0,   ["I",103,2]]
  A_recipe[170]  = [0,   ["I",103,3]]
  A_recipe[171]  = [0,   ["I",103,2]]
  A_recipe[172]  = [0,   ["I",103,3],["I",127,3]]
  A_recipe[173]  = [0,   ["I",103,3]]
  A_recipe[174]  = [0,   ["I",103,3],["I",80,2]]
  A_recipe[175]  = [0,   ["I",103,1],["I",80,2]]
  
  A_recipe[184]  = [0,   ["I",104,2]]
  A_recipe[185]  = [0,   ["I",104,3]]
  A_recipe[186]  = [0,   ["I",104,5]]
  A_recipe[187]  = [0,   ["I",104,3]]
  A_recipe[188]  = [0,   ["I",104,5]]
  A_recipe[189]  = [0,   ["I",104,10]]
  A_recipe[190]  = [0,   ["I",104,3],["I",127,3]]
  A_recipe[191]  = [0,   ["I",104,3]]
  
  A_recipe[194]  = [0,   ["I",300,3],["I",330,1]]
  A_recipe[195]  = [0,   ["I",300,3],["I",80,2],["I",87,2],["I",104,5]]
  A_recipe[196]  = [0,   ["I",104,15],["I",330,1],["I",87,2]]
  
  A_recipe[198]  = [0,   ["I",301,1],["I",82,2]]
  A_recipe[199]  = [0,   ["I",301,1]]
  A_recipe[200]  = [0,   ["I",301,1],["I",104,2]]
  A_recipe[201]  = [0,   ["I",301,1],["I",104,1]]
  A_recipe[202]  = [0,   ["I",301,10],["A",188,1]]
  
  A_recipe[204]  = [0,   ["I",105,2]]
  A_recipe[205]  = [0,   ["I",105,5]]
  A_recipe[206]  = [0,   ["I",105,3]]
  A_recipe[207]  = [0,   ["I",105,4]]
  A_recipe[208]  = [0,   ["I",105,1]]
  A_recipe[209]  = [0,   ["I",105,3],["I",82,2]]
  A_recipe[210]  = [0,   ["I",105,5],["I",82,1]]
  A_recipe[211]  = [0,   ["I",105,10]]
  A_recipe[212]  = [0,   ["I",105,2]]
  A_recipe[213]  = [0,   ["I",105,4],["I",82,2]]
  A_recipe[214]  = [0,   ["I",105,5]]
  A_recipe[215]  = [0,   ["I",105,3]]
  A_recipe[216]  = [0,   ["I",105,6]]
  A_recipe[217]  = [0,   ["I",105,12]]
  A_recipe[218]  = [0,   ["I",105,3],["I",82,2]]
  A_recipe[219]  = [0,   ["I",105,3],["I",127,3]]
  A_recipe[220]  = [0,   ["I",105,3],["I",82,2]]
  A_recipe[221]  = [0,   ["I",105,1],["I",82,2]]
  
  A_recipe[227]  = [0,   ["A",219,1],["I",105,5],["I",82,3]]
  
  
  end


#==============================================================================
# ■ WD_itemsynthesis
#------------------------------------------------------------------------------
# 　アイテム合成用の共通メソッドです。
#==============================================================================

module WD_itemsynthesis
  def i_recipe_switch_on(id)
    $game_system.i_rcp_sw = [] if $game_system.i_rcp_sw == nil
    $game_system.i_rcp_sw[id] = false if $game_system.i_rcp_sw[id] == nil
    $game_system.i_rcp_sw[id] = true
  end
  def i_recipe_switch_off(id)
    $game_system.i_rcp_sw = [] if $game_system.i_rcp_sw == nil
    $game_system.i_rcp_sw[id] = false if $game_system.i_rcp_sw[id] == nil
    $game_system.i_rcp_sw[id] = false
  end
  def i_recipe_switch_on?(id)
    $game_system.i_rcp_sw = [] if $game_system.i_rcp_sw == nil
    $game_system.i_rcp_sw[id] = false if $game_system.i_rcp_sw[id] == nil
    return $game_system.i_rcp_sw[id]
  end
  def i_recipe_all_switch_on
    for i in 1..$data_items.size
      i_recipe_switch_on(i)
    end
  end
  def i_recipe_all_switch_off
    for i in 1..$data_items.size
      i_recipe_switch_off(i)
    end
  end
  def w_recipe_switch_on(id)
    $game_system.w_rcp_sw = [] if $game_system.w_rcp_sw == nil
    $game_system.w_rcp_sw[id] = false if $game_system.w_rcp_sw[id] == nil
    $game_system.w_rcp_sw[id] = true
  end
  def w_recipe_switch_off(id)
    $game_system.w_rcp_sw = [] if $game_system.w_rcp_sw == nil
    $game_system.w_rcp_sw[id] = false if $game_system.w_rcp_sw[id] == nil
    $game_system.w_rcp_sw[id] = false
  end
  def w_recipe_switch_on?(id)
    $game_system.w_rcp_sw = [] if $game_system.w_rcp_sw == nil
    $game_system.w_rcp_sw[id] = false if $game_system.w_rcp_sw[id] == nil
    return $game_system.w_rcp_sw[id]
  end
  def w_recipe_all_switch_on
    for i in 1..$data_weapons.size
      w_recipe_switch_on(i)
    end
  end
  def w_recipe_all_switch_off
    for i in 1..$data_weapons.size
      w_recipe_switch_off(i)
    end
  end
  def a_recipe_switch_on(id)
    $game_system.a_rcp_sw = [] if $game_system.a_rcp_sw == nil
    $game_system.a_rcp_sw[id] = false if $game_system.a_rcp_sw[id] == nil
    $game_system.a_rcp_sw[id] = true
  end
  def a_recipe_switch_off(id)
    $game_system.a_rcp_sw = [] if $game_system.a_rcp_sw == nil
    $game_system.a_rcp_sw[id] = false if $game_system.a_rcp_sw[id] == nil
    $game_system.a_rcp_sw[id] = false
  end
  def a_recipe_switch_on?(id)
    $game_system.a_rcp_sw = [] if $game_system.a_rcp_sw == nil
    $game_system.a_rcp_sw[id] = false if $game_system.a_rcp_sw[id] == nil
    return $game_system.a_rcp_sw[id]
  end
  def a_recipe_all_switch_on
    for i in 1..$data_armors.size
      a_recipe_switch_on(i)
    end
  end
  def a_recipe_all_switch_off
    for i in 1..$data_armors.size
      a_recipe_switch_off(i)
    end
  end
  def recipe_all_switch_on
    i_recipe_all_switch_on
    w_recipe_all_switch_on
    a_recipe_all_switch_on
  end
  def recipe_all_switch_off
    i_recipe_all_switch_off
    w_recipe_all_switch_off
    a_recipe_all_switch_off
  end

end

class Game_Interpreter
  include WD_itemsynthesis
end

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :i_rcp_sw
  attr_accessor :w_rcp_sw
  attr_accessor :a_rcp_sw
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias wd_orig_initialize004 initialize
  def initialize
    wd_orig_initialize004
    @i_rcp_sw = []
    @w_rcp_sw = []
    @a_rcp_sw = []
  end
end


#==============================================================================
# ■ Scene_ItemSynthesis
#------------------------------------------------------------------------------
# 　合成画面の処理を行うクラスです。
#==============================================================================

class Scene_ItemSynthesis < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_dummy_window
    create_number_window
    create_status_window
    create_material_window
    create_list_window
    create_category_window
    create_gold_window
    create_change_window
  end
  #--------------------------------------------------------------------------
  # ● ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
    @gold_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 切り替え表示ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_change_window
    wx = 0
    wy = @gold_window.y
    ww = Graphics.width - @gold_window.width
    wh = @gold_window.height
    @change_window = Window_ItemSynthesisChange.new(wx, wy, ww, wh)
    @change_window.viewport = @viewport
    @change_window.hide
  end
  #--------------------------------------------------------------------------
  # ● ダミーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @help_window.y + @help_window.height + 48
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 個数入力ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_number_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @number_window = Window_ItemSynthesisNumber.new(0, wy, wh)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
    @number_window.set_handler(:change_window, method(:on_change_window))    
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wx = @number_window.width
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_ShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 素材ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_material_window
    wx = @number_window.width
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @material_window = Window_ItemSynthesisMaterial.new(wx, wy, ww, wh)
    @material_window.viewport = @viewport
    @material_window.hide
    @number_window.material_window = @material_window
  end
  #--------------------------------------------------------------------------
  # ● 合成アイテムリストウィンドウの作成
  #--------------------------------------------------------------------------
  def create_list_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @list_window = Window_ItemSynthesisList.new(0, wy, wh)
    @list_window.viewport = @viewport
    @list_window.help_window = @help_window
    @list_window.status_window = @status_window
    @list_window.material_window = @material_window
    @list_window.hide
    @list_window.set_handler(:ok,     method(:on_list_ok))
    @list_window.set_handler(:cancel, method(:on_list_cancel))
    @list_window.set_handler(:change_window, method(:on_change_window))    
  end
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemSynthesisCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.activate
    @category_window.item_window = @list_window
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 合成アイテムリストウィンドウのアクティブ化
  #--------------------------------------------------------------------------
  def activate_list_window
    @list_window.money = money
    @list_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 合成［決定］
  #--------------------------------------------------------------------------
  def on_list_ok
    @item = @list_window.item
    @list_window.hide
    @number_window.set(@item, max_buy, buying_price, currency_unit)
    @number_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 合成［キャンセル］
  #--------------------------------------------------------------------------
  def on_list_cancel
    @category_window.activate
    @category_window.show
    @dummy_window.show
    @list_window.hide
    @status_window.hide
    @status_window.item = nil
    @material_window.hide
    @material_window.set(nil, nil)
    @gold_window.hide
    @change_window.hide
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 表示切替
  #--------------------------------------------------------------------------
  def on_change_window
    if @status_window.visible
      @status_window.hide
      @material_window.show
    else
      @status_window.show
      @material_window.hide
    end
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_list_window
    @gold_window.show
    @change_window.show
    @material_window.show
    @category_window.hide
    @list_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 個数入力［決定］
  #--------------------------------------------------------------------------
  def on_number_ok
    Sound.play_shop
    do_syntetic(@number_window.number)
    end_number_input
    @gold_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 個数入力［キャンセル］
  #--------------------------------------------------------------------------
  def on_number_cancel
    Sound.play_cancel
    end_number_input
  end
  #--------------------------------------------------------------------------
  # ● 合成の実行
  #--------------------------------------------------------------------------
  def do_syntetic(number)
    $game_party.lose_gold(number * buying_price)
    $game_party.gain_item(@item, number)
    
      @recipe = @list_window.recipe(@item)
      for i in 1...@recipe.size
        kind = @recipe[i][0]
        id   = @recipe[i][1]
        num  = @recipe[i][2]
        if kind == "I"
          item = $data_items[id]
        elsif kind == "W"
          item = $data_weapons[id]
        elsif kind == "A"
          item = $data_armors[id]
        end
        $game_party.lose_item(item, num*number)
      end
  end
  #--------------------------------------------------------------------------
  # ● 個数入力の終了
  #--------------------------------------------------------------------------
  def end_number_input
    @number_window.hide
    activate_list_window
  end
  #--------------------------------------------------------------------------
  # ● 最大購入可能個数の取得
  #--------------------------------------------------------------------------
  def max_buy
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    
    @recipe = @list_window.recipe(@item)
      for i in 1...@recipe.size
        kind = @recipe[i][0]
        id   = @recipe[i][1]
        num  = @recipe[i][2]
        if kind == "I"
          item = $data_items[id]
        elsif kind == "W"
          item = $data_weapons[id]
        elsif kind == "A"
          item = $data_armors[id]
        end
        if num > 0
          max_buf = $game_party.item_number(item)/num
        else
          max_buf = 999
        end
        max = [max, max_buf].min
      end
      
    buying_price == 0 ? max : [max, money / buying_price].min

  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位の取得
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # ● 合成費用の取得
  #--------------------------------------------------------------------------
  def buying_price
    @list_window.price(@item)
  end
end


#==============================================================================
# ■ Window_ItemSynthesisList
#------------------------------------------------------------------------------
# 　合成画面で、合成可能なアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemSynthesisList < Window_Selectable
  include WD_itemsynthesis
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    
    @shop_goods = []
    @shop_recipes = []
    
    for i in 1..WD_itemsynthesis_ini::I_recipe.size
      recipe = WD_itemsynthesis_ini::I_recipe[i]
      if recipe
        good = [0, i, recipe[0]]
        if i_recipe_switch_on?(i)
          @shop_goods.push(good)
          @shop_recipes.push(recipe)
        end
      end
    end
    for i in 1..WD_itemsynthesis_ini::W_recipe.size
      recipe = WD_itemsynthesis_ini::W_recipe[i]
      if recipe
        good = [1, i, recipe[0]]
        if w_recipe_switch_on?(i)
          @shop_goods.push(good)
          @shop_recipes.push(recipe)
        end
      end
    end
    for i in 1..WD_itemsynthesis_ini::A_recipe.size
      recipe = WD_itemsynthesis_ini::A_recipe[i]
      if recipe
        good = [2, i, recipe[0]]
        if a_recipe_switch_on?(i)
          @shop_goods.push(good)
          @shop_recipes.push(recipe)
        end
      end
    end
    
    @money = 0
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # ● 所持金の設定
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● 合成費用を取得
  #--------------------------------------------------------------------------
  def price(item)
    @price[item]
  end
  #--------------------------------------------------------------------------
  # ● 合成可否を取得
  #--------------------------------------------------------------------------
  def enable?(item)
    @makable[item]
  end
  #--------------------------------------------------------------------------
  # ● レシピを取得
  #--------------------------------------------------------------------------
  def recipe(item)
    @recipe[item]
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def have_mat?(recipe)
    flag = true
    if @money >= recipe[0]
      for i in 1...recipe.size
        kind = recipe[i][0]
        id   = recipe[i][1]
        num  = recipe[i][2]
        if kind == "I"
          item = $data_items[id]
        elsif kind == "W"
          item = $data_weapons[id]
        elsif kind == "A"
          item = $data_armors[id]
        end
        if $game_party.item_number(item) < [num, 1].max
          flag = false
        end
      end
    else
      flag = false
    end
    return flag
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :key_item
      item.is_a?(RPG::Item) && item.key_item?
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @price = {}
    @makable = {}
    @recipe = {}
    for i in 0...@shop_goods.size
      goods = @shop_goods[i]
      recipe = @shop_recipes[i]
      case goods[0]
      when 0;  item = $data_items[goods[1]]
      when 1;  item = $data_weapons[goods[1]]
      when 2;  item = $data_armors[goods[1]]
      end
      if item
        if include?(item)
          @data.push(item)
          @price[item] = goods[2]
          @makable[item] = have_mat?(recipe) && $game_party.item_number(item) < $game_party.max_item_number(item) 
          @recipe[item] = recipe
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    draw_text(rect, price(item), 2)  if WD_itemsynthesis_ini::Cost_view
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 素材ウィンドウの設定
  #--------------------------------------------------------------------------
  def material_window=(material_window)
    @material_window = material_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
    @material_window.set(item, recipe(item)) if @material_window
  end
  #--------------------------------------------------------------------------
  # ● Z ボタン（表示切替）が押されたときの処理
  #--------------------------------------------------------------------------
  def process_change_window
    Sound.play_cursor
    Input.update
    call_handler(:change_window)
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    super
    if active
      return process_change_window if handle?(:change_window) && Input.trigger?(:Z)
#      return process_change_window if handle?(:change_window) && Input.trigger?(:Z)
    end
  end
end


#==============================================================================
# ■ Window_ItemSynthesisMaterial
#------------------------------------------------------------------------------
# 　合成画面で、合成に必要な素材を表示するウィンドウです。
#==============================================================================

class Window_ItemSynthesisMaterial < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_possession(4, 0)
    draw_material_info(0, line_height * 2)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def set(item, recipe)
    @item = item
    @recipe = recipe
    @make_number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 作成個数の設定
  #--------------------------------------------------------------------------
  def set_num(make_number)
    @make_number = make_number
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 所持数の描画
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab::Possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
  #--------------------------------------------------------------------------
  # ● 素材情報の描画
  #--------------------------------------------------------------------------
  def draw_material_info(x, y)
    rect = Rect.new(x, y, contents.width, line_height)
    change_color(system_color)
    contents.font.size = 18
    draw_text(rect, "必要素材", 0)
    if @recipe
      for i in 1...@recipe.size
        kind = @recipe[i][0]
        id   = @recipe[i][1]
        num  = @recipe[i][2]
        if kind == "I"
          item = $data_items[id]
        elsif kind == "W"
          item = $data_weapons[id]
        elsif kind == "A"
          item = $data_armors[id]
        end
        rect = Rect.new(x, y + line_height*i, contents.width, line_height)
        enabled = true
        enabled = false if [num*@make_number, 1].max  > $game_party.item_number(item)
        draw_item_name(item, rect.x, rect.y, enabled)
        change_color(normal_color, enabled)
        if num > 0
          draw_text(rect, "#{num*@make_number}/#{$game_party.item_number(item)}", 2)
        end
      end
    end
    change_color(normal_color)
    contents.font.size = 24
  end
end


#==============================================================================
# ■ Window_ItemSynthesisNumber
#------------------------------------------------------------------------------
# 　合成画面で、合成するアイテムの個数を入力するウィンドウです。
#==============================================================================

class Window_ItemSynthesisNumber < Window_ShopNumber
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item_name(@item, 0, item_y)
    draw_number
    draw_total_price if WD_itemsynthesis_ini::Cost_view
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def material_window=(material_window)
    @material_window = material_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 作成個数の変更
  #--------------------------------------------------------------------------
  def change_number(amount)
    @number = [[@number + amount, @max].min, 1].max
    call_update_help #追加
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def call_update_help
    @material_window.set_num(@number) if @material_window
  end
  #--------------------------------------------------------------------------
  # ● Z ボタン（表示切替）が押されたときの処理
  #--------------------------------------------------------------------------
  def process_change_window
    Sound.play_cursor
    Input.update
    call_handler(:change_window)
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    super
    if active
      return process_change_window if handle?(:change_window) && Input.trigger?(:Z)
#      return process_change_window if handle?(:change_window) && Input.trigger?(:Z)
    end
  end
end


#==============================================================================
# ■ Window_ItemSynthesisCategory
#------------------------------------------------------------------------------
# 　合成画面で、通常アイテムや装備品の分類を選択するウィンドウです。
#==============================================================================

class Window_ItemSynthesisCategory < Window_ItemCategory
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    i = 0
    i += 1 if WD_itemsynthesis_ini::Category_i
    i += 1 if WD_itemsynthesis_ini::Category_w
    i += 1 if WD_itemsynthesis_ini::Category_a
    i += 1 if WD_itemsynthesis_ini::Category_k
    return i
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::item,     :item)     if WD_itemsynthesis_ini::Category_i
    add_command(Vocab::weapon,   :weapon)   if WD_itemsynthesis_ini::Category_w
    add_command(Vocab::armor,    :armor)    if WD_itemsynthesis_ini::Category_a
    add_command(Vocab::key_item, :key_item) if WD_itemsynthesis_ini::Category_k
  end
end


#==============================================================================
# ■ Window_ItemSynthesisNumber
#------------------------------------------------------------------------------
# 　合成画面で、切替を表示するウィンドウです。
#==============================================================================

class Window_ItemSynthesisChange < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    text = "Dキー: 素材 ⇔ ステータス 表示切り替え"
    draw_text(0, 0, contents_width, line_height, text, 1)
  end
end
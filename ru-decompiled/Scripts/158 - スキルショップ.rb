#==============================================================================
# ■ RGSS3 スキルショップ ver 1.00
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVXの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================


#--------------------------------------------------------------------------
# ★ 初期設定。
#    販売条件の設定
#--------------------------------------------------------------------------
module WD_skillshop_ini

  Skill_list   = [] #この行は削除しないこと
  Dislearnable = [] #この行は削除しないこと
  
  #ウィンドウに表示されるテキスト
  Text_nonmastered  = "Не владеет"
  Text_mastered     = "Владеет"
  Text_dislearnable = "Невозможно"
  Text_buy          = "Приобрести навык"
  Text_cancel       = "До свидания"
  
  #ゴールドの代わりに変数を表示する場合の設定
  Gold_variable_use  = false #ゴールドの代わりに変数を利用する場合true
  Gold_variable_id   = 0     #変数の番号
  Gold_variable_name = "PP" #変数の名前
  Gold_variable_unit = "PP"   #変数の単位
 
  #スキルタイプをアクターが持っていない場合は、
  #スキルを習得できないようにする場合はtrue
  Stype_flag = true

  #お店のIDを指定する変数の番号
  #例えば、Shop_id_var = 10の場合、変数10番の値に
  #お店のIDを格納する。
  Shop_id_var = 1
  
  #スキルショップで販売するスキルのリストを
  #お店毎に指定
  #例えば
  #Skill_list[2] = [26,27,28]と記載した場合は、
  #お店のID指定変数が2の場合、販売されるスキルはID26,27,28のスキルとなる。
  Skill_list[0]  = [263]
  Skill_list[1]  = [26,27,28,29,30]
  
  Skill_list[5]  = [142,263,264,267,268,269,270,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695]
  
  #以下、各アクターが修得できないスキルを指定
  Dislearnable[1] = [8,9]      #1番のアクターは2番,3番のスキルを修得不可
  Dislearnable[3] = [39,40,41] #3番のアクターは39番,40番,41番のスキルを修得不可

  Dislearnable[15] = [142]  
  Dislearnable[16] = [142]
  Dislearnable[17] = [142]  
  Dislearnable[18] = [142]  
end



#==============================================================================
# ■ Scene_SkillShop
#------------------------------------------------------------------------------
# 　スキルショップ画面の処理を行うクラスです。
#==============================================================================

class Scene_SkillShop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 準備
  #--------------------------------------------------------------------------
  def initialize
    shop_id = $game_variables[WD_skillshop_ini::Shop_id_var]
    @goods = WD_skillshop_ini::Skill_list[shop_id]
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_status_window
    create_buy_window
  end
  #--------------------------------------------------------------------------
  # ● ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_SkillShopGold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_SkillShopCommand.new(@gold_window.x)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● ダミーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wx = 304
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_SkillShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
    @status_window.set_handler(:ok,     method(:on_status_ok))
    @status_window.set_handler(:cancel, method(:on_status_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 購入ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_SkillShopBuy.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 購入ウィンドウのアクティブ化
  #--------------------------------------------------------------------------
  def activate_buy_window
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● コマンド［購入する］
  #--------------------------------------------------------------------------
  def command_buy
    @dummy_window.hide
    activate_buy_window
  end
  #--------------------------------------------------------------------------
  # ● 購入［決定］
  #--------------------------------------------------------------------------
  def on_buy_ok
    @item = @buy_window.item
    @buy_window.deactivate
    @status_window.select(0)
    @status_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 購入［キャンセル］
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @dummy_window.show
    @buy_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 対象アクター選択［決定］
  #--------------------------------------------------------------------------
  def on_status_ok
    do_buy
    @status_window.refresh
    @gold_window.refresh
    @buy_window.money = money
    @buy_window.refresh
    if @buy_window.enable?(@buy_window.item)
      @status_window.activate
    else
      on_status_cancel
    end
  end
  #--------------------------------------------------------------------------
  # ● 対象アクター選択［キャンセル］
  #--------------------------------------------------------------------------
  def on_status_cancel
    @status_window.deactivate
    @status_window.select(-1)
    @buy_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 購入・修得の実行
  #--------------------------------------------------------------------------
  def do_buy
    actor = @status_window.status_members[@status_window.index]
    item = @buy_window.item
    price = @buy_window.price(item)
    actor.learn_skill(item.id)
    if WD_skillshop_ini::Gold_variable_use == false
      $game_party.lose_gold(price)
    else
      $game_variables[WD_skillshop_ini::Gold_variable_id] -= price
    end
  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
end


#==============================================================================
# ■ Window_SkillShopBuy
#------------------------------------------------------------------------------
# 　スキルショップ画面で、購入できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, height, shop_goods)
    super(x, y, window_width, height)
    @shop_goods = shop_goods
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
  # ● 商品の値段を取得
  #--------------------------------------------------------------------------
  def price(item)
    @price[item]
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    item && price(item) <= @money
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
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      item = $data_skills[goods]
      if item
        @data.push(item)
        if /<価格:(.+)>/ =~ item.note
          @price[item] = $1.to_i
        else
          @price[item] = 0
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
    draw_text(rect, price(item), 2)
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
    @status_window.price = price(item) if @status_window
  end
end


#==============================================================================
# ■ Window_SkillShopStatus
#------------------------------------------------------------------------------
# 　ショップ画面で、アクターを選択するウィンドウです。
#==============================================================================

class Window_SkillShopStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @page_index = 0
    super(x, y, width, height)
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_skill_info(4, line_height * 1)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 価格の設定
  #--------------------------------------------------------------------------
  def price=(price)
    @price = price
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    return [status_members.size, page_size].min
  end
  #--------------------------------------------------------------------------
  # ● スキル修得情報の描画
  #--------------------------------------------------------------------------
  def draw_skill_info(x, y)
    status_members.each_with_index do |actor, i|
      draw_actor_skill_info(x, y + line_height * (i * 2.4), actor)
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル修得情報を描画するアクターの配列
  #--------------------------------------------------------------------------
  def status_members
    $game_party.members[@page_index * page_size, page_size]
  end
  #--------------------------------------------------------------------------
  # ● 一度に表示できるアクターの人数
  #--------------------------------------------------------------------------
  def page_size
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    ($game_party.members.size + page_size - 1) / page_size
  end
  #--------------------------------------------------------------------------
  # ● アクターのスキル修得情報を描画
  #--------------------------------------------------------------------------
  def draw_actor_skill_info(x, y, actor)
    enabled = enable?(actor)
    change_color(normal_color, enabled)
    draw_text(x, y, 112, line_height, actor.name)
    if enabled
      draw_text(x, y + line_height, contents.width - 8, line_height, WD_skillshop_ini::Text_nonmastered, 2)
    elsif learn?(actor)
      draw_text(x, y + line_height, contents.width - 8, line_height, WD_skillshop_ini::Text_mastered, 2)
    elsif learnable?(actor) == false
      draw_text(x, y + line_height, contents.width - 8, line_height, WD_skillshop_ini::Text_dislearnable, 2)      
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ● ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && Input.trigger?(:A) && page_max > 1
      @page_index = (@page_index + 1) % page_max
      if index > -1
        select(0)
      end
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = contents.width - 4
    rect.height = line_height * 2
    rect.x = 0
    rect.y = line_height * 1 + index * line_height * 2.4
    rect
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Sound.play_shop
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    actor = status_members[index]
    enable?(actor)
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(actor)
    enabled = true
    enabled = false if learn?(actor)
    enabled = false if learnable?(actor) == false
    return enabled
  end
  #--------------------------------------------------------------------------
  # ● スキルを修得済みかどうか
  #--------------------------------------------------------------------------
  def learn?(actor)
    actor.skill_learn?(@item)
  end
  #--------------------------------------------------------------------------
  # ● スキルを修得可能かどうか
  #--------------------------------------------------------------------------
  def learnable?(actor)
    dislearnlist = WD_skillshop_ini::Dislearnable[actor.id]
    if dislearnlist
      if @item
        return false if dislearnlist.include?(@item.id)
      end
    end
    if WD_skillshop_ini::Stype_flag
      return false if have_stype?(actor) == false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプが存在するかどうか
  #--------------------------------------------------------------------------
  def have_stype?(actor)
    type_flag = false
    if @item
      actor.added_skill_types.sort.each do |stype_id|
        if stype_id == @item.stype_id
          type_flag = true
        end
      end
    end
    return type_flag
  end  
end


#==============================================================================
# ■ Window_SkillShopCommand
#------------------------------------------------------------------------------
# 　スキルショップ画面で、購入／キャンセルを選択するウィンドウです。
#==============================================================================

class Window_SkillShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(WD_skillshop_ini::Text_buy,    :buy)
    add_command(WD_skillshop_ini::Text_cancel, :cancel)
  end
end


#==============================================================================
# ■ Window_SkillShopGold
#------------------------------------------------------------------------------
# 　所持金または変数を表示するウィンドウです。
#==============================================================================

class Window_SkillShopGold < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    cw = 0
    if WD_skillshop_ini::Gold_variable_use
      change_color(system_color)
      cw = text_size(WD_skillshop_ini::Gold_variable_name).width
      draw_text(0, 0, cw, line_height, WD_skillshop_ini::Gold_variable_name, 0)
    end
    draw_currency_value(value, currency_unit, 4+cw, 0, contents.width - 8 -cw)
  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def value
    if WD_skillshop_ini::Gold_variable_use == false
      $game_party.gold
    else
      $game_variables[WD_skillshop_ini::Gold_variable_id]
    end
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位の取得
  #--------------------------------------------------------------------------
  def currency_unit
    if WD_skillshop_ini::Gold_variable_use == false
      Vocab::currency_unit
    else
      WD_skillshop_ini::Gold_variable_unit
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end


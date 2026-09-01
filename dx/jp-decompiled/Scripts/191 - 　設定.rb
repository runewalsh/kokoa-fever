#
#   * アイテム合成のデータ設定
#
#
#   ※ アイテム合成スクリプト本体より下に導入してください。
#   ※ 増減させるアイテムの設定で同じアイテムは重複できません。
#   ※ データの出力は、テストプレイ時のみ行います。
#   ※ データの出力後、このスクリプトは不要です。
#


# レシピの設定
ITEMMAKE_RECIPES = [
  # アイコン, 名前, 価格, [減らすアイテム], [増やすアイテム], 説明
  
     ["I92:5",  0, ["I93"]],
     ["I489:3",  0, ["I93"]],
     ["I80:5",  0, ["I81"]],
     ["I600:10",  0, ["I80:10","I92:10"]],
     ["I127",  0, ["I125:3"]],
     ["I630:100",  0, ["I101:10"]],
     ["I494:10",  0, ["I101:3"]],
     ["I495:10",  0, ["I103:3"]],
     ["I497:1",  0, ["I490:10"]],
     ["I602:10",  0, ["I103:3"]],
     ["I603:10",  0, ["I80:10","I92:10","I129:2"]],

    
]


ITEMMAKE_BOOKS = [
  # アイコン, 名前, [リスト], [減数,増数], [減名,増名], [背景,前景], ...
  [230, "すべて", Array(1..11), [],    []],
#  [279, "アイテム", Array(1..6)  ,  [], [], []],
#  [147, "武器",       [],      [],    [], []],

]


#/////////////////////////////////////////////////////////////////////////////#
#                                                                             #
#                下記のスクリプトを変更する必要はありません。                 #
#                                                                             #
#/////////////////////////////////////////////////////////////////////////////#

  
# レシピデータの出力
def save_item_make_recipe_data
  result = [nil]
  ITEMMAKE_RECIPES.each do |data|
    recipe = RPG::ItemMake::Recipe.new
    recipe.id = result.size
    if data.size == 3
      item = RPG::ItemMake::Item.new(data[0]).object
      recipe.icon_index = item.icon_index
      recipe.name = item.name
      recipe.price = data[1].to_i
      recipe.minus_items = data[2].map {|s| RPG::ItemMake::Item.new(s) }
      recipe.plus_items = [RPG::ItemMake::Item.new(data[0])]
      recipe.description = item.description
    else
      recipe.icon_index = data[0]
      recipe.name = data[1]
      recipe.price = data[2].to_i
      recipe.minus_items = data[3].map {|s| RPG::ItemMake::Item.new(s) }
      recipe.plus_items = data[4].map {|s| RPG::ItemMake::Item.new(s) }
      recipe.description = data[5]
    end
    result << recipe
  end
  save_data(result, "Data/#{CAO::ItemMake::FILE_RECIPE}")
end
  
# レシピブックデータの出力
def save_item_make_book_data
  result = [nil]
  ITEMMAKE_BOOKS.each do |data|
    book = RPG::ItemMake::Book.new
    book.id = result.size
    book.icon_index = data[0]
    book.name = data[1]
    book.list = data[2]
    if data[3].is_a?(Array)
      book.minus_number = data[3][0] if data[3][0]
      book.plus_number = data[3][1] if data[3][1]
    end
    if data[4].is_a?(Array)
      book.minus_name = data[4][0]
      book.plus_name = data[4][1]
    end
    if data[5].is_a?(Array)
      book.background_name = data[5][0]
      book.foreground_name = data[5][1]
    end
    book.display_price = data.include?(:price)
    book.visible_window = !data.include?(:nownd)
    result << book
  end
  save_data(result, "Data/#{CAO::ItemMake::FILE_BOOK}")
end

def chack_item_make_data
  data = [] << $data_items << $data_weapons << $data_armors
  books = load_data("Data/#{CAO::ItemMake::FILE_BOOK}")
  recipes = load_data("Data/#{CAO::ItemMake::FILE_RECIPE}")
  
  (1...books.size).each do |book_id|
    books[book_id].list.each do |recipe_id|
      unless recipes[recipe_id]
        msgbox "ブック #{book_id} 番\n#{recipe_id} 番のレシピが見つかりません。"
        next
      end
      imitems = recipes[recipe_id].plus_items | recipes[recipe_id].minus_items
      imitems.each do |im|
        item = data[im.class_id][im.item_id]
        unless item
          msgbox "レシピ #{recipe_id} 番\n#{im.item_id} 番の" +
                 "#{["アイテム","武器","防具"][im.class_id]}が見つかりません。"
          next
        end
      end
    end
  end
end

if $TEST
  $data_items   = load_data("Data/Items.rvdata2")
  $data_weapons = load_data("Data/Weapons.rvdata2")
  $data_armors  = load_data("Data/Armors.rvdata2")

  save_item_make_recipe_data
  save_item_make_book_data
  chack_item_make_data
end
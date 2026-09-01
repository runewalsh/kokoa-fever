#==============================================================================
# ■ RGSS3 使用時メッセージ拡張 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# アイテム・スキル使用時の使用時メッセージを拡張します。
# アイテム・スキル共に使用後の追加メッセージの表示と
# 使用者の名前を表示しなくする機能を追加します。
# また、アイテムについては
# 個別に使用時メッセージを指定できる機能を追加します。
# 
# 使用例1　アイテム・スキル共通（追加メッセージ）
# ポーションのメモ欄にそれぞれ下記のように記入し
# エリックがポーションを使用した場合。
# <UM:痛みがひいていく！！>
# →エリックはポーションを使った！
# 　痛みがひいていく！！
#------------------------------------------------------------------------------
# ※この追加メッセージはいくつでも指定する事ができ
# 　上から順次表示されていきますが
# 　デフォルトの戦闘ではアイテムは1つのみしか正常に表示されず
# 　スキルに関しては使用時メッセージ2を指定していない場合に
# 　1つのみ表示させる事が出来ます。
# 
# 　このスクリプト単体の場合は、アイテムの使用時メッセージ2を
# 　指定する為の機能となるでしょう。
# 
# 　正常に表示させるにはももまるLabs様のXPスタイルバトル等の
# 　長いバトルログを表示させる機能を有するスクリプトが必要です。
#------------------------------------------------------------------------------
# 使用例2　アイテムの場合（使用時メッセージの指定＆使用者名の表示をなくす）
# ポーションのメモ欄にそれぞれ下記のように記入し
# エリックがポーションを使用した場合。
# <IM:ポーションを飲んだ！>
# →エリックはポーションを飲んだ！
# 更に<使用者名表示無し>と記入していた場合
# →ポーションを飲んだ！
# 
# 使用例3　スキルの場合（使用者名の表示をなくす）
# タックルのメモ欄に<使用者名表示無し>と記入し
# ナタリーがタックルを使用した場合。
# →はタックルを放った！
# （使用時メッセージ1がそのまま適用されます）
#==============================================================================
module EX_IM
  
  #アイテム使用時メッセージを指定する為の
  #キーワードを設定します。（基本的に変更不要）
  
  MES1 = "IM"
  
  #アイテム/スキル使用時追加メッセージを指定する為の
  #キーワードを設定します。（基本的に変更不要）
  
  MES2 = "UM"
  
  #使用者名を表示無しにする為のキーワードを設定します。（基本的に変更不要）
  
  WORD = "<使用者名表示無し>"
  
end
module Vocab
  
  #使用者名表示無しの場合のアイテム使用時メッセージを指定します。
  
  UseItem_EX       = "%sを使った！"
  
end
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● スキル／アイテム使用の表示
  #--------------------------------------------------------------------------
  alias display_use_item_nameless display_use_item
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      if item.user_display_flag
        add_text(item.message1)
        if !item.message2.empty?
          wait
          add_text(item.message2)
        end
      else
        display_use_item_nameless(subject, item)
      end
    elsif item.is_a?(RPG::Item)
      if !item.ex_use_mes.empty?
        if item.user_display_flag
          add_text(item.ex_use_mes)
        else
          add_text(sprintf("%sは" + item.ex_use_mes, subject.name))
        end
      elsif item.user_display_flag
        add_text(sprintf(Vocab::UseItem_EX, item.name))
      else
        display_use_item_nameless(subject, item)
      end
    else
      display_use_item_nameless(subject, item)
    end
    if !item.message_extra.empty?
      item.message_extra.each do |text|
        wait
        add_text(text)
      end
    end
  end
end
class RPG::BaseItem
  attr_accessor :user_display_flag
  attr_accessor :ex_use_mes
  attr_accessor :message_extra
  def user_display_flag
    return @user_display_flag if @user_display_flag != nil
    @user_display_flag = @note.include?(EX_IM::WORD)
    return @user_display_flag
  end
  def ex_use_mes
    return @ex_use_mes if @ex_use_mes != nil
    @ex_use_mes = ""
    memo = @note.scan(/<#{EX_IM::MES1}[：:](\S+)>/)
    memo = memo.flatten
    @ex_use_mes = memo[0].to_s if memo != nil && !memo.empty?
    return @ex_use_mes
  end
  def message_extra
    return @message_extra if @message_extra != nil
    @message_extra = []
    @note.each_line { |line|
    memo = line.scan(/<#{EX_IM::MES2}[：:](\S+)>/)
    memo = memo.flatten
    @message_extra.push(memo[0].to_s) if memo != nil && !memo.empty?
    }
    return @message_extra
  end
end
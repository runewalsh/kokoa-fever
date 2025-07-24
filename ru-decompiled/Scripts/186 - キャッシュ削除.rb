=begin

==　タイトル　==
キャッシュ削除（VX・VX Ace共用）

==　更新履歴　==
2012/09/14　公開

==　機能　==
イベント内の「ピクチャの表示」で表示した画像のキャッシュデータを、任意の場所で
削除する。

==　使用方法　==
イベント内の「スクリプト」で下の一文を記入する。
clear_pic_cache

==　使用規約　==
使用報告は必要ありません。
クレジットなどどこかにサイト名とURLを載せてもらえると喜びます。
このスクリプトを使用した際、問題が起きたときの責任は一切負いかねます。

==　連絡先　==
サイト：http://jikkuri.info/
ブログ：http://blog.jikkuri.info/

=end


module Cache
  @picture_cache = []

  def self.clear_file(folder_name, filename, gcflag = true)
    path = folder_name + filename
    return unless @cache.include?(path)
    @cache[path].dispose
    @cache.delete(path)
    GC.start if gcflag
  end

  def self.clear_files(folder_name, filenames)
    filenames.each {|filename|
      self.clear_file(folder_name, filename, false)
    }
    GC.start
  end

  def self.clear_pic_cache
    self.clear_files("Graphics/Pictures/", @picture_cache)
    @picture_cache = []
  end

  def self.picture_cache
    @picture_cache
  end
end


class Game_Interpreter
  alias jikkuri_cache_command_231 command_231
  def command_231
    jikkuri_cache_command_231
    Cache.picture_cache.push(@params[1])
  end

  def clear_pic_cache
    Cache.clear_pic_cache
  end
end
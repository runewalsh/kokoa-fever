#==============================================================================
# ■ RGSS3 アイテム図鑑 ver 1.01　初期設定
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

#-------------------------------------------------------------------------------
# ★ 初期設定。
#-------------------------------------------------------------------------------
module WD_itemdictionary_layout

#=== 各項目のレイアウト設定項目 ================================================
#
#   *_***_display       : trueで表示。falseで非表示。
#   *_***_display_x     : 表示位置のx座標
#   *_***_display_y     : 表示位置のy座標
#   *_***_display_width : 表示テキストの幅
#   *_***_display_text* : 表示テキスト
#
#===============================================================================

#===全図鑑共通設定==============================================================

  #フォントサイズ
  C_font_size = 20

#===道具図鑑設定================================================================

  #番号の表示
  I_id_display        = true
  I_id_display_x      = 0
  I_id_display_y      = 0
  I_id_display_width  = 60
  I_id_display_digit  = 3 #桁数
  
  #名前の表示
  I_name_display        = true
  I_name_display_x      = 84
  I_name_display_y      = 0
  I_name_display_width  = 172

  #価格の表示
  I_price_display        = true
  I_price_display_x      = 150
  I_price_display_y      = 32
  I_price_display_width  = 136
  I_price_display_text1  = "価格"

  #使用可能時の表示
  I_occasion_display        = true
  I_occasion_display_x      = 0
  I_occasion_display_y      = 62
  I_occasion_display_width  = 140
  I_occasion_display_text1  = "使用"
  I_occasion_display_text2  = "常時"
  I_occasion_display_text3  = "戦闘時"
  I_occasion_display_text4  = "移動時"
  I_occasion_display_text5  = "－"

  #消耗の表示
  I_consumable_display        = true
  I_consumable_display_x      = 150
  I_consumable_display_y      = 62
  I_consumable_display_width  = 140
  I_consumable_display_text1  = "消耗"
  I_consumable_display_text2  = "消耗する"
  I_consumable_display_text3  = "消耗しない"

  #特徴の表示
  I_option_display       = true
  I_option_display_x     = 0
  I_option_display_y     = 92
  I_option_display_width = 286
  I_option_display_text1 = "特徴"
  I_option_display_text2 = "なし"

#===武器図鑑設定================================================================

  #番号の表示
  W_id_display        = true
  W_id_display_x      = 0
  W_id_display_y      = 0
  W_id_display_width  = 60
  W_id_display_digit  = 3 #桁数

  #名前の表示
  W_name_display        = true
  W_name_display_x      = 84
  W_name_display_y      = 0
  W_name_display_width  = 172

  #タイプの表示
  W_type_display        = true
  W_type_display_x      = 0
  W_type_display_y      = 32
  W_type_display_width  = 136
  W_type_display_text1  = "タイプ"

  #価格の表示
  W_price_display       = true
  W_price_display_x     = 150
  W_price_display_y     = 32
  W_price_display_width = 136
  W_price_display_text1 = "価格"

  #攻撃力の表示
  W_atk_display         = true
  W_atk_display_x       = 0
  W_atk_display_y       = 62
  W_atk_display_width   = 136

  #防御力の表示
  W_def_display         = true
  W_def_display_x       = 150
  W_def_display_y       = 62
  W_def_display_width   = 136

  #魔法力の表示
  W_mat_display         = true
  W_mat_display_x       = 0
  W_mat_display_y       = 82
  W_mat_display_width   = 136

  #魔法防御の表示
  W_mdf_display         = true
  W_mdf_display_x       = 150
  W_mdf_display_y       = 82
  W_mdf_display_width   = 136

  #敏捷性の表示
  W_agi_display         = true
  W_agi_display_x       = 0
  W_agi_display_y       = 102
  W_agi_display_width   = 136

  #運の表示
  W_luk_display         = true
  W_luk_display_x       = 150
  W_luk_display_y       = 102
  W_luk_display_width   = 136

  #最大ＨＰの表示
  W_mhp_display         = true
  W_mhp_display_x       = 0
  W_mhp_display_y       = 122
  W_mhp_display_width   = 136

  #最大ＭＰの表示
  W_mmp_display         = true
  W_mmp_display_x       = 150
  W_mmp_display_y       = 122
  W_mmp_display_width   = 136

  #特徴の表示
  W_option_display       = true
  W_option_display_x     = 0
  W_option_display_y     = 152
  W_option_display_width = 286
  W_option_display_text1 = "特徴"
  W_option_display_text2 = "なし"


#===防具図鑑設定================================================================

  #番号の表示
  A_id_display        = true
  A_id_display_x      = 0
  A_id_display_y      = 0
  A_id_display_width  = 60
  A_id_display_digit  = 3 #桁数

  #名前の表示
  A_name_display        = true
  A_name_display_x      = 84
  A_name_display_y      = 0
  A_name_display_width  = 172

  #タイプの表示
  A_type_display        = true
  A_type_display_x      = 0
  A_type_display_y      = 32
  A_type_display_width  = 136
  A_type_display_text1  = "タイプ"

  #価格の表示
  A_price_display       = true
  A_price_display_x     = 150
  A_price_display_y     = 32
  A_price_display_width = 136
  A_price_display_text1 = "価格"

  #攻撃力の表示
  A_atk_display         = true
  A_atk_display_x       = 0
  A_atk_display_y       = 62
  A_atk_display_width   = 136

  #防御力の表示
  A_def_display         = true
  A_def_display_x       = 150
  A_def_display_y       = 62
  A_def_display_width   = 136

  #魔法力の表示
  A_mat_display         = true
  A_mat_display_x       = 0
  A_mat_display_y       = 82
  A_mat_display_width   = 136

  #魔法防御の表示
  A_mdf_display         = true
  A_mdf_display_x       = 150
  A_mdf_display_y       = 82
  A_mdf_display_width   = 136

  #敏捷性の表示
  A_agi_display         = true
  A_agi_display_x       = 0
  A_agi_display_y       = 102
  A_agi_display_width   = 136

  #運の表示
  A_luk_display         = true
  A_luk_display_x       = 150
  A_luk_display_y       = 102
  A_luk_display_width   = 136

  #最大ＨＰの表示
  A_mhp_display         = true
  A_mhp_display_x       = 0
  A_mhp_display_y       = 122
  A_mhp_display_width   = 136

  #最大ＭＰの表示
  A_mmp_display         = true
  A_mmp_display_x       = 150
  A_mmp_display_y       = 122
  A_mmp_display_width   = 136

  #特徴の表示
  A_option_display       = true
  A_option_display_x     = 0
  A_option_display_y     = 152
  A_option_display_width = 286
  A_option_display_text1 = "特徴"
  A_option_display_text2 = "なし"


end
#-------------------------------------------------------------------------------
# ★ 初期設定おわり
#-------------------------------------------------------------------------------
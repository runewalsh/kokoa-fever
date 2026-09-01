#==============================================================================
# ■ RGSS3 魔物図鑑 ver 1.01　初期設定
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
# SceneManager.call(Scene_MonsterDictionary)	魔物図鑑の呼び出し
#m_dictionary_encount_switch_on(n)	n番のエネミー遭遇済み判定をON
#m_dictionary_encount_switch_off(n)	n番のエネミー遭遇済み判定をOFF
#m_dictionary_victory_switch_on(n)	n番のエネミー撃破済み判定をON
#m_dictionary_victory_switch_off(n)	n番のエネミー撃破済み判定をOFF
#m_dictionary_drop_switch_on(n, m)	n番のエネミーのドロップm番のドロップ済み判定をON(但し、mは0～2)
#m_dictionary_drop_switch_off(n, m)	n番のエネミーのドロップm番のドロップ済み判定をOFF(但し、mは0～2)
#$game_variables[n] = monster_dictionary_perfection	魔物図鑑の完成度をn番の変数に可能
#データベース上のエネミーのメモ欄に
#　「<図鑑特徴:○○○>」と記述すると、○○○の部分が図鑑の特徴欄に記述されます。
#　「<図鑑説明:○○○>」と記述すると、○○○の部分が図鑑の説明欄に記述されます。
#

#データベース上のエネミーのメモ欄に
#「<図鑑無効>」と記述すると、そのエネミーは図鑑に登録されません。

#-------------------------------------------------------------------------------
# ★ 初期設定。
#-------------------------------------------------------------------------------
module WD_monsterdictionary_layout

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

  #図鑑完成度にどの段階で繁栄するか
  Perfection_timing = 1 #1⇒遭遇時、2⇒撃破時

  #フォントサイズ
  C_font_size = 18

#===魔物図鑑設定================================================================

  #番号の表示
  M_id_display            = true
  M_id_display_x          = 0
  M_id_display_y          = 0
  M_id_display_width      = 60
  M_id_display_digit      = 3 #桁数
  
  #名前の表示
  M_name_display          = true
  M_name_display_x        = 84
  M_name_display_y        = 0
  M_name_display_width    = 172

  #画像の表示
  M_pic_display           = true
  M_pic_display_x         = 240
  M_pic_display_y         = 470
  M_pic_display_opacity   = 100 #画像の不透明度

  #最大ＨＰの表示
  M_mhp_display           = true
  M_mhp_display_x         = 0
  M_mhp_display_y         = 33
  M_mhp_display_width     = 136

  #最大ＭＰの表示
  M_mmp_display           = false
  M_mmp_display_x         = 150
  M_mmp_display_y         = 33
  M_mmp_display_width     = 136

  #攻撃力の表示
  M_atk_display           = false
  M_atk_display_x         = 0
  M_atk_display_y         = 51
  M_atk_display_width     = 136

  #防御力の表示
  M_def_display           = true
  M_def_display_x         = 150
  M_def_display_y         = 51
  M_def_display_width     = 136

  #魔法力の表示
  M_mat_display           = false
  M_mat_display_x         = 0
  M_mat_display_y         = 69
  M_mat_display_width     = 136

  #魔法防御の表示
  M_mdf_display           = true
  M_mdf_display_x         = 150
  M_mdf_display_y         = 69
  M_mdf_display_width     = 136

  #敏捷性の表示
  M_agi_display           = true
  M_agi_display_x         = 0
  M_agi_display_y         = 87
  M_agi_display_width     = 136

  #運の表示
  M_luk_display           = true
  M_luk_display_x         = 150
  M_luk_display_y         = 87
  M_luk_display_width     = 136

  #特徴の表示
  M_feature_display       = true
  M_feature_display_x     = 0
  M_feature_display_y     = 114
  M_feature_display_width = 350
  M_feature_display_text1 = "特徴"
  M_feature_display_text2 = "－"

  #経験値の表示
  M_exp_display           = true
  M_exp_display_x         = 0
  M_exp_display_y         = 230
  M_exp_display_width     = 136
  M_exp_display_text1     = "経験値"

  #お金の表示
  M_gold_display          = true
  M_gold_display_x        = 150
  M_gold_display_y        = 230
  M_gold_display_width    = 136
  M_gold_display_text1    = "お金"

  #ドロップアイテムの表示
  M_drop_display          = true
  M_drop_display_x        = 0
  M_drop_display_y        = 245
  M_drop_display_width    = 286
  M_drop_display_text1    = "ドロップアイテム"
  M_drop_display_text2    = "なし"

  #説明の表示
  M_help_display          = true
  M_help_display_x        = 0
  M_help_display_y        = 320
  M_help_display_width    = 410
  M_help_display_text1    = "説明"
  M_help_display_text2    = "－"

  #撃破数の表示
  M_geno_display          = false
  M_geno_display_x        = 0
  M_geno_display_y        = 321
  M_geno_display_width    = 136
  M_geno_display_text1    = "撃破数"

end
#-------------------------------------------------------------------------------
# ★ 初期設定おわり
#-------------------------------------------------------------------------------
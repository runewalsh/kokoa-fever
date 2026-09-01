#==============================================================================
#  ■併用化ベーススクリプト設定ファイル Ver5.05-EX1用
#　□作成者 kure
#==============================================================================
$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:base_config] = 503
p "併用化ベーススクリプト設定"

module KURE
  module BaseScript    
    #動作設定-------------------------------------------------------------------
      #転職時の設定
        #スキル削除(1に設定すると転職時にスキルが削除されます。)
        C_DELETE_SKILL_MODE = 0
        
        #メモライズ設定(1に設定すると転職時メモライズが消去されます、)
        #C_DELETE_SKILL_MODE = 0の時のみ動作します。
        C_MEMORIZE_REFRSH = 0
    
      #歩行時タプロセス(0にすると歩行時のステート処理が行わなくなります。)
      C_WALK_PROCESS = 1
    
      #歩行時ターン終了プロセス(0にすると歩行時のターン終了処理が行われなくなります。)
      C_WALK_PROCESS_EFFECT = 1
    
      #通常攻撃再設定(1を設定するとID1の通常攻撃が直前の設定で反映されます)
      C_NORMAL_ATTACK_RESET = 0
      
      #アニメーション軽量化(1を設定すると画面対象のアニメーションが1回になります)
      C_ANIMATION_CUTTER = 0
      
      #スキルコスト描画設定(1を設定するとスキルコストがTP→MP→HPの順で更新されます)
      C_SKILL_COST_DRAW = 1
        
      #オートリザレクション時に使用されるアニメーションID
      S_AUTO_REVIVE_ANIM_ID = 37
    
      #反撃の仕様(1 = デフォルト(行動前反撃) 2 = 行動後反撃)
      COUNTER_MODE = 2
    
      #スティール全般の設定
        #アイテムのアイコン(0=描画しない 1=描画する)
        C_DRAW_STEAL_ITEM_ICON = 1

        #アイテムの表示色
        C_DRAW_STEAL_ITEM_COLOR = 24
      
        #成功時SEの設定[ファイル名,ボリューム,ピッチ]
        C_STEAL_ITEM_SE = ['Chime2',100,100]
      
        #SEを鳴らすかどうか(0=鳴らさない, 1=鳴らす)
        C_STEAL_ITEM_SE_PLAY = 1
        
      #運の影響度設定(運の値1の影響度)
      C_LUK_EFFECT = 0.000
      
      #属性反映設定(0=最大値の適用、1=複数の属性を計算)
      C_ELEMENT_MODE = 0
      
      #命中率判定方法(0=デフォルト, 1 = 命中-回避)
      HIT_CHEAK_MODE = 0
      
        #最低命中( HIT_CHEAK_MODE = 1 の時に有効)
        MIN_HIT_RATE = 0.05
    
    #プロセスカッター-----------------------------------------------------------
    #以下の設定について、ゲーム中で使用しない場合値を0にすることで
    #該当設定の反映処理をスキップします。
    #分かり易く言うと（）内のメモ欄設定が無効になります。
    
    #歩行時パッシブスキル更新(0にすると全パッシブスキルが歩行時更新されなくなります)
    C_WALK_PASSIVE_REFRESH = 1
    
    #ステートブースター(<ステート指定割合強化><ステート指定固定強化>)
    C_STATE_BOOSTER = 1
    
    #戦闘時ステータス(<HP減少時強化><オーバーソウル>)
    C_BATTLE_ADD_STATUS = 1
    
    #戦闘時ステート付与(<トリガーステート>)
    C_BATTLE_ADD_STATE = 1
    
    #TP関連設定(<TPLv補正><最大TP増加><最大TP減少><TP上限値>)
    C_TP_ADDER = 1
    
    #戦闘終了後自動回復(<戦闘後回復>)
    C_BATTLE_AUTO_HEELING = 1
    
    #オートリザレクション(<オートリザレクション>)
    C_AUTO_REVIVE = 1
    
    #追撃対象ステート(<追撃対象ステート>)
    C_CHASE_ATTACK = 1
    
    #エンカウント率操作(<エンカウント率>)
    C_ENCOUNTER = 1
    
    #戦闘開始時発動能力(<戦闘開始時発動>)
    C_FIRST_INVOKE_SKILL = 1
    
    #ターン間発動能力(<ターン開始時発動><ターン終了時発動>)
    C_SE_TURN_SKILL = 1
    
    #常時オートステート(<常時オートステート>)
    C_AUTO_STATE_ADDER = 1
    
    #トラップ設置(<トラップ設置>)
    C_TRAP_PROCESS = 0
  end
end

#==============================================================================
# ▲ Vocab(追加定義)
#==============================================================================
module Vocab
  ObtainJobExp    = "%s の職業経験値を獲得！"
  ObtainEquipExp  = "%s の装備経験値を獲得！"
  ObtainAP        = "%s のアビリティポイントを獲得！"
  ObtainStatus    = "%s のステータスポイントを獲得！"
  ObtainSkillP    = "%s のスキルポイントを獲得！"
  
  ObtainSkill_AP  = "%sは%sを覚えた！"
  
  EnemySteal      = "%sから%sを盗んだ！"
  EnemyNOSteal    = "%sから何も盗めなかった！"
  EnemyStealed    = "%sは何も持っていない！"
  BreakEquip      = "%sの%sが破損してしまった！"
  
  AUTO_GUARD      = "%sの直感発動！"
  PayLife         = "%sは力尽きた！"
  Revive          = "%sは立ちあがった！"
  Stand           = "%sは踏みとどまった！"
  Reverse_deth    = "%sは効果を反転させた！"
  Defense         = "%sは攻撃を防御壁で相殺した！"
  LostSkill       = "%sは%sが使えなくなった！"
  Invalidate      = "%sはダメージを無効化した！"
  CERTAIN_B       = "%sは攻撃をはじき返した！"
  PHYSICAL_B      = "%sは攻撃をはじき返した！"
  MAGICAL_B       = "%sは魔法をかき消した！"
  MultiState      = "%sは%sにならない！"
  
  FinalCounterAttack   = "%sは倒れる間際に%sで反撃した！"
  MPCONVERT       = "%sはダメージをＭＰ消費に変換した！"
  GOLDCONVERT     = "%sはダメージをゴールド消費に変換した！"
  MPDRAIN         = "%sはＭＰを %s 吸収した！"
  GOLDDRAIN       = "%sはゴールドを %s 回収した！"
  
  Ext_CounterAttack   = "%sは%sで反撃した！"
  ChaseAttack     = "%sは追撃した！"
  CounterBreak    = "%sは反撃を無効化した！"
  TrapInvoke      = "%sが発動！"
  TeamSkill       = "%sと%s"
  
  NOEFFECT        = "%sには効果が無かった！"
end
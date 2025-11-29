#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  # ショップ画面
  ShopBuy         = "Купить"
  ShopSell        = "Продать"
  ShopCancel      = "До свидания"
  Possession      = "У меня"

  # ステータス画面
  ExpTotal        = "現在の経験値"
  ExpNext         = "次の%sまで"

  # セーブ／ロード画面
  SaveMessage     = "В какой файл сохранить?"
  LoadMessage     = "Какой файл загрузить?"
  File            = "Файл"

  # 複数メンバーの場合の表示
  PartyName       = "%s с друзьями"

  # 戦闘基本メッセージ
  Emerge          = "Против вас %s!"
  Preemptive      = "%s застаёт противника врасплох!"
  Surprise        = "%s застигнута врасплох!"
  EscapeStart     = "%s убегает!"
  EscapeFailure   = "...А нет, не убегает!"

  # 戦闘終了メッセージ
  Victory         = "%s побеждает!"
  Defeat          = "%s терпит поражение."
  ObtainExp       = "Получила %s опыта!"
  ObtainGold      = "Получила %s\\G!"
  ObtainItem      = "%s — у меня!"
  LevelUp         = "%s теперь уровня %s!"
  ObtainSkill     = "%s — изучила!"

  # アイテム使用
  UseItem         = "%s использует %s!"

  # クリティカルヒット
  CriticalToEnemy = "Точный критический удар!!"
  CriticalToActor = "Болючий критический удар!!"

  # アクター対象の行動結果
  ActorDamage     = "%s получает %s ед. урона!"
  ActorRecovery   = "%s восстанавливает %s %s!"
  ActorGain       = "%s получает %s %s!"
  ActorLoss       = "%s теряет %s %s!"
  ActorDrain      = "%s отдаёт %s %s!"
  ActorNoDamage   = "%s не получает урона!"
  ActorNoHit      = "Промах! %s не получает урона!"

  # 敵キャラ対象の行動結果
  EnemyDamage     = "%s получает %s ед. урона!"
  EnemyRecovery   = "%s восстанавливает %s %s!"
  EnemyGain       = "%s получает %s %s!"
  EnemyLoss       = "%s теряет %s %s!"
  EnemyDrain      = "%s отдаёт %s %s!"
  EnemyNoDamage   = "%s не получает урона!"
  EnemyNoHit      = "Промах! %s не получает урона!"

  # 回避／反射
  Evasion         = "%s уворачивается от атаки!"
  MagicEvasion    = "%sは魔法を打ち消した！"
  MagicReflection = "%sは魔法を跳ね返した！"
  CounterAttack   = "%s атакует в ответ!"
  Substitute      = "%s прикрывает собой (%s)."

  # 能力強化／弱体
  BuffAdd         = "%s: %s растёт!"
  DebuffAdd       = "%s: %s снижается!"
  BuffRemove      = "%s: %s возвращается к норме!"

  # スキル、アイテムの効果がなかった
  ActionFailure   = "%sには効かなかった！"

  # エラーメッセージ
  PlayerPosError  = "プレイヤーの初期位置が設定されていません。"
  EventOverflow   = "コモンイベントの呼び出しが上限を超えました。"

  # 基本ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力値
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備タイプ
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # コマンド
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 通貨単位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # レベル
  def self.level_a;     basic(1);     end   # レベル (短)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (短)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (短)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (短)
  def self.fight;       command(0);   end   # 戦う
  def self.escape;      command(1);   end   # 逃げる
  def self.attack;      command(2);   end   # 攻撃
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # アイテム
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # 並び替え
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # ゲーム終了
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 防具
  def self.key_item;    command(14);  end   # 大事なもの
  def self.equip2;      command(15);  end   # 装備変更
  def self.optimize;    command(16);  end   # 最強装備
  def self.clear;       command(17);  end   # 全て外す
  def self.new_game;    command(18);  end   # ニューゲーム
  def self.continue;    command(19);  end   # コンティニュー
  def self.shutdown;    command(20);  end   # シャットダウン
  def self.to_title;    command(21);  end   # タイトルへ
  def self.cancel;      command(22);  end   # やめる
  #--------------------------------------------------------------------------
end

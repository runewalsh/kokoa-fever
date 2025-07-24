class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      enemy.screen_x = member.x #
      enemy.screen_out_pos #
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end

end

class Game_Enemy < Game_Battler
 
  # 戦闘のコモンイベント―スクリプトでも呼び出し可能　（$game_troop.members[0].screen_out_pos）
  # ([0]は１番目のキャラ。大きさの違うキャラの"変身"後などに)
  #というか　$game_troop.members[0].screen_y = 222 とか書けば、好きな位置に配置できるけども

     def screen_out_pos
       tmp_bitmap = Cache.battler(self.battler_name, self.battler_hue)
       #self.screen_x = Graphics.width / 2
       self.screen_y = Graphics.height / 2 + (tmp_bitmap.height / 2)
    end
end

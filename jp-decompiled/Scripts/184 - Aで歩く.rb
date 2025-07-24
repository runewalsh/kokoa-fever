class Game_Player

#--------------------------------------------------------------------------
# ● ダッシュ状態判定 
#--------------------------------------------------------------------------
def dash?
return false if @move_route_forcing
return false if $game_map.disable_dash?
return false if vehicle
#ボタンAを押していない場合をダッシュ中と判定する
return !(Input.press?(:A))
end

end
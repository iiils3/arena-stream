extends Node
class_name ArenaLifeSystem
signal life_lost(remaining:int)
signal respawn_requested(seconds:float,final_life:bool)
signal final_life_entered()
signal eliminated(seconds:float)
const STARTING_LIVES:=2
const FIRST_RESPAWN:=3.0
const FULL_ELIMINATION:=180.0
const FINAL_ELIMINATION:=300.0
var lives:=STARTING_LIVES
var final_life:=false
var eliminated_until:=0.0
func on_death(now:float)->void:
    if final_life:
        eliminated_until=now+FINAL_ELIMINATION
        eliminated.emit(FINAL_ELIMINATION)
        return
    lives-=1
    life_lost.emit(lives)
    if lives>0:
        respawn_requested.emit(FIRST_RESPAWN,false)
        return
    final_life=true
    final_life_entered.emit()
    eliminated_until=now+FULL_ELIMINATION
    eliminated.emit(FULL_ELIMINATION)
func ready_for_final_life(now:float)->bool:
    return final_life and eliminated_until>0.0 and now>=eliminated_until
func consume_final_life()->void:
    eliminated_until=0.0
func heart_bonus(amount:int=3)->void:
    lives+=amount
    if final_life:
        final_life=false
        eliminated_until=0.0
func is_temporarily_eliminated(now:float)->bool:
    return now<eliminated_until

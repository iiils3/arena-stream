using UnityEngine;
using UnityEngine.EventSystems;

public class ArenaTouchButton : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public enum Action { Attack, Heavy, Block, Dodge, Sprint, Interact }
    public Action action;
    public void OnPointerDown(PointerEventData eventData) {
        var input = ArenaInput.Instance;
        if (!input) return;
        switch (action) {
            case Action.Attack: input.PressAttack(); break;
            case Action.Heavy: input.PressHeavy(); break;
            case Action.Block: input.SetBlock(true); break;
            case Action.Dodge: input.PressDodge(); break;
            case Action.Sprint: input.SetSprint(true); break;
            case Action.Interact: input.PressInteract(); break;
        }
    }
    public void OnPointerUp(PointerEventData eventData) {
        var input = ArenaInput.Instance;
        if (!input) return;
        if (action == Action.Block) input.SetBlock(false);
        if (action == Action.Sprint) input.SetSprint(false);
    }
    private void OnDisable() { OnPointerUp(null); }
}

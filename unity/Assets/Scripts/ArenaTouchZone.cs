using UnityEngine;
using UnityEngine.EventSystems;

public class ArenaTouchZone : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    public enum Zone { Move, Look }
    public Zone zone;
    [SerializeField] private float joystickRadius = 85f;
    [SerializeField] private float lookScale = 1f;
    [SerializeField] private RectTransform knob;
    private int activePointer = int.MinValue;
    private Vector2 start, previous;
    public void OnPointerDown(PointerEventData e) {
        if (activePointer != int.MinValue) return;
        activePointer = e.pointerId; start = previous = e.position;
        OnDrag(e);
    }
    public void OnDrag(PointerEventData e) {
        if (e.pointerId != activePointer || !ArenaInput.Instance) return;
        if (zone == Zone.Move) {
            Vector2 move = Vector2.ClampMagnitude((e.position - start) / Mathf.Max(1, joystickRadius), 1);
            ArenaInput.Instance.SetMove(move);
            if (knob) knob.anchoredPosition = move * joystickRadius;
        } else {
            ArenaInput.Instance.AddLook((e.position - previous) * lookScale);
            previous = e.position;
        }
    }
    public void OnPointerUp(PointerEventData e) {
        if (e != null && e.pointerId != activePointer) return;
        activePointer = int.MinValue;
        if (ArenaInput.Instance && zone == Zone.Move) ArenaInput.Instance.SetMove(Vector2.zero);
        if (knob) knob.anchoredPosition = Vector2.zero;
    }
    private void OnDisable() { OnPointerUp(null); }
}

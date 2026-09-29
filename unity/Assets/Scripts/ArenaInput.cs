using UnityEngine;

// Keyboard/mouse plus mobile UI actions. No paid input assets.
public class ArenaInput : MonoBehaviour
{
    public static ArenaInput Instance { get; private set; }
    public Vector2 MobileMove { get; private set; }
    public Vector2 MobileLook { get; private set; }
    private bool mobileAttack;
    private bool mobileHeavy;
    public bool MobileBlock { get; private set; }
    private bool mobileDodge;
    public bool MobileSprint { get; private set; }
    private bool mobileInteract;
    public bool IsMobile => Application.isMobilePlatform;
    public Vector2 Move => Vector2.ClampMagnitude(
        new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical")) + MobileMove, 1f);
    public Vector2 Look => IsMobile ? MobileLook : new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
    public bool Attack => Input.GetMouseButtonDown(0) || Consume(ref mobileAttack);
    public bool Heavy => Input.GetKeyDown(KeyCode.Q) || Consume(ref mobileHeavy);
    public bool Block => Input.GetMouseButton(1) || MobileBlock;
    public bool Dodge => Input.GetKeyDown(KeyCode.Space) || Consume(ref mobileDodge);
    public bool Sprint => Input.GetKey(KeyCode.LeftShift) || MobileSprint;
    public bool Interact => Input.GetKeyDown(KeyCode.E) || Consume(ref mobileInteract);
    private static bool Consume(ref bool value) { bool result = value; value = false; return result; }
    private void Awake() { if (Instance != null && Instance != this) { Destroy(gameObject); return; } Instance = this; }
    public void SetMove(Vector2 value) => MobileMove = Vector2.ClampMagnitude(value, 1);
    public void AddLook(Vector2 delta) => MobileLook += delta;
    public void ResetLook() => MobileLook = Vector2.zero;
    public void PressAttack() => mobileAttack = true;
    public void PressHeavy() => mobileHeavy = true;
    public void SetBlock(bool pressed) => MobileBlock = pressed;
    public void PressDodge() => mobileDodge = true;
    public void SetSprint(bool pressed) => MobileSprint = pressed;
    public void PressInteract() => mobileInteract = true;
    private void OnDisable() { MobileMove = MobileLook = Vector2.zero; MobileBlock = MobileSprint = false; }
}

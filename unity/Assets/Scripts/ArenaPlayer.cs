using UnityEngine;

[RequireComponent(typeof(CharacterController), typeof(ArenaFighter))]
public class ArenaPlayer : MonoBehaviour
{
    [SerializeField] private Camera playerCamera;
    [SerializeField] private Transform attackOrigin;
    [SerializeField] private LayerMask enemyLayers = ~0;
    [SerializeField] private float walkSpeed = 4.8f, sprintSpeed = 7.2f, gravity = -22f;
    [SerializeField] private float mouseSensitivity = 1.7f, mobileSensitivity = .11f;
    private CharacterController motor;
    private ArenaFighter fighter;
    private float pitch, verticalVelocity, attackCooldown, dodgeCooldown;
    private Vector3 dodgeVelocity;
    private bool blocking;
    private void Awake() {
        motor = GetComponent<CharacterController>(); fighter = GetComponent<ArenaFighter>();
        if (!playerCamera) playerCamera = GetComponentInChildren<Camera>();
        if (!attackOrigin && playerCamera) attackOrigin = playerCamera.transform;
    }
    private void Start() { if (!Application.isMobilePlatform) { Cursor.lockState = CursorLockMode.Locked; Cursor.visible = false; } }
    private void Update() {
        var input = ArenaInput.Instance;
        if (!input || !fighter.IsAlive) return;
        float dt = Time.deltaTime;
        Vector2 look = input.Look;
        float sensitivity = input.IsMobile ? mobileSensitivity : mouseSensitivity;
        transform.Rotate(0, look.x * sensitivity, 0);
        pitch = Mathf.Clamp(pitch - look.y * sensitivity, -78, 78);
        if (playerCamera) playerCamera.transform.localRotation = Quaternion.Euler(pitch, 0, 0);
        input.ResetLook();
        attackCooldown = Mathf.Max(0, attackCooldown - dt);
        dodgeCooldown = Mathf.Max(0, dodgeCooldown - dt);
        blocking = input.Block && fighter.Stamina > 0;
        Vector2 axes = input.Move;
        Vector3 direction = transform.right * axes.x + transform.forward * axes.y;
        direction = Vector3.ClampMagnitude(direction, 1);
        bool sprint = input.Sprint && !blocking && direction.sqrMagnitude > .01f && fighter.Stamina > 0;
        float speed = sprint ? sprintSpeed : walkSpeed;
        if (sprint) fighter.SpendStamina(Mathf.Min(fighter.Stamina, 13f * dt));
        if (blocking) { speed *= .45f; fighter.SpendStamina(Mathf.Min(fighter.Stamina, 7f * dt)); }
        if (!sprint && !blocking) fighter.Recover(15f * dt);
        if (input.Dodge && dodgeCooldown <= 0 && fighter.SpendStamina(24)) {
            dodgeVelocity = (direction.sqrMagnitude > .01f ? direction : -transform.forward) * 9f;
            dodgeCooldown = .8f;
        }
        dodgeVelocity = Vector3.MoveTowards(dodgeVelocity, Vector3.zero, 25f * dt);
        if (motor.isGrounded && verticalVelocity < 0) verticalVelocity = -2;
        verticalVelocity += gravity * dt;
        motor.Move((direction * speed + dodgeVelocity + Vector3.up * verticalVelocity) * dt);
        if (!blocking && input.Heavy) Strike(43, 35, .82f);
        else if (!blocking && input.Attack) Strike(24, 17, .43f);
    }
    private void Strike(float damage, float cost, float cooldown) {
        if (attackCooldown > 0 || !fighter.SpendStamina(cost)) return;
        attackCooldown = cooldown;
        Transform origin = attackOrigin ? attackOrigin : transform;
        Vector3 center = origin.position + origin.forward * 1.35f;
        Collider[] hits = Physics.OverlapSphere(center, 1.1f, enemyLayers, QueryTriggerInteraction.Ignore);
        var damaged = new System.Collections.Generic.HashSet<ArenaFighter>();
        foreach (Collider hit in hits) {
            ArenaFighter target = hit.GetComponentInParent<ArenaFighter>();
            if (target && target != fighter && damaged.Add(target)) {
                Vector3 toTarget = target.transform.position - transform.position;
                if (Vector3.Dot(transform.forward, toTarget.normalized) > .25f) target.TakeHit(damage);
            }
        }
    }
    public void ReceiveHit(float damage) => fighter.TakeHit(damage, blocking);
    private void OnFighterDeath() { Cursor.lockState = CursorLockMode.None; Cursor.visible = true; }
}

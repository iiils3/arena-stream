using UnityEngine;

[RequireComponent(typeof(ArenaFighter))]
public class ArenaEnemy : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private float speed = 2.2f, attackRange = 1.9f, attackInterval = 1.4f;
    private ArenaFighter fighter;
    private float nextAttack;
    private void Awake() { fighter = GetComponent<ArenaFighter>(); }
    private void Start() {
        if (!target) {
            ArenaPlayer player = FindFirstObjectByType<ArenaPlayer>();
            if (player) target = player.transform;
        }
    }
    private void Update() {
        if (!fighter.IsAlive || !target) return;
        Vector3 delta = target.position - transform.position;
        delta.y = 0;
        if (delta.sqrMagnitude < .01f) return;
        transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(delta), 270f * Time.deltaTime);
        if (delta.magnitude > attackRange) {
            transform.position += delta.normalized * speed * Time.deltaTime;
        } else if (Time.time >= nextAttack) {
            nextAttack = Time.time + attackInterval;
            ArenaPlayer player = target.GetComponent<ArenaPlayer>();
            if (player) player.ReceiveHit(12);
        }
    }
    private void OnFighterDeath() { gameObject.SetActive(false); }
}

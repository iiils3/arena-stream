using UnityEngine;

public class ArenaFighter : MonoBehaviour
{
    [SerializeField] private float maxHealth = 100f;
    [SerializeField] private float maxStamina = 100f;
    public float Health { get; private set; }
    public float Stamina { get; private set; }
    public bool IsAlive => Health > 0;
    public float HealthRatio => Health / maxHealth;
    public float StaminaRatio => Stamina / maxStamina;
    private void Awake() { Health = maxHealth; Stamina = maxStamina; }
    public bool SpendStamina(float amount) {
        if (!IsAlive || Stamina < amount) return false;
        Stamina -= amount; return true;
    }
    public void Recover(float amount) { if (IsAlive) Stamina = Mathf.Min(maxStamina, Stamina + amount); }
    public void TakeHit(float damage, bool blocking = false) {
        if (!IsAlive) return;
        Health = Mathf.Max(0, Health - (blocking ? damage * .25f : damage));
        if (!IsAlive) SendMessage("OnFighterDeath", SendMessageOptions.DontRequireReceiver);
    }
    public void ResetFighter() { Health = maxHealth; Stamina = maxStamina; }
}

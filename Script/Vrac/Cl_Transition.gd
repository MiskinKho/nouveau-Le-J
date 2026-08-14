extends CanvasLayer  # Couche UI au-dessus de tout : garantit que le fondu couvre l'intégralité de l'écran

@onready var fondu = $Fondu  # ColorRect ou Sprite noir qui couvre tout l'écran

signal transition_terminee  # Émis après le fondu retour : le callback post-transition peut s'exécuter

# Lance une transition en trois phases : fondu au noir → action masquée → fondu retour.
# Ne connaît aucun personnage : l'appelant fournit ce qui doit se produire pendant que l'écran est noir.
func lancer_transition(pendant_le_noir: Callable = Callable()):
	# Phase 1 : fondu au noir en 0.5 seconde
	var tween = create_tween()
	tween.tween_property(fondu, "modulate:a", 1.0, 0.5)  # Alpha 0 → 1
	await tween.finished

	# Phase 2 : exécute l'action fournie par l'appelant pendant que l'écran est masqué
	if pendant_le_noir.is_valid():        # Garde-fou : une transition peut être un simple fondu sans action
		await pendant_le_noir.call()      # Await pour supporter un callback synchrone comme asynchrone

	# Phase 3 : fondu retour en 0.5 seconde
	var tween2 = create_tween()
	tween2.tween_property(fondu, "modulate:a", 0.0, 0.5)  # Alpha 1 → 0
	await tween2.finished

	emit_signal("transition_terminee")  # Informe l'appelant que la transition est terminée

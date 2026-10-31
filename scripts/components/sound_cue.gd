extends AudioStreamPlayer
## Short original synthesized placeholders, generated once per node.

@export_enum("sword", "hurt", "rune", "checkpoint", "death") var cue: String = "sword"


func _ready() -> void:
	var frequencies := {"sword": 350.0, "hurt": 150.0, "rune": 740.0, "checkpoint": 520.0, "death": 110.0}
	var sample_rate := 22050
	var count := int(sample_rate * 0.16)
	var data := PackedByteArray()
	data.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = 47
	var phase := 0.0
	for index in count:
		var progress := float(index) / count
		phase += TAU * float(frequencies[cue]) * (1.0 + progress * 0.7) / sample_rate
		var wave := sin(phase)
		if cue == "sword":
			wave = random.randf_range(-1.0, 1.0)
		var envelope := minf(progress * 25.0, 1.0) * pow(1.0 - progress, 2)
		data.encode_s16(index * 2, int(wave * envelope * 12000))
	var sample := AudioStreamWAV.new()
	sample.format = AudioStreamWAV.FORMAT_16_BITS
	sample.mix_rate = sample_rate
	sample.data = data
	stream = sample
	volume_db = -12.0

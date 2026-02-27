import SwiftUI

func anxietyLabel(for value: Int) -> String {
	switch value {
	case 1: return "Peaceful"
	case 2: return "Calm"
	case 3: return "Slightly uneasy"
	case 4: return "A bit nervous"
	case 5: return "Moderately anxious"
	case 6: return "Quite anxious"
	case 7: return "Very anxious"
	case 8: return "Quite stressed "
	case 9: return "Extremely overwhelmed"
	case 10: return "Cannot function right now"
	default: return ""
	}
}

func pastelAnxietyColor(for value: Double) -> Color {
	let clamped = max(1, min(10, value))
	let progress = (clamped - 1) / 9

	return Color(
		hue: 0.33 * (1 - progress),
		saturation: 0.38,
		brightness: 0.95
	)
}

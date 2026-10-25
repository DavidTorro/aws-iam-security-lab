locals {
  # Ventana horaria en el formato ISO 8601 que espera aws:CurrentTime
  business_window = {
    window_start = "${var.business_day}T${var.opening_time}:00Z"
    window_end   = "${var.business_day}T${var.closing_time}:00Z"
  }
}

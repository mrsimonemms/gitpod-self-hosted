variable "managers" {
  type = list(object({
    node = object({
      name       = string
      public_ip  = string
      private_ip = string
      username   = string
    })
    labels      = map(bool)
    private_key = string
  }))
  default = []

  validation {
    error_message = "There must be at least one node"
    condition     = length(var.managers) > 0
  }
}

class Capabilities {
  static hasMirror {
    var f = Fiber.new {
      import "mirror"
    }
    f.try()
    return f.error ? false : true
  }
}
import "../wren-assert/Assert" for Assert
import "random" for Random
var RND = Random.new()

var SAD_EMOTION = ["😡","👺","👿","🙀","💩","😰","😤","😬"]
class Runner {
    construct new(name) {
        _name = name
        _fail = _skip = _success = 0
    }
    start() { System.print(_name + "\n") }
    skip(name) {
        _skip = _skip + 1
        System.print("  🔹 [skip] %(name)")
    }
    fail(name, error) {
        _fail = _fail + 1   
        System.print("  ❌ %(name) \n     %(error)\n")
    }
    success(name) {
        _success = _success + 1
        System.print("  ✅ %(name)")
    }
    sadEmotion { SAD_EMOTION[RND.int(SAD_EMOTION.count)] }
    done() {
        var all = _success + _fail + _skip
        var overall = "💯"
        if (_fail > 0) overall = "❌ %(sadEmotion)"
        System.print("")
        System.print("  %(overall) ✓ %(_success) successes, ✕ %(_fail) failures, ☐ %(_skip) skipped\n")
    }
}

class Skipper {
    construct new(that) {
        _that = that
    }
    should(a,b) {
        _that.skip(a,b)
    }
}
class Testie {
    construct new(name, fn) {
        _shoulds = []
        _skips = []
        _name = name
        fn.call(this, Skipper.new(this))
    }
    should(name, fn) {
        _shoulds.add([name, fn])
    }
    skip(name, fn) {
        _skips.add([name,fn])
    }
    runner=(v){ _runner = v }
    runner { _runner || Runner }
    run() {
        var r = runner.new(_name)
        r.start()

        for (test in _shoulds) {
            var name = test[0]
            var fn = test[1]
            var fiber = Fiber.new(fn)
            fiber.try()
            if (fiber.error) {
                r.fail(name, fiber.error)
            } else {
                r.success(name)
            }
        }
        for (test in _skips) {
            var name = test[0]
            r.skip(name)
        }
        r.done()
    }
}
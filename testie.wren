import "random" for Random
import "io" for Stdout
import "os" for Process
import "./vendor/colors" for Colors as Color
import "./reporters/cute" for CuteReporter
import "./src/expect" for Expect
var RND = Random.new()

class Test {
    construct new(name, fn) {
        _name = name
        _fn = fn
        _skip = false
    }
    skip { _skip }
    name { _name }
    fn { _fn }
    skip() { _skip = true }
}

class Testie {
    initialize_(name, fn) {
        _tests = []
        _skips = []
        _name = name
        _fails = 0
        _afterEach = _beforeEach = Fn.new {}
        fn.call(this, Skipper.new(this))
    }

    construct new(name, fn) {
        initialize_(name, fn)
    }
    construct new(name, options, fn) {
        initialize_(name, fn)
        for (option in options) {
            if (option.key == "reporter") {
                _reporter = option.value
            }
        }
    }

    static test(name, fn) { Testie.new(name,fn).run() }
    static test(name, options, fn) { Testie.new(name, options, fn).run() }

    expect(v) { Expect.that(v) }
    afterEach(fn) { _afterEach = fn }
    beforeEach(fn) { _beforeEach = fn }
    reporter=(v){ _reporter = v }
    reporter { _reporter || CuteReporter }

    // aliases
    must(name, fn) { test(name,fn) }
    should(name, fn) { test(name,fn) }
    describe(name, fn) { context(name,fn) }

    // core API
    test(name, fn) { _tests.add(Test.new(name, fn)) }
    skip(name, fn) { test(name,fn).skip() }
    context(name, fn) {
        _tests.add(name)
        fn.call()
    }
    run() {
        if (!(_tests[0] is String)) { _name = _name + "\n" }
        var r = reporter.new(_name)

        // sections and tests are co-mingled
        var numberOfTests = _tests.where {|t| t is Test}.count
        r.start(numberOfTests)

        var i = 0
        for (test in _tests) {
            if (test is String) {
                r.section(test)
                i = i + 1
                continue
            }
            if (test.skip) {
                r.skip(test.name)
                i = i + 1
                continue
            }

            _beforeEach.call()
            var fiber = Fiber.new(test.fn)
            var error = fiber.try()
            if (error) {
                _fails = _fails + 1
                r.fail(test.name, fiber)
            } else {
                r.success(test.name)
            }
            _afterEach.call()
            i = i + 1
        }
        r.done()
        Stdout.flush()

        if (_fails > 0) Process.exit(1)
    }
}


class Skipper {
    construct new(that) {
        _that = that
    }
    test(a,b) { _that.skip(a,b) }
    should(a,b) { _that.skip(a,b) }
}

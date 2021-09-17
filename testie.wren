import "random" for Random
import "io" for Stdout
import "os" for Process
import "./vendor/colors" for Colors as Color
import "./src/reporter" for CuteReporter
import "./src/expect" for Expect
import "./src/capabilities" for Capabilities
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
    construct new(name, fn) {
        _tests = []
        _skips = []
        _name = name
        _fails = 0
        _abortAfterFailures = true
        _afterEach = _beforeEach = Fn.new {}
        fn.call(this, Skipper.new(this))
    }
    static test(name, fn) { Testie.new(name,fn).run() }
    static test(name, options, fn) {
        var testie = Testie.new(name,fn)
        for (option in options) {
            if (option.key == "reporter") {
                testie.reporter = option.value
            }
            if (option.key == "abortAfterFailures") {
                testie.abortAfterFailures_ = option.value
            }
        }
        testie.run()
    }
    expect(v) { Expect.that(v) }
    afterEach(fn) { _afterEach = fn }
    beforeEach(fn) { _beforeEach = fn }
    abortAfterFailures_=(v){ _abortAfterFailures = v }
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
        r.start()

        var i = 0
        var first_error
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
                if (first_error == null) first_error = i
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

        if (first_error && !Capabilities.hasMirror) {
            var test = _tests[first_error]
            System.print(Color.BLACK + Color.BOLD + "--- TEST " + "-" * 66 + Color.RESET)
            System.print("%(test.name)\n")
            System.print(Color.BLACK + Color.BOLD + "--- STACKTRACE " + "-" * 60 + Color.RESET)
            Stdout.flush()
            Fiber.new(test.fn).call()
        }
        if (_fails > 0 && _abortAfterFailures) {
            Fiber.abort("Failing tests.")
        }
    }
}


class Skipper {
    construct new(that) {
        _that = that
    }
    test(a,b) { _that.skip(a,b) }
    should(a,b) { _that.skip(a,b) }
}

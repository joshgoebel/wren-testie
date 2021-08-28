import "../vendor/colors" for Colors as Color

class ExpectError {
    construct new(error) {
        _error = error
    }
    static throw(error) { ExpectError.new(error).throw() }
    error { _error }
    throw() { Fiber.abort(this) }
    toString { _error }
}

class DeepEqual {
    static isEqual(a,b) {
        if (a is List && b is List) {
            return listEqual_(a,b)
        } else if (a is Map && b is Map) {
            return mapEqual_(a,b)
        } else {
            return a == b
        }
    }
    static listEqual_(a,b) {
        if (a.count != b.count) return false
        for (i in 0...a.count) {
            if (!isEqual(a[i],b[i])) return false
        }
        return true
    }
    static mapEqual_(a,b) {
        if (a.count != b.count) return false
        for (key in a.keys) {
            if (!b.containsKey(key)) return false
            if (!isEqual(a[key],b[key])) return false
        }
        return true
    }
}

class Expect {
    construct new(value) { _value = value }
    static that(v) { Expect.new(v) }
    static value(v) { Expect.new(v) }

    // Equality tests
    toBe(v) { toEqual(v) }
    toNotBe(v) { toNotEqual(v) }

    toEqual(v) { toEqual_(v, false) }
    toNotEqual(v) { toEqual_(v, true) }

    toEqual_(v, isNegated) {
        var not = isNegated ? "not " : ""
        var method = isNegated ? "toNotEqual" : "toEqual"
        if (_value is List && v is List) {
            assert(
                expr(DeepEqual.isEqual(_value,v), isNegated),
                "Expected list %(printValue_(_value)) %(not)to be %(printValue_(v))"
            )
            return
        }
        if (v is Map && _value is Map) {
            assert(
                expr(DeepEqual.isEqual(_value,v), isNegated),
                "Expected %(_value) %(not)to be %(v)"
            )
            return
        }
        assert(expr(_value == v, isNegated), buildErrorMessage_(v, _value, method))
    }
    expr(expression, isNegated) {
        // a boolean XOR
        return ( expression && !isNegated) ||
               (!expression &&  isNegated)
    }

    // Numeric less-than, greater-than tests
    toBeGreaterThan(v) {
        assert(_value > v, "Expected %(_value) to be greater than %(v)")
    }
    toBeGreaterThanOrEqual(v) {
        assert(_value >= v, "Expected %(_value) to be greater than or equal to %(v)")
    }
    toBeLessThan(v) {
        assert(_value < v, "Expected %(_value) to be less than %(v)")
    }
    toBeLessThanOrEqual(v) {
        assert(_value <= v, "Expected %(_value) to be less than or equal to %(v)")
    }

    // List element tests
    toIncludeSameItemsAs(v) {
        assert(_value.count == v.count, "Expected %(_value) to have same count as %(v)")
        for (item in _value) {
            assert(v.contains(item), "Expected %(_value) to have same items as %(v) ('%(item)' is missing)")
        }
    }

    // Nullity
    toBeDefined() {
        assert(_value != null, "Expected %(_value) to be defined (not null)")
    }
    toBeNull() {
        assert(_value == null, "Expected %(_value) to be null")
    }

    // Error tests
    #!deprecated
    abortsWith(errorMessage) { toAbortWith(errorMessage) }

    toAbortWith(expectedMessage) {
        var f = Fiber.new { _value.call() }
        var result = f.try()
        var errorMessage = f.error
        // an ExpectError has the string error in it's `error` accessor
        if (f.error && f.error is ExpectError) {
            errorMessage = f.error.error
        }
        if (errorMessage == null) {
            raise("Expected error '%(expectedMessage)' but no error occurred")
            return
        }
        assert(errorMessage == expectedMessage, "Expected error '%(expectedMessage)' but got %(errorMessage)")
    }
    toNotAbort() {
        var f = Fiber.new { _value.call() }
        var result = f.try()
        assert(f.error == null, "Expected no error but got: %(f.error)")
    }

    // utility methods
    raise(message) { ExpectError.throw(message) }
    assert(expression, errorMessage) {
        if (!expression) raise(errorMessage)
    }
    printValue_(v) {
        if (v is String) {
            return "`%(v)`"
        } else if (v is List) {
            return "[" + v.map {|x| printValue_(x) }.join(", ") +  "]"
        } else {
            return "%(v)"
        }
    }
    buildErrorMessage_(expected, received, methodName) {
        var fade = "%(Color.BLACK + Color.BOLD)"
        var err="%(fade)expect(%(Color.RESET + Color.RED)received%(fade)).%(methodName)(%(Color.RESET + Color.GREEN)expected%(fade)) // deep equality\n\n"
        err = err + "%(Color.WHITE + Color.BOLD)Expected:%(Color.RESET) "
        err = err + Color.GREEN + printValue_(expected) + Color.RESET + "\n"
        err = err + "%(Color.WHITE + Color.BOLD)Received:%(Color.RESET) "
        err = err + Color.RED + printValue_(received) + Color.RESET
        return err
    }
}

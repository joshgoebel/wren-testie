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
    static list(a,b) {
        if (a.count != b.count) return false
        for (i in 0...a.count) {
            var c = a[i]
            var d = b[i]
            if (c is List && d is List) {
                if (!DeepEqual.list(c,d)) return false
            } else if (c is Map && d is Map) {
                if (!DeepEqual.map(c,d)) return false
            } else if (c != d) {
                return false
            }
        }
        return true
    }
    static map(a,b) {
        if (a.count != b.count) return false
        for (entry in a) {
            if (!b.containsKey(entry.key)) return false
            var c = entry.value
            var d = b[entry.key]
            if (c is List && d is List) {
                if (!DeepEqual.list(c,d)) return false
            } else if (c is Map && d is Map) {
                if (!DeepEqual.map(c,d)) return false
            } else if (c != d) {
                return false
            }
        }
        return true
    }
}

class Expect {
    construct new(value) { _value = value }
    raise(message) { ExpectError.throw(message) }
    static that(v) { Expect.new(v) }
    static value(v) { Expect.new(v) }
    toBe(v) { toEqual(v) }
    equalMaps_(v) {
        return DeepEqual.map(_value,v)
    }
    toIncludeSameItemsAs(v) {
        if (_value.count != v.count) return false
        for (item in _value) {
            if (!v.contains(item)) return false
        }
        return true
    }
    equalLists_(v) {
        return DeepEqual.list(_value,v)
    }
    toNotAbort() {
        // no need to do anything
    }
    abortsWith(err) {
        var f = Fiber.new { _value.call() }
        var result = f.try()
        if (result!=err) {
            raise("Expected error '%(err)' but got none")
        }
    }
    toBeGreaterThanOrEqual(v) {
        if (_value >= v) return
        raise("Expected %(_value) to be greater than or equal to %(v)")
    }
    toBeLessThanOrEqual(v) {
        if (_value <= v) return
        raise("Expected %(_value) to be less than or equal to %(v)")
    }
    printValue(v) {
        if (v is String) {
            return "`%(v)`"
        } else if (v is List) {
            return "[" + v.map {|x| printValue(x) }.join(", ") +  "]"
        } else {
            return "%(v)"
        }
    }
    toBeDefined() {
        if (_value != null) return
        raise("Expected %(_value) to be defined (not null).")
    }
    toEqual(v) {
        if (_value is List && v is List) {
            if (!equalLists_(v)) {
                raise("Expected list %(printValue(_value)) to be %(printValue(v))")
            }
            return
        }
        if (v is Map && _value is Map) {
            if (!equalMaps_(v)) {
                raise("Expected %(_value) to be %(v)")
            }
            return
        }
        if (_value == v) return

        var fade = "%(Color.BLACK + Color.BOLD)"
        var err="%(fade)expect(%(Color.RESET + Color.RED)received%(fade)).toEqual(%(Color.RESET + Color.GREEN)expected%(fade)) // deep equality\n\n"
        err = err + "%(Color.WHITE + Color.BOLD)Expected:%(Color.RESET) "
        err = err + Color.GREEN + printValue(v) + Color.RESET + "\n"
        err = err + "%(Color.WHITE + Color.BOLD)Received:%(Color.RESET) "
        err = err + Color.RED + printValue(_value) + Color.RESET
        raise("%(err)")
    }
}

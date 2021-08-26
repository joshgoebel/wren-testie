import "../src/expect" for DeepEqual, Expect // import this before testie does
import "../testie" for Testie

Testie.test("DeepEqual tests") {|do, skip|

  do.describe("Compare simple values") {
    do.test("numbers") {
      Expect.that(DeepEqual.isEqual(42, 42)).toBe(true)
      Expect.that(DeepEqual.isEqual(42, 43)).toBe(false)
      Expect.that(DeepEqual.isEqual(1000, 1e3)).toBe(true)
      Expect.that(DeepEqual.isEqual(10, 10.0)).toBe(true)
    }
    do.test("booleans") {
      Expect.that(DeepEqual.isEqual(false, false)).toBe(true)
      Expect.that(DeepEqual.isEqual(false, true)).toBe(false)
    }
    do.test("strings") {
      Expect.that(DeepEqual.isEqual("foo", "foo")).toBe(true)
      Expect.that(DeepEqual.isEqual("foo", "bar")).toBe(false)
    }
    do.test("ranges") {
      Expect.that(DeepEqual.isEqual(10..20, 10..20)).toBe(true)
      Expect.that(DeepEqual.isEqual(10..20, 10...20)).toBe(false)
    }
  }

  do.describe("Compare lists") {
    do.test("empty lists") {
      Expect.that(DeepEqual.isEqual([], [])).toBe(true)
    }
    do.test("short lists") {
      Expect.that(DeepEqual.isEqual([1], [1])).toBe(true)
      Expect.that(DeepEqual.isEqual([2], [1])).toBe(false)
      Expect.that(DeepEqual.isEqual([1,2,3], [1,2,3])).toBe(true)
      Expect.that(DeepEqual.isEqual([1,2,3], [1,2,4])).toBe(false)
    }
    do.test("nested lists") {
      Expect.that(DeepEqual.isEqual([1,[2,[3,4]]], [1,[2,[3,4]]])).toBe(true)
      Expect.that(DeepEqual.isEqual([1,[2,[3,4]]], [1,[2,[3,[4]]]])).toBe(false)
    }
  }

  do.describe("Compare maps") {
    do.test("empty maps") {
      Expect.that(DeepEqual.isEqual({}, {})).toBe(true)
    }
    do.test("short maps") {
      Expect.that(DeepEqual.isEqual({"a":1}, {"a":1})).toBe(true)
      Expect.that(DeepEqual.isEqual({"a":1}, {"a":2})).toBe(false)
      Expect.that(DeepEqual.isEqual({"a":1}, {"b":1})).toBe(false)
      Expect.that(DeepEqual.isEqual({"a":1,"b":2}, {"b":2,"a":1})).toBe(true)
    }
    do.test("nested maps") {
      Expect.that(DeepEqual.isEqual({"a":{"b":1}}, {"a":{"b":1}})).toBe(true)
      Expect.that(DeepEqual.isEqual({"a":{"b":1}}, {"a":{"b":2}})).toBe(false)
    }
  }

  do.describe("Mixed lists and maps") {
    do.test("mixed lists and maps") {
      var a = [[1,2,3], {"foo": [4,5], "bar": {10:20}}]
      var b = [[1,2,3], {"bar": {10:20}, "foo": [4,5]}]
      var c = [[1,2,3], {"foo": [4,6], "bar": {10:20}}]
      Expect.that(DeepEqual.isEqual(a, b)).toBe(true)
      Expect.that(DeepEqual.isEqual(a, c)).toBe(false)
    }
  }

  do.describe("Compare objects") {
    do.test("basic object equality") {
      class Thing1 {
        construct new() {}
      }
      var a = Thing1.new()
      var b = Thing1.new()
      Expect.that(DeepEqual.isEqual(a, a)).toBe(true)
      Expect.that(DeepEqual.isEqual(a, b)).toBe(false)
    }
    do.test("objects with == method") {
      class Thing2 {
        construct new(value) {_v = value}
        value {_v}
        ==(other) {this.value == other.value}
      }
      var a = Thing2.new(42)
      var b = Thing2.new(42)
      var c = Thing2.new(43)
      Expect.that(DeepEqual.isEqual(a, b)).toBe(true)
      Expect.that(DeepEqual.isEqual(a, c)).toBe(false)
    }
  }
}

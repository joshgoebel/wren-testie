import "../testie" for Testie
import "../src/expect" for Expect
import "../vendor/colors" for Colors as Color

Testie.test("Expect tests") {|do, skip|

  do.test("equality") {
    Expect.value(1).toBe(1)
    Expect.value(1).toEqual(1)
  }
  do.test("expected equality failures") {
    var err = Expect.new("").buildErrorMessage_(2, 1, "toEqual")
    Expect.that {
      Expect.value(1).toEqual(2)
    }.abortsWith(err)

    Expect.value(1).toNotBe(2)
    Expect.value(1).toNotEqual(2)
  }

  do.test("numeric comparison") {
    Expect.that(1).toBeGreaterThanOrEqual(1)
    Expect.that(1).toBeGreaterThanOrEqual(0)
    Expect.that(1).toBeGreaterThan(0)

    Expect.that {
      Expect.value(1).toBeGreaterThanOrEqual(2)
    }.abortsWith("Expected 1 to be greater than or equal to 2")
    Expect.that {
      Expect.value(1).toBeGreaterThan(2)
    }.abortsWith("Expected 1 to be greater than 2")

    Expect.that(1).toBeLessThanOrEqual(1)
    Expect.that(1).toBeLessThanOrEqual(2)
    Expect.that(1).toBeLessThan(2)

    Expect.that {
      Expect.value(1).toBeLessThanOrEqual(0)
    }.abortsWith("Expected 1 to be less than or equal to 0")
    Expect.that {
      Expect.value(1).toBeLessThan(0)
    }.abortsWith("Expected 1 to be less than 0")
  }

  do.test("nullity") {
    Expect.value(1).toBeDefined()
    Expect.that {
      Expect.value(null).toBeDefined()
    }.abortsWith("Expected null to be defined (not null)")

    Expect.value(null).toBeNull()
    Expect.that {
      Expect.value("hello").toBeNull()
    }.abortsWith("Expected hello to be null")
  }

  do.test("lists") {
    Expect.value([1,2,3]).toEqual([1,2,3])
    Expect.value([1,2,3]).toNotEqual([2,3])

    Expect.value([1,2,3]).toIncludeSameItemsAs([3,1,2])
  }

  do.test("maps") {
    Expect.value({"A":"B","C":"D"}).toEqual({"C":"D","A":"B"})
    Expect.value({"A":"B","C":"D"}).toNotEqual({"A":"B","C":"e"})
  }

  do.test("class that doesn't implement `==`") {
    class Foo {
      construct new(v) { _v = v }
      toString { _v }
    }
    var a = Foo.new("hello")
    Expect.value(a).toEqual(a)  // same object is equal

    var b = Foo.new("hello")
    Expect.value(a).toNotEqual(b)  // different object isn't equal

    var err = Expect.new("").buildErrorMessage_(a, b, "toEqual")
    Expect.that {
      Expect.value(a).toEqual(b)
    }.abortsWith(err)
  }

  do.test("class that does implement `==`") {
    class Bar {
      construct new(v) { _v = v }
      toString { _v }
      ==(other) { _v == other.toString }
    }
    var a = Bar.new("world")
    var b = Bar.new("world")
    Expect.value(a).toEqual(b)

    var err = Expect.new("").buildErrorMessage_(a, b, "toNotEqual")
    Expect.that {
      Expect.value(a).toNotEqual(b)
    }.abortsWith(err)
  }
}

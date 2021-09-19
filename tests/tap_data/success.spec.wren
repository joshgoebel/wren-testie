import "../../testie" for Testie, Expect
import "../../reporters/tap" for TapReporter

Testie.test("Test successfully", {"reporter": TapReporter}) { |do, skip|
  do.test("test 1") {
    Expect.that(1 + 1).toEqual(2)
  }
  do.test("test 2") {
    Expect.that(2 + 2).toEqual(4)
  }
}

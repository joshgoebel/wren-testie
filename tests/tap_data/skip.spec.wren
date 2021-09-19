import "../../testie" for Testie, Expect
import "../../reporters/tap" for TapReporter

Testie.test("Test skipping", {"reporter": TapReporter}) { |do, skip|
  do.test("test 1") {
    Expect.that(1 + 1).toEqual(2)
  }
  skip.test("test 2") {
    // TODO
  }
}

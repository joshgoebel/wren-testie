import "../../testie" for Testie, Expect
import "../../reporters/tap" for TapReporter

Testie.test("Test failures", {
    "reporter": TapReporter,
    "abortAfterFailures": false,
}) { |do, skip|
  do.describe("Success section") {
    do.test("test 1") {
      Expect.that(1 + 1).toEqual(2)
    }
  }
  do.describe("Failure section") {
    do.test("test 2") {
      Expect.that(2 + 2).toEqual(42)
    }
  }
}

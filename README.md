
[![forthebadge](https://forthebadge.com/images/badges/open-source.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)

# <img src="https://wren.io/wren.svg" valign="middle" width="100"> wren-testie

![MIT licensed](https://badgen.net/badge/license/MIT/cyan?scale=1.5)
![version 0.3](https://badgen.net/badge/version/0.3.0/green?scale=1.5)
![wren 0.4](https://badgen.net/badge/wren/0.4/blue?scale=1.5)

Simple and beautiful testing framework for [Wren](https://wren.io).

<img src="example.png">

### Features

- bring whatever assertion library you'd like to use with you
- it's easy to define custom reporters
- less than 100 lines of Wren if you want to learn how it works


### Tests your way

#### Shoulda

```js
Testie.test("Calculator") { |it|
  it.context("basic math") {
    it.should("add") {  }
    it.should("subtract") {  }
  }
}
```

#### Specs

```js
Testie.test("Calculator") { |it|
  it.describe("basic math") {
    it.must("add") {  }
    it.must("subtract") {  }
    it.skip("multiply") {  }
  }
}
```

#### Simple

```js
Testie.test("Calculator") { |it, skip|
  it.describe("basic math") {
    it.test("add") {  }
    it.test("subtract") {  }
    skip.test("multiply") {  }
  }
}
```

I'm open to more styles if they can be accomplished with simple aliases.  Open an issue.

### Example

```js
import "./testie/testie" for Testie, Assert

// defining custom reporters is super simple
class DotReporter
    // ..
    skip(name) { System.write("S") }
    fail(name, error) { System.write("X") }
    success(name) { System.write(".") }
    // ..
end

var suite = Testie.new("Calculator") { |it, skip|

    it.should("add") {
        var calc = Calculator.new()
        Assert.equal(4, calc.add(2,2))
    }
    it.should("subtract") {
        var calc = Calculator.new()
        Assert.equal(4, calc.subtract(9,5))
    }
    skip.should("do Calculus") {
        // TODO: implement
    }

}
suite.reporter = DotReporter
suite.run()
```


### Contributions

Licensed MIT and open to contributions!

Please open an issue to discuss or find me on [Wren Discord](https://discord.gg/VTzuWmBavH).
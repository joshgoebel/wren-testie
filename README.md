
[![forthebadge](https://forthebadge.com/images/badges/open-source.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)

# <img src="https://wren.io/wren.svg" valign="middle" width="100"> wren-testie

![MIT licensed](https://badgen.net/badge/license/MIT/cyan?scale=1.5)
![version 0.1](https://badgen.net/badge/version/0.1.0/green?scale=1.5)
![wren 0.4](https://badgen.net/badge/wren/0.4/blue?scale=1.5)

Simple and beautiful testing for [Wren](https://wren.io).

- bring whatever assertion library you wish
- easy to define a custom reporter

### What it looks like

<img src="example.png">

### Example

```dart
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

    it.should("add) {
        var calc = Calculator.new()
        Assert.equal(4, calc.add(2,2))
    }
    if.should("subtract") {
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
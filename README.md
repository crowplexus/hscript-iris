# PScript

---

a [HScript](https://github.com/HaxeFoundation/hscript) extension made to make the process of creating a script way easier.

---

# USAGE

---

Initializing a PScript should be fairly easy and very much self-explnatory

```haxe
// *
// assets/scripts/hi.hx
// *

function init() {
    trace("Hello from PScript");
}

function countUpTo(number:Int) {
    for (i in 1...number + 1)
        trace(i);
}

// *
// * src/Main.hx
// *

import pscript.PScript;

class Main {
    static function main():Void {
        // reminder that the rules are completely optional.
        final rules:PInitRules = {autoRun: false, preset: true};
        var myScript:PScript = new PScript("assets/scripts/hi.hx", rules);

        // this is necessary in case the `autoRun` rule is disabled when initializing the script, if not it will initialize by itself.
        myScript.execute();

        myScript.call("sayHello"); // prints "Hello from PScript"
        myScript.call("countUpTo", [5]); // prints "1, 2, 3, 4, 5"
    }
}

```

# FEATURES

---

Currently nothing notable aside from just being a fancy and easier to use wrapper for HScript, some features may be added in later iterations of this library

# PLANNED FEATURES...?

[ ] "import" Keyword with proper functionality

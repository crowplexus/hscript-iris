# HScript Iris

---

a [HScript](https://github.com/HaxeFoundation/hscript) extension made to make the process of creating a script way easier.

---

# INSTALLATION

Currently, Iris is not available in the haxelib, you can install it by running the following command

```
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris/
```

Once this is done, go to your Project File, whether that be a build.hxml for Haxe Projects, or Project.xml for OpenFL and Flixel projects, and add `hscript-iris` to your libraries

---

### Haxe Project Example
```hxml
--library hscript-iris

# this is optional and can be added if wanted
# provides descriptive traces and better error handling at runtime
-D hscriptPos
```

### OpenFL / Flixel Project Example

```xml
<haxelib name="hscript-iris" />
<haxedef name="hscriptPos" />
```

---

# FEATURES

[x] - Imports
[ ] - Constants/Finals
[ ] - Enums
[ ] - Classes

---

# USAGE

Initializing a Iris Script should be fairly easy and very much self-explnatory

```haxe
// *
// assets/scripts/hi.hx
// *

function sayHello() {
    trace("Hello from Iris");
}

function countUpTo(number:Int) {
    for (i in 1...number + 1)
        trace(i);
}

// *
// * src/Main.hx
// *

import crowplexus.iris.Iris;

class Main {
    static function main():Void {
        // reminder that the rules are completely optional.
        final rules:InitRules = {name: "My Script", autoRun: false, preset: true};
        final getText:String->String = #if sys sys.io.File.getContent #elseif openfl openfl.utils.Assets.getText #end;
        var myScript:Iris = new Iris(getText("assets/scripts/hi.hx"), rules);

        // this is necessary in case the `autoRun` rule is disabled when initializing the script, if not it will initialize by itself.
        myScript.execute();

        myScript.call("sayHello"); // prints "Hello from Iris"
        myScript.call("countUpTo", [5]); // prints "1, 2, 3, 4, 5"
    }
}

```

# HScript Iris

---

a [HScript](https://github.com/HaxeFoundation/hscript) extension made to make the process of creating a script way easier.

---

Brought to you by:

- [Crow](https://github.com/crowplexus)
- [Ne_Eo](https://github.com/NeeEoo)


- [Setup](docs/SETUP.md)
- [Features](docs/FEATURES.md)
- [Usage](#usage)

---

# USAGE

Initializing a Iris Script should be fairly easy and very much self-explanatory

```haxe
// *
// assets/scripts/hi.hx
// *

// import somepackage.SomeModule;

final greeting:String = "Hello from Iris!";

function sayHello() {
	trace(greeting);

	/*
	// if you try this, this function will crash as `greeting` is a constant value
	greeting = "Uh Oh!";
	// if SomeModule was imported, you can use it here!
	var module:SomeModule = new SomeModule();
	*/
}

function countUpTo(number:Int) {
	for (i in 1...number+1)
		trace(i);
}

// *
// * src/Main.hx
// *

import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

class Main {
	static function main():Void {
		// reminder that the rules are completely optional.
		final rules:RawIrisConfig = {name: "My Script", autoRun: false, autoPreset: true};
		final getText:String->String = #if sys sys.io.File.getContent #elseif openfl openfl.utils.Assets.getText #end;
		var myScript:Iris = new Iris(getText("assets/scripts/hi.hx"), rules);

		// this is necessary in case the `autoRun` rule is disabled when initializing the script, if not it will initialize by itself.
		myScript.execute();

		myScript.call("sayHello"); // prints "Hello from Iris!"
		myScript.call("countUpTo", [5]); // prints "1, 2, 3, 4, 5"
	}
}

```

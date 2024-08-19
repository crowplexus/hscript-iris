# HScript Iris

---

a [HScript](https://github.com/HaxeFoundation/hscript) extension made to make the process of creating a script way easier.

---

Brought to you by:

- [Crow](https://github.com/crowplexus)
- [Ne_Eo](https://github.com/NeeEoo)
- TahirKarabekiroglu

# INSTALLATION

For stable versions, use this

```
haxelib install hscript-iris
```

For unstable versions however, use this

```
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris/
```

Once this is done, go to your Project File, whether that be a build.hxml for Haxe Projects, or Project.xml for OpenFL and Flixel projects, and add `hscript-iris` to your libraries


- [Setup](https://github.com/crowplexus/hscript-iris#setup)
- [Features](https://github.com/crowplexus/hscript-iris#features)
- [Usage](https://github.com/crowplexus/hscript-iris#usage)


---

# SETUP

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

- [ ] Improved Error Handling
- [x] Imports
- - [x] Import Aliases
- [x] Finals
- [x] Enums
- - [ ] Abstract Enums
- [ ] Typedefs
- - [x] Redirects
- - [ ] Class Redirect (automatic import)
- [ ] Classes

- Operators
- - [ ] Null Coalescing Operator (?, ??, ??=)

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

class Main {
	static function main():Void {
		// reminder that the rules are completely optional.
		final rules:InitRules = {name: "My Script", autoRun: false, preset: true};
		final getText:String->String = #if sys sys.io.File.getContent #elseif openfl openfl.utils.Assets.getText #end;
		var myScript:Iris = new Iris(getText("assets/scripts/hi.hx"), rules);

		// this is necessary in case the `autoRun` rule is disabled when initializing the script, if not it will initialize by itself.
		myScript.execute();

		myScript.call("sayHello"); // prints "Hello from Iris!"
		myScript.call("countUpTo", [5]); // prints "1, 2, 3, 4, 5"
	}
}

```

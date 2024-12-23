# 1.1.2

- Fixed `package;` (unnamed) crashing the script.
- Script Package now gets saved in the parser.

# 1.1.1

- Added `package path;` syntax
	- This gets ignored by the interpreter, its simply there to prevent any issues
- Added `using` keyword
	- Right now, this is sort of limited, as you can only use it with `StringTools` and `Lambda`
- Fixed `#end` preprocessor value
	- Your script will no longer crash if you make a code like
		```haxe
		#if openfl
		trace("project is using the OpenFL library.");
		#end
		```
# 1.1.0

Collaborators in this update:
[Ne_Eo](https://github.com/NeeEoo)

- Added Enumerator support, along with constructors.
	- As of now, some functions in the Standard Library `Type` might not be available for scripted enums.
- Added Typedef support.
- Improved importing.
- Improved error handling.
- ANSI Colour support for the console when printing errors.

# 1.0.2

- Haxe 4.2.5 support

# 1.0.1

- Fix packaging, add changelog to the files, Fix some errors.

# 1.0.0

- Initial Haxelib Release
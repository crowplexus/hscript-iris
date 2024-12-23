package crowplexus.iris;

/**
 * This is used to mark classes that can be used with the `using` keyword.
 * You can also add @:irisUsableEntry to your class.
 * If you wanna force the class to be called with any type, you can add @:irisUsableEntry(forceAny)
**/
@:autoBuild(crowplexus.iris.macro.UsingMacro.build())
interface IrisUsingClass {}

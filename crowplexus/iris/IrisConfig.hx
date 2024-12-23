package crowplexus.iris;

abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

typedef RawIrisConfig = {
	var name: String;
	var ?autoRun: Bool;
	var ?autoPreset: Bool;
	var ?localBlocklist: Array<String>;
};

typedef AutoIrisConfig = OneOfTwo<IrisConfig, RawIrisConfig>;

class IrisConfig {
	public var name: String = null;
	public var autoRun: Bool = true;
	public var autoPreset: Bool = true;
	public var packageName: String = null;

	@:unreflective public var localBlocklist: Array<String> = [];

	/**
	 * Initialises the Iris script config.
	 *
	 * @param name			The obvious!
	 * @param autoRun					Makes the script run automatically upon being created.
	 * @param autoPreset			Makes the script automatically set imports to itself upon creation.
	 * @param localBlocklist	List of classes or enums that cannot be used within this particular script
	**/
	public function new(name: String, autoRun: Bool = true, autoPreset: Bool = true, ?localBlocklist: Array<String>) {
		this.name = name;
		this.autoRun = autoRun;
		this.autoPreset = autoPreset;
		if (localBlocklist != null)
			this.localBlocklist = localBlocklist;
	}

	public static function from(d: AutoIrisConfig): IrisConfig {
		if (d != null && Std.isOfType(d, IrisConfig))
			return d;
		var d: RawIrisConfig = cast d;
		return new IrisConfig(d.name, d.autoRun, d.autoPreset, d.localBlocklist);
	}
}

package crowplexus.iris;

@:structInit
class IrisConfig {
	public var name: String;
	public var autoRun: Bool = true;
	public var autoPreset: Bool = true;
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
}

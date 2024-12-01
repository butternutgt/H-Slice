package options;

class BaseGameSubState extends BaseOptionsMenu {
    public function new() {
        title = "V-Slice settings";
        rpcTitle = "V-Slice settings menu";
        var option:Option = new Option('Use New Freeplay State',
			'If disabled it uses older freeplay state as usual.',
			'vsliceFreeplay',
			BOOL);
		addOption(option);

        var option:Option = new Option('Freeplay Dynamic Coloring',
			'Enables dynamic freeplay background color. Disable this if you prefer original V-slice freeplay menu colors',
			'vsliceFreeplayColors',
			BOOL);
		addOption(option);

        var option:Option = new Option('Freeplay Auto Preview Song',
			"If disabled won't preview on selected song automatically.\nYou can play preview anytime space key instead.",
			'vsliceFreePreview',
			BOOL);
		addOption(option);

		var option:Option = new Option('Use Results Screen',
			'If disabled will skip showing the result screen.',
			'vsliceResults',
			BOOL);
		addOption(option);

		var option:Option = new Option('Smooth Health Bar',
			'If enabled makes health bar move more smoothly.',
			'vsliceSmoothBar',
			BOOL);
		addOption(option);

		var option:Option = new Option('Special Freeplay Cards',
			"If disabled will force every character to use BF's card. (including pico)",
			'vsliceSpecialCards',
			BOOL);
		addOption(option);

		var option:Option = new Option('Listen Whole Song Of Freeplay',
			'If enabled will load of whole music file in freeplay preview,\nIt makes more loads cpu.',
			'vsliceLoadInstAll',
			BOOL);
		addOption(option);

		var option:Option = new Option('Botplay Text Location: ',
			'P-Slice Engine is changed the Botplay Text Place,\nSo you can make Location be like original Psych Engine.',
			'vsliceBotPlayPlace',
			STRING,
			[
				"Near the Time Bar",
				"Near the Health Bar",
			]);
		addOption(option);
        super();
    }
}
NSBundle *assetBundle;
NSBundle *localizationBundle;

%ctor {
	assetBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Asphaleia/AsphaleiaAssets.bundle"];
	localizationBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle"];
}

/**
 * User: booster
 * Date: 30/09/16
 * Time: 14:41
 */
package medkit.locale {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import medkit.enum.Enum;
import medkit.object.ObjectUtil;
import medkit.util.JsonFormatter;

/**
 * A utility class for creating locale bundles.
 *
 * Simply extend to create a new bundle, like so:
 * <code>
 *     public class MenuTexts extends Locale {
 *         // don't forget to call initLocaleBundle()
 *         { initLocaleBundle(MenuTexts); }
 *
 *         public static const Title:MenuTexts          = new MenuTexts();
 *         public static const Description:MenuTexts    = new MenuTexts("Some default description.\nJust for layout testing purposes.");
 *         public static const Info:MenuTexts           = new MenuTexts();
 *
 *         public MenuTexts(defaultText:String = null) { super(defaultText); }
 *     }
 * </code>
 *
 * and use it in your code, like so:
 * <code>
 *     myMenu.title         = String(MenuTexts.Title);
 *     myMenu.description   = String(MenuTexts.Description);
 *     myMenu.info          = String(MenuTexts.Info);
 * </code>
 *
 * When ready to prepare the actual translations, export your texts when the app is running:
 * <code>
 *     var menuTexts:MenuTexts; // this makes sure your bundle is properly initialized before exporting - just a AS3 thing
 *     Locale.exportTranslations(devExportDir, MenuTexts);
 * </code>
 *
 * This will create a set of sub-directories in the given directory, corresponding to different locale IDs used.
 * Each sub-directory will contain translation files for the locale, in a simple JSON format - open it and add translations.
 *
 * The simplest way of loading your translations is calling importTranslations():
 * <code>
 *     Locale.importTranslations(localeDirectory, MenuTexts);
 * </code>
 *
 * but you can as well load the translation files manually (e.g. with Starling's AssetManager) and use the JSON objects obtained this way:
 * <code>
 *     var translationsJSON:Object = Locale.parse(translationsFile);
 *     Locale.registerTranslations("fr_FR", MenuTexts, translationsJSON);
 * </code>
 */
public class Locale extends Enum {
    // static members

    /** Default locale ID, set to English US. */
    public static const DEFAULT_LOCALE_ID:String            = "en_US";

    /** Currently used locale ID. Changing this won't change already loaded texts unless resetTexts() is called. */
    public static var localeID:String                       = DEFAULT_LOCALE_ID;

    /** If true, enables additional tests for debugging purposes. Set to false by default. */
    public static var debug:Boolean                         = false;

    private static var registeredLocales:Dictionary         = new Dictionary(); // Class -> Boolean
    private static var registeredTranslations:Dictionary    = new Dictionary(); // localeID -> (Class -> Vector.<String>)

    /** Parses a given translation file and returns a JSON object containing translation mapping. */
    public static function parse(file:File):Object {
        var reader:FileStream = new FileStream();
        reader.open(file, FileMode.READ);

        var jsonString:String   = reader.readUTFBytes(reader.bytesAvailable);
        var retVal:Object       = JSON.parse(jsonString);

        reader.close();

        return retVal;
    }

    /**
     * Imports all translations for a given class and locale IDs.
     * A specific sub-directory structure has to be maintained for this method to work:
     * parentDir/
     *   en_US/
     *     LOCALE_BUNDLE_CLASS_NAME.json
     *     OTHER_LOCALE_BUNDLE_CLASS_NAME.json
     *   fr_FR/
     *     LOCALE_BUNDLE_CLASS_NAME.json
     *     OTHER_LOCALE_BUNDLE_CLASS_NAME.json
     *   pl_PL/
     *     LOCALE_BUNDLE_CLASS_NAME.json
     *     OTHER_LOCALE_BUNDLE_CLASS_NAME.json
     * */
    public static function importTranslations(directory:File, clazz:Class, localeIDs:Vector.<String> = null):void {
        if(! directory.exists || ! directory.isDirectory)
            throw new ArgumentError("invalid import directory: " + directory.nativePath);

        if(registeredLocales[clazz] != true)
            throw new ArgumentError("invalid locale class, it does not extend medkit.locale::Locale or it hasn't been yet initialized with initLocales() call: " + clazz);

        var files:Array = directory.getDirectoryListing();
        var fileCount:int = files.length;
        for(var f:int = 0; f < fileCount; ++f) {
            var localeDir:File  = files[f];
            var localeID:String = localeDir.name;

            if(localeIDs != null && localeIDs.indexOf(localeID) >= 0)
                continue;

            if(! localeDir.isDirectory)
                throw new Error("invalid subdirectory: " + localeDir.name);

            var localeFile:File = localeDir.resolvePath(fileNameFromClass(clazz));

            if(! localeFile.exists)
                continue;

            var translationsJson:Object = parse(localeFile);

            registerTranslations(localeID, clazz, translationsJson);
        }
    }

    /**
     * Exports currently registered translations (and nulls) for a given class and localeIDs, which is useful when creating actual translation files.
     * Exported sub-directory structure can be then used with importTranslations().
     */
    public static function exportTranslations(directory:File, clazz:Class, localeIDs:Vector.<String> = null, exportDefaultTexts:Boolean = true):void {
        if(directory.exists && ! directory.isDirectory)
            throw new ArgumentError("invalid export directory: " + directory.nativePath);

        if(registeredLocales[clazz] != true)
            throw new ArgumentError("invalid locale class, it does not extend medkit.locale::Locale or it hasn't been yet initialized with initLocales() call: " + clazz);

        if(localeIDs == null) {
            localeIDs = new <String>[];

            for(var lID:String in registeredTranslations)
                localeIDs[localeIDs.length] = lID;
        }

        if(localeIDs.indexOf(DEFAULT_LOCALE_ID) < 0)
            localeIDs[localeIDs.length] = DEFAULT_LOCALE_ID;

        if(! directory.exists)
            directory.createDirectory();

        var localeIdCount:int = localeIDs.length;
        for(var l:int = 0; l < localeIdCount; ++l) {
            var localeID:String         = localeIDs[l];
            var isDefault:Boolean       = localeID == DEFAULT_LOCALE_ID;
            var clazzToText:Dictionary  = registeredTranslations[localeID];
            var texts:Vector.<String>   = clazzToText != null ? clazzToText[clazz] : null;
            var exportDirectory:File    = directory.resolvePath(localeID);

            if(! exportDirectory.exists)
                exportDirectory.createDirectory();

            var allLocale:Array         = Enum.allEnums(clazz);
            var allLocaleCount:int      = allLocale.length;
            var translationsJson:Object = {};

            for(var al:int = 0; al < allLocaleCount; ++al) {
                var locale:Locale   = allLocale[al];
                var text:String     = texts != null ? texts[al] : null;

                if(exportDefaultTexts && text == null && isDefault) {
                    var defaultText:String = locale.defaultText;

                    if(defaultText != Enum.nameForEnum(locale))
                        text = defaultText;
                }

                translationsJson[Enum.nameForEnum(locale)] = text;
            }

            var jsonString:String   = JsonFormatter.format(JSON.stringify(translationsJson)) + "\n";
            var outFile:File        = exportDirectory.resolvePath(fileNameFromClass(clazz));

            var writer:FileStream = new FileStream();
            writer.open(outFile, FileMode.WRITE);
            writer.writeUTFBytes(jsonString);
            writer.close();
        }
    }

    /** Resets all cached text properties for a given bundle class. Useful when changing Locale.localeID in run-time. */
    public static function resetTexts(clazz:Class):void {
        var allLocales:Array        = Enum.allEnums(clazz);
        var allLocaleCount:int      = allLocales.length;

        for(var l:int = 0; l < allLocaleCount; ++l) {
            var localeEnum:Locale = allLocales[l];
            localeEnum._text = null;
        }
    }

    /** Resets all cached text properties for all used bundle classes. Useful when changing Locale.localeID in run-time. */
    public static function resetAllTexts():void {
        for(var clazz:Class in registeredLocales)
            resetTexts(clazz);
    }

    /** Registers translated texts for a given locale bundle class. */
    public static function registerTranslations(locale:String, clazz:Class, translationsJson:Object):void {
        var allLocales:Array        = Enum.allEnums(clazz);
        var allLocaleCount:int      = allLocales.length;
        var texts:Vector.<String>   = new Vector.<String>(allLocaleCount, true);

        for(var l:int = 0; l < allLocaleCount; ++l) {
            var localeEnum:Locale       = allLocales[l];
            var localeEnumName:String   = Enum.nameForEnum(localeEnum);

            if(! translationsJson.hasOwnProperty(localeEnumName))
                continue;

            texts[l] = translationsJson[localeEnumName];
        }

        var clazzToText:Dictionary      = new Dictionary();
        clazzToText[clazz]              = texts;
        registeredTranslations[locale]  = clazzToText;
    }

    /** Unregisters translated texts for a given locale bundle class. */
    public static function unregisterTranslations(locale:String, clazz:Class):void {
        var clazzToTexts:Dictionary = registeredTranslations[locale];

        if(clazzToTexts != null)
            delete clazzToTexts[clazz];
    }

    /** Unregisters translated texts for all used bundle classes. */
    public static function unregisterAllTranslations(locale:String):void {
        registeredTranslations[locale] = null; // instead null instead of deleting the entry, so it's still possible to export this localeID
    }

    /**
     * Initialized a given locale bundle class.
     * This has to be called inside a static constructor, like so:
     * <code>
     *     class MyLocaleBundle extends Locale {
     *         { initLocaleBundle(MyLocaleBundle); }
     *
     *         public static const MyTextA:MyLocaleBundle = new MyLocaleBundle();
     *         public static const MyTextB:MyLocaleBundle = new MyLocaleBundle();
     *         ...
     *     }
     * </code>
     */
    protected static function initLocaleBundle(clazz:Class):void {
        if(debug && registeredLocales[clazz] == true)
            throw new Error("initLocaleBundle() already called for " + clazz);

        registeredLocales[clazz] = true;
        initEnums(clazz);
    }

    private static function fileNameFromClass(clazz:Class):String {
        var fullClassName:String = getQualifiedClassName(clazz);
        var index:int = fullClassName.indexOf("::");

        if(index < 0)
            return fullClassName + ".json";

        return fullClassName.substring(index + 2) + ".json";
    }

    // instance members

    private var _defaultText:String;
    private var _text:String;

    public function Locale(defaultText:String = null) {
        //if(debug && registeredLocales[ObjectUtil.getClass(this)] != true)
        //    throw new Error("initLocales() not called for: " + ObjectUtil.getClass(this));

        _defaultText = defaultText;
    }

    /** Default text for a given locale bundle member. If none given in the constructor, it return this member's name. */
    public function get defaultText():String {
        if(_defaultText == null)
            _defaultText = nameForEnum(this);

        return _defaultText;
    }

    /** Translated text for a given bundle member. If there's no translation for a given member, for the current Locale.localeID, it class defaultText. */
    public function get text():String {
        if(_text == null)
            _text = getText();

        return _text;
    }

    /**
     * Return the default or translated text, if the later is present. Useful when using bundle members in application code, like so:
     * <code>
     *     button.text = String(MyLocaleBundle.TextA);
     * </code>
     */
    public override function toString():String { return text; }

    private function getText():String {
        var clazzToText:Dictionary = registeredTranslations[Locale.localeID];

        if(clazzToText == null)
            return defaultText;

        var texts:Vector.<String> = clazzToText[ObjectUtil.getClass(this)];

        if(texts == null)
            return defaultText;

        var text:String = texts[index()];

        if(text == null)
            return defaultText;

        return text;
    }
}
}

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

public class Locale extends Enum {
    public static const DEFAULT_LOCALE_ID:String            = "en_US";
    public static var localeID:String                       = DEFAULT_LOCALE_ID;
    public static var debug:Boolean                         = false;

    private static var registeredLocales:Dictionary         = new Dictionary(); // Class -> Boolean
    private static var registeredTranslations:Dictionary    = new Dictionary(); // localeID -> (Class -> Vector.<String>)

    public static function parse(file:File):Object {
        var reader:FileStream = new FileStream();
        reader.open(file, FileMode.READ);

        var jsonString:String   = reader.readUTFBytes(reader.bytesAvailable);
        var retVal:Object       = JSON.parse(jsonString);

        reader.close();

        return retVal;
    }

    public static function exportAll(directory:File, localeIDs:Vector.<String> = null, exportDefaultTexts:Boolean = true):void {
        for(var clazz:Class in registeredLocales)
            export(directory, clazz, localeIDs, exportDefaultTexts);
    }

    public static function export(directory:File, clazz:Class, localeIDs:Vector.<String> = null, exportDefaultTexts:Boolean = true):void {
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

            var jsonString:String   = JsonFormatter.format(JSON.stringify(translationsJson));
            var outFile:File        = exportDirectory.resolvePath(fileNameFromClass(clazz));

            var writer:FileStream = new FileStream();
            writer.open(outFile, FileMode.WRITE);
            writer.writeUTFBytes(jsonString);
            writer.close();
        }

        function fileNameFromClass(clazz:Class):String {
            var fullClassName:String = getQualifiedClassName(clazz);
            var index:int = fullClassName.indexOf("::");

            if(index < 0)
                return fullClassName + ".json";

            return fullClassName.substring(index + 2) + ".json";
        }
    }

    public static function resetTexts(clazz:Class):void {
        var allLocales:Array        = Enum.allEnums(clazz);
        var allLocaleCount:int      = allLocales.length;

        for(var l:int = 0; l < allLocaleCount; ++l) {
            var localeEnum:Locale = allLocales[l];
            localeEnum._text = null;
        }
    }

    public static function resetAllTexts():void {
        for(var clazz:Class in registeredLocales)
            resetTexts(clazz);
    }

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

    public static function unregisterTranslations(locale:String, clazz:Class):void {
        var clazzToTexts:Dictionary = registeredTranslations[locale];

        if(clazzToTexts != null)
            delete clazzToTexts[clazz];
    }

    public static function unregisterAllTranslations(locale:String):void {
        registeredTranslations[locale] = null; // instead null instead of deleting the entry, so it's still possible to export this localeID
    }

    protected static function initLocales(clazz:Class):void {
        if(debug && registeredLocales[clazz] == true)
            throw new Error("initLocales() already called for " + clazz);

        registeredLocales[clazz] = true;
        initEnums(clazz);
    }

    private var _defaultText:String;
    private var _text:String;

    public function Locale(defaultText:String = null) {
        _defaultText = defaultText;
    }

    public function get defaultText():String {
        if(_defaultText == null)
            _defaultText = nameForEnum(this);

        return _defaultText;
    }

    public function get text():String {
        if(_text == null)
            _text = getText();

        return _text;
    }

    public override function toString():String { return text; }

    protected function getText():String {
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

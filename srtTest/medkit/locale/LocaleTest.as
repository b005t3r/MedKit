/**
 * User: booster
 * Date: 30/09/16
 * Time: 14:51
 */
package medkit.locale {
import flash.filesystem.File;

import medkit.enum.Enum;

import org.flexunit.asserts.assertEquals;

public class LocaleTest {
    [Before]
    public function setUp():void {
        Locale.debug = true;
        Locale.localeID = Locale.DEFAULT_LOCALE_ID;

        Locale.resetAllTexts();
        Locale.unregisterAllTranslations(Locale.DEFAULT_LOCALE_ID);
        Locale.unregisterAllTranslations("fr_FR");
    }

    [After]
    public function tearDown():void {

    }

    [Test]
    public function testDefaultText():void {
        assertEquals(SomeLocale.SomeTextOne.defaultText, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.defaultText, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.defaultText, Enum.nameForEnum(SomeLocale.Uninitialized));
    }

    [Test]
    public function testText():void {
        assertEquals(SomeLocale.SomeTextOne.text, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.text, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.text, Enum.nameForEnum(SomeLocale.Uninitialized));
    }

    [Test]
    public function testTranslation():void {
        var translations:Object = {
            SomeTextOne : "translation uno",
            SomeTextTwo : "translation duo",
            Uninitialized : "uninitializenado"
        };

        Locale.registerTranslations("fr_FR", SomeLocale, translations);

        assertEquals(SomeLocale.SomeTextOne.text, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.text, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.text, Enum.nameForEnum(SomeLocale.Uninitialized));

        Locale.resetTexts(SomeLocale);
        Locale.localeID = "fr_FR";

        assertEquals(SomeLocale.SomeTextOne.text, translations["SomeTextOne"]);
        assertEquals(SomeLocale.SomeTextTwo.text, translations["SomeTextTwo"]);
        assertEquals(SomeLocale.Uninitialized.text, translations["Uninitialized"]);

        // previously loaded texts don't change after just changing the current localeID, a reset is needed
        Locale.localeID = Locale.DEFAULT_LOCALE_ID;

        assertEquals(SomeLocale.SomeTextOne.text, translations["SomeTextOne"]);
        assertEquals(SomeLocale.SomeTextTwo.text, translations["SomeTextTwo"]);
        assertEquals(SomeLocale.Uninitialized.text, translations["Uninitialized"]);

        Locale.resetTexts(SomeLocale);

        assertEquals(SomeLocale.SomeTextOne.text, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.text, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.text, Enum.nameForEnum(SomeLocale.Uninitialized));
    }

    [Test]
    public function testImportExport():void {
        var translations:Object = {
            SomeTextOne : "translation uno",
            SomeTextTwo : "translation duo",
            Uninitialized : "uninitializenado"
        };

        Locale.registerTranslations("fr_FR", SomeLocale, translations);

        assertEquals(SomeLocale.SomeTextOne.text, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.text, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.text, Enum.nameForEnum(SomeLocale.Uninitialized));

        Locale.resetTexts(SomeLocale);
        Locale.localeID = "fr_FR";

        assertEquals(SomeLocale.SomeTextOne.text, translations["SomeTextOne"]);
        assertEquals(SomeLocale.SomeTextTwo.text, translations["SomeTextTwo"]);
        assertEquals(SomeLocale.Uninitialized.text, translations["Uninitialized"]);

        var tmpDirectory:File = File.createTempDirectory();

        Locale.exportTranslations(tmpDirectory, SomeLocale);

        Locale.unregisterAllTranslations("fr_FR");
        Locale.unregisterAllTranslations(Locale.DEFAULT_LOCALE_ID);
        Locale.resetTexts(SomeLocale);

        assertEquals(SomeLocale.SomeTextOne.text, String(SomeLocale.SomeTextOne));
        assertEquals(SomeLocale.SomeTextTwo.text, String(SomeLocale.SomeTextTwo));
        assertEquals(SomeLocale.Uninitialized.text, Enum.nameForEnum(SomeLocale.Uninitialized));

        Locale.resetTexts(SomeLocale);
        Locale.importTranslations(tmpDirectory, SomeLocale);

        assertEquals(SomeLocale.SomeTextOne.text, translations["SomeTextOne"]);
        assertEquals(SomeLocale.SomeTextTwo.text, translations["SomeTextTwo"]);
        assertEquals(SomeLocale.Uninitialized.text, translations["Uninitialized"]);

        tmpDirectory.deleteDirectory(true);
    }
}
}

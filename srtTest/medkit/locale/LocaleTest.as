/**
 * User: booster
 * Date: 30/09/16
 * Time: 14:51
 */
package medkit.locale {
import medkit.enum.Enum;

import org.flexunit.asserts.assertEquals;

public class LocaleTest {
    [Before]
    public function setUp():void {
        Locale.resetAllTexts();
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

    }
}
}

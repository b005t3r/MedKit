/**
 * User: booster
 * Date: 30/09/16
 * Time: 14:52
 */
package medkit.locale {
public class SomeLocale extends Locale {
    { initLocales(SomeLocale); }

    public static const SomeTextOne:SomeLocale      = new SomeLocale("This is some text");
    public static const SomeTextTwo:SomeLocale      = new SomeLocale("And this is some more text");

    public static const Uninitialized:SomeLocale    = new SomeLocale();

    public function SomeLocale(defaultText:String = null) { super(defaultText); }
}
}

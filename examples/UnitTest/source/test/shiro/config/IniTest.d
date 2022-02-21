module test.shiro.config.IniTest;

import hunt.shiro.config.Ini;

import hunt.Assert;
import hunt.logging.Logger;
import hunt.util.Common;
import hunt.util.UnitTest;


/**
 * Unit test for the {@link Ini} class.
 *
 * @since 1.0
 */
class IniTest {

    private enum string NL = "\n";

    void testIniFromFile() {
        Ini ini = Ini.fromResourcePath("resources/shiro.ini");
    }

    @Test
    void testNoSections() {
        string test =
            "prop1 = value1" ~ NL ~
                    "prop2 = value2";

        Ini ini = new Ini();
        ini.load(test);

        assertNotNull(ini.getSections());
        assertEquals(1, ini.getSections().length);

        IniSection section = ini.getSections()[0];
        assertEquals(Ini.DEFAULT_SECTION_NAME, section.getName());
        assertFalse(section.isEmpty());
        assertEquals(2, section.size());
        assertEquals("value1", section.get("prop1"));
        assertEquals("value2", section.get("prop2"));
    }

    @Test
    void testIsContinued() {
        //no slashes
        string line = "prop = value ";
        assertFalse(IniSection.isContinued(line));

        //1 slash (odd number, but edge case):
        line = "prop = value" ~ IniSection.ESCAPE_TOKEN;
        assertTrue(IniSection.isContinued(line));

        //2 slashes = even number
        line = "prop = value" ~ IniSection.ESCAPE_TOKEN ~ IniSection.ESCAPE_TOKEN;
        assertFalse(IniSection.isContinued(line));

        //3 slashes = odd number
        line = "prop = value" ~ IniSection.ESCAPE_TOKEN ~ IniSection.ESCAPE_TOKEN ~ IniSection.ESCAPE_TOKEN;
        assertTrue(IniSection.isContinued(line));
    }

    @Test
    void testSplitKeyValue() {
        string test = "Truth Beauty";
        string[] kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth=Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth:Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth = Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth:  Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth  :Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth:Beauty        ";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "    Truth:Beauty    ";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);

        test = "Truth        =Beauty";
        kv = IniSection.splitKeyValue(test);
        assertEquals("Truth", kv[0]);
        assertEquals("Beauty", kv[1]);
    }

    @Test
    void testSplitKeyValueNoValue() {
        string test = "  Truth  ";
        IniSection.splitKeyValue(test);
    }

    @Test
    void testOneSection() {
        string sectionName = "main";
        string test = NL ~
                "" ~ NL ~
                "  " ~ NL ~
                "    #  comment1 " ~ NL ~
                " ; comment 2" ~ NL ~
                "[" ~ sectionName ~ "]" ~ NL ~
                "prop1 = value1" ~ NL ~
                "  " ~ NL ~
                "; comment " ~ NL ~
                "prop2   value2" ~ NL ~
                "prop3:value3" ~ NL ~
                "prop4 : value 4" ~ NL ~
                "prop5 some long \\" ~ NL ~
                "      value " ~ NL ~
                "# comment.";

        Ini ini = new Ini();
        ini.load(test);

        assertNotNull(ini.getSections());
        assertEquals(1, ini.getSections().length);
        IniSection section = ini.getSection("main");
        assertNotNull(section);
        assertEquals(sectionName, section.getName());
        assertFalse(section.isEmpty());
        assertEquals(5, section.size());
        assertEquals("value1", section.get("prop1"));
        assertEquals("value2", section.get("prop2"));
        assertEquals("value3", section.get("prop3"));
        assertEquals("value 4", section.get("prop4"));
        assertEquals("some long value", section.get("prop5"));
    }

    /**
     * @since 1.4
     */
    @Test
    void testPutAll() {

        Ini ini1 = new Ini();
        ini1.setSectionProperty("section1", "key1", "value1");

        Ini ini2 = new Ini();
        ini2.setSectionProperty("section2", "key2", "value2");

        ini1.putAll(ini2);

        assertThat(ini1.getSectionNames(), ["section1", "section2"]);

        // two sections each with one property
        assertThat(ini1.getSectionNames().length, 2);
        assertThat(ini1.getSection("section2").size(), 1);
        assertThat(ini1.getSection("section1").size(), 1);

        // adding a value directly to ini2's section will update ini1
        ini2.setSectionProperty("section2", "key2.2", "value2.2");
        assertThat(ini1.getSection("section2").size(), 2);

        Ini ini3 = new Ini();
        ini3.setSectionProperty("section1", "key1.3", "value1.3");

        // this will replace the whole section
        ini1.putAll(ini3);
        assertThat(ini1.getSection("section1").size(), 1);

    }

    /**
     * @since 1.4
     */
    @Test
    void testMerge() {

        Ini ini1 = new Ini();
        ini1.setSectionProperty("section1", "key1", "value1");

        Ini ini2 = new Ini();
        ini2.setSectionProperty("section2", "key2", "value2");

        ini1.merge(ini2);

        assertThat(ini1.getSectionNames(), ["section1", "section2"]);

        // two sections each with one property
        assertThat(ini1.getSectionNames().length, 2);
        assertThat(ini1.getSection("section2").size(), 1);
        assertThat(ini1.getSection("section1").size(), 1);

        // updating the original ini2, will NOT effect ini1
        ini2.setSectionProperty("section2", "key2.2", "value2.2");
        assertThat(ini1.getSection("section2").size(), 1);

        Ini ini3 = new Ini();
        ini3.setSectionProperty("section1", "key1.3", "value1.3");

        // after merging the section will contain 2 values
        ini1.merge(ini3);
        assertThat(ini1.getSection("section1").size(), 2);
    }

    /**
     * @since 1.4
     */
    @Test
    void testCreateWithDefaults() {

        Ini ini1 = new Ini();
        ini1.setSectionProperty("section1", "key1", "value1");

        Ini ini2 = new Ini(ini1);
        ini2.setSectionProperty("section2", "key2", "value2");

        assertThat(ini2.getSectionNames(), ["section1", "section2"]);

        // two sections each with one property
        assertThat(ini2.getSectionNames().length, 2);
        assertThat(ini2.getSection("section2").size(), 1);
        assertThat(ini2.getSection("section1").size(), 1);

        // updating the original ini1, will NOT effect ini2
        ini1.setSectionProperty("section1", "key1.1", "value1.1");
        IniSection sec = ini2.getSection("section1");
        assertThat(sec.size(), 1);
        assert(sec.containsKey("key1"));
        assert(sec["key1"] == "value1");
    }
}

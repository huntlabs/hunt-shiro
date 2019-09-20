/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
module hunt.shiro.config.Ini;

import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Object;
import hunt.text.StringBuilder;
import hunt.util.ObjectUtils;

import std.array;
import std.file;
import std.path;
import std.range;
import std.string;
import std.stdio;
import std.ascii;




/**
 * A class representing the <a href="http://en.wikipedia.org/wiki/INI_file">INI</a> text configuration format.
 * <p/>
 * An Ini instance is a map of {@link IniSection IniSection}s, keyed by section name.  Each
 * {@code IniSection} is itself a map of {@code string} name/value pairs.  Name/value pairs are guaranteed to be unique
 * within each {@code IniSection} only - not across the entire {@code Ini} instance.
 *
 * @since 1.0
 */
class Ini : Map!(string, IniSection) {
    
    enum string DEFAULT_SECTION_NAME = ""; //empty string means the first unnamed section
    enum string DEFAULT_CHARSET_NAME = "UTF-8";

    enum string COMMENT_POUND = "#";
    enum string COMMENT_SEMICOLON = ";";
    enum string SECTION_PREFIX = "[";
    enum string SECTION_SUFFIX = "]";

    private Map!(string, IniSection) sections;

    /**
     * Creates a new empty {@code Ini} instance.
     */
    this() {
        this.sections = new LinkedHashMap!(string, IniSection)();
    }

    /**
     * Creates a new {@code Ini} instance with the specified defaults.
     *
     * @param defaults the default sections and/or key-value pairs to copy into the new instance.
     */
    this(Ini defaults) {
        this();
        if (defaults is null) {
            throw new NullPointerException("Defaults cannot be null.");
        }
        foreach (IniSection section ; defaults.getSections()) {
            IniSection copy = new IniSection(section);
            this.sections.put(section.getName(), copy);
        }
    }

    /**
     * Returns {@code true} if no sections have been configured, or if there are sections, but the sections themselves
     * are all empty, {@code false} otherwise.
     *
     * @return {@code true} if no sections have been configured, or if there are sections, but the sections themselves
     *         are all empty, {@code false} otherwise.
     */
    bool isEmpty() {
        IniSection[] sections = this.sections.values();
        foreach (IniSection section ; sections) {
            if (!section.isEmpty()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the names of all sections managed by this {@code Ini} instance or an empty collection if there are
     * no sections.
     *
     * @return the names of all sections managed by this {@code Ini} instance or an empty collection if there are
     *         no sections.
     */
    string[] getSectionNames() {
        return sections.byKey.array();
    }

    /**
     * Returns the sections managed by this {@code Ini} instance or an empty collection if there are
     * no sections.
     *
     * @return the sections managed by this {@code Ini} instance or an empty collection if there are
     *         no sections.
     */
    IniSection[] getSections() {
        return sections.values();
    }

    /**
     * Returns the {@link IniSection} with the given name or {@code null} if no section with that name exists.
     *
     * @param sectionName the name of the section to retrieve.
     * @return the {@link IniSection} with the given name or {@code null} if no section with that name exists.
     */
    IniSection getSection(string sectionName) {
        string name = cleanName(sectionName);
        return sections.get(name);
    }

    /**
     * Ensures a section with the specified name exists, adding a new one if it does not yet exist.
     *
     * @param sectionName the name of the section to ensure existence
     * @return the section created if it did not yet exist, or the existing IniSection that already existed.
     */
    IniSection addSection(string sectionName) {
        string name = cleanName(sectionName);
        IniSection section = getSection(name);
        if (section is null) {
            section = new IniSection(name);
            this.sections.put(name, section);
        }
        return section;
    }

    /**
     * Removes the section with the specified name and returns it, or {@code null} if the section did not exist.
     *
     * @param sectionName the name of the section to remove.
     * @return the section with the specified name or {@code null} if the section did not exist.
     */
    IniSection removeSection(string sectionName) {
        string name = cleanName(sectionName);
        return this.sections.remove(name);
    }

    private static string cleanName(string sectionName) {
        string name = strip(sectionName);
        if (name.empty) {
            trace("Specified name was null or empty.  Defaulting to the default section (name = \"\")");
            name = DEFAULT_SECTION_NAME;
        }
        return name;
    }

    /**
     * Sets a name/value pair for the section with the given {@code sectionName}.  If the section does not yet exist,
     * it will be created.  If the {@code sectionName} is null or empty, the name/value pair will be placed in the
     * default (unnamed, empty string) section.
     *
     * @param sectionName   the name of the section to add the name/value pair
     * @param propertyName  the name of the property to add
     * @param propertyValue the property value
     */
    void setSectionProperty(string sectionName, string propertyName, string propertyValue) {
        string name = cleanName(sectionName);
        IniSection section = getSection(name);
        if (section is null) {
            section = addSection(name);
        }
        section.put(propertyName, propertyValue);
    }

    /**
     * Returns the value of the specified section property, or {@code null} if the section or property do not exist.
     *
     * @param sectionName  the name of the section to retrieve to acquire the property value
     * @param propertyName the name of the section property for which to return the value
     * @return the value of the specified section property, or {@code null} if the section or property do not exist.
     */
    string getSectionProperty(string sectionName, string propertyName) {
        IniSection section = getSection(sectionName);
        return section !is null ? section.get(propertyName) : null;
    }

    /**
     * Returns the value of the specified section property, or the {@code defaultValue} if the section or
     * property do not exist.
     *
     * @param sectionName  the name of the section to add the name/value pair
     * @param propertyName the name of the property to add
     * @param defaultValue the default value to return if the section or property do not exist.
     * @return the value of the specified section property, or the {@code defaultValue} if the section or
     *         property do not exist.
     */
    string getSectionProperty(string sectionName, string propertyName, string defaultValue) {
        string value = getSectionProperty(sectionName, propertyName);
        return value !is null ? value : defaultValue;
    }

    /**
     * Creates a new {@code Ini} instance loaded with the INI-formatted data in the resource at the given path.  The
     * resource path may be any value interpretable by the
     * {@link ResourceUtils#getInputStreamForPath(string) ResourceUtils.getInputStreamForPath} method.
     *
     * @param resourcePath the resource location of the INI data to load when creating the {@code Ini} instance.
     * @return a new {@code Ini} instance loaded with the INI-formatted data in the resource at the given path.
     * @throws ConfigurationException if the path cannot be loaded into an {@code Ini} instance.
     */
    static Ini fromResourcePath(string resourcePath) {
        if (resourcePath.empty()) {
            throw new IllegalArgumentException("Resource Path argument cannot be null or empty.");
        }
        Ini ini = new Ini();
        ini.loadFromPath(resourcePath);
        return ini;
    }

    /**
     * Loads data from the specified resource path into this current {@code Ini} instance.  The
     * resource path may be any value interpretable by the
     * {@link ResourceUtils#getInputStreamForPath(string) ResourceUtils.getInputStreamForPath} method.
     *
     * @param resourcePath the resource location of the INI data to load into this instance.
     * @throws ConfigurationException if the path cannot be loaded
     */
    void loadFromPath(string resourcePath) {
        string rootPath = dirName(thisExePath());
        string filename = buildPath(rootPath, resourcePath);
        if (!exists(filename) || isDir(filename)) {
            throw new ConfigurationException("The config file doesn't exist: " ~ filename);
        }

        File f = File(filename, "r");
        if (!f.isOpen())
            return;
        scope (exit)
            f.close();
            
        // https://dlang.org/phobos/std_stdio.html#byLine
        parsing!(typeof(f.byLine()), true)(f.byLine());
    }

    /**
     * Loads the specified raw INI-formatted text into this instance.
     *
     * @param iniConfig the raw INI-formatted text to load into this instance.
     * @throws ConfigurationException if the text cannot be loaded
     */
    void load(string iniConfig) {
        parsing(iniConfig.lineSplitter());
    }

    private void parsing(T, bool needDup=false)(T lines) {
        // trace(typeid(T));
        
        string sectionName = DEFAULT_SECTION_NAME;
        StringBuilder sectionContent = new StringBuilder();

        while (!lines.empty()) {
            string rawLine = cast(string)lines.front();
            // version(HUNT_DEBUG_CONFIG) trace(rawLine);
            scope(exit)
                lines.popFront();
            string line = strip(rawLine);

            if (line.empty() || line.startsWith(COMMENT_POUND) || line.startsWith(COMMENT_SEMICOLON)) {
                //skip empty lines and comments:
                continue;
            }

            static if(needDup) {
                line = line.idup();
            }

            string newSectionName = getSectionName(line);
            if (!newSectionName.empty()) {
                // infof("sectionName=%s, newSectionName=%s", sectionName, newSectionName);
                //found a new section - convert the currently buffered one into a IniSection object
                addSection(sectionName, sectionContent);

                //reset the buffer for the new section:
                sectionContent = new StringBuilder();
                sectionName = newSectionName;

                version(HUNT_DEBUG) {
                    trace("Parsing " ~ SECTION_PREFIX ~ sectionName ~ SECTION_SUFFIX);
                }
            } else {
                //normal line - add it to the existing content buffer:
                sectionContent.append(rawLine).append("\n");
            }
        }

        
        //finish any remaining buffered content:
        addSection(sectionName, sectionContent);
    }

    /**
     * Loads the INI-formatted text backed by the given InputStream into this instance.  This implementation will
     * close the input stream after it has finished loading.  It is expected that the stream's contents are
     * UTF-8 encoded.
     *
     * @param is the {@code InputStream} from which to read the INI-formatted text
     * @throws ConfigurationException if unable
     */
    // void load(InputStream is) {
    //     if (is is null) {
    //         throw new NullPointerException("InputStream argument cannot be null.");
    //     }
    //     InputStreamReader isr;
    //     try {
    //         isr = new InputStreamReader(is, DEFAULT_CHARSET_NAME);
    //     } catch (UnsupportedEncodingException e) {
    //         throw new ConfigurationException(e);
    //     }
    //     load(isr);
    // }

    /**
     * Loads the INI-formatted text backed by the given Reader into this instance.  This implementation will close the
     * reader after it has finished loading.
     *
     * @param reader the {@code Reader} from which to read the INI-formatted text
     */
    // void load(Reader reader) {
    //     Scanner scanner = new Scanner(reader);
    //     try {
    //         load(scanner);
    //     } finally {
    //         try {
    //             scanner.close();
    //         } catch (Exception e) {
    //             trace("Unable to cleanly close the InputStream scanner.  Non-critical - ignoring.", e);
    //         }
    //     }
    // }

    /**
     * Merges the contents of <code>m</code>'s {@link IniSection} objects into self.
     * This differs from {@link Ini#putAll(Map)}, in that each section is merged with the existing one.
     * For example the following two ini blocks are merged and the result is the third<BR/>
     * <p>
     * Initial:
     * <pre>
     * <code>[section1]
     * key1 = value1
     *
     * [section2]
     * key2 = value2
     * </code> </pre>
     *
     * To be merged:
     * <pre>
     * <code>[section1]
     * foo = bar
     *
     * [section2]
     * key2 = new value
     * </code> </pre>
     *
     * Result:
     * <pre>
     * <code>[section1]
     * key1 = value1
     * foo = bar
     *
     * [section2]
     * key2 = new value
     * </code> </pre>
     *
     * </p>
     *
     * @param m map to be merged
     * @since 1.4
     */
    void merge(Map!(string, IniSection) m) {

        if (m !is null) {
            foreach (string key, IniSection value; m) {
                IniSection section = this.getSection(key);
                if (section is null) {
                    section = addSection(key);
                }
                section.putAll(value);
            }
        }
    }

    private void addSection(string name, StringBuilder content) {
        if (content.length() > 0) {
            string contentString = content.toString();
            string cleaned = strip(contentString);
            if (!cleaned.empty) {
                IniSection section = new IniSection(name, contentString);
                if (!section.isEmpty()) {
                    sections.put(name, section);
                }
            }
        }
    }

    protected static bool isSectionHeader(string line) {
        string s = strip(line);
        return !s.empty && s.startsWith(SECTION_PREFIX) && s.endsWith(SECTION_SUFFIX);
    }

    protected static string getSectionName(string line) {
        string s = strip(line);
        if (isSectionHeader(s)) {
            return cleanName(s[1 .. $ - 1]);
        }
        return null;
    }


    bool replace(string key, IniSection oldValue, IniSection newValue) {
        IniSection curValue = get(key);
        if (curValue != oldValue || !containsKey(key)) {
            return false;
        }
        put(key, newValue);
        return true;
    }

    IniSection replace(string key, IniSection value) {
        IniSection curValue = IniSection.init;
        if (containsKey(key)) {
            curValue = put(key, value);
        }
        return curValue;
    }


    IniSection putIfAbsent(string key, IniSection value) {
        IniSection v = IniSection.init;

        if (!containsKey(key))
            v = put(key, value);

        return v;
    }

    bool remove(string key, IniSection value) {
        IniSection curValue = get(key);
        if (curValue != value || !containsKey(key))
            return false;
        remove(key);
        return true;
    }

    IniSection opIndex(string key) {
        return get(key);
    }

    int opApply(scope int delegate(ref string, ref IniSection) dg) {
        int result = 0;

        foreach(string key, IniSection value; sections) {
            result = dg(key, value);
        }

        return result;
    }

    int opApply(scope int delegate(MapEntry!(string, IniSection) entry) dg) {
        int result = 0;

        foreach(MapEntry!(string, IniSection) entry; sections) {
            result = dg(entry);
        }

        return result;
    }

    InputRange!string byKey() {
        return sections.byKey();
    }

    InputRange!IniSection byValue() {
        return sections.byValue();
    }

    bool opEquals(IObject o) {
        return opEquals(cast(Object) o);
    }            

    override bool opEquals(Object obj) {
        Ini ini = cast(Ini) obj;
        if (ini !is null) {
            return this.sections.opEquals(ini.sections);
        }
        return false;
    }

    override size_t toHash() @trusted nothrow {
        return this.sections.toHash();
    }

    override string toString() {
        if (this.sections is null || this.sections.isEmpty()) {
            return "<empty INI>";
        } else {
            StringBuilder sb = new StringBuilder("sections=");
            int i = 0;
            foreach (IniSection section ; this.sections.values()) {
                if (i > 0) {
                    sb.append(",");
                }
                sb.append(section.toString());
                i++;
            }
            return sb.toString();
        }
    }

    int size() {
        return this.sections.size();
    }

    bool containsKey(string key) {
        return this.sections.containsKey(key);
    }

    bool containsValue(IniSection value) {
        return this.sections.containsValue(value);
    }

    IniSection get(string key) {
        return this.sections.get(key);
    }

    IniSection put(string key, IniSection value) {
        return this.sections.put(key, value);
    }

    IniSection remove(string key) {
        return this.sections.remove(key);
    }

    void putAll(Map!(string, IniSection) m) {
        this.sections.putAll(m);
    }

    void clear() {
        this.sections.clear();
    }

    // Set<string> keySet() {
    //     return Collections.unmodifiableSet(this.sections.keySet());
    // }

    IniSection[] values() {
        return this.sections.values();
    }

    // Set<Entry!(string, IniSection)> entrySet() {
    //     return Collections.unmodifiableSet(this.sections.entrySet());
    // }
    
    mixin CloneMemberTemplate!(typeof(this));

}



/**
 * An {@code IniSection} is string-key-to-string-value Map, identifiable by a
 * {@link #getName() name} unique within an {@link Ini} instance.
 */
class IniSection : Map!(string, string) {

    enum char ESCAPE_TOKEN = '\\';

    private string name;
    private Map!(string, string) props;

    private this(string name) {
        trace("section: ", name);
        if (name.empty) {
            throw new NullPointerException("name");
        }
        this.name = name;
        this.props = new LinkedHashMap!(string, string)();
    }

    private this(string name, string sectionContent) {
        trace("section: ", name);
        if (name.empty) {
            throw new NullPointerException("name");
        }
        this.name = name;
        Map!(string, string) props;
        if (!sectionContent.empty() ) {
            props = toMapProps(sectionContent);
        } else {
            props = new LinkedHashMap!(string, string)();
        }
        if ( props !is null ) {
            this.props = props;
        } else {
            this.props = new LinkedHashMap!(string, string)();
        }
    }

    private this(IniSection defaults) {
        this(defaults.getName());
        putAll(defaults.props);
    }

    //Protected to access in a test case - NOT considered part of Shiro's API

    static bool isContinued(string line) {
        if (line.empty()) {
            return false;
        }
        int length = cast(int)line.length;
        //find the number of backslashes at the end of the line.  If an even number, the
        //backslashes are considered escaped.  If an odd number, the line is considered continued on the next line
        int backslashCount = 0;
        for (int i = length - 1; i > 0; i--) {
            if (line[i] == ESCAPE_TOKEN) {
                backslashCount++;
            } else {
                break;
            }
        }
        return backslashCount % 2 != 0;
    }

    private static bool isKeyValueSeparatorChar(char c) {
        return isWhite(c) || c == ':' || c == '=';
    }

    private static bool isCharEscaped(string s, int index) {
        return index > 0 && s[index - 1] == ESCAPE_TOKEN;
    }

    //Protected to access in a test case - NOT considered part of Shiro's API
    static string[] splitKeyValue(string keyValueLine) {
        string line = strip(keyValueLine);
        if (line.empty()) {
            return null;
        }
        StringBuilder keyBuffer = new StringBuilder();
        StringBuilder valueBuffer = new StringBuilder();

        bool buildingKey = true; //we'll build the value next:

        for (int i = 0; i < cast(int)line.length; i++) {
            char c = line[i];

            if (buildingKey) {
                if (isKeyValueSeparatorChar(c) && !isCharEscaped(line, i)) {
                    buildingKey = false;//now start building the value
                } else {
                    keyBuffer.append(c);
                }
            } else {
                if (valueBuffer.length() == 0 && isKeyValueSeparatorChar(c) && !isCharEscaped(line, i)) {
                    //swallow the separator chars before we start building the value
                } else {
                    valueBuffer.append(c);
                }
            }
        }

        string key = strip(keyBuffer.toString());
        string value = strip(valueBuffer.toString());

        if (key.empty() || value.empty()) {
            version(HUNT_DEBUG) warningf("key/value is empty: %s = %s, line: %s", key, value, line);
            string msg = "Line argument must contain a key and a value.  Only one string token was found.";
            throw new IllegalArgumentException(msg);
        }

        version(HUNT_DEBUG_CONFIG) tracef("Discovered key/value pair: %s = %s", key, value);

        return [key, value];
    }

    private static Map!(string, string) toMapProps(string content) {        
        string line;
        Map!(string, string) props = new LinkedHashMap!(string, string)();
        StringBuilder lineBuffer = new StringBuilder();
        auto scanner = content.lineSplitter();

        while (!scanner.empty()) {
            line = strip(scanner.front);
            scanner.popFront();
            if (isContinued(line)) {
                //strip off the last continuation backslash:
                line = line[0 .. $ - 1];
                lineBuffer.append(line);
                continue;
            } else {
                lineBuffer.append(line);
            }
            line = lineBuffer.toString();
            lineBuffer = new StringBuilder();
            string[] kvPair = splitKeyValue(line);
            if(kvPair !is null)
                props.put(kvPair[0], kvPair[1]);
        }

        return props;
    }

    string getName() {
        return this.name;
    }

    void clear() {
        this.props.clear();
    }

    bool containsKey(string key) {
        return this.props.containsKey(key);
    }

    bool containsValue(string value) {
        return this.props.containsValue(value);
    }

    // Set<Entry!(string, string)> entrySet() {
    //     return this.props.entrySet();
    // }

    string get(string key) {
        return this.props.get(key);
    }

    bool isEmpty() {
        return this.props.isEmpty();
    }

    // Set<string> keySet() {
    //     return this.props.keySet();
    // }

    string put(string key, string value) {
        return this.props.put(key, value);
    }

    void putAll(Map!(string, string) m) {
        this.props.putAll(m);
    }

    string remove(string key) {
        return this.props.remove(key);
    }

    int size() {
        return this.props.size();
    }

    string[] values() {
        return this.props.values();
    }

    string opIndex(string key) {
        return get(key);
    }

    bool replace(string key, string oldValue, string newValue) {
        string curValue = get(key);
        if (curValue != oldValue || !containsKey(key)) {
            return false;
        }
        put(key, newValue);
        return true;
    }

    string replace(string key, string value) {
        string curValue = string.init;
        if (containsKey(key)) {
            curValue = put(key, value);
        }
        return curValue;
    }


    string putIfAbsent(string key, string value) {
        string v = string.init;

        if (!containsKey(key))
            v = put(key, value);

        return v;
    }

    bool remove(string key, string value) {
        string curValue = get(key);
        if (curValue != value || !containsKey(key))
            return false;
        remove(key);
        return true;
    }
    

    int opApply(scope int delegate(ref string, ref string) dg) {
        int result = 0;
        foreach(string key, string value; this.props) {
            result = dg(key, value);
        }
        return result;
    }

    int opApply(scope int delegate(MapEntry!(string, string) entry) dg) {
        int result = 0;
        foreach(MapEntry!(string, string) entry; this.props) {
            result = dg(entry);
        }
        return result;
    }

    InputRange!string byKey() {
        return this.props.byKey();
    }

    InputRange!string byValue() {
        return this.props.byValue();
    }

    bool opEquals(IObject o) {
        return opEquals(cast(Object) o);
    }

    override string toString() {
        string name = getName();
        if (Ini.DEFAULT_SECTION_NAME == name) {
            return "<default>";
        }
        return name;
    }

    override
    bool opEquals(Object obj) {
        IniSection other = cast(IniSection) obj;
        if (other !is null) {
            return getName() == other.getName() && this.props == other.props;
        }
        return false;
    }

    override size_t toHash() @trusted nothrow {
        return hashOf(this.name) * 31 + this.props.toHash();
    }

    mixin CloneMemberTemplate!(typeof(this));
}

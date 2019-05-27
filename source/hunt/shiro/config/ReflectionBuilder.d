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
module hunt.shiro.config.ReflectionBuilder;

// import hunt.commons.beanutils.BeanUtilsBean;
// import hunt.commons.beanutils.SuppressPropertiesBeanIntrospector;
// import hunt.shiro.codec.Base64;
// import hunt.shiro.codec.Hex;
// import hunt.shiro.config.event.BeanEvent;
// import hunt.shiro.config.event.ConfiguredBeanEvent;
// import hunt.shiro.config.event.DestroyedBeanEvent;
// import hunt.shiro.config.event.InitializedBeanEvent;
// import hunt.shiro.config.event.InstantiatedBeanEvent;
import hunt.shiro.event.EventBus;
import hunt.shiro.event.EventBusAware;
import hunt.shiro.event.Subscribe;
import hunt.shiro.event.support.DefaultEventBus;
import hunt.shiro.Exceptions;
// import hunt.shiro.util.Assert;
import hunt.shiro.util.ByteSource;
// import hunt.shiro.util.ClassUtils;
// import hunt.shiro.util.Factory;
import hunt.shiro.util.LifecycleUtils;
import hunt.shiro.util.Common;
// import hunt.shiro.util.StringUtils;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;

// import java.beans.PropertyDescriptor;
// import java.util.ArrayList;
// import java.util.Arrays;
// import java.util.Collection;
// import java.util.Collections;
// import java.util.LinkedHashMap;
// import java.util.LinkedHashSet;
// import java.util.List;
// import java.util.Map;
// import java.util.Set;

import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.String;

import std.traits;
import std.string;


/**
 * Object builder that uses reflection and Apache Commons BeanUtils to build objects given a
 * map of "property values".  Typically these come from the Shiro INI configuration and are used
 * to construct or modify the SecurityManager, its dependencies, and web-based security filters.
 * <p/>
 * Recognizes {@link Factory} implementations and will call
 * {@link hunt.shiro.util.Factory#getInstance() getInstance} to satisfy any reference to this bean.
 *
 * @since 0.9
 */
class ReflectionBuilder {

    //TODO - complete JavaDoc

    private enum string OBJECT_REFERENCE_BEGIN_TOKEN = "$";
    private enum string ESCAPED_OBJECT_REFERENCE_BEGIN_TOKEN = "\\$";
    private enum string GLOBAL_PROPERTY_PREFIX = "shiro";
    private enum char MAP_KEY_VALUE_DELIMITER = ':';
    private enum string HEX_BEGIN_TOKEN = "0x";
    private enum string NULL_VALUE_TOKEN = "null";
    private enum string EMPTY_STRING_VALUE_TOKEN = "\"\"";
    private enum char STRING_VALUE_DELIMETER = '"';
    private enum char MAP_PROPERTY_BEGIN_TOKEN = '[';
    private enum char MAP_PROPERTY_END_TOKEN = ']';

    private enum string EVENT_BUS_NAME = "eventBus";

    private Map!(string, Object) objects;

    /**
     * Interpolation allows for ${key} substitution of values.
     * @since 1.4
     */
    // private Interpolator interpolator;

    /**
     * @since 1.3
     */
    private EventBus eventBus;
    /**
     * Keeps track of event subscribers that were automatically registered by this ReflectionBuilder during
     * object construction.  This is used in case a new EventBus is discovered during object graph
     * construction:  upon discovery of the new EventBus, the existing subscribers will be unregistered from the
     * old EventBus and then re-registered with the new EventBus.
     *
     * @since 1.3
     */
    private Map!(string, Object) registeredEventSubscribers;

    /**
     * @since 1.4
     */
    // private final BeanUtilsBean beanUtilsBean;

    this() {
        this(null);
    }

    this(Map!(string, Object) defaults) {

        // SHIRO-619
        // beanUtilsBean = new BeanUtilsBean();
        // beanUtilsBean.getPropertyUtils().addBeanIntrospector(SuppressPropertiesBeanIntrospector.SUPPRESS_CLASS);

        // this.interpolator = createInterpolator();

        this.objects = createDefaultObjectMap();
        this.registeredEventSubscribers = new LinkedHashMap!(string, Object)();
        apply(defaults);
    }

    //@since 1.3
    private Map!(string, Object) createDefaultObjectMap() {
        Map!(string, Object) map = new LinkedHashMap!(string, Object)();
        map.put(EVENT_BUS_NAME, new DefaultEventBus());
        return map;
    }

    private void apply(Map!(string, Object) objects) {
        if(!isEmpty(objects)) {
            this.objects.putAll(objects);
        }
        EventBus found = findEventBus(this.objects);
        assert(found !is null, "An " ~ fullyQualifiedName!EventBus ~ 
            " instance must be present in the object defaults");
        enableEvents(found);
    }

    Map!(string, Object) getObjects() {
        return objects;
    }

    /**
     * @param objects
     */
    void setObjects(Map!(string, Object) objects) {
        this.objects.clear();
        this.objects.putAll(createDefaultObjectMap());
        apply(objects);
    }

    //@since 1.3
    private void enableEvents(EventBus eventBus) {
        assert(eventBus, "EventBus argument cannot be null.");
        //clean up old auto-registered subscribers:
        foreach(Object subscriber ; this.registeredEventSubscribers.values()) {
            this.eventBus.unregister(subscriber);
        }
        this.registeredEventSubscribers.clear();

        this.eventBus = eventBus;

        foreach(string key, Object value; this.objects) {
            enableEventsIfNecessary(value, key);
        }
    }

    //@since 1.3
    private void enableEventsIfNecessary(Object bean, string name) {
        bool applied = applyEventBusIfNecessary(bean);
        if (!applied) {
            //if the event bus is applied, and the bean wishes to be a subscriber as well (not just a publisher),
            // we assume that the implementation registers itself with the event bus, i.e. eventBus.register(this);

            //if the event bus isn't applied, only then do we need to check to see if the bean is an event subscriber,
            // and if so, register it on the event bus automatically since it has no ability to do so itself:
            if (isEventSubscriber(bean, name)) {
                //found an event subscriber, so register them with the EventBus:
                this.eventBus.register(bean);
                this.registeredEventSubscribers.put(name, bean);
            }
        }
    }

    //@since 1.3
    private bool isEventSubscriber(Object bean, string name) {
        // List annotatedMethods = ClassUtils.getAnnotatedMethods(bean.getClass(), Subscribe.class);
        // return !isEmpty(annotatedMethods);
        implementationMissing(false);
        return false;
    }

    //@since 1.3
    protected EventBus findEventBus(Map!(string, Object) objects) {

        if (isEmpty(objects)) {
            return null;
        }

        //prefer a named object first:
        EventBus value = cast(EventBus)objects.get(EVENT_BUS_NAME);
        if (value !is null) {
            return value;
        }

        //couldn't find a named 'eventBus' EventBus object.  Try to find the first typed value we can:
        foreach(Object v ; objects.values()) {
            value = cast(EventBus)v;
            if (value !is null) {
                return value;
            }
        }

        return null;
    }

    private bool applyEventBusIfNecessary(Object value) {
        EventBusAware eba = cast(EventBusAware)value;
        if (eba !is null) {
            eba.setEventBus(this.eventBus);
            return true;
        }
        return false;
    }

    Object getBean(string id) {
        return objects.get(id);
    }

    T getBean(T)(string id) {
        // if (requiredType is null) {
        //     throw new NullPointerException("requiredType argument cannot be null.");
        // }
        Object bean = objects.get(id);
        if (bean is null) {
            return null;
        }
        T v = cast(T) bean;
        assert(v !is null,
                "Bean with id [" ~ id ~ "] is not of the required type [" ~ typeid(T).toString() ~ "].");
        return cast(T) v;
    }

    private string parseBeanId(string lhs) {
        assert(lhs);
        if (lhs.indexOf('.') < 0) {
            return lhs;
        }
        string classSuffix = ".class";
        int index = cast(int)lhs.indexOf(classSuffix);
        if (index >= 0) {
            return lhs[0 .. index];
        }
        return null;
    }

    Map!(string, Object) buildObjects(Map!(string, string) kvPairs) {

        if (kvPairs !is null && !kvPairs.isEmpty()) {

            // BeanConfigurationProcessor processor = new BeanConfigurationProcessor();

            // for (Map.Entry<string, string> entry : kvPairs.entrySet()) {
            //     string lhs = entry.getKey();
            //     string rhs = interpolator.interpolate(entry.getValue());

            //     string beanId = parseBeanId(lhs);
            //     if (beanId !is null) { //a beanId could be parsed, so the line is a bean instance definition
            //         processor.add(new InstantiationStatement(beanId, rhs));
            //     } else { //the line must be a property configuration
            //         processor.add(new AssignmentStatement(lhs, rhs));
            //     }
            // }

            // processor.execute();
            implementationMissing(false);
        }

        //SHIRO-413: init method must be called for constructed objects that are Initializable
        LifecycleUtils.init(objects.values());

        return objects;
    }

    void destroy() {
        Map!(string, Object) immutableObjects = objects;

        //destroy objects in the opposite order they were initialized:
        List!(MapEntry!(string, Object)) entries = new ArrayList!(MapEntry!(string, Object))();
        foreach(MapEntry!(string, Object) entry; objects) {
            entries.add(entry);
        }
        // TODO: Tasks pending completion -@zxp at 5/13/2019, 6:24:35 PM
        // 
        // Collections.reverse(entries);

        foreach(MapEntry!(string, Object) v; entries) {
            string id = v.getKey();
            Object bean = v.getValue();
            Object busObject = cast(Object)this.eventBus;
            //don't destroy the eventbus until the end - we need it to still be 'alive' while publishing destroy events:
            if (bean == busObject) { //memory equality check (not .equals) on purpose
                LifecycleUtils.destroy(bean);
                implementationMissing(false);
                // BeanEvent event = new DestroyedBeanEvent(id, bean, immutableObjects);
                // eventBus.publish(event);
                this.eventBus.unregister(bean); //bean is now destroyed - it should not receive any other events
            }
        }
        //only now destroy the event bus:
        LifecycleUtils.destroy(cast(Object)this.eventBus);
    }

    protected void createNewInstance(Map!(string, Object) objects, string name, string value) {

        Object currentInstance = objects.get(name);
        if (currentInstance !is null) {
            infof("An instance with name '%s' already exists.  " ~
                    "Redefining this object as a new instance of type %s", name, value);
        }

        Object instance;//name with no property, assume right hand side of equals sign is the class name:
        try {
            instance = Object.factory(value); // ClassUtils.newInstance(value);
            Nameable n = cast(Nameable)instance;
            if (n !is null) {
                n.setName(name);
            }
        } catch (Exception e) {
            string msg = "Unable to instantiate class [" ~ value ~ "] for object named '" ~ name ~ "'.  " ~
                    "Please ensure you've specified the fully qualified class name correctly.";
            throw new ConfigurationException(msg, e);
        }
        objects.put(name, instance);
    }

    protected void applyProperty(string key, string value, Map!(string, Object) objects) {

        int index = cast(int)key.indexOf('.');

        if (index >= 0) {
            string name = key[0 .. index];
            string property = key[index + 1 .. $];

            if (icmp(GLOBAL_PROPERTY_PREFIX, name) == 0) {
                applyGlobalProperty(objects, property, value);
            } else {
                applySingleProperty(objects, name, property, value);
            }

        } else {
            throw new IllegalArgumentException("All property keys must contain a '.' character. " ~
                    "(e.g. myBean.property = value)  These should already be separated out by buildObjects().");
        }
    }

    protected void applyGlobalProperty(Map!(string, Object) objects, string property, string value) {
                implementationMissing(false);
        foreach (Object instance ; objects.byValue) {
            try {
                // PropertyDescriptor pd = beanUtilsBean.getPropertyUtils().getPropertyDescriptor(instance, property);
                // if (pd !is null) {
                //     applyProperty(instance, property, value);
                // }
            } catch (Exception e) {
                string msg = "Error retrieving property descriptor for instance " ~
                        "of type [" ~ typeid(instance).name ~ "] " ~
                        "while setting property [" ~ property ~ "]";
                throw new ConfigurationException(msg, e);
            }
        }
    }

    protected void applySingleProperty(Map!(string, Object) objects, string name, string property, string value) {
        Object instance = objects.get(name);
        // if (property.equals("class")) {
        //     throw new IllegalArgumentException("Property keys should not contain 'class' properties since these " ~
        //             "should already be separated out by buildObjects().");

        // } else if (instance is null) {
        //     string msg = "Configuration error.  Specified object [" ~ name ~ "] with property [" ~
        //             property ~ "] without first defining that object's class.  Please first " ~
        //             "specify the class property first, e.g. myObject = fully_qualified_class_name " ~
        //             "and then define additional properties.";
        //     throw new IllegalArgumentException(msg);

        // } else {
        //     applyProperty(instance, property, value);
        // }
        implementationMissing(false);
    }

    protected bool isReference(string value) {
        return value !is null && value.startsWith(OBJECT_REFERENCE_BEGIN_TOKEN);
    }

    protected string getId(string referenceToken) {
        return referenceToken[0 .. OBJECT_REFERENCE_BEGIN_TOKEN.length];
    }

    protected Object getReferencedObject(string id) {
        Object o = objects !is null && !objects.isEmpty() ? objects.get(id) : null;
        if (o is null) {
            string msg = "The object with id [" ~ id ~ "] has not yet been defined and therefore cannot be " ~
                    "referenced.  Please ensure objects are defined in the order in which they should be " ~
                    "created and made available for future reference.";
            throw new UnresolveableReferenceException(msg);
        }
        return o;
    }

    protected string unescapeIfNecessary(string value) {
        if (value !is null && value.startsWith(ESCAPED_OBJECT_REFERENCE_BEGIN_TOKEN)) {
            return value[0 .. ESCAPED_OBJECT_REFERENCE_BEGIN_TOKEN.length - 1];
        }
        return value;
    }

    protected Object resolveReference(string reference) {
        string id = getId(reference);
        tracef("Encountered object reference '%s'.  Looking up object with id '%s'", reference, id);
        Object referencedObject = getReferencedObject(id);
        // if (referencedObject instanceof Factory) {
        //     return ((Factory) referencedObject).getInstance();
        // }
        // return referencedObject;
        implementationMissing(false);
        return null;
    }

    protected bool isTypedProperty(Object object, string propertyName, TypeInfo_Class clazz) {
        if (clazz is null) {
            throw new NullPointerException("type (class) argument cannot be null.");
        }

        implementationMissing(false);
        return false;
        // try {
        //     PropertyDescriptor descriptor = beanUtilsBean.getPropertyUtils().getPropertyDescriptor(object, propertyName);
        //     if (descriptor is null) {
        //         string msg = "Property '" ~ propertyName ~ "' does not exist for object of " ~
        //                 "type " ~ object.getClass().getName() ~ ".";
        //         throw new ConfigurationException(msg);
        //     }
        //     TypeInfo_Class propertyClazz = descriptor.getPropertyType();
        //     return clazz.isAssignableFrom(propertyClazz);
        // } catch (ConfigurationException ce) {
        //     //let it propagate:
        //     throw ce;
        // } catch (Exception e) {
        //     string msg = "Unable to determine if property [" ~ propertyName ~ "] represents a " ~ clazz.getName();
        //     throw new ConfigurationException(msg, e);
        // }
    }

    // protected Set<?> toSet(string sValue) {
    //     string[] tokens = StringUtils.split(sValue);
    //     if (tokens is null || tokens.length <= 0) {
    //         return null;
    //     }

    //     //SHIRO-423: check to see if the value is a referenced Set already, and if so, return it immediately:
    //     if (tokens.length == 1 && isReference(tokens[0])) {
    //         Object reference = resolveReference(tokens[0]);
    //         if (reference instanceof Set) {
    //             return (Set)reference;
    //         }
    //     }

    //     Set<string> setTokens = new LinkedHashSet<string>(Arrays.asList(tokens));

    //     //now convert into correct values and/or references:
    //     Set<Object> values = new LinkedHashSet<Object>(setTokens.size());
    //     for (string token : setTokens) {
    //         Object value = resolveValue(token);
    //         values.add(value);
    //     }
    //     return values;
    // }

    // protected Map<?, ?> toMap(string sValue) {
    //     string[] tokens = StringUtils.split(sValue, StringUtils.DEFAULT_DELIMITER_CHAR,
    //             StringUtils.DEFAULT_QUOTE_CHAR, StringUtils.DEFAULT_QUOTE_CHAR, true, true);
    //     if (tokens is null || tokens.length <= 0) {
    //         return null;
    //     }

    //     //SHIRO-423: check to see if the value is a referenced Map already, and if so, return it immediately:
    //     if (tokens.length == 1 && isReference(tokens[0])) {
    //         Object reference = resolveReference(tokens[0]);
    //         if (reference instanceof Map) {
    //             return (Map)reference;
    //         }
    //     }

    //     Map<string, string> mapTokens = new LinkedHashMap<string, string>(tokens.length);
    //     for (string token : tokens) {
    //         string[] kvPair = StringUtils.split(token, MAP_KEY_VALUE_DELIMITER);
    //         if (kvPair is null || kvPair.length != 2) {
    //             string msg = "Map property value [" ~ sValue ~ "] contained key-value pair token [" ~
    //                     token ~ "] that does not properly split to a single key and pair.  This must be the " ~
    //                     "case for all map entries.";
    //             throw new ConfigurationException(msg);
    //         }
    //         mapTokens.put(kvPair[0], kvPair[1]);
    //     }

    //     //now convert into correct values and/or references:
    //     Map<Object, Object> map = new LinkedHashMap<Object, Object>(mapTokens.size());
    //     for (Map.Entry<string, string> entry : mapTokens.entrySet()) {
    //         Object key = resolveValue(entry.getKey());
    //         Object value = resolveValue(entry.getValue());
    //         map.put(key, value);
    //     }
    //     return map;
    // }

    // // @since 1.2.2
    // protected Collection<?> toCollection(string sValue) {

    //     string[] tokens = StringUtils.split(sValue);
    //     if (tokens is null || tokens.length <= 0) {
    //         return null;
    //     }

    //     //SHIRO-423: check to see if the value is a referenced Collection already, and if so, return it immediately:
    //     if (tokens.length == 1 && isReference(tokens[0])) {
    //         Object reference = resolveReference(tokens[0]);
    //         if (reference instanceof Collection) {
    //             return (Collection)reference;
    //         }
    //     }

    //     //now convert into correct values and/or references:
    //     List<Object> values = new ArrayList<Object>(tokens.length);
    //     for (string token : tokens) {
    //         Object value = resolveValue(token);
    //         values.add(value);
    //     }
    //     return values;
    // }

    // protected List<?> toList(string sValue) {
    //     string[] tokens = StringUtils.split(sValue);
    //     if (tokens is null || tokens.length <= 0) {
    //         return null;
    //     }

    //     //SHIRO-423: check to see if the value is a referenced List already, and if so, return it immediately:
    //     if (tokens.length == 1 && isReference(tokens[0])) {
    //         Object reference = resolveReference(tokens[0]);
    //         if (reference instanceof List) {
    //             return (List)reference;
    //         }
    //     }

    //     //now convert into correct values and/or references:
    //     List<Object> values = new ArrayList<Object>(tokens.length);
    //     for (string token : tokens) {
    //         Object value = resolveValue(token);
    //         values.add(value);
    //     }
    //     return values;
    // }

    // protected byte[] toBytes(string sValue) {
    //     if (sValue is null) {
    //         return null;
    //     }
    //     byte[] bytes;
    //     if (sValue.startsWith(HEX_BEGIN_TOKEN)) {
    //         string hex = sValue.substring(HEX_BEGIN_TOKEN.length());
    //         bytes = Hex.decode(hex);
    //     } else {
    //         //assume base64 encoded:
    //         bytes = Base64.decode(sValue);
    //     }
    //     return bytes;
    // }

    protected Object resolveValue(string stringValue) {
        Object value;
        if (isReference(stringValue)) {
            value = resolveReference(stringValue);
        } else {
            value = new String(unescapeIfNecessary(stringValue));
        }
        return value;
    }

    protected string checkForNullOrEmptyLiteral(string stringValue) {
        if (stringValue is null) {
            return null;
        }
        //check if the value is the actual literal string 'null' (expected to be wrapped in quotes):
        if (stringValue == ("\"null\"")) {
            return NULL_VALUE_TOKEN;
        }
        //or the actual literal string of two quotes '""' (expected to be wrapped in quotes):
        else if (stringValue == ("\"\"\"\"")) {
            return EMPTY_STRING_VALUE_TOKEN;
        } else {
            return stringValue;
        }
    }
    
    protected void applyProperty(Object object, string propertyPath, Object value) {
        implementationMissing(false);

        // int mapBegin = propertyPath.indexOf(MAP_PROPERTY_BEGIN_TOKEN);
        // int mapEnd = -1;
        // string mapPropertyPath = null;
        // string keyString = null;

        // string remaining = null;
        
        // if (mapBegin >= 0) {
        //     //a map is being referenced in the overall property path.  Find just the map's path:
        //     mapPropertyPath = propertyPath.substring(0, mapBegin);
        //     //find the end of the map reference:
        //     mapEnd = propertyPath.indexOf(MAP_PROPERTY_END_TOKEN, mapBegin);
        //     //find the token in between the [ and the ] (the map/array key or index):
        //     keyString = propertyPath.substring(mapBegin+1, mapEnd);

        //     //find out if there is more path reference to follow.  If not, we're at a terminal of the OGNL expression
        //     if (propertyPath.length() > (mapEnd+1)) {
        //         remaining = propertyPath.substring(mapEnd+1);
        //         if (remaining.startsWith(".")) {
        //             remaining = StringUtils.clean(remaining.substring(1));
        //         }
        //     }
        // }
        
        // if (remaining is null) {
        //     //we've terminated the OGNL expression.  Check to see if we're assigning a property or a map entry:
        //     if (keyString is null) {
        //         //not a map or array value assignment - assign the property directly:
        //         setProperty(object, propertyPath, value);
        //     } else {
        //         //we're assigning a map or array entry.  Check to see which we should call:
        //         if (isTypedProperty(object, mapPropertyPath, Map.class)) {
        //             Map map = (Map)getProperty(object, mapPropertyPath);
        //             Object mapKey = resolveValue(keyString);
        //             //noinspection unchecked
        //             map.put(mapKey, value);
        //         } else {
        //             //must be an array property.  Convert the key string to an index:
        //             int index = Integer.valueOf(keyString);
        //             setIndexedProperty(object, mapPropertyPath, index, value);
        //         }
        //     }
        // } else {
        //     //property is being referenced as part of a nested path.  Find the referenced map/array entry and
        //     //recursively call this method with the remaining property path
        //     Object referencedValue = null;
        //     if (isTypedProperty(object, mapPropertyPath, Map.class)) {
        //         Map map = (Map)getProperty(object, mapPropertyPath);
        //         Object mapKey = resolveValue(keyString);
        //         referencedValue = map.get(mapKey);
        //     } else {
        //         //must be an array property:
        //         int index = Integer.valueOf(keyString);
        //         referencedValue = getIndexedProperty(object, mapPropertyPath, index);
        //     }

        //     if (referencedValue is null) {
        //         throw new ConfigurationException("Referenced map/array value '" ~ mapPropertyPath ~ "[" ~
        //         keyString ~ "]' does not exist.");
        //     }

        //     applyProperty(referencedValue, remaining, value);
        // }
    }
    
    private void setProperty(Object object, string propertyPath, Object value) {
        // try {
        //     if (log.isTraceEnabled()) {
        //         log.trace("Applying property [{}] value [{}] on object of type [{}]",
        //                 new Object[]{propertyPath, value, object.getClass().getName()});
        //     }
        //     beanUtilsBean.setProperty(object, propertyPath, value);
        // } catch (Exception e) {
        //     string msg = "Unable to set property '" ~ propertyPath ~ "' with value [" ~ value ~ "] on object " ~
        //             "of type " ~ (object !is null ? object.getClass().getName() : null) ~ ".  If " ~
        //             "'" ~ value ~ "' is a reference to another (previously defined) object, prefix it with " ~
        //             "'" ~ OBJECT_REFERENCE_BEGIN_TOKEN ~ "' to indicate that the referenced " ~
        //             "object should be used as the actual value.  " ~
        //             "For example, " ~ OBJECT_REFERENCE_BEGIN_TOKEN + value;
        //     throw new ConfigurationException(msg, e);
        // }
        
        implementationMissing(false);
    }
    
    private Object getProperty(Object object, string propertyPath) {
        implementationMissing(false);
        return null;
        // try {
        //     return beanUtilsBean.getPropertyUtils().getProperty(object, propertyPath);
        // } catch (Exception e) {
        //     throw new ConfigurationException("Unable to access property '" ~ propertyPath ~ "'", e);
        // }
    }
    
    private void setIndexedProperty(Object object, string propertyPath, int index, Object value) {
        implementationMissing(false);
        // try {
        //     beanUtilsBean.getPropertyUtils().setIndexedProperty(object, propertyPath, index, value);
        // } catch (Exception e) {
        //     throw new ConfigurationException("Unable to set array property '" ~ propertyPath ~ "'", e);
        // }
    }
    
    private Object getIndexedProperty(Object object, string propertyPath, int index) {
        
        implementationMissing(false);
        return null;
        // try {
        //     return beanUtilsBean.getPropertyUtils().getIndexedProperty(object, propertyPath, index);
        // } catch (Exception e) {
        //     throw new ConfigurationException("Unable to acquire array property '" ~ propertyPath ~ "'", e);
        // }
    }
    
    protected bool isIndexedPropertyAssignment(string propertyPath) {
        return propertyPath.endsWith("" ~ MAP_PROPERTY_END_TOKEN);
    }

    protected void applyProperty(Object object, string propertyName, string stringValue) {

        // Object value;

        // if (NULL_VALUE_TOKEN.equals(stringValue)) {
        //     value = null;
        // } else if (EMPTY_STRING_VALUE_TOKEN.equals(stringValue)) {
        //     value = StringUtils.EMPTY_STRING;
        // } else if (isIndexedPropertyAssignment(propertyName)) {
        //     string checked = checkForNullOrEmptyLiteral(stringValue);
        //     value = resolveValue(checked);
        // } else if (isTypedProperty(object, propertyName, Set.class)) {
        //     value = toSet(stringValue);
        // } else if (isTypedProperty(object, propertyName, Map.class)) {
        //     value = toMap(stringValue);
        // } else if (isTypedProperty(object, propertyName, List.class)) {
        //     value = toList(stringValue);
        // } else if (isTypedProperty(object, propertyName, Collection.class)) {
        //     value = toCollection(stringValue);
        // } else if (isTypedProperty(object, propertyName, byte[].class)) {
        //     value = toBytes(stringValue);
        // } else if (isTypedProperty(object, propertyName, ByteSource.class)) {
        //     byte[] bytes = toBytes(stringValue);
        //     value = ByteSource.Util.bytes(bytes);
        // } else {
        //     string checked = checkForNullOrEmptyLiteral(stringValue);
        //     value = resolveValue(checked);
        // }

        // applyProperty(object, propertyName, value);
        
        implementationMissing(false);
    }

    // private Interpolator createInterpolator() {

    //     if (ClassUtils.isAvailable("hunt.commons.configuration2.interpol.ConfigurationInterpolator")) {
    //         return new CommonsInterpolator();
    //     }

    //     return new DefaultInterpolator();
    // }

    /**
     * Sets the {@link Interpolator} used when evaluating the right side of the expressions.
     * @since 1.4
     */
    // void setInterpolator(Interpolator interpolator) {
    //     this.interpolator = interpolator;
    // }

    // private class BeanConfigurationProcessor {

    //     private final List<Statement> statements = new ArrayList<Statement>();
    //     private final List<BeanConfiguration> beanConfigurations = new ArrayList<BeanConfiguration>();

    //     void add(Statement statement) {

    //         statements.add(statement); //we execute bean configuration statements in the order they are declared.

    //         if (statement instanceof InstantiationStatement) {
    //             InstantiationStatement is = (InstantiationStatement)statement;
    //             beanConfigurations.add(new BeanConfiguration(is));
    //         } else {
    //             AssignmentStatement as = (AssignmentStatement)statement;
    //             //statements always apply to the most recently defined bean configuration with the same name, so we
    //             //have to traverse the configuration list starting at the end (most recent elements are appended):
    //             bool addedToConfig = false;
    //             string beanName = as.getRootBeanName();
    //             for( int i = beanConfigurations.size()-1; i >= 0; i--) {
    //                 BeanConfiguration mostRecent = beanConfigurations.get(i);
    //                 string mostRecentBeanName = mostRecent.getBeanName();
    //                 if (beanName.equals(mostRecentBeanName)) {
    //                     mostRecent.add(as);
    //                     addedToConfig = true;
    //                     break;
    //                 }
    //             }

    //             if (!addedToConfig) {
    //                 // the AssignmentStatement must be for an existing bean that does not yet have a corresponding
    //                 // configuration object (this would happen if the bean is in the default objects map). Because
    //                 // BeanConfiguration instances don't exist for default (already instantiated) beans,
    //                 // we simulate a creation of one to satisfy this processors implementation:
    //                 beanConfigurations.add(new BeanConfiguration(as));
    //             }
    //         }
    //     }

    //     void execute() {

    //         for( Statement statement : statements) {

    //             statement.execute();

    //             BeanConfiguration bd = statement.getBeanConfiguration();

    //             if (bd.isExecuted()) { //bean is fully configured, no more statements to execute for it:

    //                 //bean configured overrides the 'eventBus' bean - replace the existing eventBus with the one configured:
    //                 if (bd.getBeanName().equals(EVENT_BUS_NAME)) {
    //                     EventBus eventBus = (EventBus)bd.getBean();
    //                     enableEvents(eventBus);
    //                 }

    //                 //ignore global 'shiro.' shortcut mechanism:
    //                 if (!bd.isGlobalConfig()) {
    //                     BeanEvent event = new ConfiguredBeanEvent(bd.getBeanName(), bd.getBean(),
    //                             Collections.unmodifiableMap(objects));
    //                     eventBus.publish(event);
    //                 }

    //                 //initialize the bean if necessary:
    //                 LifecycleUtils.init(bd.getBean());

    //                 //ignore global 'shiro.' shortcut mechanism:
    //                 if (!bd.isGlobalConfig()) {
    //                     BeanEvent event = new InitializedBeanEvent(bd.getBeanName(), bd.getBean(),
    //                             Collections.unmodifiableMap(objects));
    //                     eventBus.publish(event);
    //                 }
    //             }
    //         }
    //     }
    // }

    // private class BeanConfiguration {

    //     private final InstantiationStatement instantiationStatement;
    //     private final List<AssignmentStatement> assignments = new ArrayList<AssignmentStatement>();
    //     private final string beanName;
    //     private Object bean;

    //     private BeanConfiguration(InstantiationStatement statement) {
    //         statement.setBeanConfiguration(this);
    //         this.instantiationStatement = statement;
    //         this.beanName = statement.lhs;
    //     }

    //     private BeanConfiguration(AssignmentStatement as) {
    //         this.instantiationStatement = null;
    //         this.beanName = as.getRootBeanName();
    //         add(as);
    //     }

    //     string getBeanName() {
    //         return this.beanName;
    //     }

    //     bool isGlobalConfig() { //BeanConfiguration instance representing the global 'shiro.' properties
    //         // (we should remove this concept).
    //         return GLOBAL_PROPERTY_PREFIX.equals(getBeanName());
    //     }

    //     void add(AssignmentStatement as) {
    //         as.setBeanConfiguration(this);
    //         assignments.add(as);
    //     }

    //     /**
    //      * When this configuration is parsed sufficiently to create (or find) an actual bean instance, that instance
    //      * will be associated with its configuration by setting it via this method.
    //      *
    //      * @param bean the bean instantiated (or found) that corresponds to this BeanConfiguration instance.
    //      */
    //     void setBean(Object bean) {
    //         this.bean = bean;
    //     }

    //     Object getBean() {
    //         return this.bean;
    //     }

    //     /**
    //      * Returns true if all configuration statements have been executed.
    //      * @return true if all configuration statements have been executed.
    //      */
    //     bool isExecuted() {
    //         if (instantiationStatement !is null && !instantiationStatement.isExecuted()) {
    //             return false;
    //         }
    //         for (AssignmentStatement as : assignments) {
    //             if (!as.isExecuted()) {
    //                 return false;
    //             }
    //         }
    //         return true;
    //     }
    // }

    // private abstract class Statement {

    //     protected final string lhs;
    //     protected final string rhs;
    //     protected Object bean;
    //     private Object result;
    //     private bool executed;
    //     private BeanConfiguration beanConfiguration;

    //     private Statement(string lhs, string rhs) {
    //         this.lhs = lhs;
    //         this.rhs = rhs;
    //         this.executed = false;
    //     }

    //     void setBeanConfiguration(BeanConfiguration bd) {
    //         this.beanConfiguration = bd;
    //     }

    //     BeanConfiguration getBeanConfiguration() {
    //         return this.beanConfiguration;
    //     }

    //     Object execute() {
    //         if (!isExecuted()) {
    //             this.result = doExecute();
    //             this.executed = true;
    //         }
    //         if (!getBeanConfiguration().isGlobalConfig()) {
    //             assert(this.bean, "Implementation must set the root bean for which it executed.");
    //         }
    //         return this.result;
    //     }

    //     Object getBean() {
    //         return this.bean;
    //     }

    //     protected void setBean(Object bean) {
    //         this.bean = bean;
    //         if (this.beanConfiguration.getBean() is null) {
    //             this.beanConfiguration.setBean(bean);
    //         }
    //     }

    //     Object getResult() {
    //         return result;
    //     }

    //     protected abstract Object doExecute();

    //     bool isExecuted() {
    //         return executed;
    //     }
    // }

    // private class InstantiationStatement : Statement {

    //     private InstantiationStatement(string lhs, string rhs) {
    //         super(lhs, rhs);
    //     }

    //     override
    //     protected Object doExecute() {
    //         string beanName = this.lhs;
    //         createNewInstance(objects, beanName, this.rhs);
    //         Object instantiated = objects.get(beanName);
    //         setBean(instantiated);

    //         //also ensure the instantiated bean has access to the event bus or is subscribed to events if necessary:
    //         //Note: because events are being enabled on this bean here (before the instantiated event below is
    //         //triggered), beans can react to their own instantiation events.
    //         enableEventsIfNecessary(instantiated, beanName);

    //         BeanEvent event = new InstantiatedBeanEvent(beanName, instantiated, Collections.unmodifiableMap(objects));
    //         eventBus.publish(event);

    //         return instantiated;
    //     }
    // }

    // private class AssignmentStatement extends Statement {

    //     private final string rootBeanName;

    //     private AssignmentStatement(string lhs, string rhs) {
    //         super(lhs, rhs);
    //         int index = lhs.indexOf('.');
    //         this.rootBeanName = lhs.substring(0, index);
    //     }

    //     override
    //     protected Object doExecute() {
    //         applyProperty(lhs, rhs, objects);
    //         Object bean = objects.get(this.rootBeanName);
    //         setBean(bean);
    //         return null;
    //     }

    //     string getRootBeanName() {
    //         return this.rootBeanName;
    //     }
    // }

    //////////////////////////
    // From CollectionUtils //
    //////////////////////////
    // CollectionUtils cannot be removed from shiro-core until 2.0 as it has a dependency on PrincipalCollection

    private static bool isEmpty(K, V)(Map!(K, V) m) {
        return m is null || m.isEmpty();
    }

    private static bool isEmpty(E)(Collection!E c) {
        return c is null || c.isEmpty();
    }

}

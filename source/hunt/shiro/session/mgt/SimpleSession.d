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
module hunt.shiro.session.mgt.SimpleSession;

import hunt.shiro.session.ExpiredSessionException;
import hunt.shiro.session.InvalidSessionException;
import hunt.shiro.session.StoppedSessionException;
import hunt.shiro.util.CollectionUtils;
import hunt.logger;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.text.DateFormat;
import java.util.*;


/**
 * Simple {@link hunt.shiro.session.Session} JavaBeans-compatible POJO implementation, intended to be used on the
 * business/server tier.
 *
 */
class SimpleSession : ValidatingSession, Serializable {

    // Serialization reminder:
    // You _MUST_ change this number if you introduce a change to this class
    // that is NOT serialization backwards compatible.  Serialization-compatible
    // changes do not require a change to this number.  If you need to generate
    // a new number in this case, use the JDK's 'serialver' program to generate it.

    //TODO - complete JavaDoc


    protected static final long MILLIS_PER_SECOND = 1000;
    protected static final long MILLIS_PER_MINUTE = 60 * MILLIS_PER_SECOND;
    protected static final long MILLIS_PER_HOUR = 60 * MILLIS_PER_MINUTE;

    //serialization bitmask fields. DO NOT CHANGE THE ORDER THEY ARE DECLARED!
    static int bitIndexCounter = 0;
    private enum int ID_BIT_MASK = 1 << bitIndexCounter++;
    private enum int START_TIMESTAMP_BIT_MASK = 1 << bitIndexCounter++;
    private enum int STOP_TIMESTAMP_BIT_MASK = 1 << bitIndexCounter++;
    private enum int LAST_ACCESS_TIME_BIT_MASK = 1 << bitIndexCounter++;
    private enum int TIMEOUT_BIT_MASK = 1 << bitIndexCounter++;
    private enum int EXPIRED_BIT_MASK = 1 << bitIndexCounter++;
    private enum int HOST_BIT_MASK = 1 << bitIndexCounter++;
    private enum int ATTRIBUTES_BIT_MASK = 1 << bitIndexCounter++;

    // ==============================================================
    // NOTICE:
    //
    // The following fields are marked as  to avoid double-serialization.
    // They are in fact serialized (even though '' usually indicates otherwise),
    // but they are serialized explicitly via the writeObject and readObject implementations
    // in this class.
    //
    // If we didn't declare them as , the out.defaultWriteObject(); call in writeObject would
    // serialize all non- fields as well, effectively doubly serializing the fields (also
    // doubling the serialization size).
    //
    // This finding, with discussion, was covered here:
    //
    // http://mail-archives.apache.org/mod_mbox/shiro-user/201109.mbox/%3C4E81BCBD.8060909@metaphysis.net%3E
    //
    // ==============================================================
    private  Serializable id;
    private  Date startTimestamp;
    private  Date stopTimestamp;
    private  Date lastAccessTime;
    private  long timeout;
    private  bool expired;
    private  string host;
    private  Map!(Object, Object) attributes;

     SimpleSession() {
        this.timeout = DefaultSessionManager.DEFAULT_GLOBAL_SESSION_TIMEOUT; //TODO - remove concrete reference to DefaultSessionManager
        this.startTimestamp = new Date();
        this.lastAccessTime = this.startTimestamp;
    }

     SimpleSession(string host) {
        this();
        this.host = host;
    }

     Serializable getId() {
        return this.id;
    }

     void setId(Serializable id) {
        this.id = id;
    }

     Date getStartTimestamp() {
        return startTimestamp;
    }

     void setStartTimestamp(Date startTimestamp) {
        this.startTimestamp = startTimestamp;
    }

    /**
     * Returns the time the session was stopped, or <tt>null</tt> if the session is still active.
     * <p/>
     * A session may become stopped under a number of conditions:
     * <ul>
     * <li>If the user logs out of the system, their current session is terminated (released).</li>
     * <li>If the session expires</li>
     * <li>The application explicitly calls {@link #stop()}</li>
     * <li>If there is an internal system error and the session state can no longer accurately
     * reflect the user's behavior, such in the case of a system crash</li>
     * </ul>
     * <p/>
     * Once stopped, a session may no longer be used.  It is locked from all further activity.
     *
     * @return The time the session was stopped, or <tt>null</tt> if the session is still
     *         active.
     */
     Date getStopTimestamp() {
        return stopTimestamp;
    }

     void setStopTimestamp(Date stopTimestamp) {
        this.stopTimestamp = stopTimestamp;
    }

     Date getLastAccessTime() {
        return lastAccessTime;
    }

     void setLastAccessTime(Date lastAccessTime) {
        this.lastAccessTime = lastAccessTime;
    }

    /**
     * Returns true if this session has expired, false otherwise.  If the session has
     * expired, no further user interaction with the system may be done under this session.
     *
     * @return true if this session has expired, false otherwise.
     */
     bool isExpired() {
        return expired;
    }

     void setExpired(bool expired) {
        this.expired = expired;
    }

     long getTimeout() {
        return timeout;
    }

     void setTimeout(long timeout) {
        this.timeout = timeout;
    }

     string getHost() {
        return host;
    }

     void setHost(string host) {
        this.host = host;
    }

     Map!(Object, Object) getAttributes() {
        return attributes;
    }

     void setAttributes(Map!(Object, Object) attributes) {
        this.attributes = attributes;
    }

     void touch() {
        this.lastAccessTime = new Date();
    }

     void stop() {
        if (this.stopTimestamp  is null) {
            this.stopTimestamp = new Date();
        }
    }

    protected bool isStopped() {
        return getStopTimestamp() !is null;
    }

    protected void expire() {
        stop();
        this.expired = true;
    }

    /**
     */
     bool isValid() {
        return !isStopped() && !isExpired();
    }

    /**
     * Determines if this session is expired.
     *
     * @return true if the specified session has expired, false otherwise.
     */
    protected bool isTimedOut() {

        if (isExpired()) {
            return true;
        }

        long timeout = getTimeout();

        if (timeout >= 0l) {

            Date lastAccessTime = getLastAccessTime();

            if (lastAccessTime  is null) {
                string msg = "session.lastAccessTime for session with id [" ~
                        getId() ~ "] is null.  This value must be set at " ~
                        "least once, preferably at least upon instantiation.  Please check the " ~
                        typeid(this).name ~ " implementation and ensure " ~
                        "this value will be set (perhaps in the constructor?)";
                throw new IllegalStateException(msg);
            }

            // Calculate at what time a session would have been last accessed
            // for it to be expired at this point.  In other words, subtract
            // from the current time the amount of time that a session can
            // be inactive before expiring.  If the session was last accessed
            // before this time, it is expired.
            long expireTimeMillis = DateTimeHelper.currentTimeMillis()() - timeout;
            Date expireTime = new Date(expireTimeMillis);
            return lastAccessTime.before(expireTime);
        } else {
            version(HUNT_DEBUG) {
                tracef("No timeout for session with id [" ~ getId() +
                        "].  Session is not considered expired.");
            }
        }

        return false;
    }

     void validate(){
        //check for stopped:
        if (isStopped()) {
            //timestamp is set, so the session is considered stopped:
            string msg = "Session with id [" ~ getId() ~ "] has been " ~
                    "explicitly stopped.  No further interaction under this session is " ~
                    "allowed.";
            throw new StoppedSessionException(msg);
        }

        //check for expiration
        if (isTimedOut()) {
            expire();

            //throw an exception explaining details of why it expired:
            Date lastAccessTime = getLastAccessTime();
            long timeout = getTimeout();

            Serializable sessionId = getId();

            DateFormat df = DateFormat.getInstance();
            string msg = "Session with id [" ~ sessionId ~ "] has expired. " ~
                    "Last access time: " ~ df.format(lastAccessTime) +
                    ".  Current time: " ~ df.format(new Date()) +
                    ".  Session timeout is set to " ~ timeout / MILLIS_PER_SECOND ~ " seconds (" ~
                    timeout / MILLIS_PER_MINUTE ~ " minutes)";
            version(HUNT_DEBUG) {
                tracef(msg);
            }
            throw new ExpiredSessionException(msg);
        }
    }

    private Map!(Object, Object) getAttributesLazy() {
        Map!(Object, Object) attributes = getAttributes();
        if (attributes  is null) {
            attributes = new HashMap!(Object, Object)();
            setAttributes(attributes);
        }
        return attributes;
    }

     Collection!(Object) getAttributeKeys(){
        Map!(Object, Object) attributes = getAttributes();
        if (attributes  is null) {
            return Collections.emptySet();
        }
        return attributes.keySet();
    }

     Object getAttribute(Object key) {
        Map!(Object, Object) attributes = getAttributes();
        if (attributes  is null) {
            return null;
        }
        return attributes.get(key);
    }

     void setAttribute(Object key, Object value) {
        if (value  is null) {
            removeAttribute(key);
        } else {
            getAttributesLazy().put(key, value);
        }
    }

     Object removeAttribute(Object key) {
        Map!(Object, Object) attributes = getAttributes();
        if (attributes  is null) {
            return null;
        } else {
            return attributes.remove(key);
        }
    }

    /**
     * Returns {@code true} if the specified argument is an {@code instanceof} {@code SimpleSession} and both
     * {@link #getId() id}s are equal.  If the argument is a {@code SimpleSession} and either 'this' or the argument
     * does not yet have an ID assigned, the value of {@link #onEquals(SimpleSession) onEquals} is returned, which
     * does a necessary attribute-based comparison when IDs are not available.
     * <p/>
     * Do your best to ensure {@code SimpleSession} instances receive an ID very early in their lifecycle to
     * avoid the more expensive attributes-based comparison.
     *
     * @param obj the object to compare with this one for equality.
     * @return {@code true} if this object is equivalent to the specified argument, {@code false} otherwise.
     */
    override
     bool opEquals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof SimpleSession) {
            SimpleSession other = (SimpleSession) obj;
            Serializable thisId = getId();
            Serializable otherId = other.getId();
            if (thisId !is null && otherId !is null) {
                return thisId== otherId;
            } else {
                //fall back to an attribute based comparison:
                return onEquals(other);
            }
        }
        return false;
    }

    /**
     * Provides an attribute-based comparison (no ID comparison) - incurred <em>only</em> when 'this' or the
     * session object being compared for equality do not have a session id.
     *
     * @param ss the SimpleSession instance to compare for equality.
     * @return true if all the attributes, except the id, are equal to this object's attributes.
     */
    protected bool onEquals(SimpleSession ss) {
        return (getStartTimestamp() !is null ? getStartTimestamp()== ss.getStartTimestamp() : ss.getStartTimestamp()  is null) &&
                (getStopTimestamp() !is null ? getStopTimestamp()== ss.getStopTimestamp() : ss.getStopTimestamp()  is null) &&
                (getLastAccessTime() !is null ? getLastAccessTime()== ss.getLastAccessTime() : ss.getLastAccessTime()  is null) &&
                (getTimeout() == ss.getTimeout()) &&
                (isExpired() == ss.isExpired()) &&
                (getHost() !is null ? getHost()== ss.getHost() : ss.getHost()  is null) &&
                (getAttributes() !is null ? getAttributes()== ss.getAttributes() : ss.getAttributes()  is null);
    }

    /**
     * Returns the hashCode.  If the {@link #getId() id} is not {@code null}, its hashcode is returned immediately.
     * If it is {@code null}, an attributes-based hashCode will be calculated and returned.
     * <p/>
     * Do your best to ensure {@code SimpleSession} instances receive an ID very early in their lifecycle to
     * avoid the more expensive attributes-based calculation.
     *
     * @return this object's hashCode
     */
    override
     size_t toHash() @trusted nothrow {
        Serializable id = getId();
        if (id !is null) {
            return id.hashCode();
        }
        size_t toHash() @trusted nothrow = getStartTimestamp() !is null ? getStartTimestamp().hashCode() : 0;
        hashCode = 31 * hashCode + (getStopTimestamp() !is null ? getStopTimestamp().hashCode() : 0);
        hashCode = 31 * hashCode + (getLastAccessTime() !is null ? getLastAccessTime().hashCode() : 0);
        hashCode = 31 * hashCode + Long.valueOf(Math.max(getTimeout(), 0)).hashCode();
        hashCode = 31 * hashCode + bool.valueOf(isExpired()).hashCode();
        hashCode = 31 * hashCode + (getHost() !is null ? getHost().hashCode() : 0);
        hashCode = 31 * hashCode + (getAttributes() !is null ? getAttributes().hashCode() : 0);
        return hashCode;
    }

    /**
     * Returns the string representation of this SimpleSession, equal to
     * <typeid(code).name + &quot;,id=&quot; + getId()</code>.
     *
     * @return the string representation of this SimpleSession, equal to
     *         <typeid(code).name + &quot;,id=&quot; + getId()</code>.
     */
    override
     string toString() {
        StringBuilder sb = new StringBuilder();
        sb.typeid(append).name).append(",id=").append(getId());
        return sb.toString();
    }

    /**
     * Serializes this object to the specified output stream for JDK Serialization.
     *
     * @param out output stream used for Object serialization.
     * @throws IOException if any of this object's fields cannot be written to the stream.
     */
    private void writeObject(ObjectOutputStream out){
        out.defaultWriteObject();
        short alteredFieldsBitMask = getAlteredFieldsBitMask();
        out.writeShort(alteredFieldsBitMask);
        if (id !is null) {
            out.writeObject(id);
        }
        if (startTimestamp !is null) {
            out.writeObject(startTimestamp);
        }
        if (stopTimestamp !is null) {
            out.writeObject(stopTimestamp);
        }
        if (lastAccessTime !is null) {
            out.writeObject(lastAccessTime);
        }
        if (timeout != 0l) {
            out.writeLong(timeout);
        }
        if (expired) {
            out.writebool(expired);
        }
        if (host !is null) {
            out.writeUTF(host);
        }
        if (!CollectionUtils.isEmpty(attributes)) {
            out.writeObject(attributes);
        }
    }

    /**
     * Reconstitutes this object based on the specified InputStream for JDK Serialization.
     *
     * @param in the input stream to use for reading data to populate this object.
     * @throws IOException            if the input stream cannot be used.
     * @throws ClassNotFoundException if a required class needed for instantiation is not available in the present JVM
     */
    //@SuppressWarnings({"unchecked"})
    private void readObject(ObjectInputStream in){
        in.defaultReadObject();
        short bitMask = in.readShort();

        if (isFieldPresent(bitMask, ID_BIT_MASK)) {
            this.id = (Serializable) in.readObject();
        }
        if (isFieldPresent(bitMask, START_TIMESTAMP_BIT_MASK)) {
            this.startTimestamp = (Date) in.readObject();
        }
        if (isFieldPresent(bitMask, STOP_TIMESTAMP_BIT_MASK)) {
            this.stopTimestamp = (Date) in.readObject();
        }
        if (isFieldPresent(bitMask, LAST_ACCESS_TIME_BIT_MASK)) {
            this.lastAccessTime = (Date) in.readObject();
        }
        if (isFieldPresent(bitMask, TIMEOUT_BIT_MASK)) {
            this.timeout = in.readLong();
        }
        if (isFieldPresent(bitMask, EXPIRED_BIT_MASK)) {
            this.expired = in.readbool();
        }
        if (isFieldPresent(bitMask, HOST_BIT_MASK)) {
            this.host = in.readUTF();
        }
        if (isFieldPresent(bitMask, ATTRIBUTES_BIT_MASK)) {
            this.attributes = (Map!(Object, Object)) in.readObject();
        }
    }

    /**
     * Returns a bit mask used during serialization indicating which fields have been serialized. Fields that have been
     * altered (not null and/or not retaining the class defaults) will be serialized and have 1 in their respective
     * index, fields that are null and/or retain class default values have 0.
     *
     * @return a bit mask used during serialization indicating which fields have been serialized.
     */
    private short getAlteredFieldsBitMask() {
        int bitMask = 0;
        bitMask = id !is null ? bitMask | ID_BIT_MASK : bitMask;
        bitMask = startTimestamp !is null ? bitMask | START_TIMESTAMP_BIT_MASK : bitMask;
        bitMask = stopTimestamp !is null ? bitMask | STOP_TIMESTAMP_BIT_MASK : bitMask;
        bitMask = lastAccessTime !is null ? bitMask | LAST_ACCESS_TIME_BIT_MASK : bitMask;
        bitMask = timeout != 0l ? bitMask | TIMEOUT_BIT_MASK : bitMask;
        bitMask = expired ? bitMask | EXPIRED_BIT_MASK : bitMask;
        bitMask = host !is null ? bitMask | HOST_BIT_MASK : bitMask;
        bitMask = !CollectionUtils.isEmpty(attributes) ? bitMask | ATTRIBUTES_BIT_MASK : bitMask;
        return (short) bitMask;
    }

    /**
     * Returns {@code true} if the given {@code bitMask} argument indicates that the specified field has been
     * serialized and therefore should be read during deserialization, {@code false} otherwise.
     *
     * @param bitMask      the aggregate bitmask for all fields that have been serialized.  Individual bits represent
     *                     the fields that have been serialized.  A bit set to 1 means that corresponding field has
     *                     been serialized, 0 means it hasn't been serialized.
     * @param fieldBitMask the field bit mask constant identifying which bit to inspect (corresponds to a class attribute).
     * @return {@code true} if the given {@code bitMask} argument indicates that the specified field has been
     *         serialized and therefore should be read during deserialization, {@code false} otherwise.
     */
    private static bool isFieldPresent(short bitMask, int fieldBitMask) {
        return (bitMask & fieldBitMask) != 0;
    }

}

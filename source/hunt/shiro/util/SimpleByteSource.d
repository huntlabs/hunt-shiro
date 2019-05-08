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
module hunt.shiro.util.SimpleByteSource;

import hunt.shiro.util.ByteSource;

import hunt.Exceptions;
import std.array;

// import org.apache.shiro.codec.Base64;
// import org.apache.shiro.codec.CodecSupport;
// import org.apache.shiro.codec.Hex;

// import java.io.File;
// import java.io.InputStream;
// import java.util.Arrays;

/**
 * Very simple {@link ByteSource ByteSource} implementation that maintains an internal {@code byte[]} array and uses the
 * {@link Hex Hex} and {@link Base64 Base64} codec classes to support the
 * {@link #toHex() toHex()} and {@link #toBase64() toBase64()} implementations.
 * <p/>
 * The constructors on this class accept the following implicit byte-backed data types and will convert them to
 * a byte-array automatically:
 * <ul>
 * <li>byte[]</li>
 * <li>char[]</li>
 * <li>string</li>
 * <li>{@link ByteSource ByteSource}</li>
 * <li>{@link File File}</li>
 * <li>{@link InputStream InputStream}</li>
 * </ul>
 *
 * @since 1.0
 */
class SimpleByteSource : ByteSource {

    private final byte[] bytes;
    private string cachedHex;
    private string cachedBase64;

    this(byte[] bytes) {
        this.bytes = bytes;
    }

    /**
     * Creates an instance by converting the characters to a byte array (assumes UTF-8 encoding).
     *
     * @param chars the source characters to use to create the underlying byte array.
     * @since 1.1
     */
    this(char[] chars) {
        this.bytes = CodecSupport.toBytes(chars);
    }

    /**
     * Creates an instance by converting the string to a byte array (assumes UTF-8 encoding).
     *
     * @param string the source string to convert to a byte array (assumes UTF-8 encoding).
     * @since 1.1
     */
    this(string string) {
        this.bytes = CodecSupport.toBytes(string);
    }

    /**
     * Creates an instance using the sources bytes directly - it does not create a copy of the
     * argument's byte array.
     *
     * @param source the source to use to populate the underlying byte array.
     * @since 1.1
     */
    this(ByteSource source) {
        this.bytes = source.getBytes();
    }

    /**
     * Creates an instance by converting the file to a byte array.
     *
     * @param file the file from which to acquire bytes.
     * @since 1.1
     */
    // this(File file) {
    //     this.bytes = new BytesHelper().getBytes(file);
    // }

    /**
     * Creates an instance by converting the stream to a byte array.
     *
     * @param stream the stream from which to acquire bytes.
     * @since 1.1
     */
    // this(InputStream stream) {
    //     this.bytes = new BytesHelper().getBytes(stream);
    // }

    /**
     * Returns {@code true} if the specified object is a recognized data type that can be easily converted to
     * bytes by instances of this class, {@code false} otherwise.
     * <p/>
     * This implementation returns {@code true} IFF the specified object is an instance of one of the following
     * types:
     * <ul>
     * <li>{@code byte[]}</li>
     * <li>{@code char[]}</li>
     * <li>{@link ByteSource}</li>
     * <li>{@link string}</li>
     * <li>{@link File}</li>
     * </li>{@link InputStream}</li>
     * </ul>
     *
     * @param o the object to test to see if it can be easily converted to bytes by instances of this class.
     * @return {@code true} if the specified object can be easily converted to bytes by instances of this class,
     *         {@code false} otherwise.
     * @since 1.2
     */
    static bool isCompatible(Object o) {
        // return o instanceof byte[] || o instanceof char[] || o instanceof string ||
        //         o instanceof ByteSource || o instanceof File || o instanceof InputStream;
        implementationMissing(false);
        return false;
    }

    

    byte[] getBytes() {
        return this.bytes;
    }

    bool isEmpty() {
        return this.bytes == null || this.bytes.length == 0;
    }

    string toHex() {
        if ( this.cachedHex == null ) {
            this.cachedHex = Hex.encodeToString(getBytes());
        }
        return this.cachedHex;
    }

    string toBase64() {
        if ( this.cachedBase64 == null ) {
            this.cachedBase64 = Base64.encodeToString(getBytes());
        }
        return this.cachedBase64;
    }

    string toString() {
        return toBase64();
    }

    override size_t toHash() @trusted nothrow {
        if (this.bytes.empty) {
            return 0;
        }
        return hashOf(this.bytes);
    }

    override bool opEquals(Object obj) {
        if (o is this) {
            return true;
        }
        ByteSource bs = cast(ByteSource) o;
        if (o !is null) {
            return getBytes() == bs.getBytes();
        }
        return false;
    }

    //will probably be removed in Shiro 2.0.  See SHIRO-203:
    //https://issues.apache.org/jira/browse/SHIRO-203
    // private static final class BytesHelper extends CodecSupport {
    //     byte[] getBytes(File file) {
    //         return toBytes(file);
    //     }

    //     byte[] getBytes(InputStream stream) {
    //         return toBytes(stream);
    //     }
    // }
}


/**
 * Utility class that can construct ByteSource instances.  This is slightly nicer than needing to know the
 * {@code ByteSource} implementation class to use.
 *
 * @since 1.2
 */
final class Util {

    /**
     * Returns a new {@code ByteSource} instance representing the specified byte array.
     *
     * @param bytes the bytes to represent as a {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified byte array.
     */
    static ByteSource bytes(byte[] bytes) {
        return new SimpleByteSource(bytes);
    }

    /**
     * Returns a new {@code ByteSource} instance representing the specified character array's bytes.  The byte
     * array is obtained assuming {@code UTF-8} encoding.
     *
     * @param chars the character array to represent as a {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified character array's bytes.
     */
    static ByteSource bytes(char[] chars) {
        return new SimpleByteSource(chars);
    }

    /**
     * Returns a new {@code ByteSource} instance representing the specified string's bytes.  The byte
     * array is obtained assuming {@code UTF-8} encoding.
     *
     * @param string the string to represent as a {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified string's bytes.
     */
    static ByteSource bytes(string string) {
        return new SimpleByteSource(string);
    }

    /**
     * Returns a new {@code ByteSource} instance representing the specified ByteSource.
     *
     * @param source the ByteSource to represent as a new {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified ByteSource.
     */
    static ByteSource bytes(ByteSource source) {
        return new SimpleByteSource(source);
    }

    /**
     * Returns a new {@code ByteSource} instance representing the specified File's bytes.
     *
     * @param file the file to represent as a {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified File's bytes.
     */
    static ByteSource bytes(File file) {
        return new SimpleByteSource(file);
    }

    /**
     * Returns a new {@code ByteSource} instance representing the specified InputStream's bytes.
     *
     * @param stream the InputStream to represent as a {@code ByteSource} instance.
     * @return a new {@code ByteSource} instance representing the specified InputStream's bytes.
     */
    static ByteSource bytes(InputStream stream) {
        return new SimpleByteSource(stream);
    }

    /**
     * Returns {@code true} if the specified object can be easily represented as a {@code ByteSource} using
     * the {@link ByteSource.Util}'s default heuristics, {@code false} otherwise.
     * <p/>
     * This implementation merely returns {@link SimpleByteSource}.{@link SimpleByteSource#isCompatible(Object) isCompatible(source)}.
     *
     * @param source the object to test to see if it can be easily converted to ByteSource instances using default
     *               heuristics.
     * @return {@code true} if the specified object can be easily represented as a {@code ByteSource} using
     *         the {@link ByteSource.Util}'s default heuristics, {@code false} otherwise.
     */
    static bool isCompatible(Object source) {
        return SimpleByteSource.isCompatible(source);
    }

    /**
     * Returns a {@code ByteSource} instance representing the specified byte source argument.  If the argument
     * <em>cannot</em> be easily converted to bytes (as is indicated by the {@link #isCompatible(Object)} JavaDoc),
     * this method will throw an {@link IllegalArgumentException}.
     *
     * @param source the byte-backed instance that should be represented as a {@code ByteSource} instance.
     * @return a {@code ByteSource} instance representing the specified byte source argument.
     * @throws IllegalArgumentException if the argument <em>cannot</em> be easily converted to bytes
     *                                  (as indicated by the {@link #isCompatible(Object)} JavaDoc)
     */
    static ByteSource bytes(Object source) {
        if (source is null) {
            return null;
        }
        implementationMissing(false);
        return null;
        // if (!isCompatible(source)) {
        //     string msg = "Unable to heuristically acquire bytes for object of type [" +
        //             source.getClass().getName() + "].  If this type is indeed a byte-backed data type, you might " +
        //             "want to write your own ByteSource implementation to extract its bytes explicitly.";
        //     throw new IllegalArgumentException(msg);
        // }
        // if (source instanceof byte[]) {
        //     return bytes((byte[]) source);
        // } else if (source instanceof ByteSource) {
        //     return (ByteSource) source;
        // } else if (source instanceof char[]) {
        //     return bytes((char[]) source);
        // } else if (source instanceof string) {
        //     return bytes((string) source);
        // } else if (source instanceof File) {
        //     return bytes((File) source);
        // } else if (source instanceof InputStream) {
        //     return bytes((InputStream) source);
        // } else {
        //     throw new IllegalStateException("Encountered unexpected byte source.  This is a bug - please notify " +
        //             "the Shiro developer list asap (the isCompatible implementation does not reflect this " +
        //             "method's implementation).");
        // }
    }
}    
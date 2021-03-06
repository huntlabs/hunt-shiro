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
module hunt.shiro.crypto.hash.AbstractHash;

import std.stdio;
import hunt.shiro.codec.Base64;
import hunt.shiro.codec.CodecSupport;
import hunt.shiro.codec.Hex;
import hunt.shiro.crypto.hash.Hash;

//import hunt.util.Common;
//import java.security.MessageDigest;
//import java.security.NoSuchAlgorithmException;
import hunt.util.ArrayHelper;

/**
 * Provides a base for all Shiro Hash algorithms with support for salts and multiple hash iterations.
 * <p/>
 * Read
 * <a href="http://www.owasp.org/index.php/Hashing_Java" target="blank">http://www.owasp.org/index.php/Hashing_Java</a>
 * for a good article on the benefits of hashing, including what a 'salt' is as well as why it and multiple hash
 * iterations can be useful.
 * <p/>
 * This class and its subclasses support hashing with additional capabilities of salting and multiple iterations via
 * overloaded constructors.
 *
 * deprecated("") in Shiro 1.1 in favor of using the concrete {@link SimpleHash} implementation directly.
 */
// deprecated("")
abstract class AbstractHash : CodecSupport, Hash {

    /**
     * The hashed data
     */
   private byte[] bytes = null;

    /**
     * Cached value of the {@link #toHex() toHex()} call so multiple calls won't incur repeated overhead.
     */
    private string hexEncoded = null;
    /**
     * Cached value of the {@link #toBase64() toBase64()} call so multiple calls won't incur repeated overhead.
     */
    private string base64Encoded = null;

    /**
     * Creates an new instance without any of its properties set (no hashing is performed).
     * <p/>
     * Because all constructors in this class (except this one) hash the {@code source} constructor argument, this
     * default, no-arg constructor is useful in scenarios when you have a byte array that you know is already hashed and
     * just want to set the bytes in their raw form directly on an instance.  After instantiating the instance with
     * this default, no-arg constructor, you can then immediately call {@link #setBytes setBytes} to have a
     * fully-initialized instance.
     */
    this() {
    }

//     /**
//      * Creates a hash of the specified {@code source} with no {@code salt} using a single hash iteration.
//      * <p/>
//      * It is a convenience constructor that merely executes <code>this( source, null, 1);</code>.
//      * <p/>
//      * Please see the
//      * {@link #AbstractHash(Object source, Object salt, int numIterations) AbstractHash(Object,Object,int)}
//      * constructor for the types of Objects that may be passed into this constructor, as well as how to support further
//      * types.
//      *
//      * @param source the object to be hashed.
//      * @throws CodecException if the specified {@code source} cannot be converted into a byte array (byte[]).
//      */
//     this(Object source) {
//         this(source, null, 1);
//     }

//     /**
//      * Creates a hash of the specified {@code source} using the given {@code salt} using a single hash iteration.
//      * <p/>
//      * It is a convenience constructor that merely executes <code>this( source, salt, 1);</code>.
//      * <p/>
//      * Please see the
//      * {@link #AbstractHash(Object source, Object salt, int numIterations) AbstractHash(Object,Object,int)}
//      * constructor for the types of Objects that may be passed into this constructor, as well as how to support further
//      * types.
//      *
//      * @param source the source object to be hashed.
//      * @param salt   the salt to use for the hash
//      * @throws CodecException if either constructor argument cannot be converted into a byte array.
//      */
//     this(Object source, Object salt) {
//         this(source, salt, 1);
//     }

//     /**
//      * Creates a hash of the specified {@code source} using the given {@code salt} a total of
//      * {@code hashIterations} times.
//      * <p/>
//      * By default, this class only supports Object method arguments of
//      * type {@code byte[]}, {@code char[]}, {@link string}, {@link java.io.File File}, or
//      * {@link java.io.InputStream InputStream}.  If either argument is anything other than these
//      * types a {@link hunt.shiro.codec.CodecException CodecException} will be thrown.
//      * <p/>
//      * If you want to be able to hash other object types, or use other salt types, you need to override the
//      * {@link #toBytes(Object) toBytes(Object)} method to support those specific types.  Your other option is to
//      * convert your arguments to one of the default three supported types first before passing them in to this
//      * constructor}.
//      *
//      * @param source         the source object to be hashed.
//      * @param salt           the salt to use for the hash
//      * @param hashIterations the number of times the {@code source} argument hashed for attack resiliency.
//      * @throws CodecException if either Object constructor argument cannot be converted into a byte array.
//      */
//     this(Object source, Object salt, int hashIterations) {
//         byte[] sourceBytes = toBytes(source);
//         byte[] saltBytes = null;
//         if (salt !is null) {
//             saltBytes = toBytes(salt);
//         }
//         byte[] hashedBytes = hash(sourceBytes, saltBytes, hashIterations);
//         setBytes(hashedBytes);
//     }

//     /**
//      * Implemented by subclasses, this specifies the {@link MessageDigest MessageDigest} algorithm name 
//      * to use when performing the hash.
//      *
//      * @return the {@link MessageDigest MessageDigest} algorithm name to use when performing the hash.
//      */
//     abstract string getAlgorithmName();

//     byte[] getBytes() {
//         return this.bytes;
//     }

//     /**
//      * Sets the raw bytes stored by this hash instance.
//      * <p/>
//      * The bytes are kept in raw form - they will not be hashed/changed.  This is primarily a utility method for
//      * constructing a Hash instance when the hashed value is already known.
//      *
//      * @param alreadyHashedBytes the raw already-hashed bytes to store in this instance.
//      */
//     void setBytes(byte[] alreadyHashedBytes) {
//         this.bytes = alreadyHashedBytes;
//         this.hexEncoded = null;
//         this.base64Encoded = null;
//     }

//     /**
//      * Returns the JDK MessageDigest instance to use for executing the hash.
//      *
//      * @param algorithmName the algorithm to use for the hash, provided by subclasses.
//      * @return the MessageDigest object for the specified {@code algorithm}.
//      * @throws UnknownAlgorithmException if the specified algorithm name is not available.
//      */
//     // protected MessageDigest getDigest(string algorithmName) {
//     //     try {
//     //         return MessageDigest.getInstance(algorithmName);
//     //     } catch (NoSuchAlgorithmException e) {
//     //         string msg = "No native '" ~ algorithmName ~ "' MessageDigest instance available on the current JVM.";
//     //         throw new UnknownAlgorithmException(msg, e);
//     //     }
//     // }

//     /**
//      * Hashes the specified byte array without a salt for a single iteration.
//      *
//      * @param bytes the bytes to hash.
//      * @return the hashed bytes.
//      */
//    protected byte[] hash(byte[] bytes) {
//         return hash(bytes, null, 1);
//     }

//     /**
//      * Hashes the specified byte array using the given {@code salt} for a single iteration.
//      *
//      * @param bytes the bytes to hash
//      * @param salt  the salt to use for the initial hash
//      * @return the hashed bytes
//      */
//    protected byte[] hash(byte[] bytes, byte[] salt) {
//         return hash(bytes, salt, 1);
//     }

//     /**
//      * Hashes the specified byte array using the given {@code salt} for the specified number of iterations.
//      *
//      * @param bytes          the bytes to hash
//      * @param salt           the salt to use for the initial hash
//      * @param hashIterations the number of times the the {@code bytes} will be hashed (for attack resiliency).
//      * @return the hashed bytes.
//      * @throws UnknownAlgorithmException if the {@link #getAlgorithmName() algorithmName} is not available.
//      */
//    protected byte[] hash(byte[] bytes, byte[] salt, int hashIterations) {
//         MessageDigest digest = getDigest(getAlgorithmName());
//         if (salt !is null) {
//             digest.reset();
//             digest.update(salt);
//         }
//         byte[] hashed = digest.digest(bytes);
//         int iterations = hashIterations - 1; //already hashed once above
//         //iterate remaining number:
//         for (int i = 0; i < iterations; i++) {
//             digest.reset();
//             hashed = digest.digest(hashed);
//         }
//         return hashed;
//     }

//     /**
//      * Returns a hex-encoded string of the underlying {@link #getBytes byte array}.
//      * <p/>
//      * This implementation caches the resulting hex string so multiple calls to this method remain efficient.
//      * However, calling {@link #setBytes setBytes} will null the cached value, forcing it to be recalculated the
//      * next time this method is called.
//      *
//      * @return a hex-encoded string of the underlying {@link #getBytes byte array}.
//      */
//     string toHex() {
//         if (this.hexEncoded  is null) {
//             this.hexEncoded = Hex.encodeToString(getBytes());
//         }
//         return this.hexEncoded;
//     }

//     /**
//      * Returns a Base64-encoded string of the underlying {@link #getBytes byte array}.
//      * <p/>
//      * This implementation caches the resulting Base64 string so multiple calls to this method remain efficient.
//      * However, calling {@link #setBytes setBytes} will null the cached value, forcing it to be recalculated the
//      * next time this method is called.
//      *
//      * @return a Base64-encoded string of the underlying {@link #getBytes byte array}.
//      */
//     string toBase64() {
//         if (this.base64Encoded  is null) {
//             //cache result in case this method is called multiple times.
//             this.base64Encoded = Base64.encodeToString(getBytes());
//         }
//         return this.base64Encoded;
//     }

//     /**
//      * Simple implementation that merely returns {@link #toHex() toHex()}.
//      *
//      * @return the {@link #toHex() toHex()} value.
//      */
//     string toString() {
//         return toHex();
//     }

//     /**
//      * Returns {@code true} if the specified object is a Hash and its {@link #getBytes byte array} is identical to
//      * this Hash's byte array, {@code false} otherwise.
//      *
//      * @param o the object (Hash) to check for equality.
//      * @return {@code true} if the specified object is a Hash and its {@link #getBytes byte array} is identical to
//      *         this Hash's byte array, {@code false} otherwise.
//      */
//     boolean equals(Object o) {
//         auto oCast = cast(Hash)o;
//         if (oCast !is null) {
//             Hash other = oCast;
//             return MessageDigest.isEqual(getBytes(), other.getBytes());
//         }
//         return false;
//     }

//     /**
//      * Simply returns toHex().hashCode();
//      *
//      * @return toHex().hashCode()
//      */
//     size_t toHash() @trusted nothrow {
//         if (this.bytes  is null || this.bytes.length == 0) {
//             return 0;
//         }
//         return ArrayHelper.hashCode(this.bytes);
//     }

//     private static void printMainUsage(Class!AbstractHash clazz, string type) {
//         writeln("Prints an " ~ type ~ " hash value.");
//         writeln("Usage: java " ~ clazz.getName() ~ " [-base64] [-salt <saltValue>] [-times <N>] <valueToHash>");
//         writeln("Options:");
//         writeln("\t-base64\t\tPrints the hash value as a base64 string instead of the default hex.");
//         writeln("\t-salt\t\tSalts the hash with the specified <saltValue>");
//         writeln("\t-times\t\tHashes the input <N> number of times");
//     }

//     private static boolean isReserved(string arg) {
//         return "-base64"  == arg || "-times"  == arg || "-salt"  == arg;
//     }

//     static int doMain(Class!AbstractHash clazz, string[] args) {
//         string simple = clazz.getSimpleName();
//         int index = simple.indexOf("Hash");
//         string type = simple.substring(0, index).toUpperCase();

//         if (args  is null || args.length < 1 || args.length > 7) {
//             printMainUsage(clazz, type);
//             return -1;
//         }
//         boolean hex = true;
//         string salt = null;
//         int times = 1;
//         string text = args[args.length - 1];
//         for (int i = 0; i < args.length; i++) {
//             string arg = args[i];
//             if (arg.equals("-base64")) {
//                 hex = false;
//             } else if (arg.equals("-salt")) {
//                 if ((i + 1) >= (args.length - 1)) {
//                     string msg = "Salt argument must be followed by a salt value.  The final argument is " ~
//                             "reserved for the value to hash.";
//                     writeln(msg);
//                     printMainUsage(clazz, type);
//                     return -1;
//                 }
//                 salt = args[i + 1];
//             } else if (arg.equals("-times")) {
//                 if ((i + 1) >= (args.length - 1)) {
//                     string msg = "Times argument must be followed by an integer value.  The final argument is " ~
//                             "reserved for the value to hash";
//                     writeln(msg);
//                     printMainUsage(clazz, type);
//                     return -1;
//                 }
//                 try {
//                     times = Integer.valueOf(args[i + 1]);
//                 } catch (NumberFormatException e) {
//                     string msg = "Times argument must be followed by an integer value.";
//                     writeln(msg);
//                     printMainUsage(clazz, type);
//                     return -1;
//                 }
//             }
//         }

//         Hash hash = new Md2Hash(text, salt, times);
//         string hashed = hex ? hash.toHex() : hash.toBase64();
//         writeln(hex ? "Hex: " : "Base64: ");
//         writeln(hashed);
//         return 0;
//     }
}

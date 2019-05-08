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
module hunt.shiro.util.ByteSource;

// import java.io.File;
// import java.io.InputStream;

/**
 * A {@code ByteSource} wraps a byte array and provides additional encoding operations.  Most users will find the
 * {@link Util} inner class sufficient to construct ByteSource instances.
 *
 * @since 1.0
 */
interface ByteSource {

    /**
     * Returns the wrapped byte array.
     *
     * @return the wrapped byte array.
     */
    byte[] getBytes();

    /**
     * Returns the <a href="http://en.wikipedia.org/wiki/Hexadecimal">Hex</a>-formatted string representation of the
     * underlying wrapped byte array.
     *
     * @return the <a href="http://en.wikipedia.org/wiki/Hexadecimal">Hex</a>-formatted string representation of the
     *         underlying wrapped byte array.
     */
    string toHex();

    /**
     * Returns the <a href="http://en.wikipedia.org/wiki/Base64">Base 64</a>-formatted string representation of the
     * underlying wrapped byte array.
     *
     * @return the <a href="http://en.wikipedia.org/wiki/Base64">Base 64</a>-formatted string representation of the
     *         underlying wrapped byte array.
     */
    string toBase64();

    /**
     * Returns {@code true} if the underlying wrapped byte array is null or empty (zero length), {@code false}
     * otherwise.
     *
     * @return {@code true} if the underlying wrapped byte array is null or empty (zero length), {@code false}
     *         otherwise.
     * @since 1.2
     */
    bool isEmpty();
}

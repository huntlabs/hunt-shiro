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
module hunt.shiro.util.JdbcUtils;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import hunt.logger;

/**
 * A set of static helper methods for managing JDBC API objects.
 * <p/>
 * <em>Note:</em> Some parts of this class were copied from the Spring Framework and then modified.
 * They were copied here to prevent Spring dependencies in the Shiro core API.  The original license conditions
 * (Apache 2.0) have been maintained.
 *
 * @since 0.2
 */
class JdbcUtils {

    /** Private internal log instance. */


    /**
     * Private constructor to prevent instantiation.
     */
    private JdbcUtils() {
    }

    /**
     * Close the given JDBC Connection and ignore any thrown exception.
     * This is useful for typical finally blocks in manual JDBC code.
     *
     * @param connection the JDBC Connection to close (may be <tt>null</tt>)
     */
     static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException ex) {
                if (log.isDebugEnabled()) {
                    tracef("Could not close JDBC Connection", ex);
                }
            } catch (Throwable ex) {
                if (log.isDebugEnabled()) {
                    tracef("Unexpected exception on closing JDBC Connection", ex);
                }
            }
        }
    }

    /**
     * Close the given JDBC Statement and ignore any thrown exception.
     * This is useful for typical finally blocks in manual JDBC code.
     *
     * @param statement the JDBC Statement to close (may be <tt>null</tt>)
     */
     static void closeStatement(Statement statement) {
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException ex) {
                if (log.isDebugEnabled()) {
                    tracef("Could not close JDBC Statement", ex);
                }
            } catch (Throwable ex) {
                if (log.isDebugEnabled()) {
                    tracef("Unexpected exception on closing JDBC Statement", ex);
                }
            }
        }
    }

    /**
     * Close the given JDBC ResultSet and ignore any thrown exception.
     * This is useful for typical finally blocks in manual JDBC code.
     *
     * @param rs the JDBC ResultSet to close (may be <tt>null</tt>)
     */
     static void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ex) {
                if (log.isDebugEnabled()) {
                    tracef("Could not close JDBC ResultSet", ex);
                }
            } catch (Throwable ex) {
                if (log.isDebugEnabled()) {
                    tracef("Unexpected exception on closing JDBC ResultSet", ex);
                }
            }
        }
    }

}

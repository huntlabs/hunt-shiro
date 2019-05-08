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
module hunt.shiro.authz.permission.DomainPermission;

// import hunt.shiro.util.StringUtils;

import hunt.collection.Set;

/**
 * Provides a base Permission class from which type-safe/domain-specific subclasses may extend.  Can be used
 * as a base class for JPA/Hibernate persisted permissions that wish to store the parts of the permission string
 * in separate columns (e.g. 'domain', 'actions' and 'targets' columns), which can be used in querying
 * strategies.
 *
 */
class DomainPermission : WildcardPermission {

    private string domain;
    private Set!(string) actions;
    private Set!(string) targets;


    /**
     * Creates a domain permission with *all* actions for *all* targets;
     */
     this() {
        this.domain = getDomain(getClass());
        setParts(getDomain(getClass()));
    }

     this(string actions) {
        domain = getDomain(getClass());
        this.actions = StringUtils.splitToSet(actions, SUBPART_DIVIDER_TOKEN);
        encodeParts(domain, actions, null);
    }

     this(string actions, string targets) {
        this.domain = getDomain(getClass());
        this.actions = StringUtils.splitToSet(actions, SUBPART_DIVIDER_TOKEN);
        this.targets = StringUtils.splitToSet(targets, SUBPART_DIVIDER_TOKEN);
        encodeParts(this.domain, actions, targets);
    }

    protected this(Set!(string) actions, Set!(string) targets) {
        this.domain = getDomain(getClass());
        setParts(domain, actions, targets);
    }

    private void encodeParts(string domain, string actions, string targets) {
        if (!StringUtils.hasText(domain)) {
            throw new IllegalArgumentException("domain argument cannot be null or empty.");
        }
        StringBuilder sb = new StringBuilder(domain);

        if (!StringUtils.hasText(actions)) {
            if (StringUtils.hasText(targets)) {
                sb.append(PART_DIVIDER_TOKEN).append(WILDCARD_TOKEN);
            }
        } else {
            sb.append(PART_DIVIDER_TOKEN).append(actions);
        }
        if (StringUtils.hasText(targets)) {
            sb.append(PART_DIVIDER_TOKEN).append(targets);
        }
        setParts(sb.toString());
    }

    protected void setParts(string domain, Set!(string) actions, Set!(string) targets) {
        string actionsString = StringUtils.toDelimitedString(actions, SUBPART_DIVIDER_TOKEN);
        string targetsString = StringUtils.toDelimitedString(targets, SUBPART_DIVIDER_TOKEN);
        encodeParts(domain, actionsString, targetsString);
        this.domain = domain;
        this.actions = actions;
        this.targets = targets;
    }

    protected string getDomain(Class!DomainPermission clazz) {
        string domain = clazz.getSimpleName().toLowerCase();
        //strip any trailing 'permission' text from the name (as all subclasses should have been named):
        int index = domain.lastIndexOf("permission");
        if (index != -1) {
            domain = domain.substring(0, index);
        }
        return domain;
    }

     string getDomain() {
        return domain;
    }

    protected void setDomain(string domain) {
        if (this.domain !is null && this.domain== domain) {
            return;
        }
        this.domain = domain;
        setParts(domain, actions, targets);
    }

     Set!(string) getActions() {
        return actions;
    }

    protected void setActions(Set!(string) actions) {
        if (this.actions !is null && this.actions== actions) {
            return;
        }
        this.actions = actions;
        setParts(domain, actions, targets);
    }

     Set!(string) getTargets() {
        return targets;
    }

    protected void setTargets(Set!(string) targets) {
        if (this.targets !is null && this.targets== targets) {
            return;
        }
        this.targets = targets;
        setParts(domain, actions, targets);
    }
}

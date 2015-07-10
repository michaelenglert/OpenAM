/*
 * The contents of this file are subject to the terms of the Common Development and
 * Distribution License (the License). You may not use this file except in compliance with the
 * License.
 *
 * You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
 * specific language governing permission and limitations under the License.
 *
 * When distributing Covered Software, include this CDDL Header Notice in each file and include
 * the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
 * Header, with the fields enclosed by brackets [] replaced by your own identifying
 * information: "Portions copyright [year] [name of copyright owner]".
 *
 * Copyright 2015 ForgeRock AS.
 */
package org.forgerock.openam.audit;

import static org.forgerock.json.fluent.JsonValue.array;
import static org.forgerock.json.fluent.JsonValue.json;

import com.iplanet.sso.SSOException;
import com.iplanet.sso.SSOToken;
import com.sun.identity.shared.Constants;
import com.sun.identity.shared.debug.Debug;
import org.forgerock.json.fluent.JsonValue;

/**
 * Collection of static helper methods for use by AM AuditEventBuilders.
 *
 * @since 13.0.0
 */
final class AMAuditEventBuilderUtils {

    private static Debug debug = Debug.getInstance("amAudit");

    private static final String COMPONENT = "component";
    private static final String CONTEXT_ID = "contextId";
    private static final String DOMAIN = "domain";
    private static final String EXTRA_INFO = "extraInfo";

    private AMAuditEventBuilderUtils() {
        // Prevent instantiation
    }

    /**
     * Set "component" audit log field.
     *
     * @param value String "component" value.
     */
    static void putComponent(JsonValue jsonValue, String value) {
        jsonValue.put(COMPONENT, value);
    }

    /**
     * Set "contextId" audit log field.
     *
     * @param value String "contextId" value.
     */
    static void putContextId(JsonValue jsonValue, String value) {
        jsonValue.put(CONTEXT_ID, value);
    }

    /**
     * Set "domain" (aka realm) audit log field.
     *
     * @param value String "domain" value.
     */
    static void putDomain(JsonValue jsonValue, String value) {
        jsonValue.put(DOMAIN, value);
    }

    /**
     * Set "extraInfo" audit log field.
     *
     * @param values String sequence of values that should be stored in the 'extraInfo' audit log field.
     */
    static void putExtraInfo(JsonValue jsonValue, String... values) {
        jsonValue.put(EXTRA_INFO, json(array(values)));
    }

    /**
     * Sets "contextId" audit log field from property of {@link SSOToken}, iff the provided
     * <code>SSOToken</code> is not <code>null</code>.
     *
     * @param ssoToken The SSOToken from which the contextId value will be retrieved.
     */
    static void putContextIdFromSSOToken(JsonValue jsonValue, SSOToken ssoToken) {
        putContextId(
                jsonValue,
                getSSOTokenProperty(ssoToken, Constants.AM_CTX_ID, ""));
    }

    /**
     * Sets "domain" audit log field from property of {@link SSOToken}, iff the provided
     * <code>SSOToken</code> is not <code>null</code>.
     *
     * @param ssoToken The SSOToken from which the domain value will be retrieved.
     */
    static void putDomainFromSSOToken(JsonValue jsonValue, SSOToken ssoToken) {
        String clientDomain = getSSOTokenProperty(ssoToken, "Organization", "");
        if (clientDomain == null || clientDomain.isEmpty()) {
            clientDomain = getSSOTokenProperty(ssoToken, "cdomain", "");
        }
        putDomain(jsonValue, clientDomain);
    }

    private static String getSSOTokenProperty(SSOToken ssoToken, String name, String defaultValue) {
        if (ssoToken != null) {
            try {
                return ssoToken.getProperty(name);
            } catch (SSOException e) {
                debug.warning("Unable to obtain property '{}' from SSOToken.", name, e);
            }
        }
        return defaultValue;
    }

}

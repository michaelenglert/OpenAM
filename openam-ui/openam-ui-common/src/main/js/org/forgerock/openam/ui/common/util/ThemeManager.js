/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright 2011-2015 ForgeRock AS.
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://forgerock.org/license/CDDLv1.0.html
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at http://forgerock.org/license/CDDLv1.0.html
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 */

/*global require, define */
define("org/forgerock/openam/ui/common/util/ThemeManager", [
    "jquery",
    "underscore",
    "org/forgerock/openam/ui/common/util/Constants",
    "org/forgerock/commons/ui/common/main/Configuration",
    "config/ThemeConfiguration"
], function ($, _, Constants, Configuration, ThemeConfiguration) {
    /**
     * @exports org/forgerock/openam/ui/common/util/ThemeManager
     */
    var defaultThemeName = "default",
        applyThemeToPage = function (path, icon, stylesheets) {
            // We might be switching themes (due to a realm change) and so we need to clean up the previous theme.
            $("link").remove();

            $("<link/>", {
                rel: "icon",
                type: "image/x-icon",
                href: require.toUrl(path + icon)
            }).appendTo("head");

            $("<link/>", {
                rel: "shortcut icon",
                type: "image/x-icon",
                href: require.toUrl(path + icon)
            }).appendTo("head");

            _.each(stylesheets, function (stylesheet) {
                $("<link/>", {
                    rel: "stylesheet",
                    type: "text/css",
                    href: require.toUrl(stylesheet)
                }).appendTo("head");
            });
        },

        /**
         * Determine if a mapping specification matches the current environment. Mappings are of the form:
         * { theme: "theme-name", realms: ["/a", "/b"] }.
         *
         * @param {string} realm The full realm path to match the themes against.
         * @param {object} mapping the mapping specification provided by the theme configuration.
         * @returns {boolean} true if mapping matches the current environment.
         */
        isMatchingThemeMapping = function (realm, mapping) {
            return _.some(mapping.realms, function (mappingRealm) {
                if (_.isRegExp(mappingRealm)) {
                    return mappingRealm.test(realm);
                } else {
                    return mappingRealm === realm;
                }
            });
        },

        /**
         * Find the appropriate theme for the current environment by using the theme configuration mappings.
         * <p>
         * If a theme is found that matches the current environment then its name will be
         * returned, otherwise the default theme name will be returned.
         * @param {string} realm The full realm path to match the themes against.
         * @returns {string} theme The selected theme configuration name.
         */
        findMatchingTheme = function (realm) {
            if (!_.isArray(ThemeConfiguration.mappings)) {
                return defaultThemeName;
            }
            var matchedThemeMapping = _.find(ThemeConfiguration.mappings, _.partial(isMatchingThemeMapping, realm));
            if (matchedThemeMapping) {
                return matchedThemeMapping.theme;
            }
            return defaultThemeName;
        },

        makeUrlsRelativeToEntryPoint = function (theme) {
            theme = _.clone(theme, true);
            if (theme.settings) {
                if (theme.settings.logo) {
                    theme.settings.logo.src = require.toUrl(theme.settings.logo.src);
                }
                if (theme.settings.loginLogo) {
                    theme.settings.loginLogo.src = require.toUrl(theme.settings.loginLogo.src);
                }
            }
            return theme;
        },

        extendTheme = function (theme, parentTheme) {
            return _.merge({}, parentTheme, theme, function (objectValue, sourceValue) {
                // We don't want to merge arrays. If a theme has specified an array, it should be used verbatim.
                if (_.isArray(sourceValue)) {
                    return sourceValue;
                }
                return undefined;
            });
        },

        validateConfig = function () {
            if (!_.isObject(ThemeConfiguration)) {
                throw "Theme configuration must return an object";
            }

            if (!_.isObject(ThemeConfiguration.themes)) {
                throw "Theme configuration must specify a themes object";
            }

            if (!_.isObject(ThemeConfiguration.themes[defaultThemeName])) {
                throw "Theme configuration must specify a default theme";
            }
        };

    return {
        /**
         * Determine the theme from the current realm and setup the theme on the page. This will
         * clear out any previous theme.
         * @param {boolean} [force] Perform a forced refresh of the theme
         * @returns {Promise} a promise that is resolved when the theme has been applied.
         */
        getTheme: function (force) {
            validateConfig();

            var themeName = findMatchingTheme(Configuration.globalData.realm),
                defaultTheme = ThemeConfiguration.themes[defaultThemeName],
                isSameTheme = Configuration.globalData.themeName && themeName === Configuration.globalData.themeName,
                isAdminUser = Configuration.loggedUser && _.contains(Configuration.loggedUser.roles, "ui-admin"),
                theme, stylesheets;

            if (!force && isSameTheme) {
                return $.Deferred().resolve(Configuration.globalData.theme);
            }

            theme = ThemeConfiguration.themes[themeName];
            theme = extendTheme(theme, defaultTheme);
            theme = makeUrlsRelativeToEntryPoint(theme);

            // We don't apply themes to the admin interface because it would take significant effort to make the UI
            // themeable.
            stylesheets = isAdminUser ? Constants.DEFAULT_STYLESHEETS : theme.stylesheets;

            applyThemeToPage(theme.path, theme.icon, stylesheets);
            Configuration.globalData.theme = theme;
            Configuration.globalData.themeName = themeName;
            return $.Deferred().resolve(theme);
        }
    };
});

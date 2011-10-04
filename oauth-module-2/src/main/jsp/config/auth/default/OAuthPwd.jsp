<%--
   DO  NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright � 2011 ForgeRock AS. All rights reserved.
  
   The contents of this file are subject to the terms
   of the Common Development and Distribution License
   (the License). You may not use this file except in
   compliance with the License.
                                                                                
   You can obtain a copy of the License at
   http://forgerock.org/license/CDDLv1.0.html 
   See the License for the specific language governing
   permission and limitations under the License.
                                                                                
   When distributing Covered Code, include this CDDL
   Header Notice in each file and include the License file
   at http://forgerock.org/license/CDDLv1.0.html
   If applicable, add the following below the CDDL Header,
   with the fields enclosed by brackets [] replaced by
   your own identifying information:
   "Portions Copyrighted [year] [name of copyright owner]"
                                                              
--%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<%@ page  language="java"%>
<%@ page import="org.owasp.esapi.ESAPI" %>
<%@ page import="com.iplanet.am.util.SystemProperties" %>
<%@ page import="com.sun.identity.shared.Constants" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.MissingResourceException" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.forgerock.openam.authentication.modules.oauth2.OAuthUtil" %>

<%
   String ServiceURI = SystemProperties.get(Constants.AM_SERVICES_DEPLOYMENT_DESCRIPTOR); 
   String termsAndConditionsPage = ServiceURI + "/tc.html";
   String lang = request.getParameter("lang");
   ResourceBundle resources;
   Locale locale = null;
   try {
        if (lang != null && lang.length() != 0) {
           locale = new Locale(lang);
        } else {
           locale = request.getLocale();
        }
        resources = ResourceBundle.getBundle("amAuthOAuth", locale);
        OAuthUtil.debugMessage("OAuthPwd: obtained resource bundle with locale " + locale);
   } catch (MissingResourceException mr) {
        OAuthUtil.debugError("OAuthPwd: Resource Bundle not found", mr);
        resources = ResourceBundle.getBundle("amAuthOAuth");
   } 
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link rel="stylesheet" href="<%= ServiceURI %>/css/styles.css" type="text/css" />
        <script language="JavaScript" src="<%= ServiceURI %>/js/browserVersion.js"></script>
        <script language="JavaScript" src="<%= ServiceURI %>/js/auth.js"></script>

        <script language="JavaScript">
            writeCSS('<%= ServiceURI %>');
        </script>
        <script type="text/javascript"><!--// Empty script so IE5.0 Windows will draw table and button borders
            //-->
        </script>

        <title>Password change</title>

    </head>

    <body>

        <script type="text/javascript" language="JavaScript">
            
            function validatePassword(form, token1, token2)
            {
                // The following are just example rules for a password
                // For the implementation you can modify them to suit your needs
                form.output.value = "";
                if(form.elements[token1].value != '') {
                    if (form.elements[token1].value == form.elements[token2].value) {
                        if(form.elements[token1].value.length < 8) {
                            form.output.value = 
                                "<%= ESAPI.encoder().encodeForHTML(
                                resources.getString("errLength")) %>";
                            form.elements[token2].valueOf();
                            form.elements[token1].focus();
                            return false;
                        }
                                                        
                        var re = /[0-9]/;
                        if(!re.test(form.elements[token1].value)) {
                            form.output.value = 
                                "<%= ESAPI.encoder().encodeForHTML(
                            resources.getString("errNumbers")) %>";
                            form.elements[token1].focus();
                            return false;
                        }
                        re = /[a-z]/;
                        if(!re.test(form.elements[token1].value)) {
                            form.output.value = 
                                "<%= ESAPI.encoder().encodeForHTML(
                            resources.getString("errLowercase")) %>";
                            form.elements[token1].focus();
                            return false;
                        }
                        re = /[A-Z]/;
                        if(!re.test(form.elements[token1].value)) {
                            form.output.value = 
                                "<%= ESAPI.encoder().encodeForHTML(
                            resources.getString("errUppercase")) %>";
                            form.elements[token1].focus();
                            return false;
                        }
                        re = /^[a-zA-Z0-9.\\-\\/+=_ ]*$/
                        if(!re.test(form.elements[token1].value)) {
                            form.output.value = 
                                "<%= ESAPI.encoder().encodeForHTML(
                                resources.getString("errInvalidPass")) %>";
                            form.elements[token1].focus();
                            return false;
                        }
                    } else {
                        form.output.value =  
                             "<%= ESAPI.encoder().encodeForHTML(
                        resources.getString("errNoMatch")) %>";
                        form.elements[token1].focus();
                        return false;
                    }
                                                    
                    form.output.value = "<%= ESAPI.encoder().encodeForHTML("") %>";
                    return true;
                } else {
                    form.elements[token1].focus();
                    form.output.value =  
                        "<%= ESAPI.encoder().encodeForHTML(
                    resources.getString("errEmptyPass")) %>";
                    return false;
                }
                                                
           }               
             
            function validateTerms(form, terms)
            {
                form.output.value = '';
                if(form.elements[terms].checked == true) {
                    return true;
                } 

                form.elements[terms]    .focus();
                form.output.value = "<%= ESAPI.encoder().
                encodeForHTML(resources.getString("errTandC")) %>";
                return false;

            }
             
            function validateButton(form, Login)
            {   
                
                if(form.elements[Login].value == 'Cancel') {
                    return false;
                } else {
                    return true;
                }
            }
            
            function adios() { 
                    window.location = "<%= ServiceURI %>";
            }
            
        </script>
        <script type="text/javascript">
            
            function newPopup(url) {
                popupWindow = window.open(
                url,'popUpWindow','height=500,width=600,left=10,top=10,\n\
resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')
            }
            
        </script>                 

        <div style="height: 50px; width: 100%;">

        </div>
        <center>
            <div style="background-image:url('<%= ServiceURI%>/images/login-backimage.jpg'); background-repeat:no-repeat; 
     height: 435px; width: 728px; vertical-align: middle; text-align: center;">
                <table>

                    <form name="Login" method="POST" action="<%= ESAPI.encoder().encodeForHTML("") %>" 
                          onSubmit="return (
                          validatePassword(this, 'token1', 'token2') && 
                              validateTerms(this, 'terms') && 
                              validateButton(this, 'Login'));" >
                        <tr height="100px"><td width="295px"></td><td></td></tr>
                        <tr><td width="295px"></td>
                            <td align="left"><img src="<%= ServiceURI %>/images/PrimaryProductName.png" /></td>
                        </tr>    
                        <tr><td width="295px"></td>
                            <td>
                                <p><%= resources.getString("passwordSetMsg") %></p>
                                <table align="center" border="0" cellpadding="2" cellspacing="2" >

                                    <tr><td>
                                            <label for="token1" ><%= resources.getString("newPassLabel") %></label>
                                        </td>
                                        <td>
                                            <input type="password" size="15" name="<%= ESAPI.encoder().encodeForHTML("token1") %>">
                                        </td>
                                    </tr>
                                    <tr><td>
                                            <label for="token2"><%= resources.getString("confirmPassLabel") %></label>
                                        </td>
                                        <td>
                                            <input type="password" size="15" name="<%= ESAPI.encoder().encodeForHTML("token2") %>">
                                        </td>
                                    </tr>
                                    <tr><td colspan="2">
                                            <p>
                                                <input type="checkbox" name="<%= ESAPI.encoder().encodeForHTML("terms") %>" 
                                                       value="<%= ESAPI.encoder().encodeForHTML("accept") %>">
                                                I accept <a href="JavaScript:newPopup('<%= termsAndConditionsPage %>');">
                                                    <%= resources.getString("termsAndCondsLabel") %></a> <br>
                                            </p>
                                            <br>
                                            <input type="submit" name="<%= ESAPI.encoder().encodeForHTML("Login")%>" 
                                                   value="<%= ESAPI.encoder().encodeForHTML("Submit") %>" >
                                            <input type="submit" name="<%= ESAPI.encoder().encodeForHTML("Login")%>"
                                                   value="<%= ESAPI.encoder().encodeForHTML("Cancel") %>" onClick="adios()">
                                        </td>
                                    </tr>
                                </table>

                            </td>
                        </tr>
                        <tr><td width="295px"></td><td align="center">
                                <input type="text" name="<%= ESAPI.encoder().encodeForHTML("output") %>" 
                                       style="border: 0; font-family: verdana; color: blue; text-align: center;" 
                                       value="<%= ESAPI.encoder().encodeForHTML("") %>" size="60" readonly>
                            </td>
                        </tr>
                    </form>  
                </table>
            </div>
        </center>
    </body>
</html>

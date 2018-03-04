<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="org.jahia.registries.ServicesRegistry"%>
<%@ page import="org.jahia.services.templates.JahiaTemplateManagerService"%>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="mailSettings" type="org.jahia.services.mail.MailSettings"--%>
<%--@elvariable id="flowRequestContext" type="org.springframework.webflow.execution.RequestContext"--%>
<%--@elvariable id="flowExecutionUrl" type="java.lang.String"--%>
<%--@elvariable id="issueTemplate" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="issue" type="org.jahia.services.content.JCRNodeWrapper"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery.form.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>

<template:addResources type="javascript" resources="admin/angular.min.js"/>
<template:addResources type="javascript" resources="admin/app/dataPicker.js"/>
<template:addResources type="css" resources="admin/app/dataPicker.css"/>

<fmt:message var="i18nUpdateFailed" key="securitytxt.errors.update.failed"/><c:set var="i18nUpdateFailed" value="${fn:escapeXml(i18nUpdateFailed)}"/>

<script type="text/javascript">

    function showSecurityTxtErrors(message) {
    $("#securityTxtFormErrorMessages").text(message);
    $("#securityTxtFormErrorContainer").show();
    }

    function hideSecurityTxtErrors() {
    $("#securityTxtFormErrorMessages").empty();
    $("#securityTxtFormErrorContainer").hide();
    }

    function submitSecurityTxtForm(act, name, type) {
    $('#securityTxtFormAction').val(act);
    if (name) {
    $('#securityTxtActionName').val(name);
    }
    if (type) {
    $('#securityTxtActionType').val(type);
    }

    $('#securityTxtWebflowForm').submit();
    }

    $(document).ready(function () {
    $("#securityTxtFormErrorClose").bind("click", function () {
    hideSecurityTxtErrors();
    });
    var securityTxtFormOptions = {
    beforeSubmit: function (arr, $form, options) {
    },
            success: function () {
            submitSecurityTxtForm("actionPerformed", $("#securityTxtName").val(), "${'updated'}");
            },
            error: function () {

            showSecurityTxtErrors("${i18nUpdateFailed}");
            }
    };
    $('#securityTxtForm').ajaxForm(securityTxtFormOptions);
    });</script>
<div>
    Please refer to this website for more informations about the file <b>security.txt</b>: <a href="https://securitytxt.org/" target="_blank">security.txt</a></br>
    Once the file is ready, you can create the signature thanks to the command <b>gpg --output security.txt.sig --detach-sig security.txt</b>.
</div>

<div>
    <form action="${flowExecutionUrl}" method="post" style="display: inline;" id="securityTxtWebflowForm">
        <input type="hidden" name="name" id="securityTxtActionName"/>
        <input type="hidden" name="type" id="securityTxtActionType"/>
        <input type="hidden" name="model" value="securityTxt"/>
        <input type="hidden" name="_eventId" id="securityTxtFormAction"/>
    </form>

    <c:url var="actionUrl" value="${url.baseEdit}${securityTxt.path}"/>
    <h2><fmt:message key="securityTxt.edit"/> - ${fn:escapeXml(securityTxt.displayableName)}</h2>

    <div class="box-1">
        <div class="alert alert-error" style="display: none" id="securityTxtFormErrorContainer">
            <button type="button" class="close" id="securityTxtFormErrorClose">&times;</button>
            <span id="securityTxtFormErrorMessages"></span>
        </div>

        <form action="${actionUrl}" method="POST" id="securityTxtForm">
            <input type="hidden" name="jcrNodeType" value="jnt:securityTxt">

            <fieldset>
                <div class="container-fluid" ng-app="dataPicker">
                    <div class="row-fluid">
                        <div class="span4">
                            <c:set var="securityTxtContact" value="${securityTxt.properties['contact']}"/>
                            <label for="securityTxtContact"><fmt:message key="label.contact"/>: <span class="text-error"></span></label>
                            <input type="text" name="contact" class="span12" id="securityTxtContact" value="${fn:escapeXml(securityTxtContact)}"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <c:set var="securityTxtEncryption" value="${securityTxt.properties['encryption']}"/>
                        <div class="span4" ng-controller="dataPickerCtrl" ng-init='init(${localFiles}, "${fn:escapeXml(securityTxtEncryption)}", "encryption", true, "${i18NSelectTarget}")'>
                            <label for="securityTxtEncryption"><fmt:message key="label.encryption"/>: <span class="text-error"></span></label>
                                <jsp:include page="/modules/securitytxt/angular/dataPicker.jsp"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <c:set var="securityTxtAcknowledgements" value="${securityTxt.properties['acknowledgements']}"/>
                        <div class="span4" ng-controller="dataPickerCtrl" ng-init='init(${localPages}, "${fn:escapeXml(securityTxtAcknowledgements)}", "acknowledgements", true, "${i18NSelectTarget}")'>
                            <label for="securityTxtAcknowledgements"><fmt:message key="label.acknowledgements"/>: <span class="text-error"></span></label>
                                <jsp:include page="/modules/securitytxt/angular/dataPicker.jsp"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <c:set var="securityTxtPolicy" value="${securityTxt.properties['policy']}"/>
                        <div class="span4" ng-controller="dataPickerCtrl" ng-init='init(${localPages}, "${fn:escapeXml(securityTxtPolicy)}", "policy", true, "${i18NSelectTarget}")'>
                            <label for="securityTxtPolicy"><fmt:message key="label.policy"/>: <span class="text-error"></span></label>
                                <jsp:include page="/modules/securitytxt/angular/dataPicker.jsp"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <c:set var="securityTxtSignature" value="${securityTxt.properties['signature']}"/>
                        <div class="span4" ng-controller="dataPickerCtrl" ng-init='init(${localFiles}, "${fn:escapeXml(securityTxtSignature)}", "signature", true, "${i18NSelectTarget}")'>
                            <label for="securityTxtSignature"><fmt:message key="label.signature"/>: <span class="text-error"></span></label>
                                <jsp:include page="/modules/securitytxt/angular/dataPicker.jsp"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <c:set var="securityTxtHiring" value="${securityTxt.properties['hiring']}"/>
                        <div class="span4" ng-controller="dataPickerCtrl" ng-init='init(${localPages}, "${fn:escapeXml(securityTxtHiring)}", "hiring", true, "${i18NSelectTarget}")'>
                            <label for="securityTxtHiring"><fmt:message key="label.hiring"/>: <span class="text-error"></span></label>
                                <jsp:include page="/modules/securitytxt/angular/dataPicker.jsp"/>
                        </div>
                    </div>
                </div>
            </fieldset>

            <fieldset>
                <div class="container-fluid">
                    <div class="row-fluid">
                        <div class="span12">
                            <button class="btn btn-primary" type="submit">
                                <i class="icon-${'share'} icon-white"></i>
                                &nbsp;<fmt:message key="label.${'update'}"/>
                            </button>
                            <button class="btn" onclick="submitSecurityTxtForm('cancel'); return false;">
                                <i class="icon-ban-circle"></i>
                                &nbsp;<fmt:message key="label.cancel"/>
                            </button>
                        </div>
                    </div>
                </div>
            </fieldset>
        </form>
    </div>
</div>
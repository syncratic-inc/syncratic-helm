<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        <#if actionUri?has_content>
            ${msg("syncraticContinueSetupHeader")}
        <#elseif messageHeader??>
            ${kcSanitize(msg("${messageHeader}"))?no_esc}
        <#else>
            ${message.summary}
        </#if>
    <#elseif section = "form">
        <div id="kc-info-message" class="syncratic-auth-card">
            <div class="syncratic-auth-intro">
                <div class="syncratic-logo-lockup" aria-label="Syncratic">
                    <span class="syncratic-logo-mark">
                        <img src="${url.resourcesPath}/img/logo.svg" alt="Syncratic logo" />
                    </span>
                    <span class="syncratic-logo-copy">
                        <span class="syncratic-app-wordmark">${msg("syncraticSetupEyebrow")}</span>
                        <span class="syncratic-app-submark">${msg("syncraticWorkspaceAccess")}</span>
                    </span>
                </div>
                <#if actionUri?has_content>
                    <h1 class="syncratic-auth-title">${msg("syncraticContinueSetupHeader")}</h1>
                    <p class="syncratic-login-lead">${msg("syncraticContinueSetupLead")}</p>
                <#else>
                    <h1 class="syncratic-auth-title">${kcSanitize(message.summary)?no_esc}</h1>
                    <p class="syncratic-login-lead">${msg("syncraticInfoLead")}</p>
                </#if>
            </div>
            <#if requiredActions??>
                <p class="instruction"><#list requiredActions>: <b><#items as reqActionItem>${kcSanitize(msg("requiredAction.${reqActionItem}"))?no_esc}<#sep>, </#items></b></#list></p>
            </#if>
            <#if skipLink??>
            <#elseif actionUri?has_content>
                <p><a class="syncratic-return-link" href="${actionUri}">${msg("syncraticCreatePassword")}</a></p>
            <#elseif pageRedirectUri?has_content>
                <p><a class="syncratic-return-link" href="${pageRedirectUri}">${kcSanitize(msg("backToApplication"))?no_esc}</a></p>
            <#else>
                <p><a class="syncratic-return-link" href="${msg("syncraticSignInUrl")}">${msg("syncraticSignIn")}</a></p>
            </#if>
            <p class="syncratic-security-note">${msg("syncraticSecurityNote")}</p>
        </div>
    </#if>
</@layout.registrationLayout>

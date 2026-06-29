<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        ${msg("syncraticAuthUnavailableHeader")}
    <#elseif section = "form">
        <div id="kc-error-message" class="syncratic-auth-card">
            <div class="syncratic-auth-intro">
                <div class="syncratic-logo-lockup" aria-label="Syncratic">
                    <span class="syncratic-logo-mark">
                        <img src="${url.resourcesPath}/img/logo.svg" alt="Syncratic logo" />
                    </span>
                    <span class="syncratic-logo-copy">
                        <span class="syncratic-app-wordmark">${msg("syncraticLoginEyebrow")}</span>
                        <span class="syncratic-app-submark">${msg("syncraticWorkspaceAccess")}</span>
                    </span>
                </div>
                <h1 class="syncratic-auth-title">${msg("syncraticAuthUnavailableHeader")}</h1>
                <p class="syncratic-login-lead">${msg("syncraticAuthUnavailableLead")}</p>
            </div>
            <#if message?has_content>
                <div class="syncratic-flow-note syncratic-flow-note-warning">
                    <strong>${msg("syncraticRequestDetails")}</strong>
                    ${kcSanitize(message.summary)?no_esc}
                </div>
            </#if>
            <p><a class="syncratic-return-link" href="${msg("syncraticSignInUrl")}">${msg("syncraticSignIn")}</a></p>
        </div>
    </#if>
</@layout.registrationLayout>

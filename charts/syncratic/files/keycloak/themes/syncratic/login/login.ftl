<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password'); section>
    <#if section = "header">
        ${msg("syncraticLoginHeader")}
    <#elseif section = "form">
        <div class="syncratic-auth-card">
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
                <h1 class="syncratic-auth-title">${msg("syncraticLoginHeader")}</h1>
                <p class="syncratic-login-lead">${msg("syncraticLoginLead")}</p>
            </div>

            <form id="kc-form-login" class="${properties.kcFormClass!} syncratic-auth-form" action="${url.loginAction}" method="post">
                <#if !usernameHidden??>
                    <div class="${properties.kcFormGroupClass!}">
                        <label for="username" class="${properties.kcLabelClass!}">
                            <span class="pf-v5-c-form__label-text">${msg("syncraticUsernameLabel")}</span>
                        </label>
                        <input
                            tabindex="1"
                            id="username"
                            class="${properties.kcInputClass!}"
                            name="username"
                            value="${(login.username!'')}"
                            type="text"
                            autofocus
                            autocomplete="username"
                            aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                            <#if usernameEditDisabled??>disabled</#if>
                        />
                    </div>
                </#if>

                <div class="${properties.kcFormGroupClass!}">
                    <label for="password" class="${properties.kcLabelClass!}">
                        <span class="pf-v5-c-form__label-text">${msg("syncraticPasswordLabel")}</span>
                    </label>
                    <input
                        tabindex="2"
                        id="password"
                        class="${properties.kcInputClass!}"
                        name="password"
                        type="password"
                        autocomplete="current-password"
                        aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                    />
                    <#if messagesPerField.existsError('username','password')>
                        <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                        </span>
                    </#if>
                </div>

                <div class="syncratic-login-options">
                    <#if realm.rememberMe && !usernameHidden??>
                        <label class="syncratic-remember">
                            <#if login.rememberMe??>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked />
                            <#else>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" />
                            </#if>
                            <span>${msg("rememberMe")}</span>
                        </label>
                    </#if>
                    <#if realm.resetPasswordAllowed>
                        <a class="syncratic-inline-link" href="${url.loginResetCredentialsUrl}">${msg("syncraticForgotPassword")}</a>
                    </#if>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId" />
                <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                    <input
                        tabindex="4"
                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                        name="login"
                        id="kc-login"
                        type="submit"
                        value="${msg("syncraticContinue")}"
                    />
                </div>
            </form>
        </div>
    </#if>
</@layout.registrationLayout>

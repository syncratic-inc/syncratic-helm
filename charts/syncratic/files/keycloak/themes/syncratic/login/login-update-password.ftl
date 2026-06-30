<#import "template.ftl" as layout>
<#import "password-commons.ftl" as passwordCommons>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>
    <#if section = "header">
        ${msg("syncraticPasswordHeader")}
    <#elseif section = "form">
        <div class="syncratic-auth-card">
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
                <h1 class="syncratic-auth-title">${msg("syncraticPasswordHeader")}</h1>
                <p class="syncratic-login-lead">${msg("syncraticPasswordLead")}</p>
            </div>

            <form id="kc-passwd-update-form" class="${properties.kcFormClass!} syncratic-auth-form" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <label for="password-new" class="${properties.kcLabelClass!}">
                        <span class="pf-v5-c-form__label-text">${msg("passwordNew")}</span>
                    </label>
                    <div class="${properties.kcInputGroup!}">
                        <span class="${properties.kcInputClass!}">
                            <input type="password" id="password-new" name="password-new" autofocus autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>" />
                        </span>
                        <button class="${properties.kcFormPasswordVisibilityButtonClass!}" type="button" aria-label="${msg('showPassword')}" aria-controls="password-new" data-password-toggle data-icon-show="${properties.kcFormPasswordVisibilityIconShow!}" data-icon-hide="${properties.kcFormPasswordVisibilityIconHide!}" data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
                            <i class="${properties.kcFormPasswordVisibilityIconShow!}" aria-hidden="true"></i>
                        </button>
                    </div>
                    <#if messagesPerField.existsError('password')>
                        <span id="input-error-password" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                    </#if>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <label for="password-confirm" class="${properties.kcLabelClass!}">
                        <span class="pf-v5-c-form__label-text">${msg("passwordConfirm")}</span>
                    </label>
                    <div class="${properties.kcInputGroup!}">
                        <span class="${properties.kcInputClass!}">
                            <input type="password" id="password-confirm" name="password-confirm" autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>" />
                        </span>
                        <button class="${properties.kcFormPasswordVisibilityButtonClass!}" type="button" aria-label="${msg('showPassword')}" aria-controls="password-confirm" data-password-toggle data-icon-show="${properties.kcFormPasswordVisibilityIconShow!}" data-icon-hide="${properties.kcFormPasswordVisibilityIconHide!}" data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
                            <i class="${properties.kcFormPasswordVisibilityIconShow!}" aria-hidden="true"></i>
                        </button>
                    </div>
                    <#if messagesPerField.existsError('password-confirm')>
                        <span id="input-error-password-confirm" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
                    </#if>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <@passwordCommons.logoutOtherSessions/>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!} pf-m-action">
                    <div class="pf-v5-c-form__actions">
                        <#if isAppInitiatedAction??>
                            <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("syncraticContinue")}" />
                            <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true">${msg("doCancel")}</button>
                        <#else>
                            <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("syncraticContinue")}" />
                        </#if>
                    </div>
                </div>
            </form>
            <p class="syncratic-security-note">${msg("syncraticSecurityNote")}</p>
        </div>
        <script type="module" src="${url.resourcesPath}/js/passwordVisibility.js"></script>
    </#if>
</@layout.registrationLayout>

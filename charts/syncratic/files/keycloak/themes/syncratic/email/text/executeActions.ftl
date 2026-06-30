<#ftl output_format="plainText">
<#assign requiredActionsText><#if requiredActions??><#list requiredActions><#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#items></#list><#else></#if></#assign>
Complete your Syncratic account setup

You have been invited to Syncratic. Continue to verify your email and create your password.

Required actions: ${requiredActionsText}

Create password:
${link}

This setup link expires in ${linkExpirationFormatter(linkExpiration)}.

After creating your password, sign in to Syncratic with the same email address. Your workspace invitation will be accepted automatically after authentication.

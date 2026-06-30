<#outputformat "plainText">
<#assign requiredActionsText><#if requiredActions??><#list requiredActions><#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#sep></#items></#list></#if></#assign>
</#outputformat>
<#import "template.ftl" as layout>
<@layout.emailLayout>
  <h1 style="margin:0 0 14px;font-size:28px;line-height:1.1;color:#0f172a;">Complete your Syncratic account setup</h1>
  <p style="margin:0 0 18px;font-size:15px;line-height:1.7;color:#475569;">You have been invited to Syncratic. Continue to verify your email and create your password.</p>
  <p style="margin:0 0 24px;font-size:14px;line-height:1.7;color:#475569;">Required actions: <strong>${requiredActionsText}</strong></p>
  <p style="margin:0 0 24px;"><a href="${link}" style="display:inline-block;background:#0f172a;color:#ffffff;text-decoration:none;border-radius:999px;padding:13px 20px;font-weight:800;">Create password</a></p>
  <p style="margin:0 0 12px;font-size:13px;line-height:1.7;color:#64748b;">This setup link expires in ${linkExpirationFormatter(linkExpiration)}.</p>
  <p style="margin:0;font-size:13px;line-height:1.7;color:#64748b;">After creating your password, sign in to Syncratic with this same email address. Your workspace invitation will be accepted automatically after authentication.</p>
</@layout.emailLayout>

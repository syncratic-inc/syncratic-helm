<#macro emailLayout>
<!doctype html>
<html>
  <body style="margin:0;padding:0;background:#f8fafc;font-family:Arial,Helvetica,sans-serif;color:#0f172a;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f8fafc;padding:28px 0;">
      <tr>
        <td align="center">
          <table role="presentation" width="640" cellspacing="0" cellpadding="0" style="width:640px;max-width:92%;background:#ffffff;border:1px solid #e2e8f0;border-radius:24px;overflow:hidden;">
            <tr>
              <td style="background:linear-gradient(135deg,#0f172a,#164e63,#0f766e);padding:30px 34px;color:#ffffff;">
                <div style="font-size:28px;font-weight:800;letter-spacing:-1px;">Syncratic</div>
                <div style="margin-top:6px;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#ccfbf1;">Knowledge Assurance</div>
              </td>
            </tr>
            <tr>
              <td style="padding:34px;">
                <#nested>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
</#macro>

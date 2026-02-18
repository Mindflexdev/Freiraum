import type { VercelRequest, VercelResponse } from '@vercel/node';
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);
const BUSINESS_EMAIL = 'info@freiraum-aufloesung.de';

// Simple honeypot check
function isSpam(body: Record<string, string>): boolean {
  return !!body._gotcha;
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ── Business notification email (what you receive) ──────────────────────
function buildBusinessEmail(fields: Record<string, string>, isB2B: boolean): string {
  const type = isB2B ? 'B2B-Kooperationsanfrage' : 'Neue Kundenanfrage';

  const rows = Object.entries(fields)
    .filter(([key]) => !key.startsWith('_') && key !== 'datenschutz')
    .map(([key, value]) => `
      <tr>
        <td style="padding:8px 16px;font-weight:600;color:#1e293b;vertical-align:top;white-space:nowrap;">${escapeHtml(key)}</td>
        <td style="padding:8px 16px;color:#334155;">${escapeHtml(value || '–')}</td>
      </tr>
    `)
    .join('');

  return `
    <!DOCTYPE html>
    <html>
    <body style="margin:0;padding:0;background:#f1f5f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
      <div style="max-width:600px;margin:32px auto;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
        <div style="background:#1e293b;padding:24px 32px;">
          <h1 style="margin:0;color:#ffffff;font-size:20px;font-weight:600;">${type}</h1>
          <p style="margin:4px 0 0;color:#94a3b8;font-size:14px;">über freiraum-aufloesung.de</p>
        </div>
        <div style="padding:24px 16px;">
          <table style="width:100%;border-collapse:collapse;">
            ${rows}
          </table>
        </div>
        <div style="padding:16px 32px;background:#f8fafc;border-top:1px solid #e2e8f0;">
          <p style="margin:0;color:#64748b;font-size:13px;">Freiraum-Auflösungen GmbH · Mühlenstraße 8a · 14167 Berlin</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

// ── Customer confirmation email ─────────────────────────────────────────
function buildConfirmationEmail(name: string, isB2B: boolean): string {
  const greeting = name ? `Guten Tag ${escapeHtml(name)}` : 'Guten Tag';

  return `
    <!DOCTYPE html>
    <html>
    <body style="margin:0;padding:0;background:#f1f5f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
      <div style="max-width:600px;margin:32px auto;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
        <div style="background:#1e293b;padding:24px 32px;">
          <h1 style="margin:0;color:#ffffff;font-size:20px;font-weight:600;">Freiraum-Auflösungen</h1>
        </div>
        <div style="padding:32px;">
          <h2 style="margin:0 0 16px;color:#1e293b;font-size:18px;">${greeting},</h2>
          <p style="color:#334155;line-height:1.6;margin:0 0 16px;">
            vielen Dank für Ihre Anfrage. Wir haben Ihre Nachricht erhalten und melden uns
            innerhalb von 24 Stunden bei Ihnen – in der Regel deutlich schneller.
          </p>
          <p style="color:#334155;line-height:1.6;margin:0 0 16px;">
            Falls Sie uns vorher erreichen möchten:
          </p>
          <table style="margin:0 0 24px;">
            <tr>
              <td style="padding:4px 12px 4px 0;color:#64748b;">Telefon:</td>
              <td style="padding:4px 0;"><a href="tel:+4930585816730" style="color:#1e293b;font-weight:600;text-decoration:none;">030 585 816 730</a></td>
            </tr>
            <tr>
              <td style="padding:4px 12px 4px 0;color:#64748b;">WhatsApp:</td>
              <td style="padding:4px 0;"><a href="https://wa.me/+4917664916462" style="color:#1e293b;font-weight:600;text-decoration:none;">0176 649 164 62</a></td>
            </tr>
            <tr>
              <td style="padding:4px 12px 4px 0;color:#64748b;">Erreichbar:</td>
              <td style="padding:4px 0;color:#334155;">Mo–Fr 08:00–19:00, Sa 09:00–14:00</td>
            </tr>
          </table>
          <p style="color:#334155;line-height:1.6;margin:0;">
            Mit freundlichen Grüßen<br>
            <strong>Ihr Team von Freiraum-Auflösungen</strong>
          </p>
        </div>
        <div style="padding:16px 32px;background:#f8fafc;border-top:1px solid #e2e8f0;">
          <p style="margin:0;color:#64748b;font-size:13px;">
            Freiraum-Auflösungen GmbH · Mühlenstraße 8a · 14167 Berlin<br>
            <a href="https://freiraum-aufloesung.de" style="color:#64748b;">freiraum-aufloesung.de</a>
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', 'https://freiraum-aufloesung.de');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const body = req.body || {};

    // Honeypot spam check
    if (isSpam(body)) {
      // Pretend success to fool bots
      return res.status(200).json({ ok: true });
    }

    const isB2B = body._type === 'b2b';
    const customerEmail = body['E-Mail'];
    const customerName = body['Name'] || body['Ansprechpartner'] || '';
    const subject = isB2B
      ? 'Neue B2B-Kooperationsanfrage über freiraum-aufloesung.de'
      : 'Neue Anfrage über freiraum-aufloesung.de';

    // Filter out internal fields
    const visibleFields: Record<string, string> = {};
    for (const [key, value] of Object.entries(body)) {
      if (!key.startsWith('_') && key !== 'datenschutz') {
        visibleFields[key] = String(value);
      }
    }

    // 1. Send notification to business
    await resend.emails.send({
      from: 'Freiraum Website <website@freiraum-aufloesung.de>',
      replyTo: customerEmail || undefined,
      to: [BUSINESS_EMAIL],
      subject,
      html: buildBusinessEmail(visibleFields, isB2B),
    });

    // 2. Send confirmation to customer (only if email provided)
    if (customerEmail) {
      await resend.emails.send({
        from: 'Freiraum-Auflösungen <noreply@freiraum-aufloesung.de>',
        to: [customerEmail],
        subject: 'Ihre Anfrage bei Freiraum-Auflösungen – Bestätigung',
        html: buildConfirmationEmail(customerName, isB2B),
      });
    }

    return res.status(200).json({ ok: true });
  } catch (error) {
    console.error('Contact form error:', error);
    return res.status(500).json({ error: 'Fehler beim Senden der Nachricht.' });
  }
}

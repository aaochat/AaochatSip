# Aao VOIP — App Store Metadata & Screenshot Strategy

## Positioning

**App name:** Aao VOIP  
**Subtitle (30 chars):** Org calling & team directory  
**Category:** Business  
**Primary keyword:** organization communication, team calling, business VoIP  

**Do not use:** SIP softphone, generic dialer, VoIP client template language.

**Value proposition:** Secure team calling, organization directory, call history, voicemail, and call insights for AaoChat tenants.

---

## App Store Description (draft)

Aao VOIP is your organization's communication hub on AaoChat. Connect with your team using your assigned extension, browse the company directory, review call history, listen to voicemail, and access call insights — all in one workspace designed for your business.

Features:
- Organization domain sign-in
- Team directory with one-tap calling
- Workspace home with recent calls and quick dial
- Secure VoIP calling with hold, transfer, and conference
- Call history with recording playback
- Voicemail inbox
- Call insights when enabled by your admin

Aao VOIP requires an AaoChat organization account and assigned extension.

---

## Screenshot Order (6 screens)

Capture on **iPhone 15 Pro** simulator or device at 1290×2796 (6.7").

| # | Screen | Caption idea |
|---|--------|--------------|
| 1 | Onboarding welcome | "Built for your organization" |
| 2 | Workspace home | "Your communication hub" |
| 3 | Team directory | "Find colleagues instantly" |
| 4 | Active call (new UI) | "Crystal-clear team calls" |
| 5 | Call history + insights | "Review conversations" |
| 6 | Voicemail / settings | "Stay connected anywhere" |

**Avoid:** Leading with raw dialpad grid (reads as generic SIP clone).

---

## Review Notes (for App Store Connect)

This app is the official VoIP client for **AaoChat** multi-tenant organizations. It is not a generic SIP softphone:

- Requires organization domain + tenant credentials
- Backend: `voip-api.aaochat.com`
- Distinct workspace UI (hub home, directory tab, modal dialer)
- Separate bundle and branding from other VoIP products by the same developer

Test account: [provide domain, email, password, extension for Apple review]

---

## Asset checklist before submission

- [ ] Replace `assets/app_logo.png` (distinct from other apps)
- [ ] Replace `assets/aao_ringtone.mp3` (unique ringtone)
- [ ] Replace `assets/insights_icon.png` (unique insights badge)
- [ ] Update iOS App Icon set in Xcode
- [ ] Confirm `CFBundleDisplayName` = **Aao VOIP**
- [ ] Obtain dedicated Siprix license keyed to AaoChat (not shared DeepFoodsInc key)
- [ ] Privacy policy URL covering microphone and call data

---

## Keywords (100 chars max)

```
voip,business,calling,team,directory,workspace,aaochat,organization,phone,extension
```

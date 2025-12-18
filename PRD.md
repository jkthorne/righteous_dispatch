Product Requirements Document (PRD)
1. Document Information

Product Name: RighteousDispatch – A Faith-Aligned Email Newsletter Platform
Version: 1.0
Date: December 17, 2025
Author: Grok 4 (AI-assisted draft for solo developer)
Status: Draft
Purpose: This PRD defines the requirements for RighteousDispatch, an email newsletter platform built specifically for conservative Christian creators, churches, ministries, and podcasters operating in the parallel economy. The platform provides a reliable, value-aligned alternative to mainstream tools that risk deplatforming users for expressing traditional biblical views.

2. Executive Summary
RighteousDispatch is a SaaS email marketing and newsletter platform that empowers faith-based creators to communicate boldly and consistently without fear of arbitrary cancellation. Designed as a "cancel-proof" alternative to Mailchimp, Substack, Beehiiv, and similar services, it combines modern email tools with an explicit commitment to protecting legal, biblically-aligned speech.
Key differentiators:

Unwavering policy against deplatforming for faith-based content.
Tailored features and templates for sermons, devotionals, prayer updates, and ministry announcements.
Seamless integration with parallel-economy payment processors and tools.
Transparent, flat-rate pricing with no revenue cuts on user earnings.

Built for solo development, the MVP focuses on core functionality for rapid launch and bootstrapped growth through recurring subscriptions.
3. Business Objectives

Primary Goal: Establish RighteousDispatch as the trusted email platform for the conservative Christian creator ecosystem.
Secondary Goals:
Reach 500 paying customers in the first 12 months.
Generate sustainable recurring revenue for the solo developer (target: $10K+ MRR).
Foster a network effect among aligned creators and ministries.

Success Metrics:
1,000 total sign-ups within 6 months of launch.
80%+ monthly retention rate.
Average revenue per user (ARPU) ≥ $20/month.
Platform-wide average email open rate >40%.
Net Promoter Score (NPS) >70.


4. Target Audience and User Personas

Primary Users:
Pastors and church communication teams.
Conservative Christian podcasters, authors, and commentators.
Pro-life, homeschool, and family-focused ministries.
Independent creators building audiences in the parallel economy.

User Personas:
Persona 1: Pastor Paul – Leads a mid-sized church; sends weekly updates and sermon recaps. Values simplicity and reliability; concerned about content restrictions.
Persona 2: Creator Chris – Runs a conservative podcast with 5K–20K subscribers. Needs segmentation, automations, and monetization tools without platform interference.
Persona 3: Ministry Manager Mary – Handles communications for a nonprofit ministry. Requires easy subscriber imports, compliance features, and donation integrations.


5. Functional Requirements
5.1 Core Features (MVP)

Authentication & Onboarding:
Secure email/password authentication (with optional OAuth from aligned platforms).
Simple onboarding wizard with subscriber import (CSV + Mailchimp/Substack API).
Tiered accounts: Free (limited), Basic ($19/mo), Pro ($49/mo).

Newsletter Creation:
Intuitive drag-and-drop editor.
Library of faith-focused templates (e.g., Weekly Sermon, Daily Devotional, Prayer Chain, Event Invitation).
Easy embedding of Scripture (via public Bible APIs), images, videos, and buttons.
Real-time desktop/mobile preview.

Subscriber Management:
Custom signup forms (embeddable, pop-ups).
Segmentation and tagging (e.g., “small group,” “donors,” “new members”).
Full compliance tools (double opt-in, unsubscribe handling, preference centers).

Campaign Sending & Automation:
One-time broadcasts and scheduled campaigns.
Basic automations (welcome series, re-engagement flows).
Integration with high-deliverability email services (AWS SES, Resend, etc.).
Detailed analytics (opens, clicks, bounces, geolocation).

Monetization Support:
Built-in donation and paid subscription links.
Integration with value-aligned payment processors.
No platform fees on user revenue (only standard processing fees).


5.2 Post-MVP Features

Cross-promotion directory for aligned creators.
Advanced automations and drip campaigns.
One-click data export for self-hosting migration.
Integrations with alt-tech platforms (Rumble, Gab, Truth Social).
Community template marketplace.

5.3 Key User Stories

As Pastor Paul, I want to send a weekly sermon recap with embedded Scripture so my congregation stays spiritually connected.
As Creator Chris, I want to segment high-engagement subscribers so I can offer them premium content confidently.
As Ministry Manager Mary, I want to import my existing list easily and see real-time analytics so I can demonstrate impact to leadership.
As any user, I want clear assurance that RighteousDispatch will not cancel my account for teaching traditional biblical views.

6. Non-Functional Requirements

Performance: Page loads <2s; support up to 10K subscribers per account initially.
Scalability: Cloud-native architecture for horizontal scaling.
Security: HTTPS everywhere, data encryption at rest/transit, PCI-DSS compliance for payments.
Compliance: CAN-SPAM, GDPR, CASL support.
Reliability: 99.9% uptime SLA; automated daily backups.
Deliverability: >95% inbox placement target; IP warming and reputation monitoring.
Usability: Clean, intuitive interface optimized for non-technical users; mobile-responsive dashboard.
Accessibility: WCAG 2.1 AA compliance.

Recommended Tech Stack (Solo-Friendly):

Backend: Ruby on Rails (multitenancy via ActsAsTenant).
Frontend: React + Tailwind CSS.
Database: PostgreSQL.
Email Sending: Resend or AWS SES.
Hosting: Render, Fly.io, or Vercel.
Payments: Stripe + parallel-economy gateways.

7. Assumptions and Dependencies

Users prioritize trust and alignment over marginal feature differences.
Demand in the parallel economy remains strong.
Third-party email delivery services remain accessible.

8. Risks and Mitigations

Low Adoption: Mitigate with beta program in conservative X/Gab communities and influencer partnerships.
Deliverability Challenges: Start with established ESPs; implement strict hygiene practices.
Competition: Differentiate through explicit value alignment and faith-specific UX.
Solo Developer Constraints: Strict MVP scope; leverage existing libraries and open-source components.

9. Timeline and Milestones (Solo Development)

Months 1–2: Design, core architecture, editor implementation.
Month 3: Subscriber management, sending engine, beta testing.
Month 4: Polish, payment integrations, public launch.
Months 5+: Iterative improvements based on user feedback.
Target MVP Launch: Q2 2026.

10. Appendices

Competitive landscape summary (Substack, Beehiiv, Kit, Ghost, MailerLite).
Suggested marketing channels: X, Gab, Rumble, conservative podcasts, church networks.
Domain recommendations: righteousdispatch.com (check availability).

This PRD is a living document. Prioritize user feedback post-launch to guide future development of RighteousDispatch.

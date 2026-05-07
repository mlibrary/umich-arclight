#!/usr/bin/env python3
"""Generate emails/its-oidc-request.rtf with macOS TextEdit-compatible RTF.

Usage:
    python3 dotpy/_gen_rtf.py
"""

import os

# Use \' hex escapes for the apostrophe (0x92 in mac_roman = right single quote,
# but plain ASCII apostrophe 0x27 is safer; RTF \'27 = ASCII apostrophe).
# \\ in the Python string becomes a single \ in the RTF file.
# Newlines in RTF source are ignored by the parser; \par is the paragraph break.

lines = [
    r"{\rtf1\ansi\ansicpg1252\cocoartf2639",
    r"{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fmodern\fcharset0 Courier;}",
    r"{\colortbl;\red255\green255\blue255;}",
    r"\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0",
    r"\pard\pardirnatural\partightenfactor0",
    r"\f0\fs24\cf0",
    r"\b Subject:\b0  OIDC Client Fix + Demo Redirect URI -- Deep Blue Documents\par",
    r"\b To:\b0  [ITS / team that manages shibboleth.umich.edu OIDC client registrations]\par",
    r"\b CC:\b0  [Deep Blue Documents team]\par",
    r"\par",
    r"Hi,\par",
    r"\par",
    r"We have two related requests concerning an OIDC client registered at"
    r" {\f1 shibboleth.umich.edu} for the Deep Blue Documents application.\par",
    r"\par",
    r"\b 1. Fix broken OIDC client\b0\par",
    r"\par",
    r"The OIDC client listed below is currently returning \b HTTP 500\b0  from"
    r" {\f1 shibboleth.umich.edu/idp/profile/oidc/authorize},"
    r" which prevents all U-M WebLogin authentication for the Deep Blue"
    r" Documents workshop and demo environments.\par",
    r"\par",
    r"{\f1     Client ID:   5-ulib-deepblue-wkshp-auth-arotuj4xgffe5ucs9saofg\par",
    r"    Provider:    shibboleth.umich.edu}\par",
    r"\par",
    r"Please investigate and restore normal operation for this client.\par",
    r"\par",
    r"\b 2. Add demo environment callback URL\b0\par",
    r"\par",
    r"We are deploying the oauth2-proxy gate to our \b demo\b0  environment"
    r" ({\f1 demo.deepblue-documents.lib.umich.edu}) to be consistent with"
    r" the existing workshop and production setups."
    r" Demo will share the same OIDC client listed above.\par",
    r"\par",
    r"Please add the following URL to the client\'27s \b allowed redirect URIs\b0 :\par",
    r"\par",
    r"{\f1     https://demo.deepblue-documents.lib.umich.edu/oauth2/callback}\par",
    r"\par",
    r"For reference, the workshop callback URL \b already registered\b0  on this client is:\par",
    r"\par",
    r"{\f1     https://workshop.deepblue-documents.lib.umich.edu/oauth2/callback}\par",
    r"\par",
    r"\b Context\b0\par",
    r"\par",
    r"- \b Application:\b0  Deep Blue Documents -- University of Michigan Library"
    r" institutional repository (DSpace 7.6)\par",
    r"- \b Auth proxy:\b0  {\f1 quay.io/oauth2-proxy/oauth2-proxy:v7.6.0},"
    r" provider {\f1 oidc}, issuer {\f1 https://shibboleth.umich.edu}\par",
    r"- \b Scope:\b0  {\f1 openid profile email edumember}\par",
    r"- \b Impact:\b0  Workshop and demo users cannot authenticate through U-M WebLogin;"
    r" the DSpace application is still reachable but the gate OIDC is non-functional\par",
    r"\par",
    r"Please let us know if you need any additional information.\par",
    r"\par",
    r"Thank you,\par",
    r"[Your name]\par",
    r"University of Michigan Library -- Deep Blue Documents team\par",
    r"}",
]

out_path = os.path.join(os.path.dirname(__file__), "..", "emails", "its-oidc-request.rtf")
out_path = os.path.normpath(out_path)

with open(out_path, "w", encoding="ascii") as f:
    f.write("\n".join(lines) + "\n")

print(f"Written: {out_path}")


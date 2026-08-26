# 08: Receipt scanning → auto-fill

**What to build:** A user photographs or picks a receipt image, and the Add Transaction form is pre-filled with the extracted amount, merchant, and date for confirmation.

**Blocked by:** 07 (On-device natural-language transaction entry)

**Status:** ready-for-agent

- [ ] A photo-capture/picker entry point exists on Add Transaction for receipts
- [ ] Text is extracted from the receipt image on-device (Vision OCR)
- [ ] The extracted text is parsed into transaction fields using #07's parser
- [ ] A receipt with no readable text leaves the form empty/manual rather than failing silently

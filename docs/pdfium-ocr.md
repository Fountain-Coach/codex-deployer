# PDFiumExtractor OCR Hook

The `PDFiumExtractor` module uses PDFium to extract text along with positional information on Linux. If the `tesseract` executable is found on the system `PATH`, the extractor also runs OCR on embedded images and merges the recognized text into the results.

## Enabling OCR

1. Install Tesseract (Debian/Ubuntu example):
   ```bash
   sudo apt-get install tesseract-ocr
   ```
2. Ensure `tesseract` is accessible on `PATH`.
3. Invoke the extractor normally; OCR is triggered automatically. To skip OCR even when Tesseract is installed, pass `useOCR: false` to `extractText`.

## Configuration

- Set `LANG` or `TESSDATA_PREFIX` environment variables to adjust the recognition language.
- Any additional Tesseract configuration can be provided by editing `/etc/tesseract/tessdata` or custom data paths referenced by `TESSDATA_PREFIX`.

## Fallback

If `tesseract` is not present, the extractor simply returns the PDF text without OCR enhancement.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

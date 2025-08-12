#!/usr/bin/env python3
"""
Create an SPS-compatible index JSON using `pdftotext` as a fallback extractor.

Writes to `midi/models/index.pdftotext.json` by default.
"""
import sys, subprocess, json, hashlib, os

SPEC_DIR = os.path.join(os.path.dirname(__file__), 'specs')
OUT_PATH = os.path.join(os.path.dirname(__file__), 'models', 'index.pdftotext.json')

def pdftotext_path():
    for p in ('pdftotext', '/usr/local/bin/pdftotext', '/opt/homebrew/bin/pdftotext'):
        try:
            subprocess.run([p, '--version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return p
        except Exception:
            continue
    return None

def sha256(path):
    h = hashlib.sha256()
    with open(path,'rb') as f:
        while True:
            chunk = f.read(8192)
            if not chunk: break
            h.update(chunk)
    return h.hexdigest()

def extract_text(pdftotext, path):
    try:
        out = subprocess.check_output([pdftotext, '-layout', path, '-'], stderr=subprocess.DEVNULL)
        return out.decode('utf-8', errors='replace')
    except subprocess.CalledProcessError:
        return ''

def main():
    pdftotext = pdftotext_path()
    if not pdftotext:
        print('pdftotext not found on PATH', file=sys.stderr)
        sys.exit(2)

    docs = []
    pdfs = sorted([os.path.join(SPEC_DIR,f) for f in os.listdir(SPEC_DIR) if f.lower().endswith('.pdf')])
    if not pdfs:
        print('No PDFs found in', SPEC_DIR)
        sys.exit(0)

    for pdf in pdfs:
        text = extract_text(pdftotext, pdf)
        lines = [l for l in text.splitlines()]
        pages = [{
            'number': 1,
            'text': '\n'.join(lines),
            'lines': [{'text': l, 'x': 0.0, 'y': i, 'width': 0.0, 'height': 0.0} for i,l in enumerate(lines)]
        }]
        docs.append({
            'fileName': os.path.basename(pdf),
            'id': str(os.path.splitext(os.path.basename(pdf))[0]),
            'pages': pages,
            'sha256': sha256(pdf),
            'size': os.path.getsize(pdf)
        })

    out = {'documents': docs}
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(out, f, indent=2, sort_keys=True)
    print('Wrote', OUT_PATH)

if __name__ == '__main__':
    main()

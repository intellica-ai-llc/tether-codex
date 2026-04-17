# Tether Codex

**AI-assisted engineering process management. Never lose context. Never repeat yourself.**

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React + Vite + Tailwind + Monaco Editor |
| Backend | FastAPI + SQLite + Groq |
| Hosting | Render (backend) + Netlify (frontend) |

## Development

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python -m uvicorn src.main:app --reload --port 8000
Frontend
bash
cd frontend
npm install
cp .env.example .env
npm run dev
License
Proprietary — All rights reserved.

text

---

## Step 5: Create Empty `__init__.py` Files

```bash
# Backend init files
touch backend/__init__.py
touch backend/src/__init__.py
touch backend/src/core/__init__.py
touch backend/src/models/__init__.py
touch backend/src/services/__init__.py
touch backend/src/routes/__init__.py
touch backend/src/utils/__init__.py
touch backend/tests/__init__.py

# Frontend init (optional, for any future Python)
touch frontend/__init__.py 2>/dev/null || true
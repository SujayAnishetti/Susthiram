# Susthiram Backend

This is the Python/FastAPI backend for the Susthiram application. It handles the AI agent logic and orchestration.

## Setup

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Environment Variables**:
    Create a `.env` file in this directory with your keys:
    ```
    GOOGLE_API_KEY=your_gemini_api_key
    ```

3.  **Run Locally**:
    ```bash
    uvicorn main:app --reload
    ```
    The server will start at `http://127.0.0.1:8000`.

## Deployment to Cloud Run

1.  **Build the image**:
    ```bash
    gcloud builds submit --tag gcr.io/PROJECT-ID/susthiram-backend
    ```

2.  **Deploy**:
    ```bash
    gcloud run deploy susthiram-backend --image gcr.io/PROJECT-ID/susthiram-backend --platform managed
    ```

## API Endpoints

*   `GET /`: Health check.
*   `POST /chat`: Chat with the Stylist or Vendor agent.
    *   Body: `{"message": "...", "agent_type": "Stylist"}`

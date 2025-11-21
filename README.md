# Susthiram - AI-Powered Sustainable Fashion Platform

Susthiram is an intelligent garment lifecycle management platform that uses multi-agent AI to promote sustainable fashion through garment analysis, exchange, and recycling.

## 🌟 Features

### AI-Powered Garment Analysis
- **Multimodal Image Analysis**: Upload front and back photos of garments
- **Quality Assessment**: AI evaluates condition, wear, and recyclability
- **Smart Classification**: Automatically categorizes as "Reusable" or "Recyclable"
- **Scoring System**: 0-100 quality score with detailed reasoning

### Multi-Agent AI System
- **Orchestrator Agent**: Intelligently routes requests to specialist agents
- **Stylist Agent**: Provides sustainable fashion advice and garment exchange recommendations
- **Vendor Agent**: Negotiates prices (250-650 credits) and connects with recycling vendors
- **Analyzer Agent**: Performs detailed garment quality assessment

### Location-Based Services
- **Nearby Garment Exchange**: Find reusable garments available for exchange nearby
- **Vendor Matching**: Connect with local recycling vendors (e.g., Kuppili Lakshmiprasanna - 5km away)
- **Automated Quotations**: Send professional quotation emails to vendors

### Conversation Memory
- **Persistent Memory**: All agents remember past conversations
- **Personalized Service**: Recommendations based on user history
- **Context Awareness**: Agents reference previous interactions

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── core/
│   ├── router/          # Navigation (GoRouter)
│   ├── services/        # API clients & orchestration
│   └── theme/           # UI theming
├── features/
│   ├── auth/            # Authentication
│   ├── chat/            # AI agent chat interface
│   ├── scan/            # Garment scanning & analysis
│   ├── ngo/             # NGO donation tracking
│   └── commercial/      # Commercial dashboard
```

### Backend (FastAPI + Google ADK)
```
backend/
├── agents/
│   ├── agent.py         # Orchestrator agent
│   ├── stylist.py       # Stylist agent
│   ├── vendor.py        # Vendor agent
│   ├── analyzer.py      # Analyzer agent
│   ├── tools.py         # Agent tools (email, search)
│   └── config.py        # Model configuration
├── main.py              # FastAPI application
├── Dockerfile           # Container configuration
└── requirements.txt     # Python dependencies
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2+
- Python 3.12+
- Google Cloud Project with Vertex AI enabled
- gcloud CLI configured

### Backend Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd susthiram/backend
```

2. **Configure environment variables**
```bash
# Create .env file
cp .env.example .env

# Edit .env with your values
PROJECT_ID=gcplab-478805
LOCATION=europe-west1

# Optional: SMTP for email quotations
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Run locally**
```bash
python main.py
# Server runs on http://0.0.0.0:8080
```

5. **Deploy to Cloud Run**
```bash
# Windows
deploy.bat

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```

### Frontend Setup

1. **Navigate to project root**
```bash
cd susthiram
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure backend URL**
Update the backend URL in:
- `lib/core/services/agent_orchestrator.dart`
- `lib/features/scan/data/gemini_service.dart`

```dart
static const String _baseUrl = 'https://your-backend-url.run.app';
```

4. **Run the app**
```bash
flutter run
```

## 🤖 AI Agents

### Orchestrator Agent
- **Model**: Gemini 2.5 Pro
- **Role**: Routes user requests to appropriate specialist agents
- **Tools**: load_memory
- **Memory**: Full conversation history across all agents

### Stylist Agent
- **Model**: Gemini 2.5 Flash
- **Role**: Sustainable fashion advice and garment exchange
- **Tools**: find_nearby_garments, load_memory
- **Features**:
  - Outfit suggestions
  - Color palette recommendations
  - Garment exchange matching
  - Style continuity across sessions

### Vendor Agent
- **Model**: Gemini 2.5 Flash
- **Role**: Price negotiation and vendor matching
- **Tools**: find_nearby_vendors, send_quotation_email, load_memory
- **Features**:
  - Initial bid: 250-450 credits
  - Maximum: 650 credits (premium items)
  - Email quotations to vendors
  - Pickup logistics coordination

### Analyzer Agent
- **Model**: Gemini 2.5 Pro
- **Role**: Multimodal garment quality assessment
- **Input**: Front and back garment images
- **Output**: JSON with quality score, classification, tags, reasoning

## 📱 User Flow

### 1. Scan Garment
```
User → Camera Screen → Upload Front/Back Photos → AI Analysis
```

### 2. View Results
```
Analysis Results → Quality Score → Classification (Reusable/Recyclable)
```

### 3. Take Action

**For Reusable Items:**
```
Get Styling Suggestions → Chat with Stylist Agent → Find Exchange Options
```

**For Recyclable Items:**
```
Sell to Vendor → Chat with Vendor Agent → Get Price Offer → Send Quotation
```

## 🔧 API Endpoints

### GET /agents
List all available agents
```bash
curl https://susthiram-backend.run.app/agents
```

### POST /chat
Chat with AI agents
```json
{
  "message": "What vendors are nearby?",
  "agent_type": "Vendor",
  "user_id": "user123",
  "location": {
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "garment_context": {
    "itemName": "Cotton T-Shirt",
    "classification": "Recyclable",
    "score": 45
  }
}
```

### POST /analyze
Analyze garment images
```bash
curl -X POST https://susthiram-backend.run.app/analyze \
  -F "front_image=@front.jpg" \
  -F "back_image=@back.jpg" \
  -F "user_id=user123" \
  -F "latitude=12.9716" \
  -F "longitude=77.5946"
```

## 🛠️ Tech Stack

### Frontend
- Flutter 3.7.2
- Dart
- Riverpod (State Management)
- GoRouter (Navigation)
- Geolocator (Location Services)
- Firebase (Auth, Firestore, Storage)

### Backend
- FastAPI (Python Web Framework)
- Google ADK (Agent Development Kit)
- Gemini 2.5 Flash & Pro (AI Models)
- Vertex AI (Google Cloud AI Platform)
- Uvicorn (ASGI Server)

### Infrastructure
- Google Cloud Run (Hosting)
- Docker (Containerization)
- Region: europe-west1
- Auto-scaling: 0-5 instances

## 🌍 Environment Variables

### Backend (.env)
```bash
PROJECT_ID=gcplab-478805
LOCATION=europe-west1

# Optional: Email functionality
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=your-email@gmail.com
SMTP_FROM_NAME=Susthiram Vendor Agent
```

### Cloud Run (Auto-configured)
```bash
GOOGLE_CLOUD_PROJECT=gcplab-478805
GOOGLE_CLOUD_LOCATION=europe-west1
GOOGLE_GENAI_USE_VERTEXAI=True
PORT=8080  # Auto-set by Cloud Run
```

## 📊 Agent Memory System

Susthiram uses Google ADK's memory system for persistent conversations:

- **InMemoryMemoryService**: Stores conversation sessions
- **InMemorySessionService**: Manages active sessions
- **load_memory tool**: Agents recall past conversations

### Memory Features
- ✅ Remembers user preferences and style choices
- ✅ Recalls past negotiations and prices
- ✅ Provides continuity across sessions
- ✅ Personalized recommendations based on history

## 🔐 Security & Permissions

### Required GCP APIs
- Vertex AI API
- Cloud Run API
- Artifact Registry API

### IAM Roles
- Cloud Run Admin
- Vertex AI User
- Service Account User

## 📝 License

This project is part of the BNB Marathon hackathon.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📧 Contact

For questions or support, please contact the development team.

## 🙏 Acknowledgments

- Google Cloud Platform for Vertex AI and Cloud Run
- Google ADK team for the agent framework
- Flutter team for the amazing mobile framework
- All contributors and testers

---

Built with ❤️ for sustainable fashion

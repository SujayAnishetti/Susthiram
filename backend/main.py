import os
import logging
import uvicorn
import vertexai
from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel
from dotenv import load_dotenv
from google.genai import types as genai_types

# ADK Imports
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService

from agents import AGENT_REGISTRY, build_image_part
from google.adk.memory import InMemoryMemoryService

load_dotenv()

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("SusthiramBackend")

app = FastAPI(title="Susthiram Backend (ADK Root Agent)")

# Initialize Session and Memory Services
session_service = InMemorySessionService()
memory_service = InMemoryMemoryService()


def _build_content(
    message: str | None = None,
    extra_parts: list[genai_types.Part] | None = None,
) -> genai_types.Content:
    parts: list[genai_types.Part] = []
    if message:
        parts.append(genai_types.Part.from_text(text=message))
    if extra_parts:
        parts.extend(extra_parts)
    if not parts:
        raise ValueError("Content requires at least one part.")
    return genai_types.Content(role="user", parts=parts)


def _extract_event_text(event) -> str:
    if not event.content or not getattr(event.content, "parts", None):
        return ""
    text_chunks: list[str] = []
    for part in event.content.parts:
        text_value = getattr(part, "text", None)
        if text_value:
            text_chunks.append(text_value)
    return "".join(text_chunks).strip()


async def _run_agent_message(
    agent,
    *,
    message: str | None,
    user_id: str,
    app_name: str,
    extra_parts: list[genai_types.Part] | None = None,
    agent_type: str | None = None,
) -> str:
    runner = Runner(
        agent=agent,
        session_service=session_service,
        memory_service=memory_service,
        app_name=app_name,
    )
    
    # Create or reuse session (this provides in-memory conversation context)
    session = await session_service.create_session(
        app_name=app_name,
        user_id=user_id,
    )

    final_text: str | None = None
    async for event in runner.run_async(
        user_id=user_id,
        session_id=session.id,
        new_message=_build_content(message, extra_parts),
    ):
        text = _extract_event_text(event)
        if text:
            final_text = text
        if event.is_final_response():
            break

    if not final_text:
        raise HTTPException(status_code=500, detail="Agent returned no text output")

    # Add session to memory for future recall
    try:
        await memory_service.add_session_to_memory(session)
        logger.info(f"Session {session.id} added to memory for {user_id}")
    except Exception as e:
        logger.warning(f"Failed to add session to memory: {e}")

    return final_text

# --- DATA MODELS ---
class ChatRequest(BaseModel):
    message: str
    agent_type: str = "Orchestrator"
    user_id: str = "default_user"
    location: dict | None = None  # {"latitude": float, "longitude": float}
    garment_context: dict | None = None  # Garment analysis data for context

class ChatResponse(BaseModel):
    text: str
    agent_name: str

class AnalyzeRequest(BaseModel):
    user_id: str = "default_user"
    location: dict  # {"latitude": float, "longitude": float}

# --- ROUTES ---

@app.get("/agents")
def list_agents():
    return {"agents": list(AGENT_REGISTRY.keys())}


@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        target_agent = AGENT_REGISTRY.get(request.agent_type)
        if not target_agent:
            raise HTTPException(status_code=400, detail="Unknown agent type")

        # Build context-aware message
        message = request.message
        
        # Add location context for Stylist agent
        if request.location and request.agent_type == "Stylist":
            message = f"{request.message}\n\n[User location: lat={request.location['latitude']}, lng={request.location['longitude']}]"
        
        # Add garment context for Vendor agent
        if request.garment_context and request.agent_type == "Vendor":
            garment_info = f"""
[Garment Context from Previous Scan]
Item: {request.garment_context.get('itemName', 'Unknown')}
Classification: {request.garment_context.get('classification', 'Unknown')}
Quality Score: {request.garment_context.get('score', 0)}/100
Quality Assessment: {request.garment_context.get('qualityAssessment', 'N/A')}
Tags: {', '.join(request.garment_context.get('tags', []))}
Reasoning: {request.garment_context.get('reasoning', 'N/A')}
"""
            if request.location:
                garment_info += f"\nUser location: lat={request.location['latitude']}, lng={request.location['longitude']}\n"
            
            message = f"{garment_info}\n{request.message}"

        response_text = await _run_agent_message(
            target_agent,
            message=message,
            user_id=request.user_id,
            app_name=f"Susthiram-{request.agent_type}",
            agent_type=request.agent_type,
        )

        return ChatResponse(text=response_text, agent_name=target_agent.name)

    except Exception as e:
        logger.error(f"ADK Error: {e}")
        raise HTTPException(status_code=500, detail=f"Agent execution failed: {str(e)}")

@app.post("/analyze")
async def analyze_garment(
    front_image: UploadFile = File(...),
    back_image: UploadFile = File(...),
    user_id: str = "default_user",
    latitude: float = 0.0,
    longitude: float = 0.0,
):
    try:
        logger.info("=== Starting garment analysis ===")
        front_bytes = await front_image.read()
        back_bytes = await back_image.read()
        logger.info(
            "Received images front=%s (type=%s) bytes=%d back=%s (type=%s) bytes=%d",
            front_image.filename,
            front_image.content_type,
            len(front_bytes),
            back_image.filename,
            back_image.content_type,
            len(back_bytes),
        )
        
        # Fix MIME type if it's application/octet-stream
        front_mime = front_image.content_type
        back_mime = back_image.content_type
        
        if front_mime == "application/octet-stream" or not front_mime:
            # Detect from filename extension
            if front_image.filename and front_image.filename.lower().endswith(('.jpg', '.jpeg')):
                front_mime = "image/jpeg"
            elif front_image.filename and front_image.filename.lower().endswith('.png'):
                front_mime = "image/png"
            else:
                front_mime = "image/jpeg"  # default
        
        if back_mime == "application/octet-stream" or not back_mime:
            if back_image.filename and back_image.filename.lower().endswith(('.jpg', '.jpeg')):
                back_mime = "image/jpeg"
            elif back_image.filename and back_image.filename.lower().endswith('.png'):
                back_mime = "image/png"
            else:
                back_mime = "image/jpeg"  # default
        
        logger.info(f"Using MIME types: front={front_mime}, back={back_mime}")
        
        front_part = build_image_part(front_bytes, front_mime)
        back_part = build_image_part(back_bytes, back_mime)
        logger.info("Image parts created successfully")

        prompt = (
            "You are given two garment photos. The first part is the front view, "
            "the second is the back view. Assess condition, recyclability vs reuse, "
            "and respond with the strict JSON schema provided in your system instructions."
        )

        logger.info("Calling Gemini API via ADK...")
        response_text = await _run_agent_message(
            AGENT_REGISTRY["Analyzer"],
            message=prompt,
            extra_parts=[front_part, back_part],
            user_id=user_id,
            app_name="SusthiramAnalyzer",
            agent_type="Analyzer",
        )
        logger.info(f"Received response: {response_text[:200]}...")
        
        # Clean JSON
        import json
        clean_text = response_text.replace('```json', '').replace('```', '').strip()
        result = json.loads(clean_text)
        
        logger.info("=== Analysis complete ===")
        return result

    except Exception as e:
        logger.error(f"Analysis Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
import os
from dataclasses import dataclass
from pathlib import Path

import google.auth
import vertexai
from dotenv import load_dotenv


_ROOT_DIR = Path(__file__).resolve().parent.parent
load_dotenv(_ROOT_DIR / ".env")

_CREDENTIALS_PATH = _ROOT_DIR / "credentials.json"
if _CREDENTIALS_PATH.exists():
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = str(_CREDENTIALS_PATH)


def _bootstrap_gcp() -> tuple[str | None, str]:
    # Prefer ADC; fall back to explicit env overrides
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    location = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

    if not project_id:
        try:
            _, detected_project = google.auth.default()
            project_id = detected_project
        except Exception:
            detected_project = None
        if detected_project:
            os.environ.setdefault("GOOGLE_CLOUD_PROJECT", detected_project)

    os.environ.setdefault("GOOGLE_GENAI_USE_VERTEXAI", "True")
    os.environ.setdefault("GOOGLE_CLOUD_LOCATION", location)

    if project_id:
        vertexai.init(project=project_id, location=location)
    return project_id, location


@dataclass(frozen=True)
class SusthiramConfig:
    project_id: str | None
    location: str
    worker_model: str = os.getenv("SUSTHIRAM_WORKER_MODEL", "gemini-2.5-flash")
    critic_model: str = os.getenv("SUSTHIRAM_CRITIC_MODEL", "gemini-2.5-pro")
    analyzer_model: str = os.getenv("SUSTHIRAM_ANALYZER_MODEL", "gemini-2.5-pro")


_project, _location = _bootstrap_gcp()
config = SusthiramConfig(project_id=_project, location=_location)


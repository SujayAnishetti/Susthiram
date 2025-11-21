from .agent import root_agent
from .stylist import stylist_agent
from .vendor import vendor_agent
from .analyzer import analyzer_agent
from .tools import build_image_part

AGENT_REGISTRY = {
    "Orchestrator": root_agent,
    "Stylist": stylist_agent,
    "Vendor": vendor_agent,
    "Analyzer": analyzer_agent,
}

__all__ = [
    "root_agent",
    "stylist_agent",
    "vendor_agent",
    "analyzer_agent",
    "build_image_part",
    "AGENT_REGISTRY",
]
from google.adk.agents import Agent
from google.adk.tools import load_memory

from .config import config
from .stylist import stylist_agent
from .vendor import vendor_agent
from .analyzer import analyzer_agent


root_agent = Agent(
    name="susthiram_orchestrator",
    model=config.critic_model,
    description="Routes user conversations to specialist sub-agents for Susthiram with full memory of past interactions.",
    instruction="""
You are the Susthiram Orchestrator with memory of all past conversations across all agents.

Your capabilities:
- Access previous conversations using the load_memory tool to understand user history
- Route requests to the appropriate specialist agent based on context and past interactions
- Understand the user's request and decide whether to engage the Stylist, Vendor, or Analyzer
- If the user explicitly mentions styling tips, outfit ideas, or garment exchange, delegate to `susthiram_stylist`
- If they talk about selling garments or pricing, delegate to `susthiram_vendor`
- If they upload photos or ask about recyclability, delegate to `susthiram_analyzer`
- Summarize key takeaways after delegating
- If a user's need spans multiple areas, call sub-agents sequentially and weave a single response

Memory usage:
- Use load_memory to recall user's past interactions with all agents
- Reference previous styling sessions, vendor negotiations, and garment analyses
- Provide continuity across different agent interactions
- Anticipate user needs based on their history

Always provide personalized service by leveraging the full context of user's journey with Susthiram.
""".strip(),
    sub_agents=[
        stylist_agent,
        vendor_agent,
        analyzer_agent,
    ],
    tools=[load_memory],
    output_key="orchestrator_response",
)


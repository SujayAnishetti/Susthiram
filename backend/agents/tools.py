from typing import Optional
import base64
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from google.genai import types as genai_types
from google.adk.tools import FunctionTool


def build_image_part(
    image_bytes: bytes,
    mime_type: Optional[str] = None,
) -> genai_types.Part:
    """Wraps image bytes in a Gemini Part for multimodal agent inputs."""
    if not image_bytes:
        raise ValueError("image_bytes must not be empty")

    mime = mime_type or "image/jpeg"
    return genai_types.Part.from_bytes(data=image_bytes, mime_type=mime)


def find_nearby_garments(
    latitude: float,
    longitude: float,
    radius_km: float = 10.0,
    classification: Optional[str] = None,
) -> str:
    """Find garments available for exchange near a user's location.
    
    Args:
        latitude: User's latitude coordinate
        longitude: User's longitude coordinate
        radius_km: Search radius in kilometers (default: 10)
        classification: Filter by classification: 'Reusable' or 'Recyclable'
    
    Returns:
        String with garment details including distance, quality, and ID
    """
    # Mock data for demonstration - in production, this would query a database
    mock_garments = [
        {
            "item_name": "Vintage Denim Jacket",
            "distance_km": 2.3,
            "quality_assessment": "Good condition, minor wear on elbows",
            "classification": "Reusable",
            "score": 78,
            "tags": ["denim", "vintage", "casual"],
            "id": "garment_001",
        },
        {
            "item_name": "Cotton T-Shirt Bundle",
            "distance_km": 4.7,
            "quality_assessment": "Mixed condition, suitable for recycling",
            "classification": "Recyclable",
            "score": 45,
            "tags": ["cotton", "basic", "bundle"],
            "id": "garment_002",
        },
    ]
    
    # Filter by classification if provided
    if classification:
        mock_garments = [g for g in mock_garments if g["classification"] == classification]
    
    # Filter by radius
    nearby_garments = [g for g in mock_garments if g["distance_km"] <= radius_km]

    if not nearby_garments:
        return "No garments found nearby. Try expanding your search radius."

    result = f"Found {len(nearby_garments)} garment(s) nearby:\n\n"
    for i, garment in enumerate(nearby_garments, 1):
        result += f"{i}. {garment['item_name']}\n"
        result += f"   Distance: {garment['distance_km']} km\n"
        result += f"   Quality: {garment['quality_assessment']}\n"
        result += f"   Classification: {garment['classification']}\n"
        result += f"   Score: {garment['score']}/100\n"
        result += f"   Tags: {', '.join(garment['tags'])}\n"
        result += f"   ID: {garment['id']}\n\n"

    return result


def find_nearby_vendors(latitude: float, longitude: float, radius_km: float = 20.0) -> str:
    """Find recycling vendors near a user's location.
    
    Args:
        latitude: User's latitude coordinate
        longitude: User's longitude coordinate
        radius_km: Search radius in kilometers (default: 20)
    
    Returns:
        String with vendor details including contact info and distance
    """
    # Mock vendor data - in production, this would query a database
    vendors = [
        {
            "name": "Kuppili Lakshmiprasanna",
            "email": "kuppili.lakshmiprasanna@gmail.com",
            "distance_km": 5.0,
            "specialization": "Textile Recycling",
            "rating": 4.8,
        },
        {
            "name": "EcoRecycle Hub",
            "email": "contact@ecorecycle.com",
            "distance_km": 12.0,
            "specialization": "General Recycling",
            "rating": 4.5,
        },
    ]
    
    # Filter by radius
    nearby_vendors = [v for v in vendors if v["distance_km"] <= radius_km]
    
    if not nearby_vendors:
        return "No vendors found nearby. Try expanding your search radius."
    
    result = f"Found {len(nearby_vendors)} vendor(s) nearby:\n\n"
    for i, vendor in enumerate(nearby_vendors, 1):
        result += f"{i}. {vendor['name']}\n"
        result += f"   Email: {vendor['email']}\n"
        result += f"   Distance: {vendor['distance_km']} km\n"
        result += f"   Specialization: {vendor['specialization']}\n"
        result += f"   Rating: {vendor['rating']}/5.0\n\n"
    
    return result


def send_quotation_email(
    vendor_email: str,
    garment_details: str,
    offered_price: int,
    user_contact: str = "user@susthiram.com",
) -> str:
    """Send a quotation email to a vendor.
    
    Args:
        vendor_email: Vendor's email address
        garment_details: Description of the garment being sold
        offered_price: Price offered in credits
        user_contact: User's contact information
    
    Returns:
        Success or error message
    """
    try:
        smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
        smtp_port = int(os.getenv("SMTP_PORT", "587"))
        smtp_user = os.getenv("SMTP_USERNAME")
        smtp_pass = os.getenv("SMTP_PASSWORD")
        from_email = os.getenv("SMTP_FROM_EMAIL", smtp_user)
        from_name = os.getenv("SMTP_FROM_NAME", "Susthiram Vendor Agent")
        
        if not smtp_user or not smtp_pass:
            return "Email configuration not set up. Please configure SMTP settings in .env file."
        
        # Create message
        msg = MIMEMultipart()
        msg["From"] = f"{from_name} <{from_email}>"
        msg["To"] = vendor_email
        msg["Subject"] = f"Garment Recycling Quotation - {offered_price} Credits"
        
        body = f"""
Dear Vendor,

We have a garment available for recycling and would like to request a quotation.

Garment Details:
{garment_details}

Offered Price: {offered_price} credits

User Contact: {user_contact}

Please review and respond with your best offer.

Best regards,
Susthiram Vendor Agent
"""
        
        msg.attach(MIMEText(body, "plain"))
        
        # Send email
        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_pass)
            server.send_message(msg)
        
        return f"✓ Quotation email sent successfully to {vendor_email}"
        
    except Exception as e:
        return f"Failed to send email: {str(e)}"


# Create tools using FunctionTool
find_nearby_garments_tool = FunctionTool(func=find_nearby_garments)
find_nearby_vendors_tool = FunctionTool(func=find_nearby_vendors)
send_quotation_email_tool = FunctionTool(func=send_quotation_email)


import logging
from datetime import datetime
from typing import Optional, List, Dict, Any
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter
import base64

logger = logging.getLogger("SusthiramDB")


class FirestoreService:
    def __init__(self):
        self.db = firestore.Client()
        self.garments_collection = "garments"
        self.users_collection = "users"
        self.conversations_collection = "conversations"

    def store_garment(
        self,
        user_id: str,
        analysis: Dict[str, Any],
        location: Dict[str, float],  # {"latitude": float, "longitude": float}
        front_image_bytes: bytes,
        back_image_bytes: bytes,
    ) -> str:
        """Store a scanned garment with location and images."""
        try:
            garment_data = {
                "user_id": user_id,
                "item_name": analysis.get("itemName", "Unknown"),
                "quality_assessment": analysis.get("qualityAssessment", ""),
                "tags": analysis.get("tags", []),
                "classification": analysis.get("classification", "Recyclable"),
                "score": analysis.get("score", 0),
                "reasoning": analysis.get("reasoning", ""),
                "location": firestore.GeoPoint(
                    location["latitude"], location["longitude"]
                ),
                "front_image": base64.b64encode(front_image_bytes).decode("utf-8"),
                "back_image": base64.b64encode(back_image_bytes).decode("utf-8"),
                "created_at": firestore.SERVER_TIMESTAMP,
                "status": "available",  # available, exchanged, donated, recycled
            }

            doc_ref = self.db.collection(self.garments_collection).document()
            doc_ref.set(garment_data)
            logger.info(f"Stored garment {doc_ref.id} for user {user_id}")
            return doc_ref.id

        except Exception as e:
            logger.error(f"Error storing garment: {e}")
            raise

    def find_nearby_garments(
        self,
        latitude: float,
        longitude: float,
        radius_km: float = 10.0,
        classification: Optional[str] = None,
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """Find garments near a location. Note: This is a simple implementation.
        For production, use geohashing or Firestore's geoqueries extension."""
        try:
            query = self.db.collection(self.garments_collection)
            query = query.where(filter=FieldFilter("status", "==", "available"))

            if classification:
                query = query.where(
                    filter=FieldFilter("classification", "==", classification)
                )

            query = query.limit(limit * 3)  # Get more to filter by distance
            docs = query.stream()

            results = []
            for doc in docs:
                data = doc.to_dict()
                data["id"] = doc.id

                # Calculate approximate distance (simple lat/lng difference)
                garment_loc = data.get("location")
                if garment_loc:
                    lat_diff = abs(garment_loc.latitude - latitude)
                    lng_diff = abs(garment_loc.longitude - longitude)
                    # Rough distance in km (1 degree ≈ 111km)
                    distance = ((lat_diff**2 + lng_diff**2) ** 0.5) * 111

                    if distance <= radius_km:
                        data["distance_km"] = round(distance, 2)
                        results.append(data)

            # Sort by distance and limit
            results.sort(key=lambda x: x.get("distance_km", float("inf")))
            return results[:limit]

        except Exception as e:
            logger.error(f"Error finding nearby garments: {e}")
            return []

    def store_conversation_message(
        self,
        user_id: str,
        agent_type: str,
        message: str,
        is_user: bool,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> str:
        """Store a conversation message for agent memory."""
        try:
            msg_data = {
                "user_id": user_id,
                "agent_type": agent_type,
                "message": message,
                "is_user": is_user,
                "metadata": metadata or {},
                "timestamp": firestore.SERVER_TIMESTAMP,
            }

            doc_ref = self.db.collection(self.conversations_collection).document()
            doc_ref.set(msg_data)
            return doc_ref.id

        except Exception as e:
            logger.error(f"Error storing conversation: {e}")
            raise

    def get_conversation_history(
        self, user_id: str, agent_type: str, limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Retrieve conversation history for agent memory."""
        try:
            query = (
                self.db.collection(self.conversations_collection)
                .where(filter=FieldFilter("user_id", "==", user_id))
                .where(filter=FieldFilter("agent_type", "==", agent_type))
                .order_by("timestamp", direction=firestore.Query.DESCENDING)
                .limit(limit)
            )

            docs = query.stream()
            messages = []
            for doc in docs:
                data = doc.to_dict()
                data["id"] = doc.id
                messages.append(data)

            # Reverse to get chronological order
            messages.reverse()
            return messages

        except Exception as e:
            logger.error(f"Error retrieving conversation history: {e}")
            return []

    def get_user_garments(
        self, user_id: str, status: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Get all garments for a user."""
        try:
            query = self.db.collection(self.garments_collection).where(
                filter=FieldFilter("user_id", "==", user_id)
            )

            if status:
                query = query.where(filter=FieldFilter("status", "==", status))

            docs = query.stream()
            garments = []
            for doc in docs:
                data = doc.to_dict()
                data["id"] = doc.id
                garments.append(data)

            return garments

        except Exception as e:
            logger.error(f"Error retrieving user garments: {e}")
            return []


# Singleton instance
_db_service = None


def get_db_service() -> FirestoreService:
    global _db_service
    if _db_service is None:
        _db_service = FirestoreService()
    return _db_service

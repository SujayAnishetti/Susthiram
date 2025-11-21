import requests
import json
import os

BASE_URL = "http://localhost:8080"

def test_stylist():
    print("\n--- Testing Stylist Agent ---")
    try:
        payload = {
            "message": "I have a red silk saree. How can I style it for a modern office look?",
            "agent_type": "Stylist"
        }
        response = requests.post(f"{BASE_URL}/chat", json=payload)
        response.raise_for_status()
        data = response.json()
        print(f"✅ Stylist Response ({data.get('agent_name')}):")
        print(data.get("text"))
    except Exception as e:
        print(f"❌ Stylist Test Failed: {e}")

def test_vendor():
    print("\n--- Testing Vendor Agent ---")
    try:
        payload = {
            "message": "I have a batch of 5 cotton shirts in good condition. How much can I get?",
            "agent_type": "Vendor"
        }
        response = requests.post(f"{BASE_URL}/chat", json=payload)
        response.raise_for_status()
        data = response.json()
        print(f"✅ Vendor Response ({data.get('agent_name')}):")
        print(data.get("text"))
    except Exception as e:
        print(f"❌ Vendor Test Failed: {e}")

def test_analyzer():
    print("\n--- Testing Analyzer Agent (Vision + Logic) ---")
    
    # Create dummy image files for testing if they don't exist
    if not os.path.exists("test_front.jpg"):
        with open("test_front.jpg", "wb") as f:
            f.write(os.urandom(1024)) # Random bytes, Vision API will likely reject this but we test the endpoint
    
    if not os.path.exists("test_back.jpg"):
        with open("test_back.jpg", "wb") as f:
            f.write(os.urandom(1024))

    try:
        files = {
            'front_image': ('test_front.jpg', open('test_front.jpg', 'rb'), 'image/jpeg'),
            'back_image': ('test_back.jpg', open('test_back.jpg', 'rb'), 'image/jpeg')
        }
        
        print("Sending request... (Note: Random bytes might fail Vision API, but endpoint should be reachable)")
        response = requests.post(f"{BASE_URL}/analyze", files=files)
        
        if response.status_code == 500 and "Vision" in response.text:
             print("⚠️ Endpoint reached, but Vision API failed on dummy image (Expected).")
             print(f"Error message: {response.text}")
        else:
            response.raise_for_status()
            data = response.json()
            print("✅ Analysis Result:")
            print(json.dumps(data, indent=2))
            
    except Exception as e:
        print(f"❌ Analyzer Test Failed: {e}")
    finally:
        # Cleanup
        if os.path.exists("test_front.jpg"): os.remove("test_front.jpg")
        if os.path.exists("test_back.jpg"): os.remove("test_back.jpg")

if __name__ == "__main__":
    print(f"Testing Backend at {BASE_URL}")
    # Check health
    try:
        requests.get(BASE_URL)
        print("✅ Server is Online")
        
        test_stylist()
        test_vendor()
        test_analyzer()
        
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to server. Is uvicorn running?")

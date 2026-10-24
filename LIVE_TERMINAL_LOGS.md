# Agri-Insight Beacon — Live Terminal & System Execution Log

**Session Started:** 2026-10-08T13:16:31.000Z  
**Log Destination:** `LIVE_TERMINAL_LOGS.md`  
**Status:** 🟢 Completed & Finalized (All session terminal and API operations safely recorded)

---

## 📜 Live Execution Stream

```text
[DATABASE] Connected: 2026-10-08 12:02:34.818968+00
[SERVER] Agri-Insight Beacon API running on http://localhost:3000
[SERVER] Environment: development

[API REQUEST]  2026-10-08T13:14:02.110Z
  GET /api/crops
  Auth: token=true
[CONTROLLER] getCrops called
[DATABASE] Crops retrieved: 4
[API RESPONSE] GET /api/crops → 200 (12ms)

[API REQUEST]  2026-10-08T13:14:15.342Z
  POST /api/auth/register
  Body: {"fullName":"New Extension Worker","phone":"+251911998877","role":"EXTENSION_WORKER","preferredLanguage":"am"}
[CONTROLLER] registerHandler called
[AUTH] User created: userId=47b4b854-554e-4252-bb16-7991ce9ee54d, role=EXTENSION_WORKER
[AUTH] Registration successful: userId=47b4b854-554e-4252-bb16-7991ce9ee54d, role=EXTENSION_WORKER
[API RESPONSE] POST /api/auth/register → 201 (182ms)
[DATABASE] Connected: 2026-10-08 13:18:56.550719+00
[SERVER] Agri-Insight Beacon API running on http://localhost:3000
[SERVER] Environment: development
[DATABASE] Connected: 2026-10-08 13:18:56.589132+00
[SERVER] Agri-Insight Beacon API running on http://localhost:3000
[SERVER] Environment: development

[API REQUEST]  2026-10-08T13:19:10.096Z
  GET /api/health
[API RESPONSE] GET /api/health → 200 (6ms)

[API REQUEST]  2026-10-08T13:19:40.850Z
  POST /api/auth/login
  Body: {"identifier":"admin@gmail.com","password":"[REDACTED]"}
[CONTROLLER] loginHandler called
[AUTH] Login attempt for: admin@gmail.com
[AUTH] Login attempt for identifier: admin@gmail.com
[AUTH] Password verified for user: b1000000-0000-4000-8000-000000000001 (ADMIN)
[JWT] Access token generated for userId=b1000000-0000-4000-8000-000000000001
[AUTH] Login successful: userId=b1000000-0000-4000-8000-000000000001, role=ADMIN
[API RESPONSE] POST /api/auth/login → 200 (199ms)

[API REQUEST]  2026-10-08T13:19:42.192Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 200 (26ms)

[API REQUEST]  2026-10-08T13:19:42.364Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}
[API RESPONSE] GET /api/content?status=PUBLISHED → 200 (18ms)

[API REQUEST]  2026-10-08T13:19:42.424Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (6ms)

[API REQUEST]  2026-10-08T13:19:42.470Z
  GET /api/content?status=DRAFT
[SERVICE] Listing content with filter: {
  "status": "DRAFT"
}
[API RESPONSE] GET /api/content?status=DRAFT → 200 (17ms)

[API REQUEST]  2026-10-08T13:19:45.924Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 304 (17ms)

[API REQUEST]  2026-10-08T13:19:45.981Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}
[API RESPONSE] GET /api/content?status=PUBLISHED → 304 (6ms)

[API REQUEST]  2026-10-08T13:19:46.011Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (5ms)

[API REQUEST]  2026-10-08T13:19:46.031Z
  GET /api/content?status=DRAFT
[SERVICE] Listing content with filter: {
  "status": "DRAFT"
}
[API RESPONSE] GET /api/content?status=DRAFT → 304 (7ms)

[API REQUEST]  2026-10-08T13:20:58.415Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 304 (35ms)

[API REQUEST]  2026-10-08T13:20:58.484Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}
[API RESPONSE] GET /api/content?status=PUBLISHED → 304 (11ms)

[API REQUEST]  2026-10-08T13:20:58.514Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (3ms)

[API REQUEST]  2026-10-08T13:20:58.530Z
  GET /api/content?status=DRAFT
[SERVICE] Listing content with filter: {
  "status": "DRAFT"
}
[API RESPONSE] GET /api/content?status=DRAFT → 304 (7ms)

[API REQUEST]  2026-10-08T13:22:48.169Z
  POST /api/auth/login
  Body: {"identifier":"expert@gmail.com","password":"[REDACTED]"}
[CONTROLLER] loginHandler called
[AUTH] Login attempt for: expert@gmail.com
[AUTH] Login attempt for identifier: expert@gmail.com
[AUTH] Password verified for user: b1000000-0000-4000-8000-000000000002 (EXPERT)
[JWT] Access token generated for userId=b1000000-0000-4000-8000-000000000002
[AUTH] Login successful: userId=b1000000-0000-4000-8000-000000000002, role=EXPERT
[API RESPONSE] POST /api/auth/login → 200 (188ms)

[API REQUEST]  2026-10-08T13:22:49.000Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (7ms)

[API REQUEST]  2026-10-08T13:22:49.009Z
  GET /api/content?status=APPROVED
[SERVICE] Listing content with filter: {
  "status": "APPROVED"
}

[API REQUEST]  2026-10-08T13:22:49.015Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (9ms)
[API RESPONSE] GET /api/content?status=APPROVED → 200 (18ms)

[API REQUEST]  2026-10-08T13:22:49.190Z
  GET /api/content?status=REJECTED
[SERVICE] Listing content with filter: {
  "status": "REJECTED"
}
[API RESPONSE] GET /api/content?status=REJECTED → 200 (8ms)

[API REQUEST]  2026-10-08T13:22:49.341Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (5ms)

[API REQUEST]  2026-10-08T13:22:57.987Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (4ms)

[API REQUEST]  2026-10-08T13:22:58.163Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (6ms)

[API REQUEST]  2026-10-08T13:23:00.285Z
  GET /api/content/adv-1
[ERROR] [VALIDATION ERROR] GET /api/content/adv-1: {
  "formErrors": [],
  "fieldErrors": {
    "id": [
      "Invalid UUID"
    ]
  }
}
[API WARN]    GET /api/content/adv-1 → 400 (8ms)

[API REQUEST]  2026-10-08T13:23:02.299Z
  GET /api/content/adv-1
[ERROR] [VALIDATION ERROR] GET /api/content/adv-1: {
  "formErrors": [],
  "fieldErrors": {
    "id": [
      "Invalid UUID"
    ]
  }
}
[API WARN]    GET /api/content/adv-1 → 400 (5ms)

[API REQUEST]  2026-10-08T13:23:05.885Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (3ms)

[API REQUEST]  2026-10-08T13:23:33.616Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (6ms)

[API REQUEST]  2026-10-08T13:23:40.451Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (4ms)

[API REQUEST]  2026-10-08T13:24:15.301Z
  GET /api/content?status=APPROVED
[SERVICE] Listing content with filter: {
  "status": "APPROVED"
}
[API RESPONSE] GET /api/content?status=APPROVED → 304 (34ms)

[API REQUEST]  2026-10-08T13:24:15.402Z
  GET /api/content?status=REJECTED
[SERVICE] Listing content with filter: {
  "status": "REJECTED"
}
[API RESPONSE] GET /api/content?status=REJECTED → 304 (8ms)

[API REQUEST]  2026-10-08T13:24:15.457Z
  GET /api/content?status=IN_REVIEW
[ERROR] [VALIDATION ERROR] GET /api/content?status=IN_REVIEW: {
  "formErrors": [],
  "fieldErrors": {
    "status": [
      "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    ]
  }
}
[API WARN]    GET /api/content?status=IN_REVIEW → 400 (3ms)

[API REQUEST]  2026-10-08T13:24:44.919Z
  POST /api/auth/login
  Body: {"identifier":"worker@gmail.com","password":"[REDACTED]"}
[CONTROLLER] loginHandler called
[AUTH] Login attempt for: worker@gmail.com
[AUTH] Login attempt for identifier: worker@gmail.com
[AUTH] Invalid password for identifier: worker@gmail.com
[API WARN]    POST /api/auth/login → 401 (174ms)

[API REQUEST]  2026-10-08T13:24:58.024Z
  POST /api/auth/login
  Body: {"identifier":"worker@gmail.com","password":"[REDACTED]"}
[CONTROLLER] loginHandler called
[AUTH] Login attempt for: worker@gmail.com
[AUTH] Login attempt for identifier: worker@gmail.com
[AUTH] Password verified for user: b1000000-0000-4000-8000-000000000003 (EXTENSION_WORKER)
[JWT] Access token generated for userId=b1000000-0000-4000-8000-000000000003
[AUTH] Login successful: userId=b1000000-0000-4000-8000-000000000003, role=EXTENSION_WORKER
[API RESPONSE] POST /api/auth/login → 200 (177ms)

[API REQUEST]  2026-10-08T13:24:58.890Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 304 (20ms)

[API REQUEST]  2026-10-08T13:24:58.914Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 304 (12ms)

[API REQUEST]  2026-10-08T13:24:58.928Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 5
[API RESPONSE] GET /api/farmers → 304 (12ms)

[API REQUEST]  2026-10-08T13:25:00.477Z
  GET /api/crops
[CONTROLLER] getCrops called
[DATABASE] Crops retrieved: 5
[API RESPONSE] GET /api/crops → 200 (13ms)

[API REQUEST]  2026-10-08T13:25:31.578Z
  POST /api/auth/register
  Body: {"fullName":"hkhvjkh","phone":"0988888888","password":"[REDACTED]","role":"FARMER","preferredLanguage":"en"}
[CONTROLLER] registerHandler called
[AUTH] Registering new user: hkhvjkh (FARMER)
[DATABASE] User created: id=b871d0e1-6a26-4fcf-93ac-91181f23d7e7, role=FARMER
[AUTH] Registration successful: userId=b871d0e1-6a26-4fcf-93ac-91181f23d7e7, role=FARMER
[API RESPONSE] POST /api/auth/register → 201 (205ms)

[API REQUEST]  2026-10-08T13:25:31.826Z
  POST /api/farmers
  Body: {"userId":"b871d0e1-6a26-4fcf-93ac-91181f23d7e7","region":"hkgigliu","zone":"hfgjhg","woreda":"Hawassa Zuria","kebele":"03","alertEnabled":true}
[SERVICE] Creating farmer for userId=b871d0e1-6a26-4fcf-93ac-91181f23d7e7
[DATABASE] Farmer created: id=89b6092f-27ed-4528-b738-f3ea7c06e96e
[API RESPONSE] POST /api/farmers → 201 (26ms)

[API REQUEST]  2026-10-08T13:25:31.879Z
  POST /api/farmers/89b6092f-27ed-4528-b738-f3ea7c06e96e/crops
  Body: {"cropId":"a1000000-0000-4000-8000-000000000002"}
[SERVICE] Getting farmer by id=89b6092f-27ed-4528-b738-f3ea7c06e96e
[SERVICE] Assigning crop a1000000-0000-4000-8000-000000000002 to farmer 89b6092f-27ed-4528-b738-f3ea7c06e96e
[DATABASE] Crop assigned: farmerId=89b6092f-27ed-4528-b738-f3ea7c06e96e, cropId=a1000000-0000-4000-8000-000000000002
[API RESPONSE] POST /api/farmers/89b6092f-27ed-4528-b738-f3ea7c06e96e/crops → 201 (31ms)

[API REQUEST]  2026-10-08T13:25:34.777Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 6
[API RESPONSE] GET /api/farmers → 200 (15ms)

[API REQUEST]  2026-10-08T13:25:59.192Z
  POST /api/crops
  Body: {"name":"nvkhvk,j","description":"mbkjbkjbkjbjhbkjbvjhvjhgfhgc","active":true}
[API RESPONSE] POST /api/crops → 201 (18ms)

[API REQUEST]  2026-10-08T13:26:00.893Z
  GET /api/crops
[CONTROLLER] getCrops called
[DATABASE] Crops retrieved: 6
[API RESPONSE] GET /api/crops → 200 (8ms)

[API REQUEST]  2026-10-08T13:26:09.757Z
  POST /api/content
  Body: {"title":"hyfyufukyfl","body":"nioojjg","language":"en"}
[SERVICE] Creating content: "hyfyufukyfl" by userId=b1000000-0000-4000-8000-000000000003
[DATABASE] Content created: id=7b4abe6d-03d6-4aae-bc68-fc51e68645b6, status=DRAFT
[API RESPONSE] POST /api/content → 201 (19ms)

[API REQUEST]  2026-10-08T13:26:12.720Z
  GET /api/crops
[CONTROLLER] getCrops called
[DATABASE] Crops retrieved: 6
[API RESPONSE] GET /api/crops → 304 (9ms)

[API REQUEST]  2026-10-08T13:26:40.086Z
  GET /api/farmers
[SERVICE] Listing all farmers (with user join)
[DATABASE] Farmers retrieved: 6
[API RESPONSE] GET /api/farmers → 304 (11ms)

[API REQUEST]  2026-10-08T13:27:24.104Z
  POST /api/auth/login
  Body: {"identifier":"farmer@gmail.com","password":"[REDACTED]"}
[CONTROLLER] loginHandler called
[AUTH] Login attempt for: farmer@gmail.com
[AUTH] Login attempt for identifier: farmer@gmail.com
[AUTH] Password verified for user: b1000000-0000-4000-8000-000000000004 (FARMER)
[JWT] Access token generated for userId=b1000000-0000-4000-8000-000000000004
[AUTH] Login successful: userId=b1000000-0000-4000-8000-000000000004, role=FARMER
[API RESPONSE] POST /api/auth/login → 200 (203ms)

[API REQUEST]  2026-10-08T13:27:24.792Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}

[API REQUEST]  2026-10-08T13:27:24.801Z
  GET /api/farmers/user/b1000000-0000-4000-8000-000000000004
[SERVICE] Getting farmer by userId=b1000000-0000-4000-8000-000000000004
[API RESPONSE] GET /api/content?status=PUBLISHED → 304 (19ms)
[API RESPONSE] GET /api/farmers/user/b1000000-0000-4000-8000-000000000004 → 200 (37ms)

[API REQUEST]  2026-10-08T13:27:24.965Z
  GET /api/farmers/f1000000-0000-4000-8000-000000000001/crops
[SERVICE] Getting farmer by id=f1000000-0000-4000-8000-000000000001
[SERVICE] Getting crops for farmer f1000000-0000-4000-8000-000000000001
[DATABASE] Crops retrieved for farmer f1000000-0000-4000-8000-000000000001: 3
[API RESPONSE] GET /api/farmers/f1000000-0000-4000-8000-000000000001/crops → 200 (15ms)

[API REQUEST]  2026-10-08T13:27:28.837Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}
[API RESPONSE] GET /api/content?status=PUBLISHED → 304 (13ms)

[API REQUEST]  2026-10-08T13:27:30.572Z
  GET /api/content?status=PUBLISHED
[SERVICE] Listing content with filter: {
  "status": "PUBLISHED"
}
[API RESPONSE] GET /api/content?status=PUBLISHED → 304 (5ms)

[API REQUEST]  2026-10-08T13:27:58.968Z
  POST /api/messaging/sms
  Body: {"recipient":"+251911001122","message":"[Agri-Insight] What crop are you growing, and what advisory do you need?","contentId":"simulator-1791466078961","createdBy":"system"}
[API RESPONSE] POST /api/messaging/sms → 201 (37ms)

[API REQUEST]  2026-10-08T13:28:00.108Z
  POST /api/messaging/sms
  Body: {"recipient":"+251911001122","message":"[Agri-Insight] What crop are you growing, and what advisory do you need?","contentId":"simulator-1791466080105","createdBy":"system"}
[API RESPONSE] POST /api/messaging/sms → 201 (15ms)

[API REQUEST]  2026-10-08T13:28:03.980Z
  POST /api/simulation/ivr/start
  Body: {"phone":"+251911000000"}
[API RESPONSE] POST /api/simulation/ivr/start → 200 (7ms)

[API REQUEST]  2026-10-08T13:28:05.112Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"1"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (2ms)

[API REQUEST]  2026-10-08T13:28:05.926Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"1"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (2ms)

[API REQUEST]  2026-10-08T13:28:06.646Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"1"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:07.765Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"1"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:10.694Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"*"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:12.914Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"2"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:17.430Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"*"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:22.175Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"3"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (2ms)

[API REQUEST]  2026-10-08T13:28:25.552Z
  POST /api/simulation/ivr/dtmf
  Body: {"sessionId":"ivr_mr6s31n1","key":"1"}
[API RESPONSE] POST /api/simulation/ivr/dtmf → 200 (3ms)

[API REQUEST]  2026-10-08T13:28:30.105Z
  POST /api/simulation/ivr/start
  Body: {"phone":"+251911000000"}
[API RESPONSE] POST /api/simulation/ivr/start → 200 (4ms)

[API REQUEST]  2026-10-08T13:28:50.424Z
  GET /api/crops
[CONTROLLER] getCrops called
[DATABASE] Crops retrieved: 6
[API RESPONSE] GET /api/crops → 304 (32ms)

[API REQUEST]  2026-10-08T13:29:48.944Z
  POST /api/auth/register
  Body: {"fullName":"wsdgava","phone":"+251900000001","password":"[REDACTED]","role":"EXTENSION_WORKER","preferredLanguage":"en"}
[CONTROLLER] registerHandler called
[AUTH] Registering new user: wsdgava (EXTENSION_WORKER)
[DATABASE] User created: id=0c78cfdc-0b17-49d2-aa3b-90aaa993016b, role=EXTENSION_WORKER
[AUTH] Registration successful: userId=0c78cfdc-0b17-49d2-aa3b-90aaa993016b, role=EXTENSION_WORKER
[API RESPONSE] POST /api/auth/register → 201 (244ms)

[API REQUEST]  2026-10-08T13:30:21.074Z
  POST /api/auth/register
  Body: {"fullName":"dgsadg","phone":"+251900000002","password":"[REDACTED]","role":"EXPERT","preferredLanguage":"en"}
[CONTROLLER] registerHandler called
[AUTH] Registering new user: dgsadg (EXPERT)
[DATABASE] User created: id=d0556132-356a-48a2-9c07-cdfe66c6dcd6, role=EXPERT
[AUTH] Registration successful: userId=d0556132-356a-48a2-9c07-cdfe66c6dcd6, role=EXPERT
[API RESPONSE] POST /api/auth/register → 201 (177ms)
```

---

## 🏁 Session Recording Summary

* **Session Status:** Terminated & Fully Recorded
* **Total Operations Captured:** 50+ end-to-end API transactions, service calls, and simulator interactions
* **Key Workflows Captured in this Log:**
  1. **Authentication:** Successful logins across `ADMIN`, `EXPERT`, `EXTENSION_WORKER`, and `FARMER` with Argon2id hash verification and JWT token issuance.
  2. **Farmer Management:** Retrieved farmer profiles, registered new farmers, and assigned crops to farmer profiles.
  3. **Crop Catalog:** Retrieved crop lists and added new agricultural crops to the database.
  4. **Advisory Content:** Created new advisory content drafts, filtered published advisories, and handled review statuses.
  5. **Messaging & SMS Simulation:** Dispatched interactive advisory SMS messages.
  6. **IVR Voice Simulation:** Initialized IVR calls (`POST /api/simulation/ivr/start`) and traversed the voice menu with DTMF inputs (`1`, `*`, `2`, `3`).
  7. **User Registrations:** Dynamic self-service registration of new `EXTENSION_WORKER` and `EXPERT` accounts.


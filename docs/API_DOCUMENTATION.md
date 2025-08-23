# 🚀 PsyClinicAI API Documentation

## 📋 Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Core Services](#core-services)
4. [AI Services](#ai-services)
5. [Security Services](#security-services)
6. [SaaS Services](#saas-services)
7. [Integration Services](#integration-services)
8. [Error Handling](#error-handling)
9. [Rate Limiting](#rate-limiting)
10. [Examples](#examples)

## 🌟 Overview

PsyClinicAI is a comprehensive mental health platform that provides AI-powered diagnosis, secure patient management, and enterprise-grade SaaS capabilities.

**Base URL**: `https://api.psyclinicai.com/v1`
**API Version**: 1.0.0
**Content Type**: `application/json`

## 🔐 Authentication

### JWT Token Authentication
All API requests require a valid JWT token in the Authorization header.

```http
Authorization: Bearer <your-jwt-token>
```

### Token Refresh
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "your-refresh-token"
}
```

**Response**:
```json
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token",
  "expiresIn": 3600
}
```

## 🏥 Core Services

### Patient Management

#### Get Patient
```http
GET /patients/{patientId}
Authorization: Bearer <token>
```

**Response**:
```json
{
  "id": "patient_001",
  "name": "John Doe",
  "dateOfBirth": "1990-01-01",
  "email": "john.doe@email.com",
  "phone": "+1234567890",
  "diagnosis": "Depression",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Create Patient
```http
POST /patients
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Smith",
  "dateOfBirth": "1985-05-15",
  "email": "jane.smith@email.com",
  "phone": "+1234567891",
  "diagnosis": "Anxiety"
}
```

#### Update Patient
```http
PUT /patients/{patientId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "diagnosis": "Depression and Anxiety",
  "notes": "Patient showing improvement"
}
```

### Session Management

#### Create Session
```http
POST /sessions
Authorization: Bearer <token>
Content-Type: application/json

{
  "patientId": "patient_001",
  "clinicianId": "clinician_001",
  "sessionType": "therapy",
  "duration": 60,
  "notes": "Initial assessment session"
}
```

#### Get Session History
```http
GET /patients/{patientId}/sessions
Authorization: Bearer <token>
Query Parameters:
- page: 1
- limit: 20
- startDate: 2024-01-01
- endDate: 2024-12-31
```

## 🧠 AI Services

### AI Diagnosis

#### Generate AI Diagnosis
```http
POST /ai/diagnosis
Authorization: Bearer <token>
Content-Type: application/json

{
  "patientId": "patient_001",
  "symptoms": [
    {
      "symptomId": "symptom_001",
      "severity": 8,
      "duration": "2 weeks"
    }
  ],
  "patientHistory": "Previous diagnosis of mild depression",
  "requestType": "initial_assessment"
}
```

**Response**:
```json
{
  "diagnosisId": "diag_001",
  "primaryDiagnosis": "Major Depressive Disorder",
  "confidence": 0.85,
  "alternativeDiagnoses": [
    "Persistent Depressive Disorder",
    "Adjustment Disorder"
  ],
  "recommendedTreatments": [
    "Cognitive Behavioral Therapy",
    "SSRI Medication",
    "Lifestyle Changes"
  ],
  "riskLevel": "moderate",
  "generatedAt": "2024-01-01T00:00:00Z"
}
```

### Voice Analysis

#### Analyze Voice
```http
POST /ai/voice/analyze
Authorization: Bearer <token>
Content-Type: multipart/form-data

{
  "audioFile": <audio_file>,
  "patientId": "patient_001",
  "analysisType": "emotion_stress",
  "metadata": {
    "recordingDuration": 30,
    "quality": "high"
  }
}
```

**Response**:
```json
{
  "analysisId": "voice_001",
  "emotions": {
    "sadness": 0.7,
    "anxiety": 0.4,
    "anger": 0.1,
    "happiness": 0.2
  },
  "stressLevel": 0.6,
  "speechPatterns": {
    "pace": "slow",
    "clarity": "clear",
    "volume": "low"
  },
  "riskIndicators": ["high_sadness", "low_volume"],
  "recommendations": [
    "Consider immediate follow-up",
    "Monitor for suicidal ideation"
  ]
}
```

### Facial Analysis

#### Analyze Facial Expressions
```http
POST /ai/facial/analyze
Authorization: Bearer <token>
Content-Type: multipart/form-data

{
  "imageFile": <image_file>,
  "patientId": "patient_001",
  "analysisType": "emotion_microexpressions",
  "metadata": {
    "imageQuality": "high",
    "lighting": "good"
  }
}
```

**Response**:
```json
{
  "analysisId": "facial_001",
  "primaryEmotion": "sadness",
  "emotionConfidence": 0.82,
  "microexpressions": [
    {
      "type": "sadness",
      "intensity": 0.7,
      "duration": "2.5s"
    }
  ],
  "stressIndicators": {
    "eyeMovement": "rapid",
    "facialTension": "high",
    "blinkRate": "increased"
  },
  "recommendations": [
    "Assess current emotional state",
    "Consider crisis intervention if needed"
  ]
}
```

### Predictive Analytics

#### Generate Predictions
```http
POST /ai/predictions
Authorization: Bearer <token>
Content-Type: application/json

{
  "patientId": "patient_001",
  "predictionType": "treatment_outcome",
  "modelId": "depression_outcome_v1",
  "inputData": {
    "currentSymptoms": ["sadness", "fatigue"],
    "treatmentHistory": ["CBT", "SSRI"],
    "complianceRate": 0.8
  }
}
```

**Response**:
```json
{
  "predictionId": "pred_001",
  "predictionType": "treatment_outcome",
  "predictedOutcome": "significant_improvement",
  "confidence": 0.78,
  "timeframe": "3-6 months",
  "factors": [
    "high_compliance",
    "early_intervention",
    "strong_support_system"
  ],
  "recommendations": [
    "Continue current treatment plan",
    "Increase therapy frequency",
    "Monitor for side effects"
  ]
}
```

## 🔐 Security Services

### Encryption

#### Encrypt Data
```http
POST /security/encrypt
Authorization: Bearer <token>
Content-Type: application/json

{
  "data": "sensitive patient information",
  "encryptionLevel": "high",
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

**Response**:
```json
{
  "encryptedData": "encrypted_string_here",
  "encryptionKey": "key_id_001",
  "algorithm": "AES-256",
  "encryptedAt": "2024-01-01T00:00:00Z"
}
```

#### Decrypt Data
```http
POST /security/decrypt
Authorization: Bearer <token>
Content-Type: application/json

{
  "encryptedData": "encrypted_string_here",
  "encryptionKey": "key_id_001"
}
```

### Audit Logging

#### Get Audit Logs
```http
GET /security/audit-logs
Authorization: Bearer <token>
Query Parameters:
- userId: user_001
- action: data_access
- startDate: 2024-01-01
- endDate: 2024-12-31
- page: 1
- limit: 50
```

**Response**:
```json
{
  "logs": [
    {
      "id": "log_001",
      "userId": "user_001",
      "action": "data_access",
      "resource": "patient_001",
      "timestamp": "2024-01-01T00:00:00Z",
      "ipAddress": "192.168.1.1",
      "userAgent": "Mozilla/5.0...",
      "success": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "pages": 3
  }
}
```

## 💳 SaaS Services

### Tenant Management

#### Get Tenant Info
```http
GET /saas/tenant
Authorization: Bearer <token>
```

**Response**:
```json
{
  "id": "tenant_001",
  "name": "Mental Health Clinic",
  "domain": "clinic.psyclinicai.com",
  "plan": "enterprise",
  "status": "active",
  "subscriptionEndsAt": "2025-01-01T00:00:00Z",
  "features": [
    "ai_diagnosis",
    "voice_analysis",
    "facial_analysis",
    "predictive_analytics"
  ]
}
```

#### Update Tenant Settings
```http
PUT /saas/tenant/settings
Authorization: Bearer <token>
Content-Type: application/json

{
  "featureFlags": {
    "advanced_ai": true,
    "biometric_auth": true,
    "offline_mode": false
  },
  "securitySettings": {
    "mfaRequired": true,
    "sessionTimeout": 3600
  }
}
```

### Usage Analytics

#### Get Usage Metrics
```http
GET /saas/usage
Authorization: Bearer <token>
Query Parameters:
- period: monthly
- startDate: 2024-01-01
- endDate: 2024-12-31
```

**Response**:
```json
{
  "period": "monthly",
  "aiRequests": {
    "total": 1250,
    "diagnosis": 450,
    "voiceAnalysis": 300,
    "facialAnalysis": 200,
    "predictions": 300
  },
  "storageUsage": {
    "totalMB": 2048,
    "patients": 1024,
    "sessions": 512,
    "aiData": 512
  },
  "activeUsers": 45,
  "sessionCount": 180
}
```

### Billing

#### Get Billing History
```http
GET /saas/billing/history
Authorization: Bearer <token>
Query Parameters:
- page: 1
- limit: 20
```

**Response**:
```json
{
  "invoices": [
    {
      "id": "inv_001",
      "amount": 299.99,
      "currency": "USD",
      "status": "paid",
      "dueDate": "2024-01-15T00:00:00Z",
      "paidAt": "2024-01-10T00:00:00Z",
      "items": [
        {
          "description": "Enterprise Plan",
          "amount": 299.99,
          "quantity": 1
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 12,
    "pages": 1
  }
}
```

## 🔗 Integration Services

### FHIR Integration

#### Search FHIR Resources
```http
GET /fhir/patients
Authorization: Bearer <token>
Query Parameters:
- name: John
- birthDate: 1990-01-01
- identifier: patient_001
```

**Response**:
```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 1,
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "id": "patient_001",
        "identifier": [
          {
            "system": "https://psyclinicai.com/patients",
            "value": "patient_001"
          }
        ],
        "name": [
          {
            "use": "official",
            "text": "John Doe"
          }
        ],
        "birthDate": "1990-01-01"
      }
    }
  ]
}
```

#### Create FHIR Resource
```http
POST /fhir/observations
Authorization: Bearer <token>
Content-Type: application/fhir+json

{
  "resourceType": "Observation",
  "status": "final",
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "PHQ-9",
        "display": "PHQ-9 Depression Screening"
      }
    ]
  },
  "subject": {
    "reference": "Patient/patient_001"
  },
  "valueInteger": 15,
  "interpretation": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
        "code": "H",
        "display": "High"
      }
    ]
  }
}
```

## ❌ Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ],
    "timestamp": "2024-01-01T00:00:00Z",
    "requestId": "req_001"
  }
}
```

### Common Error Codes
- `AUTHENTICATION_FAILED`: Invalid or expired token
- `AUTHORIZATION_DENIED`: Insufficient permissions
- `VALIDATION_ERROR`: Invalid input data
- `RESOURCE_NOT_FOUND`: Requested resource doesn't exist
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `INTERNAL_SERVER_ERROR`: Server-side error

## 🚦 Rate Limiting

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

### Rate Limits by Plan
- **Starter**: 100 requests/hour
- **Professional**: 1000 requests/hour
- **Enterprise**: 10000 requests/hour

## 📝 Examples

### Complete Patient Workflow

#### 1. Create Patient
```bash
curl -X POST https://api.psyclinicai.com/v1/patients \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "dateOfBirth": "1990-01-01",
    "email": "john.doe@email.com"
  }'
```

#### 2. Generate AI Diagnosis
```bash
curl -X POST https://api.psyclinicai.com/v1/ai/diagnosis \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient_001",
    "symptoms": [
      {
        "symptomId": "symptom_001",
        "severity": 8
      }
    ]
  }'
```

#### 3. Create Session
```bash
curl -X POST https://api.psyclinicai.com/v1/sessions \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient_001",
    "clinicianId": "clinician_001",
    "sessionType": "therapy"
  }'
```

### Python SDK Example
```python
import requests

class PsyClinicAI:
    def __init__(self, api_key, base_url="https://api.psyclinicai.com/v1"):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def create_patient(self, patient_data):
        response = requests.post(
            f"{self.base_url}/patients",
            headers=self.headers,
            json=patient_data
        )
        return response.json()
    
    def generate_diagnosis(self, patient_id, symptoms):
        response = requests.post(
            f"{self.base_url}/ai/diagnosis",
            headers=self.headers,
            json={
                "patientId": patient_id,
                "symptoms": symptoms
            }
        )
        return response.json()

# Usage
client = PsyClinicAI("your-api-key")
patient = client.create_patient({
    "name": "John Doe",
    "email": "john@example.com"
})
diagnosis = client.generate_diagnosis(patient["id"], [
    {"symptomId": "symptom_001", "severity": 8}
])
```

### JavaScript SDK Example
```javascript
class PsyClinicAI {
    constructor(apiKey, baseUrl = 'https://api.psyclinicai.com/v1') {
        this.apiKey = apiKey;
        this.baseUrl = baseUrl;
        this.headers = {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json'
        };
    }
    
    async createPatient(patientData) {
        const response = await fetch(`${this.baseUrl}/patients`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify(patientData)
        });
        return response.json();
    }
    
    async generateDiagnosis(patientId, symptoms) {
        const response = await fetch(`${this.baseUrl}/ai/diagnosis`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify({
                patientId,
                symptoms
            })
        });
        return response.json();
    }
}

// Usage
const client = new PsyClinicAI('your-api-key');
client.createPatient({
    name: 'John Doe',
    email: 'john@example.com'
}).then(patient => {
    return client.generateDiagnosis(patient.id, [
        { symptomId: 'symptom_001', severity: 8 }
    ]);
}).then(diagnosis => {
    console.log('Diagnosis:', diagnosis);
});
```

## 📞 Support

For API support and questions:
- **Email**: api-support@psyclinicai.com
- **Documentation**: https://docs.psyclinicai.com
- **Status Page**: https://status.psyclinicai.com
- **Developer Community**: https://community.psyclinicai.com

---

**Last Updated**: January 2024
**API Version**: 1.0.0
**Maintained by**: PsyClinicAI Development Team

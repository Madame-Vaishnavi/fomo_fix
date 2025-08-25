# Complete API Documentation - Event Project

## Overview
This document contains all the API endpoints available across the entire Event Project microservices architecture. The project consists of multiple services that communicate through an API Gateway.

## Architecture
- **API Gateway** (Port: 8080) - Entry point for all API requests
- **Eureka Server** (Port: 8761) - Service discovery
- **Event Service** (Port: 8084) - Manages events and categories
- **Booking Service** (Port: 8081) - Handles event bookings
- **Payment Service** (Port: 8082) - Processes payments
- **Notification Service** (Port: 8083) - Sends notifications (Kafka-based)
- **User Service** (Port: 8085) - Registration, login (JWT), and user profile

## Base URLs
- **API Gateway**: `http://localhost:8080`
- **Direct Service Access**:
  - Event Service: `http://localhost:8084`
  - Booking Service: `http://localhost:8081`
  - Payment Service: `http://localhost:8082`
  - Notification Service: `http://localhost:8083`
  - User Service: `http://localhost:8085`

---

## Authentication via API Gateway

- All endpoints under `/api/**` require a JWT in `Authorization: Bearer <TOKEN>` when accessed through the API Gateway, except:
  - `POST /api/users/register`
  - `POST /api/users/login`
  These two are publicly accessible to obtain a token.

---

## 1. Event Service API (`/api/events`)

### 1.1 Get All Event Categories
**GET** `/api/events/categories`

Returns a list of all available event category display names.

**Response:**
```json
[
    "Concert",
    "Theater", 
    "Sports",
    "Comedy",
    "Other"
]
```

### 1.2 Create Event
**POST** `/api/events`

Creates a new event with category and seat information.

**Request Body:**
```json
{
    "name": "Rock Concert 2024",
    "description": "Amazing rock concert featuring top artists",
    "location": "Madison Square Garden",
    "date": "2024-06-15T19:00:00",
    "category": "CONCERT",
    "seatCategories": [
        {
            "categoryName": "VIP",
            "totalSeats": 100,
            "pricePerSeat": 150.0
        },
        {
            "categoryName": "General",
            "totalSeats": 500,
            "pricePerSeat": 75.0
        }
    ]
}
```

**Response:**
```json
{
    "id": 1,
    "name": "Rock Concert 2024",
    "description": "Amazing rock concert featuring top artists",
    "location": "Madison Square Garden",
    "date": "2024-06-15T19:00:00",
    "category": "CONCERT",
    "seatCategories": [
        {
            "categoryName": "VIP",
            "totalSeats": 100,
            "availableSeats": 100,
            "pricePerSeat": 150.0
        }
    ]
}
```

### 1.3 Get Event by ID
**GET** `/api/events/{id}`

Retrieves a specific event by its ID.

**Response:**
```json
{
    "id": 1,
    "name": "Rock Concert 2024",
    "description": "Amazing rock concert featuring top artists",
    "location": "Madison Square Garden",
    "date": "2024-06-15T19:00:00",
    "category": "CONCERT",
    "seatCategories": [
        {
            "categoryName": "VIP",
            "totalSeats": 100,
            "availableSeats": 95,
            "pricePerSeat": 150.0
        }
    ]
}
```

### 1.4 Get All Events
**GET** `/api/events`

Retrieves all events in the system.

**Response:**
```json
[
    {
        "id": 1,
        "name": "Rock Concert 2024",
        "description": "Amazing rock concert featuring top artists",
        "location": "Madison Square Garden",
        "date": "2024-06-15T19:00:00",
        "category": "CONCERT",
        "seatCategories": [...]
    }
]
```

### 1.5 Get Events by Category
**GET** `/api/events/category/{category}`

Retrieves all events in a specific category.

**Example:** `GET /api/events/category/CONCERT`

**Response:**
```json
[
    {
        "id": 1,
        "name": "Rock Concert 2024",
        "description": "Amazing rock concert featuring top artists",
        "location": "Madison Square Garden",
        "date": "2024-06-15T19:00:00",
        "category": "CONCERT",
        "seatCategories": [...]
    }
]
```

### 1.6 Update Event
**PUT** `/api/events/{id}`

Updates an existing event.

**Request Body:** (Same as create event)
```json
{
    "name": "Updated Rock Concert 2024",
    "description": "Updated description",
    "location": "Updated Location",
    "date": "2024-06-15T19:00:00",
    "category": "CONCERT",
    "seatCategories": [...]
}
```

### 1.7 Delete Event
**DELETE** `/api/events/{id}`

Deletes an event by ID.

**Response:** `204 No Content`

---

## 2. Booking Service API (`/api/bookings`)

### 2.1 Create Booking
**POST** `/api/bookings`

Creates a new booking for an event.

**Request Body:**
```json
{
    "eventId": 1,
    "userEmail": "user@example.com",
    "categoryName": "VIP",
    "seatsBooked": 2
}
```

**Response:**
```json
{
    "bookingId": 1,
    "eventId": 1,
    "eventName": "Rock Concert 2024",
    "categoryName": "VIP",
    "seatsBooked": 2,
    "totalPrice": 300.0,
    "userEmail": "user@example.com",
    "bookingTime": "2024-01-15T10:30:00",
    "status": "CONFIRMED"
}
```

### 2.2 Get Booking by ID
**GET** `/api/bookings/{id}`

Retrieves a specific booking by its ID.

**Response:**
```json
{
    "bookingId": 1,
    "eventId": 1,
    "eventName": "Rock Concert 2024",
    "categoryName": "VIP",
    "seatsBooked": 2,
    "totalPrice": 300.0,
    "userEmail": "user@example.com",
    "bookingTime": "2024-01-15T10:30:00",
    "status": "CONFIRMED"
}
```

### 2.3 Get Bookings by User
**GET** `/api/bookings/user/{email}`

Retrieves all bookings for a specific user.

**Response:**
```json
[
    {
        "bookingId": 1,
        "eventId": 1,
        "eventName": "Rock Concert 2024",
        "categoryName": "VIP",
        "seatsBooked": 2,
        "totalPrice": 300.0,
        "userEmail": "user@example.com",
        "bookingTime": "2024-01-15T10:30:00",
        "status": "CONFIRMED"
    }
]
```

### 2.4 Get Bookings by User ID
**GET** `/api/bookings/user-id/{userId}`

Retrieves all bookings for a specific user by user ID.

**Response:**
```json
[
    {
        "bookingId": 1,
        "eventId": 1,
        "eventName": "Rock Concert 2024",
        "categoryName": "VIP",
        "seatsBooked": 2,
        "totalPrice": 300.0,
        "userEmail": "user@example.com",
        "bookingTime": "2024-01-15T10:30:00",
        "status": "CONFIRMED"
    }
]
```

### 2.5 Get Bookings by Event
**GET** `/api/bookings/event/{eventId}`

Retrieves all bookings for a specific event.

**Response:**
```json
[
    {
        "bookingId": 1,
        "eventId": 1,
        "eventName": "Rock Concert 2024",
        "categoryName": "VIP",
        "seatsBooked": 2,
        "totalPrice": 300.0,
        "userEmail": "user@example.com",
        "bookingTime": "2024-01-15T10:30:00",
        "status": "CONFIRMED"
    }
]
```

### 2.6 Delete Booking
**DELETE** `/api/bookings/{id}`

Deletes a booking by ID.

**Response:** `204 No Content`

---

## 3. Payment Service API (`/api/payments`)

### 3.1 Process Payment
**POST** `/api/payments/process`

Processes a payment for a booking.

**Request Body:**
```json
{
    "bookingId": 1,
    "userEmail": "user@example.com",
    "amount": 300.0,
    "paymentMode": "CREDIT_CARD",
    "cardNumber": "1234567890123456",
    "expiryDate": "12/25",
    "cvv": "123"
}
```

**Response:**
```json
{
    "paymentId": 1,
    "bookingId": 1,
    "userEmail": "user@example.com",
    "amount": 300.0,
    "paymentMode": "CREDIT_CARD",
    "status": "SUCCESS",
    "transactionId": "TXN123456789",
    "paymentTime": "2024-01-15T10:35:00"
}
```

### 3.2 Get Payment by ID
**GET** `/api/payments/{paymentId}`

Retrieves a specific payment by its ID.

**Response:**
```json
{
    "paymentId": 1,
    "bookingId": 1,
    "userEmail": "user@example.com",
    "amount": 300.0,
    "paymentMode": "CREDIT_CARD",
    "status": "SUCCESS",
    "transactionId": "TXN123456789",
    "paymentTime": "2024-01-15T10:35:00"
}
```

### 3.3 Get Payment by Booking
**GET** `/api/payments/booking/{bookingId}`

Retrieves payment information for a specific booking.

**Response:**
```json
{
    "paymentId": 1,
    "bookingId": 1,
    "userEmail": "user@example.com",
    "amount": 300.0,
    "paymentMode": "CREDIT_CARD",
    "status": "SUCCESS",
    "transactionId": "TXN123456789",
    "paymentTime": "2024-01-15T10:35:00"
}
```

### 3.4 Get Payments by User
**GET** `/api/payments/user/{userEmail}`

Retrieves all payments for a specific user.

**Response:**
```json
[
    {
        "paymentId": 1,
        "bookingId": 1,
        "userEmail": "user@example.com",
        "amount": 300.0,
        "paymentMode": "CREDIT_CARD",
        "status": "SUCCESS",
        "transactionId": "TXN123456789",
        "paymentTime": "2024-01-15T10:35:00"
    }
]
```

---

## 4. User Service API (`/api/users`)

### 4.1 Register
**POST** `/api/users/register`

Registers a new user.

**Request Body:**
```json
{
  "username": "john",
  "email": "john@example.com",
  "password": "Pass@123"
}
```

**Response:**
```json
"User registered successfully!"
```

### 4.2 Login
**POST** `/api/users/login`

Authenticates the user and returns a JWT token string.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "Pass@123"
}
```

**Response:**
```json
"<JWT_TOKEN>"
```

### 4.3 Get Profile
**GET** `/api/users/profile`

Requires `Authorization: Bearer <TOKEN>` header. Returns the authenticated user's profile.

**Response:**
```json
{
  "id": 1,
  "email": "john@example.com",
  "username": "john",
  "role": "ROLE_USER"
}
```

---

## 5. Notification Service

The Notification Service operates through Kafka events and doesn't expose REST endpoints directly. It automatically sends notifications when:

- A booking is created (topic: `booking-created`)
- A payment is processed (topic: `payment-events`)

### Notification Types
1. **Booking Confirmation** - Sent when a booking is successfully created
2. **Payment Status** - Sent when payment processing is completed

---

## 6. Error Responses

### Common Error Format
```json
{
    "timestamp": "2024-01-15T10:30:00",
    "status": 400,
    "error": "Bad Request",
    "message": "Invalid category: INVALID_CATEGORY"
}
```

### Common HTTP Status Codes
- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `204 No Content` - Request successful, no content to return
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## 7. Data Models

### Event Categories
- `CONCERT` - Musical performances
- `THEATER` - Theater productions
- `SPORTS` - Sporting events
- `CONFERENCE` - Business conferences
- `WORKSHOP` - Educational workshops
- `EXHIBITION` - Art and trade exhibitions
- `FESTIVAL` - Cultural festivals
- `COMEDY` - Comedy shows
- `DANCE` - Dance performances
- `MOVIE` - Movie screenings
- `OTHER` - Other events

### Payment Modes
- `CREDIT_CARD` - Credit card payments
- `DEBIT_CARD` - Debit card payments
- `BANK_TRANSFER` - Bank transfer
- `CASH` - Cash payment

### Booking Status
- `CONFIRMED` - Booking confirmed
- `PENDING` - Booking pending
- `CANCELLED` - Booking cancelled

### Payment Status
- `SUCCESS` - Payment successful
- `FAILED` - Payment failed
- `PENDING` - Payment pending
- `CANCELLED` - Payment cancelled

---

## 8. Usage Examples

### Complete Booking Flow

1. (Optional) **Register**
```bash
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "email": "john@example.com",
    "password": "Pass@123"
  }'
```

2. **Login** (get JWT token)
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "Pass@123"
  }' | tr -d '"')
```

3. **Get Event Categories**
```bash
curl http://localhost:8080/api/events/categories \
  -H "Authorization: Bearer $TOKEN"
```

4. **Create Event**
```bash
curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Jazz Night",
    "description": "Smooth jazz evening",
    "location": "Blue Note Club",
    "date": "2024-02-15T20:00:00",
    "category": "CONCERT",
    "seatCategories": [
      {
        "categoryName": "Premium",
        "totalSeats": 50,
        "pricePerSeat": 100.0
      }
    ]
  }'
```

5. **Create Booking**
```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "eventId": 1,
    "userEmail": "user@example.com",
    "categoryName": "Premium",
    "seatsBooked": 2
  }'
```

6. **Process Payment**
```bash
curl -X POST http://localhost:8080/api/payments/process \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "bookingId": 1,
    "userEmail": "user@example.com",
    "amount": 200.0,
    "paymentMode": "CREDIT_CARD",
    "cardNumber": "1234567890123456",
    "expiryDate": "12/25",
    "cvv": "123"
  }'
```

---

## 9. Service Dependencies

### Internal Service Communication
- **Booking Service** → **Event Service** (via Feign Client)
  - Gets event details when creating bookings
- **Payment Service** → **Booking Service** (via Kafka events)
  - Receives booking events for payment processing
- **Notification Service** → **All Services** (via Kafka events)
  - Receives events for sending notifications

### External Dependencies
- **PostgreSQL** - Database for all services
- **Kafka** - Message broker for event-driven communication
- **Eureka** - Service discovery
- **SMTP** - Email notifications (Gmail)

---

## 10. Deployment

### Prerequisites
1. Java 17+
2. Maven 3.6+
3. PostgreSQL
4. Apache Kafka
5. Eureka Server

### Startup Order
1. Start Eureka Server
2. Start PostgreSQL and Kafka
3. Start Event Service
4. Start Booking Service
5. Start Payment Service
6. Start Notification Service
7. Start API Gateway

### Health Checks
- Eureka Server: `http://localhost:8761`
- API Gateway: `http://localhost:8080/actuator/health`
- Event Service: `http://localhost:8084/actuator/health`
- Booking Service: `http://localhost:8081/actuator/health`
- Payment Service: `http://localhost:8082/actuator/health`
- Notification Service: `http://localhost:8083/actuator/health`
- User Service: `http://localhost:8085/actuator/health`


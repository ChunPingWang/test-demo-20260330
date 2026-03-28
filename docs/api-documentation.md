# Customer Management API Documentation

Base URL: `http://localhost:8080`

## API List

| # | Method | Path | Description | Request Body | Response Body | Status Code |
|---|--------|------|-------------|--------------|---------------|-------------|
| 1 | GET | `/api/customers` | Get all customers | None | [{id, name, email, phone, address, createdAt, updatedAt}] | 200 OK |
| 2 | GET | `/api/customers/{id}` | Get customer by ID | None | {id, name, email, phone, address, createdAt, updatedAt} | 200 OK |
| 3 | POST | `/api/customers` | Create a new customer | {name*, email*, phone, address} | {id, name, email, phone, address, createdAt, updatedAt} | 201 Created |
| 4 | PUT | `/api/customers/{id}` | Update customer by ID | {name*, email*, phone, address} | {id, name, email, phone, address, createdAt, updatedAt} | 200 OK |
| 5 | DELETE | `/api/customers/{id}` | Delete customer by ID | None | None | 204 No Content |

## Data Model

### Customer

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | Long | Auto | Primary key |
| name | String(50) | Yes | Customer name |
| email | String(100) | Yes | Email (unique) |
| phone | String(20) | No | Phone number |
| address | String(200) | No | Address |
| createdAt | DateTime | Auto | Creation time |
| updatedAt | DateTime | Auto | Last update time |

## Example

### Create Customer

```json
POST /api/customers
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0912345678",
  "address": "Taipei, Taiwan"
}
```

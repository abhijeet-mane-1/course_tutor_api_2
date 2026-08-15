# Course & Tutor API

A Rails API-only application for managing courses and their tutors.

A **Course can have many Tutors**, while a **Tutor belongs to exactly one Course**.

---

## Features

- API-only Ruby on Rails application
- RESTful API endpoints
- Course and Tutor management
- Create a Course with multiple Tutors in a single request
- List Courses with their associated Tutors
- Centralized API error handling
- RSpec request and model tests
- Shoulda Matchers for model specifications

---

## Tech Stack

| Technology | Version / Usage |
|---|---|
| Ruby | 4.0.5 |
| Rails | 8.1.3 |
| PostgreSQL | 18.4 |
| RSpec | 8.0.4 |
| Bundler | 4.0.10 |
| Git | 2.51.0 |
| API Format | JSON |
| Database | PostgreSQL |

---


# Requirements

Make sure the following are installed:

- Ruby 4.0.5
- Rails 8.1.3
- PostgreSQL 18+
- Bundler
- Git

Verify the installation:

```bash
ruby -v
rails -v
bundle -v
psql --version
git --version
```
---

# Setup

Install dependencies
```bash
bundle install
```

Configure the database
- Copy the example database configuration:
```bash
cp config/database.yml.example config/database.yml
```

Create databases
```bash
bin/rails db:create
```

Run migrations
```bash
bin/rails db:migrate
```

Run the test suite
```bash
bundle exec rspec
```

Start the rails server
```bash
bin/rails server
```

---

## API Endpoints

### 1. Create Course with Tutors

```http
POST /api/v1/courses
Content-Type: application/json
```

#### Request

```json
{
  "course": {
    "title": "Ruby on Rails",
    "description": "Advanced Ruby on Rails course",
    "tutors_attributes": [
      {
        "name": "John Doe",
        "email": "john@example.com"
      },
      {
        "name": "Jane Doe",
        "email": "jane@example.com"
      }
    ]
  }
}
```

#### Successful Response

**HTTP 201 Created**

```json
{
  "id": 1,
  "title": "Ruby on Rails",
  "description": "Advanced Ruby on Rails course",
  "tutors": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Doe",
      "email": "jane@example.com"
    }
  ]
}
```

The application uses Rails nested attributes to create the course and its tutors in a single operation.

## 2. List Courses with Tutors

```http
GET /api/v1/courses
```

#### Successful Response

**HTTP 200 OK**

```json
[
  {
    "id": 1,
    "title": "Ruby on Rails",
    "description": "Advanced Ruby on Rails course",
    "tutors": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      },
      {
        "id": 2,
        "name": "Jane Doe",
        "email": "jane@example.com"
      }
    ]
  }
]
```

If there are no courses:

```json
[]
```

## JSON Responses

Jbuilder is used to generate API responses.

The common course representation is extracted into a Jbuilder partial:

```text
app/views/api/v1/courses/_course.json.jbuilder
```

Both `index.json.jbuilder` and `show.json.jbuilder` reuse this partial to avoid duplicating the course/tutor JSON representation.

## Error Handling

Validation failures return:

**HTTP 422 Unprocessable Content**

Example:

```json
{
  "errors": [
    "Title can't be blank"
  ]
}
```

Missing required request parameters return:

**HTTP 400 Bad Request**

Example:

```json
{
  "errors": [
    "param is missing or the value is empty or invalid: course"
  ]
}
```

The controller handles:

* `ActiveRecord::RecordInvalid`
* `ActionController::ParameterMissing`

---


## Data Validation

### Course

* `title` is required.

### Tutor

* `name` is required.
* `email` is required.
* `email` must be unique.
* `course` is required.

Validation is implemented at the Rails model level, while important data integrity rules are also enforced at the database level.

## Database Design

### Course

| Column      | Type     | Constraints |
| ----------- | -------- | ----------- |
| id          | bigint   | Primary key |
| title       | string   | Not null    |
| description | text     | Nullable    |
| created_at  | datetime | Not null    |
| updated_at  | datetime | Not null    |

### Tutor

| Column     | Type     | Constraints           |
| ---------- | -------- | --------------------- |
| id         | bigint   | Primary key           |
| course_id  | bigint   | Not null, foreign key |
| name       | string   | Not null              |
| email      | string   | Not null, unique      |
| created_at | datetime | Not null              |
| updated_at | datetime | Not null              |

### Associations

```ruby
Course
  has_many :tutors, dependent: :destroy

Tutor
  belongs_to :course
```

A database foreign key is used for `tutors.course_id`, and indexes are added for efficient lookups and data integrity.

Tutor email has a unique database index in addition to model-level uniqueness validation.


## Project Structure

```text
app/
├── controllers/
│   └── api/
│       └── v1/
│           └── courses_controller.rb
│
├── models/
│   ├── course.rb
│   └── tutor.rb
│
└── views/
    └── api/
        └── v1/
            └── courses/
                ├── _course.json.jbuilder
                ├── index.json.jbuilder
                └── show.json.jbuilder

spec/
├── factories/
│   ├── courses.rb
│   └── tutors.rb
│
├── models/
│   ├── course_spec.rb
│   └── tutor_spec.rb
│
└── requests/
    └── api/
        └── v1/
            └── courses_spec.rb
```

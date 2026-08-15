require "rails_helper"

RSpec.describe "Courses API", type: :request do
  describe "GET /api/v1/courses" do
    it "returns all courses with their tutors" do
      course1 = create(:course)
      course2 = create(:course, title: "React", description: "React fundamentals")

      tutor1 = create(:tutor, course: course1, name: "John Doe", email: "john@example.com")
      tutor2 = create(:tutor, course: course1, name: "Jane Doe", email: "jane@example.com")
      tutor3 = create(:tutor, course: course2, name: "Alice Smith", email: "alice@example.com")

      get "/api/v1/courses"

      expect(response).to have_http_status(:ok)

      body = response.parsed_body

      expect(body.size).to eq(2)

      first_course = body.find { |course| course["id"] == course1.id }
      second_course = body.find { |course| course["id"] == course2.id }

      expect(first_course).to include(
        "id" => course1.id,
        "title" => "Ruby on Rails",
        "description" => "Advanced Ruby on Rails course"
      )

      expect(first_course["tutors"]).to contain_exactly(
        { "id" => tutor1.id, "name" => "John Doe", "email" => "john@example.com" },
        { "id" => tutor2.id, "name" => "Jane Doe", "email" => "jane@example.com" }
      )

      expect(second_course).to include(
        "id" => course2.id,
        "title" => "React",
        "description" => "React fundamentals"
      )

      expect(second_course["tutors"]).to contain_exactly(
        { "id" => tutor3.id, "name" => "Alice Smith", "email" => "alice@example.com" }
      )
    end

    it "returns an empty array when there are no courses" do
      get "/api/v1/courses"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end

  describe "POST /api/v1/courses" do
    let(:params) do
      {
        course: {
          title: "Ruby on Rails",
          description: "Advanced Ruby on Rails course",
          tutors_attributes: [
            { name: "John Doe", email: "john@example.com" },
            { name: "Jane Doe", email: "jane@example.com" }
          ]
        }
      }
    end

    context "with valid parameters" do
      it "creates a course with its tutors" do
        expect { post "/api/v1/courses", params: params, as: :json }
          .to change(Course, :count).by(1)
          .and change(Tutor, :count).by(2)

        expect(response).to have_http_status(:created)

        body = response.parsed_body

        expect(body["title"]).to eq("Ruby on Rails")
        expect(body["description"]).to eq("Advanced Ruby on Rails course")

        expect(body["tutors"].map { |tutor| tutor["name"] }).to contain_exactly(
          "John Doe",
          "Jane Doe"
        )
      end
    end

    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        params[:course][:title] = nil

        expect { post "/api/v1/courses", params: params, as: :json }
          .not_to change(Course, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("Title can't be blank")
      end

      it "returns validation errors when tutor name is missing" do
        params[:course][:tutors_attributes][0][:name] = nil

        expect { post "/api/v1/courses", params: params, as: :json }
          .not_to change(Course, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("Tutors name can't be blank")
      end

      it "returns validation errors when tutor email is missing" do
        params[:course][:tutors_attributes][0][:email] = nil

        expect { post "/api/v1/courses", params: params, as: :json }
          .not_to change(Course, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("Tutors email can't be blank")
      end

      it "returns validation errors when tutor email already exists" do
        create(:tutor, email: "john@example.com")

        expect { post "/api/v1/courses", params: params, as: :json }
          .not_to change(Course, :count)

        expect(Tutor.count).to eq(1)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("Tutors email has already been taken")
      end

      it "returns bad request when course parameter is missing" do
        post "/api/v1/courses", params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end
end

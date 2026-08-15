json.id course.id
json.title course.title
json.description course.description

json.tutors course.tutors do |tutor|
  json.id tutor.id
  json.name tutor.name
  json.email tutor.email
end

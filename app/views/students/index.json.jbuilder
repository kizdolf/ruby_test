json.array!(@students) do |student|
  json.extract! student, :id, :uid, :cn, :uidNumber, :picture, :gidNumber, :mail, :firstName, :lastName
  json.url student_url(student, format: :json)
end

class Subject < ActiveResource::Base
  self.site = SUBJECT_URI
  self.user = PREALLOWED_LOGIN
  self.password = PREALLOWED_PASSWORD
end

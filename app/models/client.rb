class Client < ActiveResource::Base
  self.site = CLEANTOGETHER_HOST
  self.user = PREALLOWED_LOGIN
  self.password = PREALLOWED_PASSWORD
end

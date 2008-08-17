class Role < ActiveResource::Base
  self.site = CLIENTS_URI
  self.user = PREALLOWED_LOGIN
  self.password = PREALLOWED_PASSWORD
end

module ApiGuardian
  class PermissionSerializer < ApiGuardian::Serializers::Base
    set_type 'permissions'

    attributes :id, :name, :desc
  end
end

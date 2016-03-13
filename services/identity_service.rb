class IdentityService
    def self.query_parameters identifier, medium, channel
        {
            identifier: identifier,
            medium:     medium,
            channel:    channel
        }.reject { |k, v| v.nil? }
    end
end
module Eleyo
  module API
    class Account
      def self.server_uri
        if Eleyo::API.standardmode?
          "https://acc.reg.eleyo.com"
        elsif Eleyo::API.testmode?
          "https://acc.reg.eleyo.green"
        elsif Eleyo::API.devmode?
          "https://acc.#{HOSTNAME}"
        end
      end

      attr_accessor :auth, :access_token, :api_version

      def initialize(options = {})
        self.auth         = options[:auth]
        self.access_token = options[:access_token]
        self.api_version  = options[:api_version] || 1.2

        raise API::InitializerError.new(:auth_or_access_token, "can't be blank") if self.auth.nil? and self.access_token.nil?
        raise API::InitializerError.new(:auth, "must be of class type Eleyo::API::Auth") if self.auth and !self.auth.is_a?(Eleyo::API::Auth)
        raise API::InitializerError.new(:access_token, "must be of class type Eleyo::API::Auth::AccessToken") if self.access_token and !self.access_token.is_a?(Eleyo::API::Auth::AccessToken)
      end

      def list(params = {})
        request = HTTPI::Request.new
        request.url = "#{api_route}/users"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def get(uuid, params = {})
        uuid = URI.escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def create(params)
        request = HTTPI::Request.new
        request.url = "#{api_route}/users/"
        request.body = params.to_json
        request.headers = self.generate_headers

        response = HTTPI.post(request)

        if response.code == 201
          true
        elsif !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def update(uuid, params)
        uuid = URI.escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.body = params
        request.headers = self.generate_headers

        response = HTTPI.put(request)

        if response.code == 204
          true
        elsif !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def merge(uuid1, uuid2)
        uuid1 = URI.escape(uuid1)
        uuid2 = URI.escape(uuid2)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/merge/#{uuid1}/#{uuid2}"
        request.headers = self.generate_headers

        response = HTTPI.put(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def delete(uuid)
        uuid = URI.escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.headers = self.generate_headers

        response = HTTPI.delete(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def owner(params = {})
        raise API::RequirementError.new(:access_token, "can't be blank") if self.access_token.nil?

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/owner"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def list_user_locks(user_uuid)
        uuid = URI.escape(user_uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{user_uuid}/locks"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def add_user_lock(user_uuid, scope, reason = "")
        uuid = URI.escape(user_uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}/locks"
        request.body = {
          user_lock: {
            scope: scope,
            reason: reason
          }
        }.to_json
        request.headers = self.generate_headers

        response = HTTPI.post(request)

        if response.code == 201
          true
        elsif !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def delete_user_lock(user_uuid, lock_id)
        uuid = URI.escape(user_uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}/locks/#{lock_id}"
        request.headers = self.generate_headers

        response = HTTPI.delete(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      # TODO:: create mapping for relationships api endpoints
      def list_relationships
      end

      def add_relationship
      end

      def update_relationship
      end

      def delete_relationship
      end

      protected

      def api_route
        "#{self.class.server_uri}/api/v#{api_version}"
      end

      def generate_headers
        if self.access_token
          {'User-Agent' => USER_AGENT, 'Authorization' => self.access_token.token, 'Content-Type' => "application/json"}
        else
          {'User-Agent' => USER_AGENT, 'Client-Secret' => self.auth.client_secret, 'Client-Id' => self.auth.client_id, 'Content-Type' => "application/json"}
        end
      end

    end
  end
end

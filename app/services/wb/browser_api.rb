module Wb
  class BrowserApi < ActiveInteraction::Base
    CONNECT_TTL = 5

    # HEADERS = { Authorization: token }.freeze

    private

    def response
      # return true unless Rails.env.production?
      Rails.logger.info(message: "[Browser API] request to: #{base_url + '/' + api_method}, with params: #{base_params.merge(params).to_s}")

      response = if type == :get
                   connection.get(api_method, base_params.merge!(params))
                 elsif type == :post
                   connection.post(api_method) do |request|
                     request.body = params
                     request.options.timeout = CONNECT_TTL
                     request.options.open_timeout = CONNECT_TTL
                   end
                 end

      parsed_body = response.body

      # Rails.logger.debug(message: "[API] Got response. Body: #{parsed_body.to_s}")

      if parsed_body.is_a?(Hash) && parsed_body['errors'].present?
        errors.add(:base, "Response error: method: #{api_method}")
        error_log(parsed_body['errorText'], parsed_body['additionalErrors'])
      end

      parsed_body
    rescue StandardError => e
      errors.add(:base, "Response error: smothing went wrong with api url: #{base_url + api_method} error: #{e}")
      error_log(e, parsed_body = nil)
      # Sentry.capture_exception(e)
    end

    def connection
      @connection ||= Faraday.new(base_url, headers: {}) do |f|
        f.request :json # encode req bodies as JSON and automatically set the Content-Type header
        f.response :json # decode response bodies as JSON
      end
    end

    def error_log(errors, additional_errors = nil)
      Rails.logger.error(message: "[API] Error response",
                         payload: { api_method: api_method,
                                    params: base_params.merge(params),
                                    errors: errors,
                                    additional_errors: additional_errors,
                         })
    end

    def base_url
      raise NotImplementedError, 'Define in subclass'
    end

    def api_method
      raise NotImplementedError, 'Define in subclass'
    end

    def params
      raise NotImplementedError, 'Define in subclass'
    end

    def type
      raise NotImplementedError, 'Define in subclass'
    end

    # def token
    #   raise NotImplementedError, 'Define in subclass'
    # end

    def base_params
      {}
    end
  end
end

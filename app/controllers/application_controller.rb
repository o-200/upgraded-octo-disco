module App
  module Controllers
    class ApplicationController
      def parse_req_body(request)
        JSON.parse(request.body.read, symbolize_names: true)
      end
    end
  end
end

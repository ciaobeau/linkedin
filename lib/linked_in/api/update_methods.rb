module LinkedIn
  module Api

    module UpdateMethods
      
      include Helpers::Request

      def add_share(share)
        path = "/people/~/shares"
        defaults = {:visibility => {:code => "anyone"}}
        post(path, defaults.merge(share).to_json, "Content-Type" => "application/json")
      end

      # def share(options={})
      #   path = "/people/~/shares"
      #   defaults = { :visability => 'anyone' }
      #   post(path, share_to_xml(defaults.merge(options)))
      # end
      #
      # def update_comment(network_key, comment)
      #   path = "/people/~/network/updates/key=#{network_key}/update-comments"
      #   post(path, comment_to_xml(comment))
      # end
      #
      # def update_network(message)
      #   path = "/people/~/person-activities"
      #   post(path, network_update_to_xml(message))
      # end
      #
      # def send_message(subject, body, recipient_paths)
      #   path = "/people/~/mailbox"
      #
      #   message         = LinkedIn::Message.new
      #   message.subject = subject
      #   message.body    = body
      #   recipients      = LinkedIn::Recipients.new
      #
      #   recipients.recipients = recipient_paths.map do |profile_path|
      #     recipient             = LinkedIn::Recipient.new
      #     recipient.person      = LinkedIn::Person.new
      #     recipient.person.path = "/people/#{profile_path}"
      #     recipient
      #   end
      #   message.recipients = recipients
      #   post(path, message_to_xml(message)).code
      # end
      #
      # def clear_status
      #   path = "/people/~/current-status"
      #   delete(path).code
      # end
      #
      
      def send_message(member_id, subject, message)
        path = "/people/~/mailbox"
        resp = post(path, message_to_xml(member_id, subject, message), {'Content-Type' => 'application/xml'})
        (resp.message == "Created" || resp.code.to_s == '201')  ? true : false
      end

      def message_to_xml(member_id, subject, message)
          %Q{<?xml version="1.0" encoding="UTF-8"?>
            <mailbox-item>
                <recipients>
                  <recipient>
                    <person path="/people/#{member_id}" />
                  </recipient>
                </recipients>
                <subject>#{subject}</subject>
                <body>#{message.strip}</body>
              </mailbox-item>}
      end

      def post(path, body='', options={})
        response = access_token.post("#{API_PATH}#{path}", body, options)
        raise_errors(response)
        response
      end

    end

  end
end

module LinkedIn
  module Api

    module QueryMethods

      def profile(options={})
        path = person_path(options)
        simple_query(path, options)
      end

      def connections(options={})
        path = "#{person_path(options)}/connections"
        simple_query(path, options)
      end

      def network_updates(start, options={})
        path = "#{person_path(options)}/network/updates?type=PRFU&after=#{start}&count=50&show-hidden-members=true"
        simple_query(path, options)
      end

      def company(options = {})
        path   = company_path(options)
        simple_query(path, options, "companies")
      end
      
      def company_search(options = {})
        path = "/company-search"
        if options[:keywords]
          path += "?keywords=#{CGI.escape(options[:keywords])}"
        end
        
        Mash.from_json(get(path))
      end

      private
      
        def company_path(options)
          path = "/companies"
          if options[:id]
            path += "/id=#{options[:id]}"
          elsif options[:universal_name]
            path += "/universal-name=#{CGI.escape(options[:universal_name])}"
          elsif options[:email_domain]
            path += "?email-domain=#{CGI.escape(options[:email_domain])}"
          else
            path += "/~"
          end
        end

        def simple_query(path, options={}, type="people")
          if type == "people"
            fields = options[:fields] || LinkedIn.default_profile_fields
          elsif type == "companies"
             fields = options[:fields] || LinkedIn.default_company_fields
          end

          if options.delete(:public)
            path +=":public"
          elsif fields
            path +=":(#{fields.map{ |f| f.to_s.gsub("_","-") }.join(',')})"  unless options[:email_domain]
          end
          
          if type == "people"
            headers = options.delete(:headers) || {}
            params  = options.map { |k,v| "#{k}=#{v}" }.join("&")
            path   += "?#{params}" if not params.empty?
            
            if options[:modified] and options[:modified_since]
              path += "?modified=#{options[:modified]}&modified-since=#{options[:modified_since]}"
            end
          end

          puts path
          Mash.from_json(get(path))
        end

        def person_path(options)
          path = "/people/"
          if id = options.delete(:id)
            path += "id=#{id}"
          elsif url = options.delete(:url)
            path += "url=#{CGI.escape(url)}"
          else
            path += "~"
          end
        end

        def company_path(options)
          path = "/companies/"
          if id = options.delete(:id)
            path += "id=#{id}"
          elsif url = options.delete(:url)
            path += "url=#{CGI.escape(url)}"
          elsif name = options.delete(:name)
            path += "universal-name=#{CGI.escape(name)}"
          elsif domain = options.delete(:domain)
            path += "email-domain=#{CGI.escape(domain)}"
          else
            path += "~"
          end
        end

    end

  end
end

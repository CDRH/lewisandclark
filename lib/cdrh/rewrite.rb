# Written with heavy influence from Rack::Rewrite,
# because its YAML loading seems broken at present

# Matching YAML file format for Rack::Rewrite with feature subset
    # Method may only be "rewrite" or "r30[1,2,3,7,8]" syntax
# URL rewrites and redirects with regexes work, but no procs or sending files
# Addition - May specify to drop the query string with options['no_qs']

require 'yaml'

module CDRH
    class Rewrite
        # Variables
        @@rewrites = nil

        # Save rewrites as class variable to only load once at server start
        if @@rewrites.nil?
            begin
                @@rewrites = YAML.load_file("#{Rails.root}/config/rewrites.yml")
            rescue => e
                puts "CDRH::Rewrite - Unable to open #{Rails.root}/config/rewrites.yml:\n  #{e}"
                exit 1
            end
        end



        private
        def initialize(app)
            @app = app
        end



        protected
        def _call(env)
            response = !@@rewrites.nil? \
                ? route_request(env) \
                : nil

            if !response.nil?
                return response
            else
                @app.call(env)
            end
        end

        def compute_to(from, path_qs, to)
            if from.is_a?(Regexp) && from.match(path_qs)
                computed_to = to.dup
                computed_to.gsub!("$&", from.match(path_qs).to_s)
                (from.match(path_qs).size - 1).downto(1) do |num|
                    computed_to.gsub!("$#{num}", from.match(path_qs)[num].to_s)
                end

                return computed_to
            else
                return to
            end
        end

        def match_options_not?(from_not, r, path_qs)
            from_not.is_a?(Regexp) \
            && (r.path.match(from_not) || path_qs.match(from_not)) \
            || (r.path === from_not || path_qs === from_not) \
                ? true \
                : false
        end

        def route_request(env)
            r = Rack::Request.new(env)
            path_qs = r.path || ''
            qs = r.query_string || ''
            if not qs.empty?
                path_qs += '?'+ qs
            end

            @@rewrites.each do |rewrite|
                options = !rewrite['options'].nil? \
                    ? rewrite['options'] \
                    : {}

                next if options['host'] && !r.host.match(options['host'])
                next if options['method'] && !env['REQUEST_METHOD'].match(options['method'])
                next if options['scheme'] && !r.scheme.match(options['scheme'])

                from = rewrite['from']
                to = rewrite['to']
                from_not = options['not'] || ''

                if rule_matches?(from, r, path_qs, from_not)
                    # Response variables
                    body = []
                    headers = {}

                    # Rewrite variables
                    method = rewrite['method']
                    to = compute_to(rewrite['from'], path_qs, to)
                    if !qs.empty? && !options['no_qs']
                        to += '?'+ qs
                    end

                    if method =~ /r30[12378]/
                        status = method[1..-1]

                        headers['Location'] = to
                        headers['Content-Type'] = Rack::Mime.mime_type(File.extname(to), fallback='text/html')

                        body.push %Q{Redirecting to <a href="#{to}">#{to}</a>}

                        puts "CDRH::Rewrite - Redirecting #{path_qs} to #{to}"

                        return [status, headers, body]
                    elsif method == "rewrite"
                        env['REQUEST_URI'] = to
                        if q_index = to.index('?')
                            env['PATH_INFO'] = to[0..q_index-1]
                            env['QUERY_STRING'] = (!options['no_qs']) \
                                ? to[q_index+1..-1] \
                                : ''
                        else
                            env['PATH_INFO'] = to
                            env['QUERY_STRING'] = ''
                        end

                        puts "CDRH::Rewrite - Rewriting #{path_qs} to #{to}"

                        return nil
                    end
                end
            end

            return nil
        end # /route_request

        def rule_matches?(from, r, path_qs, from_not)
            from.is_a?(Regexp) \
            &&  ((r.path.match(from) || path_qs.match(from)) \
                && !match_options_not?(from_not, r, path_qs) \
            ) \
            || ((r.path === from || path_qs === from) \
                && !match_options_not?(from_not, r, path_qs) \
            ) \
                ? true \
                : false
        end



        public
        def call(env)
            dup._call(env)  # Thread-safety for instance vars
        end
    end
end


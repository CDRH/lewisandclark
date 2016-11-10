# Written with heavy influence from Rack::Rewrite,
# because its YAML loading seems broken at present

# Matching YAML file format for Rack::Rewrite with feature subset
    # Method may only be "rewrite" or "r30[1,2,3,7,8]" syntax
# URL rewrites and redirects with regexes work, but no procs or sending files

# Additions
# - May specify to drop the query string with options['no_qs']
# - Rewrites are checked again before returned to prevent multiple redirects

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

        def match_options_not?(from_not, request, path_qs)
            from_not.is_a?(Regexp) \
            && (request.path.match(from_not) || path_qs.match(from_not)) \
            || (request.path === from_not || path_qs === from_not) \
                ? true \
                : false
        end

        def route_request(env)
            request = Rack::Request.new(env)
            path_qs = request.path || ''
            qs = request.query_string || ''
            if not qs.empty?
                path_qs += '?'+ qs
            end

            @@rewrites.each do |rewrite|
                options = !rewrite['options'].nil? \
                    ? rewrite['options'] \
                    : {}

                next if options['host'] && !request.host.match(options['host'])
                next if options['method'] && !env['REQUEST_METHOD'].match(options['method'])
                next if options['scheme'] && !request.scheme.match(options['scheme'])

                from = rewrite['from']
                to = rewrite['to']
                from_not = options['not'] || ''

                if rule_matches?(from, request, path_qs, from_not)
                    # Response variables
                    body = []
                    headers = {}

                    # Rewrite variables
                    method = rewrite['method']
                    to = compute_to(rewrite['from'], path_qs, to)
                    to_qs = (!qs.empty? && !options['no_qs']) \
                        ? to +'?'+ qs \
                        : to

                    if request.path_info === '/' && to === request.path[0..-2]
                        puts "CDRH::Rewrite - Skipping rule that loops redirects to site root\n  From: #{from}\n  To: #{to_qs}"
                        next
                    end

                    if method =~ /r30[12378]/
                        status = method[1..-1]

                        headers['Location'] = to_qs
                        headers['Content-Type'] = Rack::Mime.mime_type(File.extname(to), fallback='text/html')

                        body.push %Q{Redirecting to <a href="#{to_qs}">#{to_qs}</a>}

                        puts "CDRH::Rewrite - Redirecting #{path_qs} to #{to_qs}"

                        return [status, headers, body]
                    elsif method == "rewrite"
                        env['REQUEST_URI'] = to_qs
                        if q_index = to_qs.index('?')
                            env['PATH_INFO'] = to_qs[0..q_index-1]
                            env['QUERY_STRING'] = (!options['no_qs']) \
                                ? to_qs[q_index+1..-1] \
                                : ''
                        else
                            env['PATH_INFO'] = to_qs
                            env['QUERY_STRING'] = ''
                        end

                        puts "CDRH::Rewrite - Rewriting #{path_qs} to #{to_qs}"

                        # Recheck rules after rewrite
                        return route_request(env)
                    end
                end
            end

            return nil
        end # /route_request

        def rule_matches?(from, request, path_qs, from_not)
            from.is_a?(Regexp) \
            &&  ((request.path.match(from) || path_qs.match(from)) \
                && !match_options_not?(from_not, request, path_qs) \
            ) \
            || ((request.path === from || path_qs === from) \
                && !match_options_not?(from_not, request, path_qs) \
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


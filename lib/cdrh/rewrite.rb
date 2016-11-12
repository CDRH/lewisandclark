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
        @@uri_prefix = nil

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
            # Determine if URI prefix upon receiving first request
            if @@uri_prefix.nil?
                request = Rack::Request.new(env)

                if request.path_info != request.path
                    # Remove last occurrence of path_info
                    # so removing / from /prefix/ is /prefix
                    @@uri_prefix = request.path.sub(/(.*)(#{request.path_info})(.*)/, '\1\3')
                    puts "CDRH::Rewrite - URI prefix set to '#{@@uri_prefix}'"
                else
                    @@uri_prefix = ''
                end
            end

            response = !@@rewrites.nil? \
                ? route_request(env) \
                : nil

            if !response.nil?
                return response
            else
                @app.call(env)
            end
        end

        def compute_to(from, request, path_qs, to)
            # Prepend URI prefix if present
            to = @@uri_prefix + to if !@@uri_prefix.blank?

            if from.is_a?(Regexp) && (from.match(request.path_info) || from.match(path_qs))
                matched_path = from.match(request.path_info) \
                    ? from.match(request.path_info) \
                    : from.match(path_qs)

                computed_to = to.dup
                computed_to.gsub!("$&", matched_path.to_s)
                (matched_path.size - 1).downto(1) do |num|
                    computed_to.gsub!("$#{num}", matched_path[num].to_s)
                end

                return computed_to
            else
                return to
            end
        end

        def match_options_not?(from_not, request, path_qs)
            from_not.is_a?(Regexp) \
<<<<<<< HEAD
            && (request.path_info.match(from_not) || path_qs.match(from_not)) \
            || (request.path_info === from_not || path_qs === from_not) \
=======
            && (request.path.match(from_not) || path_qs.match(from_not)) \
            || (request.path === from_not || path_qs === from_not) \
>>>>>>> 85a85de0a0025dec70a5c2cffd02079066501d1b
                ? true \
                : false
        end

        def route_request(env)
            request = Rack::Request.new(env)
<<<<<<< HEAD
            path_qs = request.path_info || ''
=======
            path_qs = request.path || ''
>>>>>>> 85a85de0a0025dec70a5c2cffd02079066501d1b
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
                    to = compute_to(rewrite['from'], request, path_qs, to)
                    to_qs = (!qs.empty? && !options['no_qs']) \
                        ? to +'?'+ qs \
                        : to

                    if to === request.path
                        puts "CDRH::Rewrite - Skipping rule that redirects to self in infinte loop"
                        puts "  Request Path: #{request.path}"
                        puts "  Rule From: #{from}"
                        puts "  Rule To: #{rewrite['to']}"
                        puts "    Evals: #{to}"
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
<<<<<<< HEAD
            &&  ((request.path_info.match(from) || path_qs.match(from)) \
                && !match_options_not?(from_not, request, path_qs) \
            ) \
            || ((request.path_info === from || path_qs === from) \
=======
            &&  ((request.path.match(from) || path_qs.match(from)) \
                && !match_options_not?(from_not, request, path_qs) \
            ) \
            || ((request.path === from || path_qs === from) \
>>>>>>> 85a85de0a0025dec70a5c2cffd02079066501d1b
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


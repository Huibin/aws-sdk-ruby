# Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'json'
require 'stringio'

module Aws
  module Plugins
    class JsonSerializer < Seahorse::Client::Plugin
      handle(:Handler) do |context|

        metadata = context.config.api.metadata

        target = "#{metadata['json-target-prefix']}.#{context.operation_name}"
        version = metadata['json-version']

        # build request
        req = context.http_request
        req.headers['X-Amz-Target'] = target
        req.headers['Content-Type'] = "application/x-amz-json-#{version}"
        req.body = MultiJson.dump(context.params)

        # parse response
        super(context).on_complete do |response|
          response.context.http_response.body.tap do |body|
            response.data = MultiJson.load(body.read) || {}
            body.rewind
          end
        end

      end
    end
  end
end

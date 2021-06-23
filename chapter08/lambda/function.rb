require 'json'

require 'aws-sigv4'
require 'aws-sdk'
require 'vault'

def lambda_handler(event:, context:)
		puts "setting Vault address"
    Vault.address = "https://vault.lyndseyferguson.info:8200"

    puts "authenticating into Vault"
    token = Vault.auth.aws_iam(
        'BetaPublisherCredsUpdator',
        Aws::AssumeRoleCredentials.new(
            role_arn: "arn:aws:iam::492939359554:role/BetaPublsherCredsUpdator",
            role_session_name: "RotateBetaPublisherAppRoleSecretId"
        ),
        'vault.lyndseyferguson.info'
    )

    puts "looking up token info"
    puts Vault.auth_token.lookup(token)
    { statusCode: 200, body: JSON.generate('Hello from Lambda!') }
end

## ERROR RESPONSE:
# Response
# {
#   "errorMessage": "User: arn:aws:sts::492939359554:assumed-role/BetaPublsherCredsUpdator/BetaPublisherCredsUpdator is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::492939359554:role/BetaPublsherCredsUpdator",
#   "errorType": "Function<Aws::STS::Errors::AccessDenied>",
#   "stackTrace": [
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/seahorse/client/plugins/raise_response_errors.rb:17:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/plugins/jsonvalue_converter.rb:22:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/plugins/idempotency_token.rb:19:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/plugins/param_converter.rb:26:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/seahorse/client/plugins/request_callback.rb:71:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/plugins/response_paging.rb:12:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/seahorse/client/plugins/response_target.rb:24:in `call'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/seahorse/client/request.rb:72:in `send_request'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-sts/client.rb:778:in `assume_role'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/assume_role_credentials.rb:51:in `refresh'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/refreshing_credentials.rb:22:in `initialize'",
#     "/var/runtime/gems/aws-sdk-core-3.114.0/lib/aws-sdk-core/assume_role_credentials.rb:42:in `initialize'",
#     "/var/task/function.rb:14:in `new'",
#     "/var/task/function.rb:14:in `lambda_handler'"
#   ]
# }

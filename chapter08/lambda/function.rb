#!/usr/bin/env ruby
#
require 'json'

require 'aws-sigv4'
require 'aws-sdk'
require 'vault'
require "rbnacl"
require "base64"
require 'octokit'
require 'optparse'

GITHUB_REPO = 'lyndsey-ferguson/vault-in-action-book'

def create_box(public_key)
  b64_key = RbNaCl::PublicKey.new(Base64.decode64(public_key[:key]))
  {
    key_id: public_key[:key_id],
    box: RbNaCl::Boxes::Sealed.from_public_key(b64_key)
  }
end

def update_secret_value(github_token, secret_key, secret_value)
  github_client = Octokit::Client.new(:access_token => github_token)
  repo = github_client.repository(GITHUB_REPO)
  box = create_box(github_client.get("#{repo.url}/actions/secrets/public-key"))
  encrypted = box[:box].encrypt(secret_value)
  response = github_client.put("#{repo.url}/actions/secrets/#{secret_key}",
    encrypted_value: Base64.strict_encode64(encrypted),
    key_id: box[:key_id]
  )
end

def lambda_handler(event:, context:)
    Vault.address = "https://vault.lyndseyferguson.info:8200"

    secret = Vault.auth.aws_iam(
        'beta_publisher-creds-updater',
        Aws::AssumeRoleCredentials.new(
            role_arn: "arn:aws:iam::492939359554:role/BetaPublsherCredsUpdator",
            role_session_name: "RotateBetaPublisherAppRoleSecretId"
        ),
        'vault.lyndseyferguson.info'
    )
    Vault.token = secret.auth.client_token

    secret = Vault.logical.write('auth/approle/role/beta_publisher/secret-id')
    new_secret_id = secret.data[:secret_id]
    new_secret_id_accessor = secret.data[:secret_id_accessor]

    secret = Vault.logical.read('kv/data/users/margo/magic-dollar-wallet-repo')
    ghp_token = secret.data.dig(:data, :token)

    update_secret_value(ghp_token, 'BETA_PUBLISHER_VAULT_SECRET_ID', new_secret_id)

    secret_id_accessors = Vault.logical.list('auth/approle/role/beta_publisher/secret-id')
    secret_id_accessors.each do |secret_id_accessor|
      next if secret_id_accessor == new_secret_id_accessor
      Vault.logical.write(
        'auth/approle/role/beta_publisher/secret-id-accessor/destroy',
        secret_id_accessor: secret_id_accessor
      )
    end
    { statusCode: 200, body: JSON.generate("Destroyed #{secret_id_accessors.length} beta_publisher secret-id(s)") }
end

if __FILE__ == $0
  lambda_handler(event: {}, context: {})
end

# So, let's try to understand the issue. A role is not able to assume itself. So, my lambad has already assumed the role?
# The documentation suggests that the the role is attached to the AWS resource.:q
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

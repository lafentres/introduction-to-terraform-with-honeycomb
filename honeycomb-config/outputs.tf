output "api_key_team_name" {
  value = data.honeycombio_auth_metadata.current.team.name
}

output "api_key_environment_slug" {
  value = data.honeycombio_auth_metadata.current.environment.slug
}

output "api_key_slo_management_access" {
  value = data.honeycombio_auth_metadata.current.api_key_access.slos
}
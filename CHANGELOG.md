# Changelog

## Unreleased

### Changed

## [1.1.0] - 2023-05-17

### Changed

- Removed approving creds. Approving new creds with the container provided 
  token doesn't work and instead must be done with "system:admin" creds.
- Do not persist new creds if they are not valid. 
- Accept WAIT_APPROVED_SEC and CSR_NAME as input.

## [1.0.0] - 2021-07-14

### Changed

- Initial version

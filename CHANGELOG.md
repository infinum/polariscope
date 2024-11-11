## [Unreleased]

- Add `update_audit_database` option to `Polariscope.scan` to control whether to update the audit DB

## [0.5.0] - 2024-10-30

- Fix regression for standalone installation
- Raise `Polariscope::Error` on unparseable Gemfile

## [0.4.0] - 2024-10-25

- Count Ruby versions towards health score
- Update audit database if older than one day

## [0.3.0] - 2024-10-17

- Count Ruby advisories towards health score

## [0.2.0] - 2024-08-23

- Check if audit database is missing or stale (older than 7 weeks) & update if true

## [0.1.3] - 2024-08-12

- Remove color#hsl feature

## [0.1.2] - 2024-08-08

- Fix issue when no Gemfile found in project & reach 100% coverage with tests

## [0.1.1] - 2024-08-08

- Make **spec_type** optional in `.gem_versions`
- Add readme

## [0.1.0] - 2024-08-07

- Initial release

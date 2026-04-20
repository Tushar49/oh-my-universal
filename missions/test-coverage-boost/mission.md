# Mission: Test Coverage Boost

Increase test coverage for untested critical paths. Identify gaps, write meaningful tests, and ensure reliability without introducing flaky tests.

## Goal

Raise test coverage on business-critical code by at least 15 percentage points, focusing on paths that handle money, auth, data mutations, and error conditions.

## Focus Areas

- Files with less than 50% line coverage
- Business-critical functions (payments, auth, data writes)
- Error handling paths and edge cases
- Integration points between modules

## Success Criteria

1. Overall test coverage increases by at least 15 percentage points from baseline
2. All newly written tests pass consistently (run 3 times, zero flakes)
3. Every business-critical function has at least one happy-path and one error-path test
4. No existing tests are deleted or weakened
5. Coverage report generates successfully with `npm test -- --coverage` (or equivalent)

## Constraints

- Do not modify production code solely to make it testable (minor refactors for dependency injection are OK)
- Do not write trivial getter/setter tests just to inflate coverage numbers
- Do not mock everything — prefer integration tests where practical
- Focus on meaningful coverage, not vanity metrics
